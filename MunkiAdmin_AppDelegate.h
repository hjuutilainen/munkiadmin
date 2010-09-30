//
//  MunkiAdmin_AppDelegate.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 11.1.2010.
//

#import <Cocoa/Cocoa.h>
#import "PackageMO.h"
#import "PackageInfoMO.h"
#import "CatalogMO.h"
#import "CatalogInfoMO.h"
#import "ApplicationMO.h"
#import "ApplicationInfoMO.h"
#import "ReceiptMO.h"
#import "ManifestMO.h"
#import "ManifestInfoMO.h"
#import "InstallsItemMO.h"
#import "PreferencesController.h"

@class ApplicationsArrayController;
@class PackageArrayController;
@class ManifestsArrayController;
@class PreferencesController;


@interface MunkiAdmin_AppDelegate : NSObject <NSTabViewDelegate, NSSplitViewDelegate>
{
	// ------------------
	// IBOutlet variables
	// ------------------
    NSWindow *window;
	NSWindow *progressPanel;
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
	NSTextField *newManifestCustomView;
	
	// The current master and detail view
	// that we are displaying
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
	NSProgressIndicator *progressIndicator;
	double subProgress;
	
	NSUserDefaults *defaults;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	PreferencesController *preferencesController;
	ApplicationsArrayController *applicationsArrayController;
	PackageArrayController *allPackagesArrayController;
	ManifestsArrayController *manifestsArrayController;
	NSArrayController *manifestInfosArrayController;
}

# pragma mark -
# pragma mark Variable declarations
@property (retain) NSString *selectedViewDescr;
@property NSUInteger selectedViewTag;
@property (readonly) NSUserDefaults *defaults;
@property (retain) NSURL *repoURL;
@property (retain) NSURL *pkgsURL;
@property (retain) NSURL *pkgsInfoURL;
@property (retain) NSURL *catalogsURL;
@property (retain) NSURL *manifestsURL;
@property (retain) NSArray *defaultRepoContents;
@property (retain) NSOperationQueue *operationQueue;
@property BOOL queueIsRunning;
@property double subProgress;
@property (retain) NSString *currentStatusDescription;

# pragma mark -
# pragma mark IBOutlet declarations
@property (nonatomic, retain) IBOutlet ApplicationsArrayController *applicationsArrayController;
@property (nonatomic, retain) IBOutlet PackageArrayController *allPackagesArrayController;
@property (nonatomic, retain) IBOutlet ManifestsArrayController *manifestsArrayController;
@property (nonatomic, retain) IBOutlet NSArrayController *manifestInfosArrayController;
@property (nonatomic, retain) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet NSWindow *progressPanel;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, retain) IBOutlet NSTabView *mainTabView;
@property (nonatomic, retain) IBOutlet NSTextField *newManifestCustomView;
@property (nonatomic, retain) IBOutlet NSView *detailViewPlaceHolder;
@property (nonatomic, retain) IBOutlet NSView *sourceViewPlaceHolder;
@property (nonatomic, retain) IBOutlet NSView *catalogsListView;
@property (nonatomic, retain) IBOutlet NSView *catalogsDetailView;
@property (nonatomic, retain) IBOutlet NSView *applicationsListView;
@property (nonatomic, retain) IBOutlet NSView *applicationsDetailView;
@property (nonatomic, retain) IBOutlet NSView *packagesListView;
@property (nonatomic, retain) IBOutlet NSView *packagesDetailView;
@property (nonatomic, retain) IBOutlet NSView *manifestsListView;
@property (nonatomic, retain) IBOutlet NSView *manifestsDetailView;
@property (nonatomic, retain) IBOutlet NSTableView *applicationTableView;
@property (nonatomic, retain) IBOutlet NSSplitView *mainSplitView;
@property (nonatomic, retain) IBOutlet NSSegmentedControl *mainSegmentedControl;

# pragma mark -
# pragma mark Core data specific declarations
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

# pragma mark -
# pragma mark GUI actions
- (IBAction)saveAction:sender;
- (IBAction)openPreferencesAction:sender;
- (IBAction)cancelOperationsAction:sender;
- (IBAction)writeChangesToDisk:sender;
- (IBAction)openRepository:sender;
- (IBAction)reloadRepositoryAction:sender;
- (IBAction)updateCatalogs:sender;
- (IBAction)propagateAppDescriptionToVersions:sender;
- (IBAction)createNewRepository:sender;
- (IBAction)createNewManifestAction:sender;
- (IBAction)createNewCatalogAction:sender;
- (IBAction)addNewPackage:sender;
- (IBAction)addNewInstallsItem:sender;
- (IBAction)didSelectSegment:sender;
- (IBAction)selectViewAction:sender;
- (IBAction)renameSelectedManifestAction:sender;
- (IBAction)deleteSelectedManifestsAction:sender;
- (IBAction)deleteSelectedPackagesAction:sender;
- (IBAction)enableAllPackagesForManifestAction:sender;
- (IBAction)disableAllPackagesForManifestAction:sender;

# pragma mark -
# pragma mark Helper methods

// Creates a new PackageMO managed object with the given properties
// This is called primarily from |scanCurrentRepoForPackages|
- (PackageMO *)newPackageWithProperties:(NSDictionary *)properties;

// Returns all managed objects for provided entity
- (NSArray *)allObjectsForEntity:(NSString *)entityName;

- (NSURL *)chooseRepositoryFolder;
- (NSArray *)chooseFolder;
- (NSURL *)chooseFile;
- (NSArray *)chooseFiles;
- (NSURL *)showSavePanel;


- (void)scanCurrentRepoForManifests;
- (void)scanCurrentRepoForIncludedManifests;
- (void)scanCurrentRepoForPackages;
- (void)scanCurrentRepoForCatalogs;
- (void)deleteAllManagedObjects;
- (void)selectRepoAtURL:(NSURL *)newURL;
- (void)writePackagePropertyListsToDisk;
- (void)changeItemView;

@end
