//
//  MunkiAdmin_AppDelegate.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 11.1.2010.
//

#import <Cocoa/Cocoa.h>

#import "MAPreferences.h"
#import "PackageInfosArrayController.h"
#import "CatalogsArrayController.h"
#import "DataModelHeaders.h"

@class MAApplicationsArrayController;
@class PackageArrayController;
@class ManifestsArrayController;
@class MAPreferences;
@class MAManifestDetailView;
@class MASelectPkginfoItemsWindow;
@class MASelectManifestItemsWindow;
@class MAPackageNameEditor;
@class MAPackagesView;
@class MAManifestsView;
@class MAAdvancedPackageEditor;
@class MAPkginfoAssimilator;
@class MAPreferences;
@class MAMunkiImportController;
@class DDFileLogger;


@interface MAMunkiAdmin_AppDelegate : NSObject <NSApplicationDelegate, NSTabViewDelegate, NSSplitViewDelegate, NSOpenSavePanelDelegate>
{
    MASelectPkginfoItemsWindow *addItemsWindowController;
    MASelectManifestItemsWindow *selectManifestsWindowController;
    MAAdvancedPackageEditor *advancedPackageEditor;
    //MAPredicateEditor *predicateEditor;
    MAPkginfoAssimilator *pkginfoAssimilator;
}

@property (assign) NSView *currentWholeView;
@property (assign) NSView *currentDetailView;
@property (assign) NSView *currentSourceView;

@property (weak) IBOutlet NSButton *searchToolbarButton;
@property (weak) IBOutlet NSButton *reloadToolbarButton;

@property (weak) IBOutlet NSArrayController *installsItemsArrayController;
@property (weak) IBOutlet NSArrayController *itemsToCopyArrayController;
@property (weak) IBOutlet NSArrayController *receiptsArrayController;
@property (weak) IBOutlet PackageArrayController *pkgsForAddingArrayController;
@property (weak) IBOutlet MAApplicationsArrayController *pkgGroupsForAddingArrayController;
@property (weak) IBOutlet NSView *makepkginfoOptionsView;
@property (weak) IBOutlet PackageInfosArrayController *packageInfosArrayController;
@property (weak) IBOutlet CatalogsArrayController *allCatalogsArrayController;

@property (strong) MAPackageNameEditor *packageNameEditor;
@property (strong) MAPackagesView *packagesViewController;
@property (strong) MAManifestsView *manifestsViewController;
@property (strong) MAMunkiImportController *munkiImportController;
@property (strong) MAPreferences *preferencesController;
@property (strong) NSTimer *operationTimer;
@property (strong) DDFileLogger *currentFileLogger;

# pragma mark -
# pragma mark Variable declarations
@property (strong) NSString *selectedViewDescr;
@property NSUInteger selectedViewTag;
@property (strong, readonly) NSUserDefaults *defaults;
@property (strong) NSURL *repoURL;
@property (strong) NSURL *pkgsURL;
@property (strong) NSURL *pkgsInfoURL;
@property (strong) NSURL *catalogsURL;
@property (strong) NSURL *manifestsURL;
@property (strong) NSURL *iconsURL;
@property (strong) NSArray *defaultRepoContents;
@property (strong) NSOperationQueue *operationQueue;
@property BOOL queueIsRunning;
@property double subProgress;
@property (strong) NSString *currentStatusDescription;
@property (strong) NSString *queueStatusDescription;
@property (strong) NSString *jobDescription;
@property (strong) NSString *addItemsType;
@property BOOL repositoryHasUnstagedChanges;
@property (strong) NSURL *previousPkgSaveURL;
@property (strong) NSURL *previousPkginfoSaveURL;

