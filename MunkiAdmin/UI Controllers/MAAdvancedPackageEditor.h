//
//  AdvancedPackageEditor.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 19.12.2011.
//

#import <Cocoa/Cocoa.h>

@class MASelectPkginfoItemsWindow;
@class MAPackageNameEditor;
@class MAInstallsItemEditor;
@class PackageMO;
@class MARequestStringValueController;
@class MAIconEditor;

@interface MAAdvancedPackageEditor : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate, NSComboBoxDelegate> {
     
    NSUndoManager *undoManager;
    
    MASelectPkginfoItemsWindow *pkginfoSelector;
}

- (void)installsItemEditorDidFinish:(id)sender returnCode:(NSModalResponse)returnCode object:(id)object;
- (IBAction)addInstallsItemFromDiskAction:(id)sender;
- (IBAction)createNewInstallsItem:(id)sender;
- (IBAction)renameCurrentPackageAction:(id)sender;
- (IBAction)createNewCategoryAction:(id)sender;
- (IBAction)createNewDeveloperAction:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (void)endEditingInWindow;
- (void)commitChangesToCurrentPackage;
- (void)setDefaultValuesFromPackage:(PackageMO *)aPackage;
- (void)beginEditSessionWithObject:(PackageMO *)aPackage delegate:(id)modalDelegate;

@property (weak) id delegate;
@property (weak) PackageMO *pkginfoToEdit;
@property (strong) MAInstallsItemEditor *installsItemEditor;
@property (strong) MAPackageNameEditor *packageNameEditor;
@property (strong) MARequestStringValueController *createNewCategoryController;
@property (strong) MARequestStringValueController *createNewDeveloperController;
@property (strong) MAIconEditor *iconEditor;
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
@property (weak) IBOutlet NSArrayController *categoriesArrayController;
@property (weak) IBOutlet NSArrayController *developersArrayController;
@property (weak) IBOutlet NSComboBox *iconNameComboBox;

@property BOOL                  temp_force_install_after_date_enabled;
@property BOOL                  temp_postinstall_script_enabled;
@property BOOL                  temp_postuninstall_script_enabled;
@property BOOL                  temp_preinstall_script_enabled;
@property BOOL                  temp_preuninstall_script_enabled;
@property BOOL                  temp_uninstall_script_enabled;
@property BOOL                  temp_installcheck_script_enabled;
@property BOOL                  temp_uninstallcheck_script_enabled;
@property BOOL                  temp_version_script_enabled;
@property BOOL                  temp_blocking_applications_include_empty;
@property (strong) NSDate      *temp_force_install_after_date;
@property (strong) NSString    *temp_postinstall_script;
@property (strong) NSString    *temp_postuninstall_script;
@property (strong) NSString    *temp_preinstall_script;
@property (strong) NSString    *temp_preuninstall_script;
@property (strong) NSString    *temp_uninstall_script;
@property (strong) NSString    *temp_installcheck_script;
@property (strong) NSString    *temp_uninstallcheck_script;
@property (strong) NSString    *temp_version_script;
@property (strong) NSArray     *osVersions;
@property (strong) NSArray     *installerTypes;
@property (strong) NSArray     *iconNameSuggestions;

@end
