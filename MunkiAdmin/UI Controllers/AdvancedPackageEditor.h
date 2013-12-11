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
     
    NSUndoManager *undoManager;
    
    SelectPkginfoItemsWindow *pkginfoSelector;
}

- (void)installsItemEditorDidFinish:(id)sender returnCode:(int)returnCode object:(id)object;
- (IBAction)addInstallsItemFromDiskAction:(id)sender;
- (IBAction)renameCurrentPackageAction:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (void)commitChangesToCurrentPackage;
- (void)setDefaultValuesFromPackage:(PackageMO *)aPackage;
- (NSModalSession)beginEditSessionWithObject:(PackageMO *)aPackage delegate:(id)modalDelegate;

@property (weak) id delegate;
@property (weak) PackageMO *pkginfoToEdit;
@property (strong) InstallsItemEditor *installsItemEditor;
@property (strong) PackageNameEditor *packageNameEditor;
@property NSModalSession modalSession;
@property (weak) IBOutlet NSDatePicker *forceInstallDatePicker;
@property (weak) IBOutlet NSTabView *mainTabView;
@property (weak) IBOutlet NSTableView *installsTableView;
@property (weak) IBOutlet NSTableView *receiptsTableView;
@property (weak) IBOutlet NSTableView *itemsToCopyTableView;
@property (weak) IBOutlet NSTableView *installerChoicesXMLTableView;
@property (weak) IBOutlet NSTableView *blockingApplicationsTableView;
@property (weak) IBOutlet NSTableView *supportedArchitecturesTableView;
@property (assign) IBOutlet NSTextView *preinstallScriptTextView;
@property (assign) IBOutlet NSTextView *postinstallScriptTextView;
@property (assign) IBOutlet NSTextView *uninstallScriptTextView;
@property (assign) IBOutlet NSTextView *preuninstallScriptTextView;
@property (assign) IBOutlet NSTextView *postuninstallScriptTextView;
@property (assign) IBOutlet NSTextView *installCheckScriptTextView;
@property (assign) IBOutlet NSTextView *uninstallCheckScriptTextView;
@property (weak) IBOutlet NSArrayController *installsItemsController;
@property (weak) IBOutlet NSObjectController *pkgController;
@property (weak) IBOutlet NSArrayController *receiptsArrayController;
@property (weak) IBOutlet NSArrayController *itemsToCopyArrayController;
@property (weak) IBOutlet NSArrayController *requiresArrayController;
@property (weak) IBOutlet NSArrayController *updateForArrayController;
@property (weak) IBOutlet NSArrayController *blockingApplicationsArrayController;
@property (weak) IBOutlet NSArrayController *supportedArchitecturesArrayController;
@property (weak) IBOutlet NSArrayController *installerChoicesArrayController;
@property (weak) IBOutlet NSArrayController *catalogInfosArrayController;
@property (weak) IBOutlet NSArrayController *installerEnvironmentVariablesArrayController;

@property BOOL                  temp_force_install_after_date_enabled;
@property BOOL                  temp_postinstall_script_enabled;
@property BOOL                  temp_postuninstall_script_enabled;
@property BOOL                  temp_preinstall_script_enabled;
@property BOOL                  temp_preuninstall_script_enabled;
@property BOOL                  temp_uninstall_script_enabled;
@property BOOL                  temp_installcheck_script_enabled;
@property BOOL                  temp_uninstallcheck_script_enabled;
@property BOOL                  temp_blocking_applications_include_empty;
@property (strong) NSDate      *temp_force_install_after_date;
@property (strong) NSString    *temp_postinstall_script;
@property (strong) NSString    *temp_postuninstall_script;
@property (strong) NSString    *temp_preinstall_script;
@property (strong) NSString    *temp_preuninstall_script;
@property (strong) NSString    *temp_uninstall_script;
@property (strong) NSString    *temp_installcheck_script;
@property (strong) NSString    *temp_uninstallcheck_script;
@property (strong) NSArray     *osVersions;
@property (strong) NSArray     *installerTypes;

@end