# pragma mark -
# pragma mark IBOutlet declarations
@property (strong) IBOutlet MAApplicationsArrayController *applicationsArrayController;
@property (strong) IBOutlet PackageArrayController *allPackagesArrayController;
@property (strong) IBOutlet ManifestsArrayController *manifestsArrayController;
@property (nonatomic, strong) IBOutlet NSArrayController *manifestInfosArrayController;
@property (nonatomic, strong) IBOutlet NSArrayController *managedInstallsArrayController;
@property (nonatomic, strong) IBOutlet NSArrayController *managedUpdatesArrayController;
@property (nonatomic, strong) IBOutlet NSArrayController *managedUninstallsArrayController;
@property (nonatomic, strong) IBOutlet NSArrayController *optionalInstallsArrayController;
@property (nonatomic, strong) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet NSWindow *progressPanel;
@property (nonatomic, strong) IBOutlet NSWindow *addItemsWindow;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, strong) IBOutlet NSTabView *mainTabView;
@property (nonatomic, strong) IBOutlet NSTextField *createNewManifestCustomView;
@property (nonatomic, strong) IBOutlet NSView *detailViewPlaceHolder;
@property (nonatomic, strong) IBOutlet NSView *sourceViewPlaceHolder;
@property (nonatomic, strong) IBOutlet NSView *catalogsListView;
@property (nonatomic, strong) IBOutlet NSView *catalogsDetailView;
@property (nonatomic, strong) IBOutlet NSView *applicationsListView;
@property (nonatomic, strong) IBOutlet NSView *applicationsDetailView;
@property (nonatomic, strong) IBOutlet NSView *packagesListView;
@property (nonatomic, strong) IBOutlet NSView *packagesDetailView;
@property (nonatomic, strong) IBOutlet NSView *manifestsListView;
@property (nonatomic, strong) IBOutlet NSView *manifestsDetailView;
@property (nonatomic, strong) IBOutlet NSTableView *applicationTableView;
@property (nonatomic, strong) IBOutlet NSSplitView *mainSplitView;
@property (nonatomic, strong) IBOutlet NSSegmentedControl *mainSegmentedControl;
@property (weak) IBOutlet NSSearchField *catalogContentSearchField;
@property (weak) IBOutlet NSSearchField *catalogsSearchField;

# pragma mark -
# pragma mark Core data specific declarations
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

# pragma mark -
# pragma mark GUI actions
- (IBAction)saveAction:sender;
- (IBAction)openPreferencesAction:sender;
- (IBAction)cancelOperationsAction:sender;
- (IBAction)writeChangesToDisk:sender;
- (IBAction)openRepository:sender;
- (IBAction)reloadRepositoryAction:sender;
- (IBAction)updateCatalogs:sender;
- (IBAction)createNewRepository:sender;
- (IBAction)createNewManifestAction:sender;
- (IBAction)createNewCatalogAction:sender;
- (IBAction)importManifestsFromFileAction:sender;
- (void)addNewPackagesFromFileURLs:(NSArray *)filesToAdd;
- (IBAction)addNewPackage:sender;
- (IBAction)addNewInstallsItem:sender;
- (IBAction)didSelectSegment:sender;
- (IBAction)selectViewAction:sender;
- (IBAction)duplicateSelectedManifestAction:(id)sender;
- (IBAction)renameSelectedManifestAction:sender;
- (IBAction)renameSelectedPackagesAction:sender;
- (void)packageNameEditorDidFinish:(id)sender returnCode:(int)returnCode object:(id)object;
- (IBAction)deleteSelectedManifestsAction:sender;
- (IBAction)deleteSelectedPackagesAction:sender;
- (IBAction)enableAllPackagesForManifestAction:sender;
- (IBAction)disableAllPackagesForManifestAction:sender;

- (IBAction)getInfoAction:(id)sender;
- (IBAction)selectPreviousPackageForEditing:(id)sender;
- (IBAction)selectNextPackageForEditing:(id)sender;
- (void)packageEditorDidFinish:(id)sender returnCode:(int)returnCode object:(id)object;
- (IBAction)showPkginfoInFinderAction:(id)sender;
- (IBAction)showInstallerInFinderAction:(id)sender;
- (IBAction)showManifestInFinderAction:(id)sender;
- (void)pkginfoAssimilatorDidFinish:(id)sender returnCode:(int)returnCode object:(id)object;
- (IBAction)startPkginfoAssimilatorAction:(id)sender;
- (IBAction)openCurrentLogFileAction:(id)sender;
- (IBAction)findAction:(id)sender;

# pragma mark -
# pragma mark Helper methods

- (BOOL)makepkginfoInstalled;
- (BOOL)makecatalogsInstalled;

// Creates a new PackageMO managed object with the given properties
// This is called primarily from |scanCurrentRepoForPackages|
//- (PackageMO *)newPackageWithProperties:(NSDictionary *)properties;

// Returns all managed objects for provided entity
- (NSArray *)allObjectsForEntity:(NSString *)entityName;

- (NSURL *)chooseRepositoryFolder;
- (NSArray *)chooseFolderForSave;
- (NSURL *)chooseFile;
- (NSArray *)chooseFiles;
- (NSURL *)showSavePanel;

- (void)mergeChanges:(NSNotification*)notification;
- (void)relationshipScannerDidFinish:(NSString *)mode;
- (void)scannerDidProcessPkginfo;
- (void)scanCurrentRepoForManifests;
- (void)scanCurrentRepoForPackages;
- (void)scanCurrentRepoForCatalogFiles;
- (void)deleteAllManagedObjects;
- (void)selectRepoAtURL:(NSURL *)newURL;
- (void)changeItemView;
- (void)updateSourceList;

@end
