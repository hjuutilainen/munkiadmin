//
//  MunkiAdmin_AppDelegate.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 11.1.2010.
//

#import <Cocoa/Cocoa.h>

#import "PreferencesController.h"
#import "PackageInfosArrayController.h"
#import "CatalogsArrayController.h"
#import "DataModelHeaders.h"

@class ApplicationsArrayController;
@class PackageArrayController;
@class ManifestsArrayController;
@class PreferencesController;
@class ManifestDetailView;
@class SelectPkginfoItemsWindow;
@class SelectManifestItemsWindow;
@class PackageNameEditor;
@class PackagesView;
@class AdvancedPackageEditor;
@class PredicateEditor;
@class PkginfoAssimilator;


@interface MunkiAdmin_AppDelegate : NSObject <NSTabViewDelegate, NSSplitViewDelegate, NSOpenSavePanelDelegate>
{
	// ------------------
	// IBOutlet variables
	// ------------------
    NSWindow *window;
	NSWindow *progressPanel;
	NSWindow *addItemsWindow;
	NSTabView *mainTabView;
	NSTableView *applicationTableView;
	NSSplitView *mainSplitView;
	NSView *applicationsListView;
	NSView *catalogsListView;
	NSView *packagesListView;
	NSView *manifestsListView;
	NSView *applicationsDetailView;
	NSView *catalogsDetailView;
	NSView *packagesDetailView;
	NSView *manifestsDetailView;
    PackagesView *packagesViewController;
    ManifestDetailView *manifestDetailViewController;
    SelectPkginfoItemsWindow *addItemsWindowController;
    SelectManifestItemsWindow *selectManifestsWindowController;
    AdvancedPackageEditor *advancedPackageEditor;
    PredicateEditor *predicateEditor;
    PkginfoAssimilator *pkginfoAssimilator;
    NSString *addItemsType;
	NSTextField *createNewManifestCustomView;
    NSView *__weak makepkginfoOptionsView;
    PackageInfosArrayController *__weak packageInfosArrayController;
    CatalogsArrayController *__weak allCatalogsArrayController;
	
	// The current master and detail view
	// that we are displaying
    NSView *currentWholeView;
	NSView *currentDetailView;
	NSView *currentSourceView;
	
	// Place holder views that are used
	// while changing the view
	NSView *detailViewPlaceHolder;
	NSView *sourceViewPlaceHolder;
	
	// The NSSegmentedControl that is used to change
	// views betweeen packages, catalogs and manifests
	NSSegmentedControl *mainSegmentedControl;
	NSUInteger selectedViewTag;
	NSString *selectedViewDescr;
	
	// ------------------
	// Internal variables
	// ------------------
	
	// URLs pointing to the current repo and its contents
	NSURL *repoURL;
	NSURL *pkgsURL;
	NSURL *pkgsInfoURL;
	NSURL *catalogsURL;
	NSURL *manifestsURL;
	
	// Contains the default repo directory names
	// This is used when opening and creating a repo
	NSArray *defaultRepoContents;
	
	// We use operation queue when reading or writing to the repo
	NSOperationQueue *operationQueue;
	BOOL queueIsRunning;
	NSString *currentStatusDescription;
	NSString *queueStatusDescription;
	NSString *jobDescription;
	NSProgressIndicator *progressIndicator;
	double subProgress;
    NSTimer *operationTimer;
	
	NSUserDefaults *defaults;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	PreferencesController *preferencesController;
	ApplicationsArrayController *applicationsArrayController;
	PackageArrayController *allPackagesArrayController;
	ManifestsArrayController *manifestsArrayController;
	NSArrayController *manifestInfosArrayController;
	NSArrayController *managedInstallsArrayController, *managedUpdatesArrayController, *managedUninstallsArrayController, *optionalInstallsArrayController;
    NSArrayController *__weak installsItemsArrayController;
    NSArrayController *__weak itemsToCopyArrayController;
    NSArrayController *__weak receiptsArrayController;
    PackageArrayController *__weak pkgsForAddingArrayController;
    ApplicationsArrayController *__weak pkgGroupsForAddingArrayController;
}

