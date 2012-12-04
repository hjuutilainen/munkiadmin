//
//  PkginfoAssimilator.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 3.12.2012.
//
//

#import <Cocoa/Cocoa.h>
#import "PackageMO.h"
#import "StringObjectMO.h"

@interface PkginfoAssimilator : NSWindowController {
    
    NSUndoManager *undoManager;
    PackageMO *sourcePkginfo;
    PackageMO *targetPkginfo;
    NSModalSession modalSession;
    id delegate;
    NSArrayController *allPackagesArrayController;
    NSButton *cancelButton;
    NSButton *okButton;
    
    NSArray *defaultsKeysToLoop;
    NSDictionary *keyGroups;
    
    BOOL assimilate_blocking_applications;
    BOOL assimilate_requires;
    BOOL assimilate_update_for;
    BOOL assimilate_supported_architectures;
    BOOL assimilate_installs_items;
    BOOL assimilate_installer_choices_xml;
    
    BOOL assimilate_autoremove;
    BOOL assimilate_description;
    BOOL assimilate_display_name;
    BOOL assimilate_installable_condition;
    BOOL assimilate_maximum_os_version;
    BOOL assimilate_minimum_munki_version;
    BOOL assimilate_minimum_os_version;
    BOOL assimilate_name;
    BOOL assimilate_unattended_install;
    BOOL assimilate_unattended_uninstall;
    BOOL assimilate_uninstallable;
    BOOL assimilate_uninstaller_item_location;
    
    BOOL assimilate_installcheck_script;
    BOOL assimilate_preinstall_script;
    BOOL assimilate_postinstall_script;
    BOOL assimilate_preuninstall_script;
    BOOL assimilate_postuninstall_script;
    BOOL assimilate_uninstall_method;
    BOOL assimilate_uninstall_script;
    BOOL assimilate_uninstallcheck_script;
    
}

- (NSModalSession)beginEditSessionWithObject:(PackageMO *)targetPackage
                                      source:(PackageMO *)sourcePackage
                                    delegate:(id)modalDelegate;

- (IBAction)saveAction:(id)sender;
- (IBAction)enableAllAction:(id)sender;
- (IBAction)disableAllAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (void)commitChangesToCurrentPackage;

@property (assign) IBOutlet NSButton *cancelButton;
@property (assign) IBOutlet NSButton *okButton;
@property (assign) IBOutlet NSArrayController *allPackagesArrayController;

@property (retain) id delegate;
@property (assign) PackageMO *sourcePkginfo;
@property (assign) PackageMO *targetPkginfo;
@property NSModalSession modalSession;

@property BOOL assimilate_blocking_applications;
@property BOOL assimilate_requires;
@property BOOL assimilate_update_for;
@property BOOL assimilate_supported_architectures;
@property BOOL assimilate_installs_items;
@property BOOL assimilate_installer_choices_xml;

@property BOOL assimilate_autoremove;
@property BOOL assimilate_description;
@property BOOL assimilate_display_name;
@property BOOL assimilate_installable_condition;
@property BOOL assimilate_maximum_os_version;
@property BOOL assimilate_minimum_munki_version;
@property BOOL assimilate_minimum_os_version;
@property BOOL assimilate_name;
@property BOOL assimilate_unattended_install;
@property BOOL assimilate_unattended_uninstall;
@property BOOL assimilate_uninstallable;
@property BOOL assimilate_uninstaller_item_location;

@property BOOL assimilate_installcheck_script;
@property BOOL assimilate_preinstall_script;
@property BOOL assimilate_postinstall_script;
@property BOOL assimilate_preuninstall_script;
@property BOOL assimilate_postuninstall_script;
@property BOOL assimilate_uninstall_method;
@property BOOL assimilate_uninstall_script;
@property BOOL assimilate_uninstallcheck_script;


@end
