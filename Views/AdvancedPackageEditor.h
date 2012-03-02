//
//  AdvancedPackageEditor.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 19.12.2011.
//

#import <Cocoa/Cocoa.h>
#import "PackageMO.h"
#import "StringObjectMO.h"

@class SelectPkginfoItemsWindow;

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
    NSArrayController *requiresArrayController;
    NSArrayController *updateForArrayController;
    NSArrayController *blockingApplicationsArrayController;
    NSArrayController *supportedArchitecturesArrayController;
    NSArrayController *installerChoicesArrayController;
    
    NSModalSession modalSession;
    id delegate;
    
    SelectPkginfoItemsWindow *pkginfoSelector;
}

- (IBAction)addInstallsItemFromDiskAction:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (void)commitChangesToCurrentPackage;
- (void)setDefaultValuesFromPackage:(PackageMO *)aPackage;
- (NSModalSession)beginEditSessionWithObject:(PackageMO *)aPackage delegate:(id)modalDelegate;

@property (retain) id delegate;
@property (assign) PackageMO *pkginfoToEdit;
@property NSModalSession modalSession;
@property (assign) IBOutlet NSDatePicker *forceInstallDatePicker;
@property (assign) IBOutlet NSTabView *mainTabView;
@property (assign) IBOutlet NSArrayController *installsItemsController;
@property (assign) IBOutlet NSObjectController *pkgController;
@property (assign) IBOutlet NSArrayController *receiptsArrayController;
@property (assign) IBOutlet NSArrayController *itemsToCopyArrayController;
@property (assign) IBOutlet NSArrayController *requiresArrayController;
@property (assign) IBOutlet NSArrayController *updateForArrayController;
@property (assign) IBOutlet NSArrayController *blockingApplicationsArrayController;
@property (assign) IBOutlet NSArrayController *supportedArchitecturesArrayController;
@property (assign) IBOutlet NSArrayController *installerChoicesArrayController;

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
