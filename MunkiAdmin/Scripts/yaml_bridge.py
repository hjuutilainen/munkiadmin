#!/usr/bin/env python3
"""
YAML to Property List converter for MunkiAdmin
Provides a robust bridge between YAML files and Objective-C NSDictionary objects

Implements the same key ordering as yamlutils.swift in the Munki CLI tools:
- Priority keys first: name, display_name, version
- All other keys alphabetically
- _metadata last

Uses block scalar style (|) for multiline strings like scripts.
Avoids unnecessary quoting of simple values since Munki's Swift tools 
handle type coercion correctly.
"""

import sys
import yaml
import plistlib
import json
import io
import re
from pathlib import Path


# Keys that should appear first in pkginfo YAML output, in this order
# Matches priorityKeys from Munki's yamlutils.swift
PRIORITY_KEYS = ['name', 'display_name', 'version']

# Keys that should appear last in pkginfo YAML output
LAST_KEYS = ['_metadata']

# Keys that should appear first in manifest YAML output (catalogs at top for manifests)
MANIFEST_PRIORITY_KEYS = ['catalogs']

# Keys that should appear last in manifest YAML output
MANIFEST_LAST_KEYS = ['included_manifests']

# Preferred key order for receipt entries - packageid first
RECEIPT_KEY_ORDER = ['packageid', 'name', 'filename', 'installed_size', 'version', 'optional']

# Preferred key order for installs items - path first
INSTALLS_KEY_ORDER = ['path', 'type', 'CFBundleIdentifier', 'CFBundleName',
                      'CFBundleShortVersionString', 'CFBundleVersion', 'md5checksum', 'minosversion']

# Preferred key order for conditional_items - condition MUST be first for readability
CONDITIONAL_ITEM_KEY_ORDER = ['condition', 'managed_installs', 'managed_uninstalls', 'managed_updates',
                              'optional_installs', 'default_installs', 'featured_items',
                              'included_manifests', 'conditional_items']

class BlockScalarDumper(yaml.SafeDumper):
    """Custom YAML dumper that uses block scalar style for multiline strings
    and avoids unnecessary quoting."""
    pass


def is_number_like(s):
    """Check if a string looks like a number (int, float, or version-like)."""
    # Match integers
    if re.match(r'^-?\d+$', s):
        return True
    # Match floats (including version-like single decimal: 12.0, 10.13)
    if re.match(r'^-?\d+\.\d+$', s):
        return True
    return False


def str_representer(dumper, data):
    """Use literal block style (|) for multiline strings.
    For single-line strings, avoid unnecessary quoting.
    Munki's Swift tools handle type coercion correctly.
    
    Note: PyYAML's emitter refuses to use literal block style (|) for strings
    containing tab characters or carriage returns (\r). We:
    - Convert tabs to 4 spaces
    - Remove carriage returns (normalize to Unix line endings)
    This preserves readability while maintaining script functionality.
    """
    if '\n' in data:
        # Normalize to Unix line endings - PyYAML refuses literal style for \r
        data_for_yaml = data.replace('\r\n', '\n').replace('\r', '\n')
        # Convert tabs to spaces - PyYAML refuses literal style for strings with tabs
        # Using 4 spaces is a common convention and works for shell script indentation
        data_for_yaml = data_for_yaml.replace('\t', '    ')
        # Use literal block style for multiline strings
        return dumper.represent_scalar('tag:yaml.org,2002:str', data_for_yaml, style='|')
    
    # For single-line strings, check if we absolutely must quote
    
    # Empty string needs quotes
    if data == '':
        return dumper.represent_scalar('tag:yaml.org,2002:str', data, style="'")
    
    # YAML boolean/null keywords need quotes
    if data.lower() in ('null', '~', 'true', 'false', 'yes', 'no', 'on', 'off'):
        return dumper.represent_scalar('tag:yaml.org,2002:str', data, style="'")
    
    # Strings with leading/trailing whitespace need quotes
    if data[0] in ' \t' or data[-1] in ' \t':
        return dumper.represent_scalar('tag:yaml.org,2002:str', data, style="'")
    
    # Strings starting with special YAML indicators need quotes
    special_start_chars = '-?:,[]{}#&*!|>\'"%@`'
    if data[0] in special_start_chars:
        return dumper.represent_scalar('tag:yaml.org,2002:str', data, style="'")
    
    # Strings containing : followed by space, or # preceded by space need quotes
    if ': ' in data or ' #' in data:
        return dumper.represent_scalar('tag:yaml.org,2002:str', data, style="'")
    
    # For numeric-looking strings (like version numbers), represent as the actual
    # numeric type. Munki's YAML parser will read them and coerce to string as needed.
    # This avoids quotes/!!str tags.
    if is_number_like(data):
        if '.' in data:
            return dumper.represent_float(float(data))
        else:
            return dumper.represent_int(int(data))
    
    # Regular string - use default representation (may get quotes if needed)
    return dumper.represent_scalar('tag:yaml.org,2002:str', data, style=None)


