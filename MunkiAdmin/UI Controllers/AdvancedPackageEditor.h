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
    NSDatePicker *__weak forceInstallDatePicker;
    NSTabView *__weak mainTabView;
    NSTableView *__weak installsTableView;
    NSTableView *__weak receiptsTableView;
    NSTableView *__weak itemsToCopyTableView;
    NSTableView *__weak installerChoicesXMLTableView;
    NSTableView *__weak blockingApplicationsTableView;
    NSTableView *__weak supportedArchitecturesTableView;
    NSTextView *__unsafe_unretained preinstallScriptTextView;
    NSTextView *__unsafe_unretained postinstallScriptTextView;
    NSTextView *__unsafe_unretained uninstallScriptTextView;
    NSTextView *__unsafe_unretained preuninstallScriptTextView;
    NSTextView *__unsafe_unretained postuninstallScriptTextView;
    NSTextView *__unsafe_unretained installCheckScriptTextView;
    NSTextView *__unsafe_unretained uninstallCheckScriptTextView;
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
    PackageMO *__weak pkginfoToEdit;
    NSObjectController *__weak pkgController;
    
    NSArrayController *__weak installsItemsController;
    NSArrayController *__weak receiptsArrayController;
    NSArrayController *__weak itemsToCopyArrayController;
    NSArrayController *__weak requiresArrayController;
    NSArrayController *__weak updateForArrayController;
    NSArrayController *__weak blockingApplicationsArrayController;
    NSArrayController *__weak supportedArchitecturesArrayController;
    NSArrayController *__weak installerChoicesArrayController;
    NSArrayController *__weak catalogInfosArrayController;
    NSArrayController *__weak installerEnvironmentVariablesArrayController;
    
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

@property (strong) id delegate;
@property (weak) PackageMO *pkginfoToEdit;
@property NSModalSession modalSession;
@property (weak) IBOutlet NSDatePicker *forceInstallDatePicker;
@property (weak) IBOutlet NSTabView *mainTabView;
@property (weak) IBOutlet NSTableView *installsTableView;
@property (weak) IBOutlet NSTableView *receiptsTableView;
@property (weak) IBOutlet NSTableView *itemsToCopyTableView;
@property (weak) IBOutlet NSTableView *installerChoicesXMLTableView;
@property (weak) IBOutlet NSTableView *blockingApplicationsTableView;
@property (weak) IBOutlet NSTableView *supportedArchitecturesTableView;
@property (unsafe_unretained) IBOutlet NSTextView *preinstallScriptTextView;
@property (unsafe_unretained) IBOutlet NSTextView *postinstallScriptTextView;
@property (unsafe_unretained) IBOutlet NSTextView *uninstallScriptTextView;
@property (unsafe_unretained) IBOutlet NSTextView *preuninstallScriptTextView;
@property (unsafe_unretained) IBOutlet NSTextView *postuninstallScriptTextView;
@property (unsafe_unretained) IBOutlet NSTextView *installCheckScriptTextView;
@property (unsafe_unretained) IBOutlet NSTextView *uninstallCheckScriptTextView;
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
