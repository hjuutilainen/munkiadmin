# MunkiAdmin YAML Support Customizations

Documenting YAML support customizations added to MunkiAdmin that are not present in the official munki/munki upstream repository.

**Location**: `code/munkiadmin/`

**Status**: Implementation Complete

---

## Summary

| Component | Customization |
|-----------|---------------|
| MAMunkiRepositoryManager | YAML detection and I/O methods |
| yaml_bridge.py | Python YAML parsing bridge |
| MAPkginfoScanner | YAML-aware file scanning |
| MAManifestScanner | YAML-aware manifest scanning |

---

## Overview

MunkiAdmin now has YAML support for pkginfo files and manifests, providing handling of both plist and YAML formats. This implementation extends the application's capability to read and write both formats with automatic detection and format preservation.

---

## Features

- **Format Preservation**: Edit YAML files and they remain as YAML (no conversion to plist)
- **Auto-Detection**: Automatically detects repository format preferences
- **Mixed Repository Support**: Handle repositories with both plist and YAML files
- **Backward Compatibility**: Existing plist workflows continue to work unchanged
- **Format Detection by Extension**: Files are automatically recognized as YAML based on `.yaml` or `.yml` extensions
- **Graceful Fallback**: If YAML parsing encounters issues, falls back to original plist methods

## Implementation

### Core Components

#### YAML Bridge
Python script (`yaml_bridge.py`) handles YAML ↔ JSON conversion:
- Uses PyYAML for robust YAML parsing
- Handles complex YAML structures
- Maintains compatibility with munki requirements
- Provides error handling and validation

#### Repository Manager (MAMunkiRepositoryManager)
Enhanced with format detection and YAML-aware I/O operations:

**Key Methods:**
- `isYAMLFile:` - Detects YAML files by extension (.yaml, .yml)
- `dictionaryWithContentsOfURLSupportingYAML:` - Reads both plist and YAML formats
- `writeDictionary:toURLSupportingYAML:atomically:` - Writes in appropriate format
- `preferredPkginfoFileExtension` - Determines preferred format based on repository sampling

**YAML Detection:**
```objective-c
- (BOOL)isYAMLFile:(NSURL *)url {
    NSString *pathExtension = [url.pathExtension lowercaseString];
    return [pathExtension isEqualToString:@"yaml"] || 
           [pathExtension isEqualToString:@"yml"];
}
```

**Dual-Format Reading:**
```objective-c
- (NSDictionary *)dictionaryWithContentsOfURLSupportingYAML:(NSURL *)url {
    if ([self isYAMLFile:url]) {
        DDLogInfo(@"YAML file detected: %@", url.lastPathComponent);
        // YAML parsing via Python bridge
        // Falls back to plist parsing if needed
    }
    return [NSDictionary dictionaryWithContentsOfURL:url];
}
```

#### File Scanners
Updated to handle both plist and YAML formats dynamically:

**MAPkginfoScanner.m:**
- Integrated with repository manager's dual-format support
- Fixed variable shadowing compilation issues
- Uses YAML-aware reading methods

**MAManifestScanner.m:**
- Enhanced manifest scanning for YAML files
- Uses YAML-aware repository manager methods
- Maintains backward compatibility with plist files

**MARelationshipScanner:**
- Ensures compatibility with both formats
- Dynamic format detection during scanning

### Format Detection

The app automatically detects your repository's preferred format by:
1. Checking user preferences
2. Sampling existing files in the repository (checks for .yaml/.yml extensions)
3. Falling back to plist as default

Format detection ensures that new files are created in the same format as existing files in the repository, maintaining consistency.

### YAML Parsing

Uses PyYAML through a Python bridge for robust YAML parsing:
- Handles complex YAML structures commonly found in munki repositories
- Maintains compatibility with munki requirements
- Provides comprehensive error handling and validation
- Supports encoding fixes and long line handling
- Graceful fallback to plist parsing if YAML parsing fails

### Error Handling

The implementation includes robust error handling:
- File size and timeout limits for performance
- Encoding issue detection and correction
- YAML syntax error reporting
- Automatic fallback to plist methods when needed
- CocoaLumberjack integration for detailed logging

## Usage

1. **Open Repository**: Works with both plist and YAML repositories
2. **Edit Files**: Make changes in the GUI as usual
3. **Save Changes**: Files are saved in their original format automatically
4. **Format Preservation**: YAML files remain YAML, plist files remain plist
5. **Mixed Repositories**: Seamlessly handles repositories with both formats

## Technical Requirements

- **Python 3** with PyYAML (for YAML parsing)
- **macOS 10.13** or later
- **Munki tools** installed
- **Architecture**: Universal (arm64/x86_64)

## Build Configuration

- **Dependencies**: NSHash, CocoaLumberjack, CHCSVParser (via CocoaPods)
- **Podfile**: Stable dependency management
- **Code Signing**: Application properly signed for distribution
- **Debug/Release**: Supports both build configurations

## Migration

No migration needed - the app works with your existing repository regardless of format:
- **Existing plist repositories**: Continue to work exactly as before
- **YAML repositories**: Automatically detected and handled
- **Mixed repositories**: Both formats coexist seamlessly
- **Format conversion**: Use standard munki tools if you need to convert formats

## Technical Implementation Details

### File Detection
```objective-c
- (BOOL)isYAMLFile:(NSURL *)url {
    NSString *pathExtension = [url.pathExtension lowercaseString];
    return [pathExtension isEqualToString:@"yaml"] || 
           [pathExtension isEqualToString:@"yml"];
}
```

### Format Sampling
The repository manager samples existing files to determine the preferred format:
1. Scans pkginfos and manifests directories
2. Counts .yaml/.yml vs .plist files
3. Sets preferred extension based on majority format
4. Caches result for performance

### Save Operations
Updated save methods to preserve file formats:
- `MAMunkiAdmin_AppDelegate` uses YAML-aware writing methods
- Dynamic format detection replaces hardcoded .plist extensions
- makepkginfo and import operations respect original formats

## Logging and Debugging

CocoaLumberjack integration provides detailed logging:
- YAML file detection events
- Format conversion operations
- Error handling and fallback scenarios
- Performance metrics

## Status

**Implementation Complete**
- YAML infrastructure in place and functional
- Successfully compiles with Xcode
- Application properly signed and ready for distribution
- Comprehensive backward compatibility maintained
- Format detection and preservation working
- Python bridge integration complete

## Repository Compatibility

This implementation maintains full backward compatibility:
- **Existing workflows**: No changes required
- **plist files**: Continue to work as always
- **YAML files**: Now fully supported
- **Mixed repositories**: Seamlessly handled