# Register the custom string representer
BlockScalarDumper.add_representer(str, str_representer)

class RobustYAMLLoader:
    """A robust YAML loader that handles common real-world issues"""
    
    @staticmethod
    def safe_load_yaml(content):
        """Safely load YAML with multiple fallback strategies"""
        
        # Strategy 1: Try standard safe_load first
        try:
            return yaml.safe_load(content)
        except yaml.YAMLError as e:
            print(f"Standard YAML parsing failed: {e}", file=sys.stderr)
        
        # Strategy 2: Try with custom loader for common issues
        try:
            # Handle common munki-specific YAML issues
            content = RobustYAMLLoader.preprocess_yaml(content)
            return yaml.safe_load(content)
        except yaml.YAMLError as e:
            print(f"Preprocessed YAML parsing failed: {e}", file=sys.stderr)
        
        # Strategy 3: Try line-by-line parsing for very long lines
        try:
            return RobustYAMLLoader.parse_chunked_yaml(content)
        except Exception as e:
            print(f"Chunked YAML parsing failed: {e}", file=sys.stderr)
        
        return None
    
    @staticmethod
    def preprocess_yaml(content):
        """Preprocess YAML content to handle common issues"""
        lines = content.splitlines()
        processed_lines = []
        
        for line_num, line in enumerate(lines, 1):
            # Handle excessively long lines by truncating at word boundaries
            if len(line) > 10000:
                # Find last word boundary before limit
                truncate_pos = 9000
                while truncate_pos > 8000 and line[truncate_pos] not in ' \t':
                    truncate_pos -= 1
                
                if truncate_pos > 8000:
                    line = line[:truncate_pos] + "..."
                    print(f"Warning: Truncated long line {line_num} at {truncate_pos} characters", file=sys.stderr)
                else:
                    # If no word boundary found, hard truncate
                    line = line[:9000] + "..."
                    print(f"Warning: Hard truncated line {line_num}", file=sys.stderr)
            
            # Handle tab characters
            if '\t' in line:
                line = line.expandtabs(2)
            
            # Handle some common encoding issues
            try:
                line.encode('utf-8')
            except UnicodeEncodeError:
                # Replace problematic characters
                line = line.encode('utf-8', errors='replace').decode('utf-8')
                print(f"Warning: Fixed encoding issues on line {line_num}", file=sys.stderr)
            
            processed_lines.append(line)
        
        return '\n'.join(processed_lines)
    
    @staticmethod
    def parse_chunked_yaml(content):
        """Parse YAML by processing in chunks to handle large files"""
        # This is a simplified approach - split into logical YAML sections
        # and try to parse each section separately if the full parse fails
        
        lines = content.splitlines()
        if len(lines) < 100:
            # For small files, just fail normally
            return yaml.safe_load(content)
        
        # Try to identify YAML document boundaries
        yaml_docs = []
        current_doc = []
        
        for line in lines:
            if line.strip() == '---' and current_doc:
                # Found document separator
                yaml_docs.append('\n'.join(current_doc))
                current_doc = []
            else:
                current_doc.append(line)
        
        if current_doc:
            yaml_docs.append('\n'.join(current_doc))
        
        # If we found multiple documents, try to parse the first valid one
        if len(yaml_docs) > 1:
            for i, doc in enumerate(yaml_docs):
                try:
                    result = yaml.safe_load(doc)
                    if result is not None:
                        print(f"Successfully parsed YAML document {i+1} of {len(yaml_docs)}", file=sys.stderr)
                        return result
                except yaml.YAMLError:
                    continue
        
        # Fall back to original content
        raise yaml.YAMLError("All chunked parsing attempts failed")

