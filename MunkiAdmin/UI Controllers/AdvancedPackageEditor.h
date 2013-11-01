//
//  AdvancedPackageEditor.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 19.12.2011.
//

#import <Cocoa/Cocoa.h>

@class SelectPkginfoItemsWindow;
@class PackageNameEditor;
@class InstallsItemEditor;
@class PackageMO;

@interface AdvancedPackageEditor : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate> {
    NSDatePicker *forceInstallDatePicker;
    NSTabView *mainTabView;
    NSTableView *installsTableView;
    NSTableView *receiptsTableView;
    NSTableView *itemsToCopyTableView;
    NSTableView *installerChoicesXMLTableView;
    NSTableView *blockingApplicationsTableView;
    NSTableView *supportedArchitecturesTableView;
    NSTextView *preinstallScriptTextView;
    NSTextView *postinstallScriptTextView;
    NSTextView *uninstallScriptTextView;
    NSTextView *preuninstallScriptTextView;
    NSTextView *postuninstallScriptTextView;
    NSTextView *installCheckScriptTextView;
    NSTextView *uninstallCheckScriptTextView;
    NSArray *osVersions;
    NSArray *installerTypes;
    
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
    BOOL        temp_installcheck_script_enabled;
    NSString    *temp_installcheck_script;
    BOOL        temp_uninstallcheck_script_enabled;
    NSString    *temp_uninstallcheck_script;
    BOOL        temp_blocking_applications_include_empty;
    
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
    NSArrayController *catalogInfosArrayController;
    NSArrayController *installerEnvironmentVariablesArrayController;
    
    NSModalSession modalSession;
    id delegate;
    
    SelectPkginfoItemsWindow *pkginfoSelector;
}

- (IBAction)addInstallsItemFromDiskAction:(id)sender;
- (IBAction)renameCurrentPackageAction:(id)sender;
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
@property (assign) IBOutlet NSTableView *installsTableView;
@property (assign) IBOutlet NSTableView *receiptsTableView;
@property (assign) IBOutlet NSTableView *itemsToCopyTableView;
@property (assign) IBOutlet NSTableView *installerChoicesXMLTableView;
@property (assign) IBOutlet NSTableView *blockingApplicationsTableView;
@property (assign) IBOutlet NSTableView *supportedArchitecturesTableView;
@property (assign) IBOutlet NSTextView *preinstallScriptTextView;
@property (assign) IBOutlet NSTextView *postinstallScriptTextView;
@property (assign) IBOutlet NSTextView *uninstallScriptTextView;
@property (assign) IBOutlet NSTextView *preuninstallScriptTextView;
@property (assign) IBOutlet NSTextView *postuninstallScriptTextView;
@property (assign) IBOutlet NSTextView *installCheckScriptTextView;
@property (assign) IBOutlet NSTextView *uninstallCheckScriptTextView;
@property (assign) IBOutlet NSArrayController *installsItemsController;
@property (assign) IBOutlet NSObjectController *pkgController;
@property (assign) IBOutlet NSArrayController *receiptsArrayController;
@property (assign) IBOutlet NSArrayController *itemsToCopyArrayController;
@property (assign) IBOutlet NSArrayController *requiresArrayController;
@property (assign) IBOutlet NSArrayController *updateForArrayController;
@property (assign) IBOutlet NSArrayController *blockingApplicationsArrayController;
@property (assign) IBOutlet NSArrayController *supportedArchitecturesArrayController;
@property (assign) IBOutlet NSArrayController *installerChoicesArrayController;
@property (assign) IBOutlet NSArrayController *catalogInfosArrayController;
@property (assign) IBOutlet NSArrayController *installerEnvironmentVariablesArrayController;

@property BOOL                  temp_force_install_after_date_enabled;
@property BOOL                  temp_postinstall_script_enabled;
@property BOOL                  temp_postuninstall_script_enabled;
@property BOOL                  temp_preinstall_script_enabled;
@property BOOL                  temp_preuninstall_script_enabled;
@property BOOL                  temp_uninstall_script_enabled;
@property BOOL                  temp_installcheck_script_enabled;
@property BOOL                  temp_uninstallcheck_script_enabled;
@property BOOL                  temp_blocking_applications_include_empty;
@property (retain) NSDate      *temp_force_install_after_date;
@property (retain) NSString    *temp_postinstall_script;
@property (retain) NSString    *temp_postuninstall_script;
@property (retain) NSString    *temp_preinstall_script;
@property (retain) NSString    *temp_preuninstall_script;
@property (retain) NSString    *temp_uninstall_script;
@property (retain) NSString    *temp_installcheck_script;
@property (retain) NSString    *temp_uninstallcheck_script;
@property (retain) NSArray     *osVersions;
@property (retain) NSArray     *installerTypes;

@end