@property (weak) IBOutlet NSArrayController *installsItemsArrayController;
@property (weak) IBOutlet NSArrayController *itemsToCopyArrayController;
@property (weak) IBOutlet NSArrayController *receiptsArrayController;
@property (weak) IBOutlet PackageArrayController *pkgsForAddingArrayController;
@property (weak) IBOutlet ApplicationsArrayController *pkgGroupsForAddingArrayController;
@property (weak) IBOutlet NSView *makepkginfoOptionsView;
@property (weak) IBOutlet PackageInfosArrayController *packageInfosArrayController;
@property (weak) IBOutlet CatalogsArrayController *allCatalogsArrayController;

@property (strong) PackageNameEditor *packageNameEditor;

# pragma mark -
# pragma mark Variable declarations
@property (strong) NSString *selectedViewDescr;
@property NSUInteger selectedViewTag;
@property (weak, readonly) NSUserDefaults *defaults;
@property (strong) NSURL *repoURL;
@property (strong) NSURL *pkgsURL;
@property (strong) NSURL *pkgsInfoURL;
@property (strong) NSURL *catalogsURL;
@property (strong) NSURL *manifestsURL;
@property (strong) NSArray *defaultRepoContents;
@property (strong) NSOperationQueue *operationQueue;
@property BOOL queueIsRunning;
@property double subProgress;
@property (strong) NSString *currentStatusDescription;
@property (strong) NSString *queueStatusDescription;
@property (strong) NSString *jobDescription;
@property (strong) NSString *addItemsType;

# pragma mark -
# pragma mark IBOutlet declarations
@property (strong) IBOutlet ApplicationsArrayController *applicationsArrayController;
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

- (void)processAddItemsAction:(id)sender;
- (IBAction)addNewIncludedManifestAction:(id)sender;
- (IBAction)removeIncludedManifestAction:(id)sender;
- (IBAction)addNewConditionalItemAction:(id)sender;
- (IBAction)removeConditionalItemAction:(id)sender;
- (IBAction)editConditionalItemAction:(id)sender;
- (IBAction)addNewManagedInstallAction:(id)sender;
- (IBAction)removeManagedInstallAction:(id)sender;
- (IBAction)addNewManagedUninstallAction:(id)sender;
- (IBAction)removeManagedUninstallAction:(id)sender;
- (IBAction)addNewManagedUpdateAction:(id)sender;
- (IBAction)removeManagedUpdateAction:(id)sender;
- (IBAction)addNewOptionalInstallAction:(id)sender;
- (IBAction)removeOptionalInstallAction:(id)sender;
- (IBAction)getInfoAction:(id)sender;
- (IBAction)selectPreviousPackageForEditing:(id)sender;
- (IBAction)selectNextPackageForEditing:(id)sender;
- (void)packageEditorDidFinish:(id)sender returnCode:(int)returnCode object:(id)object;
- (IBAction)showPkginfoInFinderAction:(id)sender;
- (IBAction)showInstallerInFinderAction:(id)sender;
- (void)pkginfoAssimilatorDidFinish:(id)sender returnCode:(int)returnCode object:(id)object;
- (IBAction)startPkginfoAssimilatorAction:(id)sender;

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


- (void)scanCurrentRepoForManifests;
- (void)scanCurrentRepoForIncludedManifests;
- (void)scanCurrentRepoForPackages;
- (void)scanCurrentRepoForCatalogFiles;
- (void)deleteAllManagedObjects;
- (void)selectRepoAtURL:(NSURL *)newURL;
- (void)changeItemView;
- (void)configureSourceListDirectoriesSection;
- (void)configureContainersForPackage:(PackageMO *)aPackage;

@end