def yaml_to_dict(yaml_file_path):
    """Convert YAML file to Python dictionary with robust error handling"""
    try:
        # Basic file checks
        file_path = Path(yaml_file_path)
        if not file_path.exists():
            print(f"Error: File not found: {yaml_file_path}", file=sys.stderr)
            return None
        
        file_size = file_path.stat().st_size
        
        # More reasonable size limits
        if file_size > 50 * 1024 * 1024:  # 50MB absolute limit
            print(f"Error: YAML file too large ({file_size} bytes)", file=sys.stderr)
            return None
        
        # Read file with robust encoding handling
        content = None
        encodings = ['utf-8', 'utf-8-sig', 'latin1', 'cp1252']
        
        for encoding in encodings:
            try:
                with open(yaml_file_path, 'r', encoding=encoding) as file:
                    content = file.read()
                break
            except UnicodeDecodeError:
                continue
        
        if content is None:
            print(f"Error: Unable to decode file with any supported encoding", file=sys.stderr)
            return None
        
        # Handle empty files
        if not content.strip():
            print("Warning: Empty YAML file", file=sys.stderr)
            return {}
        
        # Use robust YAML loader
        return RobustYAMLLoader.safe_load_yaml(content)
            
    except Exception as e:
        print(f"Error reading YAML file: {e}", file=sys.stderr)
        return None

def dict_to_plist_string(data):
    """Convert Python dictionary to property list XML string"""
    try:
        # Remove order preservation markers before converting to plist
        cleaned_data = remove_order_markers(data)
        return plistlib.dumps(cleaned_data).decode('utf-8')
    except Exception as e:
        print(f"Error converting to plist: {e}", file=sys.stderr)
        return None

def remove_order_markers(data):
    """Remove __ordered_keys__ markers from data structure"""
    if isinstance(data, dict):
        result = {}
        for key, value in data.items():
            if key == '__ordered_keys__':
                continue
            result[key] = remove_order_markers(value)
        return result
    elif isinstance(data, list):
        return [remove_order_markers(item) for item in data]
    else:
        return data

def dict_to_yaml_string(data):
    """Convert Python dictionary to YAML string with pkginfo key ordering.
    
    Implements the same ordering as Munki's yamlutils.swift:
    - name, display_name, version appear first (in that order)
    - All other keys alphabetically
    - _metadata last
    
    Uses block scalar style (|) for multiline strings like scripts.
    Avoids unnecessary quoting of simple values.
    """
    try:
        # Apply Munki-compatible pkginfo key ordering
        ordered_data = order_pkginfo_keys(data)
        
        yaml_string = yaml.dump(ordered_data, Dumper=BlockScalarDumper, 
                               default_flow_style=False, allow_unicode=True, sort_keys=False)
        
        # Remove trailing newline to match Munki's output behavior
        if yaml_string.endswith('\n'):
            yaml_string = yaml_string[:-1]
        
        return yaml_string
    except Exception as e:
        print(f"Error converting to YAML: {e}", file=sys.stderr)
        return None

def is_receipt_dict(d):
    """Check if a dictionary looks like a receipt entry."""
    return isinstance(d, dict) and 'packageid' in d

