//
//  AdvancedPackageEditor.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 19.12.2011.
//

#import <Cocoa/Cocoa.h>
#import "PackageMO.h"
#import "StringObjectMO.h"

@interface AdvancedPackageEditor : NSWindowController {
    NSDatePicker *forceInstallDatePicker;
    NSTabView *mainTabView;
    
    NSDate      *temp_force_install_after_date;
    BOOL        temp_force_install_after_date_enabled;
    BOOL        temp_postinstall_script_enabled;
    NSString    *temp_postinstall_script;
    BOOL        temp_postuninstall_script_enabled;
    NSString    *temp_postuninstall_script;
    BOOL        temp_preinstall_script_enabled;
    NSString    *temp_preinstall_script;
    BOOL        temp_preuninstall_script_enabled;
    NSString    *temp_preuninstall_script;
    BOOL        temp_uninstall_script_enabled;
    NSString    *temp_uninstall_script;
    
    NSUndoManager *undoManager;
    PackageMO *pkginfoToEdit;
    NSObjectController *pkgController;
    
    NSArrayController *installsItemsController;
    NSArrayController *receiptsArrayController;
    NSArrayController *itemsToCopyArrayController;

}

- (IBAction)addInstallsItemFromDiskAction:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (void)setDefaultValuesFromPackage:(PackageMO *)aPackage;

@property (assign) PackageMO *pkginfoToEdit;

@property (assign) IBOutlet NSDatePicker *forceInstallDatePicker;
@property (assign) IBOutlet NSTabView *mainTabView;
@property (assign) IBOutlet NSArrayController *installsItemsController;
@property (assign) IBOutlet NSObjectController *pkgController;
@property (assign) IBOutlet NSArrayController *receiptsArrayController;
@property (assign) IBOutlet NSArrayController *itemsToCopyArrayController;

@property BOOL                  temp_force_install_after_date_enabled;
@property BOOL                  temp_postinstall_script_enabled;
@property BOOL                  temp_postuninstall_script_enabled;
@property BOOL                  temp_preinstall_script_enabled;
@property BOOL                  temp_preuninstall_script_enabled;
@property BOOL                  temp_uninstall_script_enabled;
@property (retain) NSDate      *temp_force_install_after_date;
@property (retain) NSString    *temp_postinstall_script;
@property (retain) NSString    *temp_postuninstall_script;
@property (retain) NSString    *temp_preinstall_script;
@property (retain) NSString    *temp_preuninstall_script;
@property (retain) NSString    *temp_uninstall_script;

@end
