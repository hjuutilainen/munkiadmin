//
//  AdvancedPackageEditor.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 19.12.2011.
//

#import <Cocoa/Cocoa.h>
#import "PackageMO.h"

@interface AdvancedPackageEditor : NSWindowController {
    NSDatePicker *forceInstallDatePicker;
    
    NSNumber    *temp_autoremove;
    NSString    *temp_description;
    NSString    *temp_display_name;
    NSDate      *temp_force_install_after_date;
    NSNumber    *temp_installed_size;
    NSString    *temp_installer_item_hash;
    NSString    *temp_installer_item_location;
    NSNumber    *temp_installer_item_size;
    NSString    *temp_installer_type;
    NSString    *temp_maximum_os_version;
    NSString    *temp_minimum_os_version;
    NSString    *temp_name;
    NSString    *temp_package_path;
    NSString    *temp_postinstall_script;
    NSString    *temp_postuninstall_script;
    NSString    *temp_preinstall_script;
    NSString    *temp_preuninstall_script;
    NSString    *temp_RestartAction;
    NSNumber    *temp_suppress_bundle_relocation;
    NSNumber    *temp_unattended_install;
    NSNumber    *temp_unattended_uninstall;
    NSString    *temp_uninstall_method;
    NSString    *temp_uninstall_script;
    NSString    *temp_uninstaller_item_location;
    NSNumber    *temp_uninstallable;
    NSString    *temp_version;

}

- (void)setDefaultValuesFromPackage:(PackageMO *)aPackage;

@property (assign) IBOutlet NSDatePicker *forceInstallDatePicker;

@property (retain) NSNumber    *temp_autoremove;
@property (retain) NSString    *temp_description;
@property (retain) NSString    *temp_display_name;
@property (retain) NSDate      *temp_force_install_after_date;
@property (retain) NSNumber    *temp_installed_size;
@property (retain) NSString    *temp_installer_item_hash;
@property (retain) NSString    *temp_installer_item_location;
@property (retain) NSNumber    *temp_installer_item_size;
@property (retain) NSString    *temp_installer_type;
@property (retain) NSString    *temp_maximum_os_version;
@property (retain) NSString    *temp_minimum_os_version;
@property (retain) NSString    *temp_name;
@property (retain) NSString    *temp_package_path;
@property (retain) NSString    *temp_postinstall_script;
@property (retain) NSString    *temp_postuninstall_script;
@property (retain) NSString    *temp_preinstall_script;
@property (retain) NSString    *temp_preuninstall_script;
@property (retain) NSString    *temp_RestartAction;
@property (retain) NSNumber    *temp_suppress_bundle_relocation;
@property (retain) NSNumber    *temp_unattended_install;
@property (retain) NSNumber    *temp_unattended_uninstall;
@property (retain) NSString    *temp_uninstall_method;
@property (retain) NSString    *temp_uninstall_script;
@property (retain) NSString    *temp_uninstaller_item_location;
@property (retain) NSNumber    *temp_uninstallable;
@property (retain) NSString    *temp_version;

@end