def is_installs_dict(d):
    """Check if a dictionary looks like an installs item."""
    return isinstance(d, dict) and 'path' in d and 'type' in d

def sort_receipt_keys(keys):
    """Sort receipt dictionary keys with packageid first."""
    ordered = []
    other = []
    for key in keys:
        if key in RECEIPT_KEY_ORDER:
            ordered.append(key)
        else:
            other.append(key)
    # Sort ordered keys by their position in RECEIPT_KEY_ORDER
    ordered.sort(key=lambda k: RECEIPT_KEY_ORDER.index(k) if k in RECEIPT_KEY_ORDER else 999)
    other.sort()
    return ordered + other

def sort_installs_keys(keys):
    """Sort installs item dictionary keys with path first."""
    ordered = []
    other = []
    for key in keys:
        if key in INSTALLS_KEY_ORDER:
            ordered.append(key)
        else:
            other.append(key)
    # Sort ordered keys by their position in INSTALLS_KEY_ORDER
    ordered.sort(key=lambda k: INSTALLS_KEY_ORDER.index(k) if k in INSTALLS_KEY_ORDER else 999)
    other.sort()
    return ordered + other

def is_conditional_item_dict(d):
    """Check if a dictionary looks like a conditional_items entry (manifest conditional block)."""
    if not isinstance(d, dict):
        return False
    # A conditional item typically has "condition" key
    if 'condition' in d:
        return True
    # Also detect conditional items without explicit condition (unconditional blocks)
    # These have manifest keys but no pkginfo keys like name, version, display_name
    manifest_keys = {'managed_installs', 'managed_uninstalls', 'managed_updates', 
                     'optional_installs', 'included_manifests', 'conditional_items'}
    has_manifest_keys = bool(set(d.keys()) & manifest_keys)
    has_pkginfo_keys = 'name' in d or 'version' in d or 'installer_item_location' in d
    return has_manifest_keys and not has_pkginfo_keys

def sort_conditional_item_keys(keys):
    """Sort conditional_items dictionary keys with condition first."""
    ordered = []
    other = []
    for key in keys:
        if key in CONDITIONAL_ITEM_KEY_ORDER:
            ordered.append(key)
        else:
            other.append(key)
    # Sort ordered keys by their position in CONDITIONAL_ITEM_KEY_ORDER
    ordered.sort(key=lambda k: CONDITIONAL_ITEM_KEY_ORDER.index(k) if k in CONDITIONAL_ITEM_KEY_ORDER else 999)
    other.sort()
    return ordered + other

def sort_pkginfo_keys(keys):
    """Sort pkginfo dictionary keys with custom ordering.
    
    - name, display_name, version appear first (in that order)
    - _metadata appears last
    - All other keys appear alphabetically in between
    """
    first_keys = []
    middle_keys = []
    end_keys = []
    
    for key in keys:
        if key in PRIORITY_KEYS:
            first_keys.append(key)
        elif key in LAST_KEYS:
            end_keys.append(key)
        else:
            middle_keys.append(key)
    
    # Sort first keys by their position in PRIORITY_KEYS
    first_keys.sort(key=lambda k: PRIORITY_KEYS.index(k) if k in PRIORITY_KEYS else 999)
    
    # Sort middle keys alphabetically
    middle_keys.sort()
    
    # Sort end keys alphabetically
    end_keys.sort()
    
    return first_keys + middle_keys + end_keys

def is_manifest_dict(data):
    """Check if dictionary looks like a manifest (vs a pkginfo)."""
    # Manifests have keys like managed_installs, catalogs, but NOT name/display_name/version
    manifest_indicators = ['managed_installs', 'managed_uninstalls', 'managed_updates', 
                          'optional_installs', 'default_installs', 'included_manifests']
    pkginfo_indicators = ['name', 'installer_item_location', 'installer_type']
    
    has_manifest_key = any(key in data for key in manifest_indicators)
    has_pkginfo_key = any(key in data for key in pkginfo_indicators)
    
    # If it has manifest keys but not pkginfo keys, it's a manifest
    return has_manifest_key and not has_pkginfo_key

def sort_manifest_keys(keys):
    """Sort manifest dictionary keys with custom ordering.
    
    - catalogs appears first
    - included_manifests appears last
    - All other keys appear alphabetically in between
    """
    first_keys = []
    middle_keys = []
    end_keys = []
    
    for key in keys:
        if key in MANIFEST_PRIORITY_KEYS:
            first_keys.append(key)
        elif key in MANIFEST_LAST_KEYS:
            end_keys.append(key)
        else:
            middle_keys.append(key)
    
    # Sort first keys by their position in MANIFEST_PRIORITY_KEYS
    first_keys.sort(key=lambda k: MANIFEST_PRIORITY_KEYS.index(k) if k in MANIFEST_PRIORITY_KEYS else 999)
    
    # Sort middle keys alphabetically
    middle_keys.sort()
    
    # Sort end keys alphabetically
    end_keys.sort()
    
    return first_keys + middle_keys + end_keys

def order_pkginfo_keys(data):
    """Recursively order keys in a pkginfo dictionary structure."""
    if isinstance(data, dict):
        # Remove order preservation markers
        clean_data = {k: v for k, v in data.items() if k != '__ordered_keys__'}
        
        # Determine sort order based on dict type
        if is_manifest_dict(clean_data):
            sorted_keys = sort_manifest_keys(clean_data.keys())
        elif is_receipt_dict(clean_data):
            sorted_keys = sort_receipt_keys(clean_data.keys())
        elif is_installs_dict(clean_data):
            sorted_keys = sort_installs_keys(clean_data.keys())
        elif is_conditional_item_dict(clean_data):
            sorted_keys = sort_conditional_item_keys(clean_data.keys())
        else:
            sorted_keys = sort_pkginfo_keys(clean_data.keys())
        
        # Create ordered dictionary
        result = {}
        for key in sorted_keys:
            value = clean_data[key]
            result[key] = order_pkginfo_keys(value)
        
        return result
    elif isinstance(data, list):
        return [order_pkginfo_keys(item) for item in data]
    else:
        return data

def main():
    if len(sys.argv) < 3:
        print("Usage: yaml_bridge.py <input_file> <output_format>")
        print("  output_format: plist, json, yaml")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_format = sys.argv[2].lower()
    
    if not Path(input_file).exists():
        print(f"Error: File not found: {input_file}", file=sys.stderr)
        sys.exit(1)
    
    # Determine input format
    if input_file.lower().endswith(('.yaml', '.yml')):
        data = yaml_to_dict(input_file)
    elif input_file.lower().endswith('.plist'):
        try:
            with open(input_file, 'rb') as file:
                data = plistlib.load(file)
        except Exception as e:
            print(f"Error reading plist file: {e}", file=sys.stderr)
            sys.exit(1)
    elif input_file.lower().endswith('.json'):
        try:
            with open(input_file, 'r', encoding='utf-8') as file:
                data = json.load(file)
        except Exception as e:
            print(f"Error reading JSON file: {e}", file=sys.stderr)
            sys.exit(1)
    else:
        print("Error: Unsupported input file format", file=sys.stderr)
        sys.exit(1)
    
    if data is None:
        sys.exit(1)
    
    # Convert to requested output format
    if output_format == 'plist':
        result = dict_to_plist_string(data)
    elif output_format == 'json':
        try:
            result = json.dumps(data, indent=2, ensure_ascii=False)
        except Exception as e:
            print(f"Error converting to JSON: {e}", file=sys.stderr)
            sys.exit(1)
    elif output_format == 'yaml':
        result = dict_to_yaml_string(data)
    else:
        print("Error: Unsupported output format", file=sys.stderr)
        sys.exit(1)
    
    if result:
        print(result)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()
