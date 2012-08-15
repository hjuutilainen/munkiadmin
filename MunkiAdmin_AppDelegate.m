//
//  MunkiAdmin_AppDelegate.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 11.1.2010.
//

#import "MunkiAdmin_AppDelegate.h"
#import "PkginfoScanner.h"
#import "ManifestScanner.h"
#import "MunkiOperation.h"
#import "RelationshipScanner.h"
#import "FileCopyOperation.h"
#import "ManifestDetailView.h"
#import "SelectPkginfoItemsWindow.h"
#import "SelectManifestItemsWindow.h"
#import "PackageNameEditor.h"
#import "AdvancedPackageEditor.h"
#import "PredicateEditor.h"
#import "PackagesView.h"

@implementation MunkiAdmin_AppDelegate
@synthesize installsItemsArrayController;
@synthesize itemsToCopyArrayController;
@synthesize receiptsArrayController;
@synthesize pkgsForAddingArrayController;
@synthesize pkgGroupsForAddingArrayController;
@synthesize addItemsType;
@synthesize makepkginfoOptionsView;
@synthesize packageInfosArrayController;
@synthesize allCatalogsArrayController;

# pragma mark -
# pragma mark Property Implementation Directives

@dynamic defaults;
@synthesize applicationsArrayController, allPackagesArrayController, manifestsArrayController;
@synthesize manifestInfosArrayController;
@synthesize managedInstallsArrayController;
@synthesize managedUpdatesArrayController;
@synthesize managedUninstallsArrayController;
@synthesize optionalInstallsArrayController;
@synthesize selectedViewDescr;
@synthesize window;
@synthesize progressPanel;
@synthesize addItemsWindow;
@synthesize mainTabView;
@synthesize mainSplitView;
@synthesize sourceViewPlaceHolder;
@synthesize detailViewPlaceHolder;
@synthesize createNewManifestCustomView;
@synthesize applicationsDetailView;
@synthesize applicationsListView;
@synthesize applicationTableView;
@synthesize catalogsListView;
@synthesize catalogsDetailView;
@synthesize packagesListView;
@synthesize packagesDetailView;
@synthesize manifestsListView;
@synthesize manifestsDetailView;
@synthesize mainSegmentedControl;
@synthesize repoURL;
@synthesize pkgsURL;
@synthesize pkgsInfoURL;
@synthesize catalogsURL;
@synthesize manifestsURL;
@synthesize operationQueue;
@synthesize queueIsRunning;
@synthesize progressIndicator;
@synthesize currentStatusDescription;
@synthesize queueStatusDescription;
@synthesize jobDescription;
@synthesize subProgress;
@synthesize defaultRepoContents;
@synthesize selectedViewTag;


# pragma mark -
# pragma mark Helper methods

- (IBAction)openPreferencesAction:sender
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"Preferences"];
	[preferencesController showWindow:self];
}

- (IBAction)showPkginfoInFinderAction:(id)sender
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    NSURL *selectedURL = (NSURL *)[[[[packagesViewController packagesArrayController] selectedObjects] lastObject] packageInfoURL];
    [[NSWorkspace sharedWorkspace] selectFile:[selectedURL relativePath] inFileViewerRootedAtPath:[self.repoURL relativePath]];
}

- (NSUserDefaults *)defaults
{
	return [NSUserDefaults standardUserDefaults];
}

- (BOOL)makepkginfoInstalled
{
	// Check if /usr/local/munki/makepkginfo exists
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *makepkginfoPath = [self.defaults stringForKey:@"makepkginfoPath"];
	if ([fm fileExistsAtPath:makepkginfoPath]) {
		return YES;
	} else {
		NSLog(@"Can't find %@. Check the paths to munki tools.", makepkginfoPath);
		return NO;
	}
}

- (BOOL)makecatalogsInstalled
{
	// Check if /usr/local/munki/makecatalogs exists
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *makecatalogsPath = [self.defaults stringForKey:@"makecatalogsPath"];
	if ([fm fileExistsAtPath:makecatalogsPath]) {
		return YES;
	} else {
		NSLog(@"Can't find %@. Check the paths to munki tools.", makecatalogsPath);
		return NO;
	}
}

- (void)deleteAllManagedObjects
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"Deleting all managed objects (in-memory)");
	}
    NSManagedObjectContext *moc = [self managedObjectContext];
    
	[moc processPendingChanges];
    [[moc undoManager] disableUndoRegistration];
	
	for (NSEntityDescription *entDescr in [[self managedObjectModel] entities]) {
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		NSArray *allObjects = [self allObjectsForEntity:[entDescr name]];
		//NSArray *allObjects = [[NSArray alloc] initWithArray:[self allObjectsForEntity:[entDescr name]]];
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Deleting %lu objects from entity: %@", (unsigned long)[allObjects count], [entDescr name]);
		for (id anObject in allObjects) {
			[moc deleteObject:anObject];
		}
		//[allObjects release];
		[pool release];
	}
	[moc processPendingChanges];
    [[moc undoManager] enableUndoRegistration];
}

- (NSArray *)allObjectsForEntity:(NSString *)entityName
{
	NSEntityDescription *entityDescr = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescr];
	NSArray *fetchResults = [[self managedObjectContext] executeFetchRequest:fetchRequest error:nil];
	//NSArray *fetchResults = [[[NSArray alloc] initWithArray:[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil]] autorelease];
	[fetchRequest release];
	return fetchResults;
}

- (void)checkMaxVersionsForCatalogs
{	
	for (CatalogMO *aCatalog in [self allObjectsForEntity:@"Catalog"]) {
		
		NSEntityDescription *entityDescr = [NSEntityDescription entityForName:@"CatalogInfo" inManagedObjectContext:[self managedObjectContext]];
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entityDescr];
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"(isEnabledForPackage == 1)"];
		[fetchRequest setPredicate:pred];
		NSArray *fetchResults = [[self managedObjectContext] executeFetchRequest:fetchRequest error:nil];
		[fetchRequest release];
		for (CatalogInfoMO *catInfo in fetchResults) {
			//NSLog(@"%@:%@-%@", catInfo.catalog.title, catInfo.package.munki_name, catInfo.package.munki_version);
		}
	}
}


- (NSURL *)chooseRepositoryFolder
{
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	openPanel.title = @"Select a munki Repository";
	openPanel.allowsMultipleSelection = NO;
	openPanel.canChooseDirectories = YES;
	openPanel.canChooseFiles = NO;
	openPanel.resolvesAliases = YES;
	openPanel.directoryURL = [self.defaults URLForKey:@"openRepositoryLastDir"];
    
	if ([openPanel runModal] == NSFileHandlingPanelOKButton)
	{
		[self.defaults setURL:[[openPanel URLs] objectAtIndex:0] forKey:@"openRepositoryLastDir"];
		return [[openPanel URLs] objectAtIndex:0];
	} else {
		return nil;
	}
}

- (NSArray *)chooseFolder
{
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	openPanel.title = @"Select a munki Repository";
	openPanel.allowsMultipleSelection = NO;
	openPanel.canChooseDirectories = YES;
	openPanel.canChooseFiles = NO;
	openPanel.resolvesAliases = YES;
	
	if ([openPanel runModal] == NSFileHandlingPanelOKButton)
	{
		return [openPanel URLs];
	} else {
		return nil;
	}
}

- (NSURL *)chooseFile
{
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	openPanel.title = @"Select a File";
	openPanel.allowsMultipleSelection = NO;
	openPanel.canChooseDirectories = NO;
	openPanel.canChooseFiles = YES;
	openPanel.resolvesAliases = YES;
	
	if ([openPanel runModal] == NSFileHandlingPanelOKButton)
	{
		return [[openPanel URLs] objectAtIndex:0];
	} else {
		return nil;
	}
}

- (NSArray *)chooseFiles
{
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	openPanel.title = @"Select a File";
	openPanel.allowsMultipleSelection = YES;
	openPanel.canChooseDirectories = NO;
	openPanel.canChooseFiles = YES;
	openPanel.resolvesAliases = YES;
	
	if ([openPanel runModal] == NSFileHandlingPanelOKButton)
	{
		return [openPanel URLs];
	} else {
		return nil;
	}
}


- (NSArray *)chooseFilesForMakepkginfo
{
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	openPanel.title = @"Select a File";
	openPanel.allowsMultipleSelection = YES;
	openPanel.canChooseDirectories = NO;
	openPanel.canChooseFiles = YES;
	openPanel.resolvesAliases = YES;
    openPanel.directoryURL = self.pkgsURL;
    [openPanel setAccessoryView:self.makepkginfoOptionsView];
	
	// Make the accessory view first responder
	//[openPanel layout];
	//[[openPanel window] makeFirstResponder:createNewManifestCustomView];
	
	if ([openPanel runModal] == NSFileHandlingPanelOKButton)
	{
		return [openPanel URLs];
	} else {
		return nil;
	}
}

- (NSURL *)showSavePanelForCopyOperation:(NSString *)fileName
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	savePanel.nameFieldStringValue = fileName;
    savePanel.directoryURL = self.pkgsURL;
    savePanel.title = @"Save package";
    savePanel.message = [NSString stringWithFormat:@"Original item is not in your pkgs directory. It will be copied to the selected destination."];
	if ([savePanel runModal] == NSFileHandlingPanelOKButton)
	{
		return [savePanel URL];
	} else {
		return nil;
	}
}


- (NSURL *)showSavePanelForPkginfo:(NSString *)fileName
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	savePanel.nameFieldStringValue = fileName;
    savePanel.directoryURL = self.pkgsInfoURL;
    savePanel.title = @"Save pkginfo";
	if ([savePanel runModal] == NSFileHandlingPanelOKButton)
	{
		return [savePanel URL];
	} else {
		return nil;
	}
}


- (NSURL *)showSavePanel
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	savePanel.nameFieldStringValue = @"New Repository";
	if ([savePanel runModal] == NSFileHandlingPanelOKButton)
	{
		return [savePanel URL];
	} else {
		return nil;
	}
}

# pragma mark -
# pragma mark Application Startup

- (void)awakeFromNib
{	
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@: Setting up the app", NSStringFromSelector(_cmd));
	}
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoManagerDidUndo:) name:NSUndoManagerDidUndoChangeNotification object:nil];
	
    packagesViewController = [[PackagesView alloc] initWithNibName:@"PackagesView" bundle:nil];
    manifestDetailViewController = [[ManifestDetailView alloc] initWithNibName:@"ManifestDetailView" bundle:nil];
    addItemsWindowController = [[SelectPkginfoItemsWindow alloc] initWithWindowNibName:@"SelectPkginfoItemsWindow"];
    selectManifestsWindowController = [[SelectManifestItemsWindow alloc] initWithWindowNibName:@"SelectManifestItemsWindow"];
    packageNameEditor = [[PackageNameEditor alloc] initWithWindowNibName:@"PackageNameEditor"];
    advancedPackageEditor = [[AdvancedPackageEditor alloc] initWithWindowNibName:@"AdvancedPackageEditor"];
    predicateEditor = [[PredicateEditor alloc] initWithWindowNibName:@"PredicateEditor"];
    
    
	// Configure segmented control
	NSWorkspace *wp = [NSWorkspace sharedWorkspace];
	[mainSegmentedControl setSegmentCount:3];
	
	NSImage *packagesIcon = [wp iconForFileType:@"pkg"];
	[packagesIcon setSize:NSMakeSize(16, 16)];
	NSImage *catalogsIcon = [[[NSImage imageNamed:@"catalogIcon3"] copy] autorelease];
	[catalogsIcon setSize:NSMakeSize(16, 16)];
	NSImage *manifestsIcon = [[[NSImage imageNamed:@"manifestIcon2"] copy] autorelease];
	[manifestsIcon setSize:NSMakeSize(16, 16)];
	
	[mainSegmentedControl setImage:packagesIcon forSegment:0];
	[mainSegmentedControl setImage:catalogsIcon forSegment:1];
	[mainSegmentedControl setImage:manifestsIcon forSegment:2];
	
	[mainTabView setDelegate:self];
	[mainSplitView setDelegate:self];
	
	if ([self.defaults integerForKey:@"startupSelectedView"] == 0) {
		self.selectedViewTag = 0;
		self.selectedViewDescr = @"Packages";
        currentWholeView = [packagesViewController view];
		[mainSegmentedControl setSelectedSegment:0];
	}
	else if ([self.defaults integerForKey:@"startupSelectedView"] == 1) {
		self.selectedViewTag = 1;
		self.selectedViewDescr = @"Catalogs";
		currentDetailView = catalogsDetailView;
		currentSourceView = catalogsListView;
        currentWholeView = self.mainSplitView;
		[mainSegmentedControl setSelectedSegment:1];
	}
	else if ([self.defaults integerForKey:@"startupSelectedView"] == 2) {
		self.selectedViewTag = 2;
		self.selectedViewDescr = @"Manifests";
		currentDetailView = [manifestDetailViewController view];
		currentSourceView = manifestsListView;
        currentWholeView = self.mainSplitView;
		[mainSegmentedControl setSelectedSegment:2];
	}
	else {
		self.selectedViewTag = 0;
		self.selectedViewDescr = @"Packages";
        currentWholeView = [packagesViewController view];
		[mainSegmentedControl setSelectedSegment:0];
	}
    	
	[self changeItemView];
	
	[self.window center];
	
	// Create an operation queue for later use
	self.operationQueue = [[[NSOperationQueue alloc] init] autorelease];
	[self.operationQueue setMaxConcurrentOperationCount:1];
	self.queueIsRunning = NO;
	[progressIndicator setUsesThreadedAnimation:YES];
		
	// Define default repository contents
    self.defaultRepoContents = [NSArray arrayWithObjects:@"catalogs", @"manifests", @"pkgsinfo", nil];
	
	// Set sort descriptors for array controllers
    NSSortDescriptor *sortManifestsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"parentManifest.title" ascending:YES selector:@selector(localizedStandardCompare:)];
	[manifestInfosArrayController setSortDescriptors:[NSArray arrayWithObject:sortManifestsByTitle]];
	
    NSSortDescriptor *sortAppProxiesByTitle = [NSSortDescriptor sortDescriptorWithKey:@"parentApplication.munki_name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortAppProxiesByDisplayName = [NSSortDescriptor sortDescriptorWithKey:@"parentApplication.munki_display_name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray *appSorters = [NSArray arrayWithObjects:sortAppProxiesByDisplayName, sortAppProxiesByTitle, nil];
	[managedInstallsArrayController setSortDescriptors:appSorters];
	[managedUninstallsArrayController setSortDescriptors:appSorters];
	[managedUpdatesArrayController setSortDescriptors:appSorters];
	[optionalInstallsArrayController setSortDescriptors:appSorters];
    
    NSSortDescriptor *sortInstallsItems = [NSSortDescriptor sortDescriptorWithKey:@"munki_path" ascending:YES];
    [installsItemsArrayController setSortDescriptors:[NSArray arrayWithObject:sortInstallsItems]];
    
    NSSortDescriptor *sortItemsToCopyByDestPath = [NSSortDescriptor sortDescriptorWithKey:@"munki_destination_path" ascending:YES];
    NSSortDescriptor *sortItemsToCopyBySource = [NSSortDescriptor sortDescriptorWithKey:@"munki_source_item" ascending:YES];
    [itemsToCopyArrayController setSortDescriptors:[NSArray arrayWithObjects:sortItemsToCopyByDestPath, sortItemsToCopyBySource, nil]];
    
    NSSortDescriptor *sortReceiptsByPackageID = [NSSortDescriptor sortDescriptorWithKey:@"munki_packageid" ascending:YES];
    NSSortDescriptor *sortReceiptsByName = [NSSortDescriptor sortDescriptorWithKey:@"munki_name" ascending:YES];
    [receiptsArrayController setSortDescriptors:[NSArray arrayWithObjects:sortReceiptsByPackageID, sortReceiptsByName, nil]];
	
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    
    // Select a repository
    if ([self.defaults integerForKey:@"startupWhatToDo"] == 1) {
        NSURL *tempURL = [self chooseRepositoryFolder];
        if (tempURL != nil) {
            [self selectRepoAtURL:tempURL];
        }
    }
    
    // Open previous repository
    else if ([self.defaults integerForKey:@"startupWhatToDo"] == 2) {
        NSURL *tempURL = [self.defaults URLForKey:@"selectedRepositoryPath"];
        if (tempURL != nil) {
            [self selectRepoAtURL:tempURL];
        }
    }
    // Do nothing
    else if ([self.defaults integerForKey:@"startupWhatToDo"] == 0) {
        
    }
	
}


# pragma mark -
# pragma mark NSOperationQueue specific

- (void)checkOperations:(NSTimer *)timer
{	
	int numOp = [self.operationQueue operationCount];
	
    if (numOp < 1) {
		// There are no more operations in queue
		[timer invalidate];
		self.queueIsRunning = NO;
		self.jobDescription = @"Done";
		self.currentStatusDescription = @"--";
		[progressIndicator setDoubleValue:[progressIndicator maxValue]];
		[NSApp endSheet:progressPanel];
		[progressPanel close];
		[progressIndicator stopAnimation:self];
	}
	
	else {
		// Update progress
		self.queueStatusDescription = [NSString stringWithFormat:@"%i items remaining", numOp - 1];
		if (numOp == 1) {
			[progressIndicator setIndeterminate:YES];
			[progressIndicator startAnimation:self];
		} else {
			[progressIndicator setIndeterminate:NO];
			double currentProgress = [progressIndicator maxValue] - (double)numOp + 1;
			[progressIndicator setDoubleValue:currentProgress];
		}
		
		// Get the currently running operation
		//id firstOpItem = [[self.operationQueue operations] objectAtIndex:0];
        
        for (id firstOpItem in [self.operationQueue operations]) {
            if ([firstOpItem isExecuting]) {
                // Running item is PkginfoScanner
                if ([firstOpItem isKindOfClass:[PkginfoScanner class]]) {
                    self.currentStatusDescription = [NSString stringWithFormat:@"%@", [firstOpItem fileName]];
                    self.jobDescription = @"Scanning Packages";
                }
                
                // Running item is ManifestScanner
                else if ([firstOpItem isKindOfClass:[ManifestScanner class]]) {
                    self.currentStatusDescription = [NSString stringWithFormat:@"%@", [firstOpItem fileName]];
                    self.jobDescription = @"Scanning Manifests";
                }
                
                // Running item is MunkiOperation
                else if ([firstOpItem isKindOfClass:[MunkiOperation class]]) {
                    NSString *munkiCommand = [firstOpItem command];
                    if ([munkiCommand isEqualToString:@"makecatalogs"]) {
                        self.jobDescription = @"Running makecatalogs";
                        self.currentStatusDescription = [NSString stringWithFormat:@"%@", [[firstOpItem targetURL] relativePath]];
                    } else if ([munkiCommand isEqualToString:@"makepkginfo"]) {
                        self.jobDescription = @"Running makepkginfo";
                        self.currentStatusDescription = [NSString stringWithFormat:@"%@", [[firstOpItem targetURL] lastPathComponent]];
                    } else if ([munkiCommand isEqualToString:@"installsitem"]) {
                        self.jobDescription = @"Running makepkginfo";
                        self.currentStatusDescription = [NSString stringWithFormat:@"%@", [[firstOpItem targetURL] lastPathComponent]];
                    }
                }
                
                // Running item is MunkiOperation
                else if ([firstOpItem isKindOfClass:[FileCopyOperation class]]) {
                    self.jobDescription = @"Copying";
                    self.currentStatusDescription = [NSString stringWithFormat:@"%@", [[firstOpItem sourceURL] lastPathComponent]];
                }
                
                // Running item is MunkiOperation
                else if ([firstOpItem isKindOfClass:[RelationshipScanner class]]) {
                    self.jobDescription = @"Organizing package relationships";
                    self.currentStatusDescription = [NSString stringWithFormat:@"%@", [firstOpItem currentJobDescription]];
                }
            }
        }
	}
}

- (void)startOperationTimer
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	operationTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
													  target:self
													selector:@selector(checkOperations:)
													userInfo:nil
													 repeats:YES];
}

- (void)showProgressPanel
{
	[NSApp beginSheet:progressPanel 
	   modalForWindow:self.window modalDelegate:nil 
	   didEndSelector:nil contextInfo:nil];
	[progressIndicator setDoubleValue:0.0];
	[progressIndicator setMaxValue:[self.operationQueue operationCount]];
	[progressIndicator startAnimation:self];
	[self startOperationTimer];
}

- (IBAction)cancelOperationsAction:sender
{
	self.queueIsRunning = NO;
	self.currentStatusDescription = @"Canceling all operations";
	if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@", self.currentStatusDescription);
	[self.operationQueue cancelAllOperations];
}

# pragma mark - Modifying manifests

- (void)renameSelectedManifest
{
	ManifestMO *selMan = [[manifestsArrayController selectedObjects] objectAtIndex:0];
	NSString *oldTitle = selMan.title;
    
	// Configure the dialog
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Rename"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Rename Manifest"];
    [alert setInformativeText:[NSString stringWithFormat:@"Rename manifest \"%@\" to:", selMan.title]];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert setShowsSuppressionButton:NO];
	
	NSRect textRect = NSMakeRect(0, 0, 350, 22);
	NSTextField *textField=[[NSTextField alloc] initWithFrame:textRect];
	[textField setStringValue:selMan.title];
    [alert setAccessoryView:textField];
	
	// Make the accessory view first responder
	[alert layout];
	[[alert window] makeFirstResponder:textField];
	
	// Display the dialog
    NSInteger result = [alert runModal];
	if (result == NSAlertFirstButtonReturn) {
		NSString *newTitle = [textField stringValue];
		if (![newTitle isEqualToString:selMan.title]) {
			if ([self.defaults boolForKey:@"debug"]) {
				NSLog(@"Renaming %@ to %@", selMan.title, newTitle);
			}
			NSURL *currentURL = (NSURL *)selMan.manifestURL;
			NSURL *newURL = [[(NSURL *)selMan.manifestURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:newTitle];
			if ([[NSFileManager defaultManager] moveItemAtURL:currentURL toURL:newURL error:nil]) {
				selMan.manifestURL = newURL;
				selMan.title = newTitle;
                
                // Rename other references (this might be a nested manifest)
                NSFetchRequest *getReferencingManifests = [[NSFetchRequest alloc] init];
                [getReferencingManifests setEntity:[NSEntityDescription entityForName:@"StringObject" inManagedObjectContext:self.managedObjectContext]];
                NSPredicate *referencingPred = [NSPredicate predicateWithFormat:@"title == %@ AND typeString == %@", oldTitle, @"includedManifest"];
                [getReferencingManifests setPredicate:referencingPred];
                if ([self.managedObjectContext countForFetchRequest:getReferencingManifests error:nil] > 0) {
                    NSArray *referencingObjects = [self.managedObjectContext executeFetchRequest:getReferencingManifests error:nil];
                    for (StringObjectMO *aReference in referencingObjects) {
                        if ([self.defaults boolForKey:@"debug"]) NSLog(@"Renaming reference from manifest: %@", aReference.manifestReference.title);
                        aReference.title = newTitle;
                    }
                } else {
                    if ([self.defaults boolForKey:@"debug"]) NSLog(@"No referencing objects to rename");
                }
                [getReferencingManifests release];
                
			} else {
				NSLog(@"Failed to rename manifest on disk");
			}
		}
	}
	[textField release];
	[alert release];
}

- (IBAction)renameSelectedManifestAction:sender
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	[self renameSelectedManifest];
}

- (void)duplicateSelectedManifest
{
    ManifestMO *selMan = [[manifestsArrayController selectedObjects] objectAtIndex:0];
	
	// Configure the dialog
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Duplicate"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Duplicate Manifest"];
    [alert setInformativeText:[NSString stringWithFormat:@"Duplicate %@ to:", selMan.title]];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert setShowsSuppressionButton:NO];
	
	NSRect textRect = NSMakeRect(0, 0, 350, 22);
	NSTextField *textField=[[NSTextField alloc] initWithFrame:textRect];
	[textField setStringValue:selMan.title];
    [alert setAccessoryView:textField];
	
	// Make the accessory view first responder
	[alert layout];
	[[alert window] makeFirstResponder:textField];
	
	// Display the dialog
    NSInteger result = [alert runModal];
	if (result == NSAlertFirstButtonReturn) {
		NSString *newTitle = [textField stringValue];
		if (![newTitle isEqualToString:selMan.title]) {
			if ([self.defaults boolForKey:@"debug"]) {
				NSLog(@"Duplicating %@ to %@", selMan.title, newTitle);
			}
			NSURL *currentURL = (NSURL *)selMan.manifestURL;
			NSURL *newURL = [[(NSURL *)selMan.manifestURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:newTitle];
			if ([[NSFileManager defaultManager] copyItemAtURL:currentURL toURL:newURL error:nil]) {
                
                RelationshipScanner *manifestRelationships = [RelationshipScanner manifestScanner];
                manifestRelationships.delegate = self;
                
                ManifestScanner *scanOp = [[[ManifestScanner alloc] initWithURL:newURL] autorelease];
                scanOp.delegate = self;
                [manifestRelationships addDependency:scanOp];
                [self.operationQueue addOperation:scanOp];
                [self.operationQueue addOperation:manifestRelationships];
                
                [self showProgressPanel];
			} else {
				NSLog(@"Failed to copy manifest on disk");
			}
		}
	}
	[textField release];
	[alert release];
    
}

- (IBAction)duplicateSelectedManifestAction:(id)sender
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    [self duplicateSelectedManifest];
}

- (void)deleteSelectedManifests
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	
	NSArray *selectedManifests = [manifestsArrayController selectedObjects];
	NSManagedObjectContext *moc = [self managedObjectContext];
	// Configure the dialog
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Delete"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Delete Manifests"];
    [alert setInformativeText:[NSString stringWithFormat:@"Are you sure you want to delete %lu manifest(s)? This can't be undone.", (unsigned long)[selectedManifests count]]];
    [alert setAlertStyle:NSInformationalAlertStyle];
	//NSImage *theIcon = [NSImage imageNamed:@"trash"];
	//[theIcon setScalesWhenResized:NO];
	//[alert setIcon:theIcon];
    [alert setShowsSuppressionButton:NO];
	
	NSInteger result = [alert runModal];
	if (result == NSAlertFirstButtonReturn) {
		for (ManifestMO *aManifest in selectedManifests) {
			if ([self.defaults boolForKey:@"debug"]) {
				NSLog(@"Deleting %@", aManifest.title);
			}
			[[NSWorkspace sharedWorkspace] recycleURLs:[NSArray arrayWithObject:aManifest.manifestURL] completionHandler:nil];
			[moc deleteObject:aManifest];
		}
	}
	[alert release];
}

- (IBAction)deleteSelectedManifestsAction:sender
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	[self deleteSelectedManifests];
}

- (void)createNewManifest
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	
	// Configure the dialog
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Create"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"New Manifest"];
    [alert setInformativeText:@"Create a new manifest with title:"];
    [alert setAlertStyle:NSInformationalAlertStyle];
	//NSImage *theIcon = [NSImage imageNamed:@"manifestIcon2"];
	//[theIcon setScalesWhenResized:NO];
	//[alert setIcon:theIcon];
    [alert setShowsSuppressionButton:NO];
    [alert setAccessoryView:createNewManifestCustomView];
	
	// Make the accessory view first responder
	[alert layout];
	[[alert window] makeFirstResponder:createNewManifestCustomView];
	
	// Display the dialog and act accordingly
    NSInteger result = [alert runModal];
    if (result == NSAlertFirstButtonReturn) {
		NSManagedObjectContext *moc = [self managedObjectContext];
        ManifestMO *manifest;
		manifest = [NSEntityDescription insertNewObjectForEntityForName:@"Manifest" inManagedObjectContext:moc];
		manifest.title = [createNewManifestCustomView stringValue];
		manifest.manifestURL = [self.manifestsURL URLByAppendingPathComponent:manifest.title];
		
		for (CatalogMO *aCatalog in [self allObjectsForEntity:@"Catalog"]) {
			CatalogInfoMO *newCatalogInfo;
			newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:moc];
			newCatalogInfo.catalog.title = aCatalog.title;
			[aCatalog addManifestsObject:manifest];
			newCatalogInfo.manifest = manifest;
			[aCatalog addCatalogInfosObject:newCatalogInfo];
			newCatalogInfo.isEnabledForManifestValue = NO;
		}
		
    } else if ( result == NSAlertSecondButtonReturn ) {
        
    }
    [alert release];
}

- (IBAction)createNewManifestAction:sender
{
	[self createNewManifest];
}


# pragma mark - Modifying packages

- (IBAction)processRenamePackagesAction:(id)sender
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    
    NSString *newName = [packageNameEditor changedName];
    if ([self.defaults boolForKey:@"debug"]) NSLog(@"Renaming to: %@", newName);
    
    
    for (PackageMO *selectedPackage in [[packagesViewController packagesArrayController] selectedObjects]) {
        if ([packageNameEditor shouldRenameAll]) {
            // Get the current app
            ApplicationMO *currentApp = selectedPackage.parentApplication;
            
            // Check for existing ApplicationMO with the same title
            NSFetchRequest *getApplication = [[NSFetchRequest alloc] init];
            [getApplication setEntity:[NSEntityDescription entityForName:@"Application" inManagedObjectContext:self.managedObjectContext]];
            NSPredicate *appPred = [NSPredicate predicateWithFormat:@"munki_name == %@", newName];
            [getApplication setPredicate:appPred];
            if ([self.managedObjectContext countForFetchRequest:getApplication error:nil] > 0) {
                // Application object exists with the new name so use it
                NSArray *apps = [self.managedObjectContext executeFetchRequest:getApplication error:nil];
                ApplicationMO *app = [apps objectAtIndex:0];
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"Found ApplicationMO: %@", app.munki_name);
                selectedPackage.munki_name = newName;
                selectedPackage.parentApplication = app;
            } else {
                // No existing application objects with this name so just rename it
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"Renaming ApplicationMO %@ to %@", currentApp.munki_name, newName);
                currentApp.munki_name = newName;
                selectedPackage.munki_name = newName;
                selectedPackage.parentApplication = currentApp; // Shouldn't need this...
            }
            [getApplication release];
            
            // Get sibling packages
            NSFetchRequest *getSiblings = [[NSFetchRequest alloc] init];
            [getSiblings setEntity:[NSEntityDescription entityForName:@"Package" inManagedObjectContext:self.managedObjectContext]];
            NSPredicate *siblingPred = [NSPredicate predicateWithFormat:@"parentApplication == %@", currentApp];
            [getSiblings setPredicate:siblingPred];
            if ([self.managedObjectContext countForFetchRequest:getSiblings error:nil] > 0) {
                NSArray *siblingPackages = [self.managedObjectContext executeFetchRequest:getSiblings error:nil];
                for (PackageMO *aSibling in siblingPackages) {
                    if ([self.defaults boolForKey:@"debug"]) NSLog(@"Renaming sibling %@ to %@", aSibling.munki_name, newName);
                    aSibling.munki_name = newName;
                    aSibling.parentApplication = selectedPackage.parentApplication;
                }
            } else {
                
            }
            [getSiblings release];
            
            for (StringObjectMO *i in [selectedPackage referencingStringObjects]) {
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"Renaming packageref %@ to: %@", i.title, selectedPackage.titleWithVersion);
                i.title = selectedPackage.titleWithVersion;
                [self.managedObjectContext refreshObject:i mergeChanges:YES];
                
            }
            for (StringObjectMO *i in [selectedPackage.parentApplication referencingStringObjects]) {
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"Renaming appref %@ to: %@", i.title, selectedPackage.parentApplication.munki_name);
                i.title = selectedPackage.parentApplication.munki_name;
                [self.managedObjectContext refreshObject:i mergeChanges:YES];
                
            }

        } else {
            selectedPackage.munki_name = newName;
            for (StringObjectMO *i in [selectedPackage referencingStringObjects]) {
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"Renaming packageref %@ to: %@", i.title, selectedPackage.titleWithVersion);
                i.title = selectedPackage.titleWithVersion;
                [self.managedObjectContext refreshObject:i mergeChanges:YES];
                
            }
            for (StringObjectMO *i in [selectedPackage.parentApplication referencingStringObjects]) {
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"Renaming appref %@ to: %@", i.title, selectedPackage.parentApplication.munki_name);
                i.title = selectedPackage.parentApplication.munki_name;
                [self.managedObjectContext refreshObject:i mergeChanges:YES];
                
            }
        }
    }
    [NSApp endSheet:[packageNameEditor window]];
	[[packageNameEditor window] close];
}

- (IBAction)cancelRenamePackagesAction:(id)sender
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    [NSApp endSheet:[packageNameEditor window]];
	[[packageNameEditor window] close];
}

- (void)renameSelectedPackages
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    
    [NSApp beginSheet:[packageNameEditor window] 
	   modalForWindow:self.window modalDelegate:nil 
	   didEndSelector:nil contextInfo:nil];
    NSArray *selTitles = [[[packagesViewController packagesArrayController] selectedObjects] valueForKeyPath:@"@distinctUnionOfObjects.munki_name"];
    [packageNameEditor setChangedName:[selTitles objectAtIndex:0]];
}

- (IBAction)renameSelectedPackagesAction:sender
{
    [self renameSelectedPackages];
}

- (IBAction)renamePackageFromAdvancedEditor:(id)sender
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    
    [NSApp beginSheet:[packageNameEditor window] 
	   modalForWindow:[advancedPackageEditor window] modalDelegate:nil 
	   didEndSelector:nil contextInfo:nil];
    [packageNameEditor setChangedName:[[advancedPackageEditor pkginfoToEdit] munki_name]];
}

- (void)deleteSelectedPackages
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	
	NSArray *selectedPackages = [[packagesViewController packagesArrayController] selectedObjects];
	NSManagedObjectContext *moc = [self managedObjectContext];
	
	// Configure the dialog
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Delete"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Delete Packages"];
	if ([selectedPackages count] == 1) {
		PackageMO *singlePackage = [selectedPackages objectAtIndex:0];
		[alert setInformativeText:[NSString stringWithFormat:
								   @"Are you sure you want to delete %@ and its packageinfo file from the repository? This cannot be undone.", 
								   singlePackage.munki_name]];
	} else {
		[alert setInformativeText:[NSString stringWithFormat:
								   @"Are you sure you want to delete %lu packages and their packageinfo files from the repository? This cannot be undone.", 
								   (unsigned long)[selectedPackages count]]];
	}
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert setShowsSuppressionButton:NO];
	
	NSInteger result = [alert runModal];
	if (result == NSAlertFirstButtonReturn) {
		for (PackageMO *aPackage in selectedPackages) {
			if ([self.defaults boolForKey:@"debug"]) {
				NSLog(@"Deleting %@", [(NSURL *)aPackage.packageURL relativePath]);
				NSLog(@"Deleting %@", [(NSURL *)aPackage.packageInfoURL relativePath]);
			}
			NSArray *objectsToDelete = [NSArray arrayWithObjects:aPackage.packageURL, aPackage.packageInfoURL, nil];
			[[NSWorkspace sharedWorkspace] recycleURLs:objectsToDelete completionHandler:nil];
			[moc deleteObject:aPackage];
		}
	}
	[alert release];
}

- (IBAction)deleteSelectedPackagesAction:sender
{
	[self deleteSelectedPackages];
}

- (void)createNewCatalog
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	
	// Configure the dialog
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Create"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"New Catalog"];
    [alert setInformativeText:@"Create a new catalog with title:"];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert setShowsSuppressionButton:NO];
	NSRect textRect = NSMakeRect(0, 0, 350, 22);
	NSTextField *textField=[[NSTextField alloc] initWithFrame:textRect];
	[textField setStringValue:@"Untitled Catalog"];
    [alert setAccessoryView:textField];
	
	// Make the accessory view first responder
	[alert layout];
	[[alert window] makeFirstResponder:textField];
	
	// Display the dialog and act accordingly
    NSInteger result = [alert runModal];
    if (result == NSAlertFirstButtonReturn) {
		NSManagedObjectContext *moc = [self managedObjectContext];
        CatalogMO *catalog;
		catalog = [NSEntityDescription insertNewObjectForEntityForName:@"Catalog" inManagedObjectContext:moc];
		catalog.title = [textField stringValue];
		NSURL *catalogURL = [self.catalogsURL URLByAppendingPathComponent:catalog.title];
		[[NSFileManager defaultManager] createFileAtPath:[catalogURL relativePath] contents:nil attributes:nil];
		
		// Loop through Package managed objects
		for (PackageMO *aPackage in [self allObjectsForEntity:@"Package"]) {
			CatalogInfoMO *newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:moc];
			newCatalogInfo.package = aPackage;
			newCatalogInfo.catalog = catalog;
			newCatalogInfo.catalog.title = catalog.title;
			
			[catalog addPackagesObject:aPackage];
			[catalog addCatalogInfosObject:newCatalogInfo];
			
			PackageInfoMO *newPackageInfo = [NSEntityDescription insertNewObjectForEntityForName:@"PackageInfo" inManagedObjectContext:moc];
			newPackageInfo.catalog = catalog;
			newPackageInfo.title = [aPackage.munki_display_name stringByAppendingFormat:@" %@", aPackage.munki_version];
			newPackageInfo.package = aPackage;
			
			newCatalogInfo.isEnabledForPackageValue = NO;
			newPackageInfo.isEnabledForCatalogValue = NO;
			
		}
		
    } else if ( result == NSAlertSecondButtonReturn ) {
        
    }
	[textField release];
    [alert release];
}

- (IBAction)createNewCatalogAction:sender
{
	[self createNewCatalog];
}

- (void)enableAllPackagesForManifest
{
	ManifestMO *selectedManifest = [[manifestsArrayController selectedObjects] objectAtIndex:0];
	for (ManagedInstallMO *managedInstall in [selectedManifest managedInstalls]) {
		managedInstall.isEnabledValue = YES;
	}
}

- (IBAction)enableAllPackagesForManifestAction:sender
{
	[self enableAllPackagesForManifest];
}

- (void)disableAllPackagesForManifest
{
	ManifestMO *selectedManifest = [[manifestsArrayController selectedObjects] objectAtIndex:0];
	for (ManagedInstallMO *managedInstall in [selectedManifest managedInstalls]) {
		managedInstall.isEnabledValue = NO;
	}
}

- (IBAction)disableAllPackagesForManifestAction:sender
{
	[self disableAllPackagesForManifest];
}

# pragma mark - Modifying repository

- (IBAction)createNewRepository:sender
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	
	NSURL *newRepoURL = [self showSavePanel];
	if (newRepoURL != nil) {
		NSString *newRepoPath = [newRepoURL relativePath];
		NSFileManager *fm = [NSFileManager defaultManager];
		BOOL catalogsDirCreated = [fm createDirectoryAtPath:[newRepoPath stringByAppendingPathComponent:@"catalogs"] withIntermediateDirectories:YES attributes:nil error:nil];
		BOOL manifestsDirCreated = [fm createDirectoryAtPath:[newRepoPath stringByAppendingPathComponent:@"manifests"] withIntermediateDirectories:YES attributes:nil error:nil];
		BOOL pkgsDirCreated = [fm createDirectoryAtPath:[newRepoPath stringByAppendingPathComponent:@"pkgs"] withIntermediateDirectories:YES attributes:nil error:nil];
		BOOL pkgsinfoDirCreated = [fm createDirectoryAtPath:[newRepoPath stringByAppendingPathComponent:@"pkgsinfo"] withIntermediateDirectories:YES attributes:nil error:nil];
		if (catalogsDirCreated && manifestsDirCreated && pkgsDirCreated && pkgsinfoDirCreated) {
			[self selectRepoAtURL:newRepoURL];
		} else {
			NSLog(@"Can't create repository: %@", newRepoPath);
		}
	}
}

- (void)assimilatePackageProperties:(NSDictionary *)aPkgProps
{
	// Fetch for Application objects
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSEntityDescription *applicationEntityDescr = [NSEntityDescription entityForName:@"Application" inManagedObjectContext:moc];
	NSEntityDescription *packageEntityDescr = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc];
	
	NSFetchRequest *fetchForPackage = [[NSFetchRequest alloc] init];
	[fetchForPackage setEntity:packageEntityDescr];
	NSPredicate *pkgPredicate = [NSPredicate predicateWithFormat:
								 @"munki_name == %@ AND munki_display_name == %@ AND munki_version == %@",
								 [aPkgProps valueForKey:@"name"],
								 [aPkgProps valueForKey:@"display_name"],
								 [aPkgProps valueForKey:@"version"]];
	[fetchForPackage setPredicate:pkgPredicate];
	NSUInteger numFoundPkgs = [moc countForFetchRequest:fetchForPackage error:nil];
	if (numFoundPkgs == 1) {
		
		PackageMO *aPkg = [[moc executeFetchRequest:fetchForPackage error:nil] objectAtIndex:0];
		
		NSFetchRequest *fetchForApplications = [[NSFetchRequest alloc] init];
		[fetchForApplications setEntity:applicationEntityDescr];
		NSPredicate *applicationTitlePredicate;
		applicationTitlePredicate = [NSPredicate predicateWithFormat:@"munki_name like[cd] %@", aPkg.munki_name];
		
		[fetchForApplications setPredicate:applicationTitlePredicate];
		
		NSUInteger numFoundApplications = [moc countForFetchRequest:fetchForApplications error:nil];
		if (numFoundApplications == 0) {
			// No matching Applications found.
			NSLog(@"Assimilator found zero matching Applications for package.");
		} else if (numFoundApplications == 1) {
			ApplicationMO *existingApplication = [[moc executeFetchRequest:fetchForApplications error:nil] objectAtIndex:0];
			if ([existingApplication hasCommonDescription]) {
				if ([self.defaults boolForKey:@"UseExistingDescriptionForPackages"]) {
					aPkg.munki_description = [[existingApplication.packages anyObject] munki_description];
				}
			}
			[existingApplication addPackagesObject:aPkg];
			if ([self.defaults boolForKey:@"UseExistingDisplayNameForPackages"]) {
				aPkg.munki_display_name = existingApplication.munki_display_name;
			}
			
		} else {
			NSLog(@"Assimilator found multiple matching Applications for package. Can't decide on my own...");
		}
		[fetchForApplications release];
	}
	else {
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Can't assimilate. %lu results found for package search", (unsigned long)numFoundPkgs);
	}

	[fetchForPackage release];
}


# pragma mark - Callbacks

- (void)makepkginfoDidFinish:(NSDictionary *)pkginfoPlist
{
	// Callback from makepkginfo
    
    if (pkginfoPlist) {
        
        // Extract a name for the new pkginfo item
        NSString *name = [pkginfoPlist objectForKey:@"name"];
        NSString *version = [pkginfoPlist objectForKey:@"version"];
        NSString *newBaseName = [name stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        NSString *newNameAndVersion = [NSString stringWithFormat:@"%@-%@", newBaseName, version];
        NSString *newPkginfoTitle = [newNameAndVersion stringByAppendingPathExtension:@"plist"];
        
        // Ask the user to save
        NSURL *newPkginfoURL = [self showSavePanelForPkginfo:newPkginfoTitle];
        
        // Write the pkginfo to disk and add it to our datastore
        BOOL saved = [pkginfoPlist writeToURL:newPkginfoURL atomically:YES];
        if (saved) {
            
            // Rescan the main pkginfo dir for any newly created directories
            [self configureSourceListDirectoriesSection];
            
            // Create a scanner job but run it without an operation queue
            PkginfoScanner *scanOp = [PkginfoScanner scannerWithURL:newPkginfoURL];
            scanOp.canModify = YES;
            scanOp.delegate = self;
            [scanOp start];
            
            // Fetch the newly created package
            NSFetchRequest *fetchForPackage = [[NSFetchRequest alloc] init];
            [fetchForPackage setEntity:[NSEntityDescription entityForName:@"Package" inManagedObjectContext:self.managedObjectContext]];
            NSPredicate *pkgPred;
            pkgPred = [NSPredicate predicateWithFormat:@"packageInfoURL == %@", newPkginfoURL];
            [fetchForPackage setPredicate:pkgPred];
            
            NSUInteger numFoundPkgs = [self.managedObjectContext countForFetchRequest:fetchForPackage error:nil];
            if (numFoundPkgs == 0) {
                // Didn't find anything
            }
            else if (numFoundPkgs == 1) {
                PackageMO *createdPkg = [[self.managedObjectContext executeFetchRequest:fetchForPackage error:nil] objectAtIndex:0];
                
                // Add the newly created package to any needed containers
                [self configureContainersForPackage:createdPkg];
                
                // Select the newly created package
                [[packagesViewController packagesArrayController] setSelectedObjects:[NSArray arrayWithObject:createdPkg]];
            }
            else {
                // Found multiple matches for a single URL
            }
            [fetchForPackage release];
        }
    } else {
        NSLog(@"makepkginfo failed!");
        NSAlert *makepkginfoFailedAlert = [NSAlert alertWithMessageText:@"Invalid pkginfo"
                                                          defaultButton:@"OK"
                                                        alternateButton:@""
                                                            otherButton:@""
                                              informativeTextWithFormat:@"Failed to create a pkginfo."];
        [makepkginfoFailedAlert runModal];
    }
}

- (void)installsItemDidFinish:(NSDictionary *)pkginfoPlist
{
	NSArray *selectedPackages = [[packagesViewController packagesArrayController] selectedObjects];
	NSDictionary *installsItemProps = [[pkginfoPlist objectForKey:@"installs"] objectAtIndex:0];
	if (installsItemProps != nil) {
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Got new dictionary from makepkginfo");
		for (PackageMO *aPackage in selectedPackages) {
			InstallsItemMO *newInstallsItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallsItem" inManagedObjectContext:self.managedObjectContext];
			newInstallsItem.munki_CFBundleIdentifier = [installsItemProps objectForKey:@"CFBundleIdentifier"];
			newInstallsItem.munki_CFBundleName = [installsItemProps objectForKey:@"CFBundleName"];
			newInstallsItem.munki_CFBundleShortVersionString = [installsItemProps objectForKey:@"CFBundleShortVersionString"];
			newInstallsItem.munki_path = [installsItemProps objectForKey:@"path"];
			newInstallsItem.munki_type = [installsItemProps objectForKey:@"type"];
			newInstallsItem.munki_md5checksum = [installsItemProps objectForKey:@"md5checksum"];
			[aPackage addInstallsItemsObject:newInstallsItem];
		}
	} else {
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Error. Got nil from makepkginfo");
	}
}

- (void)scannerDidProcessPkginfo
{
	//[self arrangeCatalogs];
}

- (void)enableAllBindings
{
    [self.allPackagesArrayController setManagedObjectContext:[self managedObjectContext]];
    [self.allPackagesArrayController setEntityName:@"Package"];
    if ([self.allPackagesArrayController fetchWithRequest:nil merge:YES error:nil]) {
        [self.allPackagesArrayController setAutomaticallyPreparesContent:YES];
        [self.allPackagesArrayController setSelectionIndex:0];
    }
    [[packagesViewController packagesArrayController] setManagedObjectContext:[self managedObjectContext]];
    [[packagesViewController packagesArrayController] setEntityName:@"Package"];
    if ([[packagesViewController packagesArrayController] fetchWithRequest:nil merge:YES error:nil]) {
        [[packagesViewController packagesArrayController] setAutomaticallyPreparesContent:YES];
        [[packagesViewController packagesArrayController] setSelectionIndex:0];
    }
    [[packagesViewController directoriesTreeController] setManagedObjectContext:[self managedObjectContext]];
    [[packagesViewController directoriesTreeController] setEntityName:@"PackageSourceListItem"];
    if ([[packagesViewController directoriesTreeController] fetchWithRequest:nil merge:YES error:nil]) {
        [[packagesViewController directoriesTreeController] setAutomaticallyPreparesContent:YES];
        [[packagesViewController directoriesOutlineView] expandItem:nil expandChildren:YES];
        NSUInteger defaultIndexes[] = {0,0};
        [[packagesViewController directoriesTreeController] setSelectionIndexPath:[NSIndexPath indexPathWithIndexes:defaultIndexes length:2]];
    }
    [self.packageInfosArrayController setManagedObjectContext:[self managedObjectContext]];
    [self.packageInfosArrayController setEntityName:@"PackageInfo"];
    if ([self.packageInfosArrayController fetchWithRequest:nil merge:YES error:nil]) {
        [self.packageInfosArrayController setAutomaticallyPreparesContent:YES];
        [self.packageInfosArrayController setSelectionIndex:0];
    }
    [self.manifestsArrayController setManagedObjectContext:[self managedObjectContext]];
    [self.manifestsArrayController setEntityName:@"Manifest"];
    if (![self.manifestsArrayController fetchWithRequest:nil merge:YES error:nil]) {
        [self.manifestsArrayController setAutomaticallyPreparesContent:YES];
        [self.manifestsArrayController setSelectionIndex:0];
    }
    [self.applicationsArrayController setManagedObjectContext:[self managedObjectContext]];
    [self.applicationsArrayController setEntityName:@"Application"];
    if (![self.applicationsArrayController fetchWithRequest:nil merge:YES error:nil]) {
        [self.applicationsArrayController setAutomaticallyPreparesContent:YES];
        [self.applicationsArrayController setSelectionIndex:0];
    }
    [self.allCatalogsArrayController setManagedObjectContext:[self managedObjectContext]];
    [self.allCatalogsArrayController setEntityName:@"Catalog"];
    if (![self.allCatalogsArrayController fetchWithRequest:nil merge:YES error:nil]) {
        [self.allCatalogsArrayController setAutomaticallyPreparesContent:YES];
        [self.allCatalogsArrayController setSelectionIndex:0];
    }
}

- (void)disableAllBindings
{
    [self.allCatalogsArrayController setManagedObjectContext:nil];
    [self.applicationsArrayController setManagedObjectContext:nil];
    [self.packageInfosArrayController setManagedObjectContext:nil];
    [self.allPackagesArrayController setManagedObjectContext:nil];
    [[packagesViewController packagesArrayController] setManagedObjectContext:nil];
    [[packagesViewController directoriesTreeController] setManagedObjectContext:nil];
    [self.manifestsArrayController setManagedObjectContext:nil];
}

- (void)relationshipScannerDidFinish:(NSString *)mode
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    if ([mode isEqualToString:@"pkgs"]) {
        
        
    } else if ([mode isEqualToString:@"manifests"]) {
        
        // Configure packages view source list
        [[packagesViewController directoriesOutlineView] expandItem:nil expandChildren:YES];
        NSUInteger defaultIndexes[] = {0,0};
        [[packagesViewController directoriesTreeController] setSelectionIndexPath:[NSIndexPath indexPathWithIndexes:defaultIndexes length:2]];
    }
}

- (void)mergeChanges:(NSNotification*)notification
{
	NSAssert([NSThread mainThread], @"Not on the main thread");
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"Merging changes in main thread");
	}
	[[self managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
}


# pragma mark - Advanced package editor IBActions

- (void)packageEditorDidFinish:(id)sender returnCode:(int)returnCode object:(id)object
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    [self.managedObjectContext refreshObject:[advancedPackageEditor pkginfoToEdit] mergeChanges:YES];
    [[[self managedObjectContext] undoManager] endUndoGrouping];
    if (returnCode == NSOKButton) return;
    [[[self managedObjectContext] undoManager] undo];
}

- (IBAction)selectNextPackageForEditing:(id)sender
{
    // Commit any changes
    [advancedPackageEditor commitChangesToCurrentPackage];
    
    // Change selection
    NSIndexSet *currentIndexes = [[packagesViewController packagesArrayController] selectionIndexes];
    if ([currentIndexes lastIndex] < [[[packagesViewController packagesArrayController] arrangedObjects] count] - 1) {
        [[packagesViewController packagesArrayController] setSelectionIndex:[currentIndexes lastIndex]+1];
        
        // Populate new values
        PackageMO *object = [[[packagesViewController packagesArrayController] selectedObjects] objectAtIndex:0];
        [advancedPackageEditor setPkginfoToEdit:object];
        [advancedPackageEditor setDefaultValuesFromPackage:object];
    }
}

- (IBAction)selectPreviousPackageForEditing:(id)sender
{
    // Commit any changes
    [advancedPackageEditor commitChangesToCurrentPackage];
    
    // Change selection
    NSIndexSet *currentIndexes = [[packagesViewController packagesArrayController] selectionIndexes];
    if ([currentIndexes lastIndex] > 0) {
        [[packagesViewController packagesArrayController] setSelectionIndex:([currentIndexes lastIndex] - 1)];
        
        // Populate new values
        PackageMO *object = [[[packagesViewController packagesArrayController] selectedObjects] objectAtIndex:0];
        [advancedPackageEditor setPkginfoToEdit:object];
        [advancedPackageEditor setDefaultValuesFromPackage:object];
    }
}

- (IBAction)getInfoAction:(id)sender
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    
    if (currentWholeView == [packagesViewController view]) {
        
        PackageMO *object = [[[packagesViewController packagesArrayController] selectedObjects] lastObject];
        if (!object) return;
        
        [[[self managedObjectContext] undoManager] beginUndoGrouping];
        [[[self managedObjectContext] undoManager] setActionName:[NSString stringWithFormat:@"Editing \"%@\"", [object titleWithVersion]]];
        
        [advancedPackageEditor beginEditSessionWithObject:object delegate:self];
        
        if ([sender isKindOfClass:[NSButton class]]) {
            switch ([sender tag]) {
                case 0: // Catalogs
                    [[advancedPackageEditor mainTabView] selectTabViewItemAtIndex:0];
                    break;
                case 1: // Receipts
                    [[advancedPackageEditor mainTabView] selectTabViewItemAtIndex:1];
                    break;
                case 2: // Installs
                    [[advancedPackageEditor mainTabView] selectTabViewItemAtIndex:1];
                    break;
                case 3: // Items to copy
                    [[advancedPackageEditor mainTabView] selectTabViewItemAtIndex:3];
                    break;
                case 4: // Requires
                    [[advancedPackageEditor mainTabView] selectTabViewItemAtIndex:2];
                    break;
                case 5: // Update for
                    [[advancedPackageEditor mainTabView] selectTabViewItemAtIndex:2];
                    break;
                case 6: // Installer Choices XML
                    [[advancedPackageEditor mainTabView] selectTabViewItemAtIndex:3];
                    break;
                case 7: // Blocking Applications
                    [[advancedPackageEditor mainTabView] selectTabViewItemAtIndex:3];
                    break;
                case 8: // Architectures
                    [[advancedPackageEditor mainTabView] selectTabViewItemAtIndex:3];
                    break;
                case 99: // Generic -> select the first tab view item
                    [[advancedPackageEditor mainTabView] selectTabViewItemAtIndex:0];
                    break;
                default:
                    [[advancedPackageEditor mainTabView] selectTabViewItemAtIndex:0];
                    break;
            }
        } else {
            [[advancedPackageEditor mainTabView] selectTabViewItemAtIndex:0];
        }
    }
}


# pragma mark - Manifest detail view IBActions

- (void)newPredicateSheetDidEnd:(id)sheet returnCode:(int)returnCode object:(id)object
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    if (returnCode == NSCancelButton) return;
    
    NSString *thePredicateString = nil;
    if ([predicateEditor.tabView selectedTabViewItem] == predicateEditor.predicateEditorTabViewItem) {
        thePredicateString = [predicateEditor.predicate description];
    } else {
        thePredicateString = [predicateEditor.customTextField stringValue];
    }
    
    NSArray *selectedManifests = [manifestsArrayController selectedObjects];
    NSArray *selectedConditionalItems = [[manifestDetailViewController conditionsTreeController] selectedObjects];
    
    for (ManifestMO *selectedManifest in selectedManifests) {
        if ([[[manifestDetailViewController conditionsTreeController] selectedObjects] count] == 0) {
            ConditionalItemMO *newConditionalItem = [NSEntityDescription insertNewObjectForEntityForName:@"ConditionalItem" inManagedObjectContext:self.managedObjectContext];
            newConditionalItem.munki_condition = thePredicateString;
            newConditionalItem.manifest = selectedManifest;
        } else {
            for (id selectedConditionalItem in selectedConditionalItems) {
                ConditionalItemMO *newConditionalItem = [NSEntityDescription insertNewObjectForEntityForName:@"ConditionalItem" inManagedObjectContext:self.managedObjectContext];
                newConditionalItem.munki_condition = thePredicateString;
                newConditionalItem.manifest = selectedManifest;
                newConditionalItem.parent = selectedConditionalItem;
            }
        }
        [self.managedObjectContext refreshObject:selectedManifest mergeChanges:YES];
    }
}

- (void)editPredicateSheetDidEnd:(id)sheet returnCode:(int)returnCode object:(id)object
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    if (returnCode == NSCancelButton) return;
    
    NSString *thePredicateString = nil;
    if ([predicateEditor.tabView selectedTabViewItem] == predicateEditor.predicateEditorTabViewItem) {
        thePredicateString = [predicateEditor.predicate description];
    } else {
        thePredicateString = [predicateEditor.customTextField stringValue];
    }
    
    ManifestMO *selectedManifest = [[manifestsArrayController selectedObjects] objectAtIndex:0];
    predicateEditor.conditionToEdit.munki_condition = thePredicateString;
    [self.managedObjectContext refreshObject:selectedManifest mergeChanges:YES];
}

- (IBAction)addNewConditionalItemAction:(id)sender
{
    predicateEditor.conditionToEdit = nil;
    [predicateEditor resetPredicateToDefault];
    
    [NSApp beginSheet:[predicateEditor window] 
	   modalForWindow:self.window 
        modalDelegate:self 
	   didEndSelector:@selector(newPredicateSheetDidEnd:returnCode:object:) 
          contextInfo:nil];
}

- (IBAction)editConditionalItemAction:(id)sender
{
    ConditionalItemMO *selectedCondition = [[manifestDetailViewController.conditionsTreeController selectedObjects] lastObject];
    
    @try {
        NSPredicate *predicateToEdit = [NSPredicate predicateWithFormat:selectedCondition.munki_condition];
        if (predicateToEdit != nil) {
            predicateEditor.conditionToEdit = selectedCondition;
            predicateEditor.customPredicateString = selectedCondition.munki_condition;
            predicateEditor.predicate = [NSPredicate predicateWithFormat:selectedCondition.munki_condition];
            
            [NSApp beginSheet:[predicateEditor window] 
               modalForWindow:self.window 
                modalDelegate:self 
               didEndSelector:@selector(editPredicateSheetDidEnd:returnCode:object:) 
                  contextInfo:nil];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        
    }
    
}

- (IBAction)removeConditionalItemAction:(id)sender
{
    ManifestMO *selectedManifest = [[manifestsArrayController selectedObjects] objectAtIndex:0];
    
    for (ConditionalItemMO *aConditionalItem in [manifestDetailViewController.conditionsTreeController selectedObjects]) {
        [self.managedObjectContext deleteObject:aConditionalItem];
    }
    [self.managedObjectContext refreshObject:selectedManifest mergeChanges:YES];
}

- (IBAction)addNewIncludedManifestAction:(id)sender
{
    [NSApp beginSheet:[selectManifestsWindowController window] 
	   modalForWindow:self.window modalDelegate:nil 
	   didEndSelector:nil contextInfo:nil];
    
    ManifestMO *selectedManifest = [[manifestsArrayController selectedObjects] objectAtIndex:0];
    NSMutableArray *tempPredicates = [[NSMutableArray alloc] init];
    
    for (StringObjectMO *aNestedManifest in [selectedManifest includedManifestsFaster]) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"title != %@", aNestedManifest.title];
        [tempPredicates addObject:newPredicate];
    }
    NSPredicate *denySelfPred = [NSPredicate predicateWithFormat:@"title != %@", selectedManifest.title];
    [tempPredicates addObject:denySelfPred];
    NSPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates:tempPredicates];
    //[[selectManifestsWindowController manifestsArrayController] setFilterPredicate:compPred];
    [selectManifestsWindowController setOriginalPredicate:compPred];
    [tempPredicates release];
}

- (IBAction)removeIncludedManifestAction:(id)sender
{
    ManifestMO *selectedManifest = [[manifestsArrayController selectedObjects] objectAtIndex:0];
    
    for (StringObjectMO *anIncludedManifest in [manifestDetailViewController.includedManifestsController selectedObjects]) {
        [self.managedObjectContext deleteObject:anIncludedManifest];
    }
    [self.managedObjectContext refreshObject:selectedManifest mergeChanges:YES];
}

- (void)addNewManagedInstallSheetDidEnd:(id)sheet returnCode:(int)returnCode object:(id)object
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    if (returnCode == NSCancelButton) return;
    [self processAddItemsAction:sheet];
}

- (IBAction)addNewManagedInstallAction:(id)sender
{
    self.addItemsType = @"managedInstall";
    
    [NSApp beginSheet:[addItemsWindowController window] 
	   modalForWindow:self.window modalDelegate:self 
	   didEndSelector:@selector(addNewManagedInstallSheetDidEnd:returnCode:object:) contextInfo:nil];
    
    ManifestMO *selectedManifest = [[manifestsArrayController selectedObjects] objectAtIndex:0];
    NSMutableArray *tempPredicates = [[NSMutableArray alloc] init];
    
    for (StringObjectMO *aManagedInstall in [selectedManifest managedInstallsFaster]) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"munki_name != %@", aManagedInstall.title];
        [tempPredicates addObject:newPredicate];
    }
    NSPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates:tempPredicates];
    [[addItemsWindowController groupedPkgsArrayController] setFilterPredicate:compPred];
    [[addItemsWindowController groupedPkgsArrayController] setSelectedObjects:nil];
    [[addItemsWindowController individualPkgsArrayController] setFilterPredicate:compPred];
    [[addItemsWindowController individualPkgsArrayController] setSelectedObjects:nil];
    [tempPredicates release];
}

- (IBAction)removeManagedInstallAction:(id)sender
{
    ManifestMO *selectedManifest = [[manifestsArrayController selectedObjects] objectAtIndex:0];
    
    for (StringObjectMO *aManagedInstall in [manifestDetailViewController.managedInstallsController selectedObjects]) {
        [self.managedObjectContext deleteObject:aManagedInstall];
    }
    [self.managedObjectContext refreshObject:selectedManifest mergeChanges:YES];
}

- (IBAction)addNewManagedUninstallAction:(id)sender
{
    self.addItemsType = @"managedUninstall";
    
    [NSApp beginSheet:[addItemsWindowController window] 
	   modalForWindow:self.window modalDelegate:self 
	   didEndSelector:@selector(addNewManagedInstallSheetDidEnd:returnCode:object:) contextInfo:nil];
    
    ManifestMO *selectedManifest = [[manifestsArrayController selectedObjects] objectAtIndex:0];
    NSMutableArray *tempPredicates = [[NSMutableArray alloc] init];
    
    for (StringObjectMO *aManagedUninstall in [selectedManifest managedUninstallsFaster]) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"munki_name != %@", aManagedUninstall.title];
        [tempPredicates addObject:newPredicate];
    }
    NSPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates:tempPredicates];
    [[addItemsWindowController groupedPkgsArrayController] setFilterPredicate:compPred];
    [[addItemsWindowController individualPkgsArrayController] setFilterPredicate:compPred];
    [tempPredicates release];
}

- (IBAction)removeManagedUninstallAction:(id)sender
{
    ManifestMO *selectedManifest = [[manifestsArrayController selectedObjects] objectAtIndex:0];
    
    for (StringObjectMO *aManagedUninstall in [manifestDetailViewController.managedUninstallsController selectedObjects]) {
        [self.managedObjectContext deleteObject:aManagedUninstall];
    }
    [self.managedObjectContext refreshObject:selectedManifest mergeChanges:YES];
}

- (IBAction)addNewManagedUpdateAction:(id)sender
{
    self.addItemsType = @"managedUpdate";
    
    [NSApp beginSheet:[addItemsWindowController window] 
	   modalForWindow:self.window modalDelegate:self 
	   didEndSelector:@selector(addNewManagedInstallSheetDidEnd:returnCode:object:) contextInfo:nil];
    
    ManifestMO *selectedManifest = [[manifestsArrayController selectedObjects] objectAtIndex:0];
    NSMutableArray *tempPredicates = [[NSMutableArray alloc] init];
    
    for (StringObjectMO *aManagedUpdate in [selectedManifest managedUpdatesFaster]) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"munki_name != %@", aManagedUpdate.title];
        [tempPredicates addObject:newPredicate];
    }
    NSPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates:tempPredicates];
    [[addItemsWindowController groupedPkgsArrayController] setFilterPredicate:compPred];
    [[addItemsWindowController individualPkgsArrayController] setFilterPredicate:compPred];
    [tempPredicates release];
}

- (IBAction)removeManagedUpdateAction:(id)sender
{
    ManifestMO *selectedManifest = [[manifestsArrayController selectedObjects] objectAtIndex:0];
    
    for (StringObjectMO *aManagedUpdate in [manifestDetailViewController.managedUpdatesController selectedObjects]) {
        [self.managedObjectContext deleteObject:aManagedUpdate];
    }
    [self.managedObjectContext refreshObject:selectedManifest mergeChanges:YES];
}

- (IBAction)addNewOptionalInstallAction:(id)sender
{
    self.addItemsType = @"optionalInstall";
    
    [NSApp beginSheet:[addItemsWindowController window] 
	   modalForWindow:self.window modalDelegate:self 
	   didEndSelector:@selector(addNewManagedInstallSheetDidEnd:returnCode:object:) contextInfo:nil];
    
    ManifestMO *selectedManifest = [[manifestsArrayController selectedObjects] objectAtIndex:0];
    NSMutableArray *tempPredicates = [[NSMutableArray alloc] init];
    
    for (StringObjectMO *anOptionalInstall in [selectedManifest optionalInstallsFaster]) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"munki_name != %@", anOptionalInstall.title];
        [tempPredicates addObject:newPredicate];
    }
    NSPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates:tempPredicates];
    [[addItemsWindowController groupedPkgsArrayController] setFilterPredicate:compPred];
    [[addItemsWindowController individualPkgsArrayController] setFilterPredicate:compPred];
    [tempPredicates release];
}

- (IBAction)removeOptionalInstallAction:(id)sender
{
    ManifestMO *selectedManifest = [[manifestsArrayController selectedObjects] objectAtIndex:0];
    
    for (StringObjectMO *anOptionalInstall in [manifestDetailViewController.optionalInstallsController selectedObjects]) {
        [self.managedObjectContext deleteObject:anOptionalInstall];
    }
    [self.managedObjectContext refreshObject:selectedManifest mergeChanges:YES];
}

- (IBAction)processAddNestedManifestAction:(id)sender
{
    NSString *selectedTabViewLabel = [[[selectManifestsWindowController tabView] selectedTabViewItem] label];
    for (ManifestMO *selectedManifest in [manifestsArrayController selectedObjects]) {
        if ([selectedTabViewLabel isEqualToString:@"Existing"]) {
            if ([self.defaults boolForKey:@"debug"]) NSLog(@"Adding nested manifest in Existing mode");
            for (ManifestMO *aManifest in [[selectManifestsWindowController manifestsArrayController] selectedObjects]) {
                StringObjectMO *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:self.managedObjectContext];
                newItem.title = aManifest.title;
                newItem.typeString = @"includedManifest";
                newItem.indexInNestedManifestValue = [selectedManifest.includedManifestsFaster count];
                [selectedManifest addIncludedManifestsFasterObject:newItem];
            }
        } else if ([selectedTabViewLabel isEqualToString:@"Custom"]) {
            if ([self.defaults boolForKey:@"debug"]) NSLog(@"Adding nested manifest in Custom mode");
            StringObjectMO *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:self.managedObjectContext];
            NSString *newTitle = [[selectManifestsWindowController customValueTextField] stringValue];
            newItem.title = newTitle;
            newItem.typeString = @"includedManifest";
            newItem.indexInNestedManifestValue = [selectedManifest.includedManifestsFaster count];
            [selectedManifest addIncludedManifestsFasterObject:newItem];
        }
        // Need to refresh fetched properties
        [self.managedObjectContext refreshObject:selectedManifest mergeChanges:YES];
    }
    [NSApp endSheet:[selectManifestsWindowController window]];
	[[selectManifestsWindowController window] close];
}


- (void)processAddItemsAction:(id)sender
{
    for (ManifestMO *selectedManifest in [manifestsArrayController selectedObjects]) {
        for (StringObjectMO *selectedItem in [addItemsWindowController selectionAsStringObjects]) {
            selectedItem.typeString = self.addItemsType;
            if ([self.addItemsType isEqualToString:@"managedInstall"]) {
                [selectedManifest addManagedInstallsFasterObject:selectedItem];
            }
            else if ([self.addItemsType isEqualToString:@"managedUninstall"]) {
                [selectedManifest addManagedUninstallsFasterObject:selectedItem];
            }
            else if ([self.addItemsType isEqualToString:@"managedUpdate"]) {
                [selectedManifest addManagedUpdatesFasterObject:selectedItem];
            }
            else if ([self.addItemsType isEqualToString:@"optionalInstall"]) {
                [selectedManifest addOptionalInstallsFasterObject:selectedItem];
            }
        }
        // Need to refresh fetched properties
        [self.managedObjectContext refreshObject:selectedManifest mergeChanges:YES];
	}
	[NSApp endSheet:[addItemsWindowController window]];
	[[addItemsWindowController window] close];
}


- (IBAction)cancelAddNestedManifestsAction:sender
{
	[NSApp endSheet:[selectManifestsWindowController window]];
	[[selectManifestsWindowController window] close];
}

# pragma mark - NSUndoManager notifications

- (void)undoManagerDidUndo:(id)sender
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
}


# pragma mark - pkginfo

- (void)setupCopyOperation:(FileCopyOperation *)copyOp withDependingOperation:(MunkiOperation *)depOp
{
    [depOp addDependency:copyOp];
    copyOp.delegate = self;
}

- (void)setupMakepkginfoOperation:(MunkiOperation *)theOp withDependingOperation:(RelationshipScanner *)relScan
{
    [relScan addDependency:theOp];
    theOp.delegate = self;
}

- (IBAction)addNewPackage:sender
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	
	if ([self makepkginfoInstalled]) {
		NSArray *filesToAdd = [self chooseFilesForMakepkginfo];
		if (filesToAdd) {
			if ([self.defaults boolForKey:@"debug"]) NSLog(@"Adding %lu files to repository", (unsigned long)[filesToAdd count]);
			
            [self disableAllBindings];
            
            RelationshipScanner *packageRelationships = [RelationshipScanner pkginfoScanner];
            packageRelationships.delegate = self;
            
            NSMutableArray *operationsToAdd = [[[NSMutableArray alloc] init] autorelease];
			for (NSURL *fileToAdd in filesToAdd) {
				if (fileToAdd != nil) {
                    MunkiOperation *theOp;
                    
                    if (![[fileToAdd relativePath] hasPrefix:[self.repoURL relativePath]]) {
                        if (([self.defaults boolForKey:@"CopyPkgsToRepo"]) && 
                            ([[NSFileManager defaultManager] fileExistsAtPath:[self.pkgsURL relativePath]])) {
                            if ([self.defaults boolForKey:@"debug"])
                                NSLog(@"%@ not within %@ -> Should copy", [fileToAdd relativePath], [self.repoURL relativePath]);
                            NSURL *newTarget = [self showSavePanelForCopyOperation:[[fileToAdd relativePath] lastPathComponent]];
                            if (newTarget) {
                                FileCopyOperation *copyOp = [FileCopyOperation fileCopySourceURL:fileToAdd toTargetURL:newTarget];
                                theOp = [MunkiOperation makepkginfoOperationWithSource:newTarget];
                                [self setupCopyOperation:copyOp withDependingOperation:theOp];
                                [self setupMakepkginfoOperation:theOp withDependingOperation:packageRelationships];
                                [operationsToAdd addObject:copyOp];
                                [operationsToAdd addObject:theOp];
                            } else {
                                if ([self.defaults boolForKey:@"debug"])
                                    NSLog(@"User chose to cancel the copy operation for %@. Bailing out...", [fileToAdd relativePath]);
                            }
                            
                        } else {
                            theOp = [MunkiOperation makepkginfoOperationWithSource:fileToAdd];
                            [self setupMakepkginfoOperation:theOp withDependingOperation:packageRelationships];
                            [operationsToAdd addObject:theOp];
                        }
                        
                    } else {
                        theOp = [MunkiOperation makepkginfoOperationWithSource:fileToAdd];
                        [self setupMakepkginfoOperation:theOp withDependingOperation:packageRelationships];
                        [operationsToAdd addObject:theOp];
                    }
				}
			}
            if ([operationsToAdd count] > 0) {
                [self.operationQueue addOperations:operationsToAdd waitUntilFinished:NO];
                [self.operationQueue addOperation:packageRelationships];
                NSBlockOperation *enableBindingsOp = [NSBlockOperation blockOperationWithBlock:^{
                    [self performSelectorOnMainThread:@selector(enableAllBindings) withObject:nil waitUntilDone:YES];
                }];
                [enableBindingsOp addDependency:packageRelationships];
                [self.operationQueue addOperation:enableBindingsOp];
                [self showProgressPanel];
            } else {
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"Re-enabling all bindings...");
                NSBlockOperation *enableBindingsOp = [NSBlockOperation blockOperationWithBlock:^{
                    [self performSelectorOnMainThread:@selector(enableAllBindings) withObject:nil waitUntilDone:YES];
                }];
                [self.operationQueue addOperation:enableBindingsOp];
            }
		}
	} else {
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Can't find %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"makepkginfoPath"]);
	}
}


- (IBAction)addNewInstallsItem:sender
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	if ([self makepkginfoInstalled]) {
		NSArray *filesToAdd = [self chooseFiles];
		if (filesToAdd) {
			if ([self.defaults boolForKey:@"debug"]) NSLog(@"Adding %lu installs items", (unsigned long)[filesToAdd count]);
			for (NSURL *fileToAdd in filesToAdd) {
				if (fileToAdd != nil) {
					MunkiOperation *theOp = [MunkiOperation installsItemFromURL:fileToAdd];
					theOp.delegate = self;
					[self.operationQueue addOperation:theOp];
				}
			}
			[self showProgressPanel];
		}
	} else {
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Can't find %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"makepkginfoPath"]);
	}
}

# pragma mark -
# pragma mark Writing to the repository

- (void)updateCatalogs
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	
	// Run makecatalogs against the current repo
	if ([self makecatalogsInstalled]) {
		
		MunkiOperation *op = [MunkiOperation makecatalogsOperationWithTarget:self.repoURL];
		op.delegate = self;
		[self.operationQueue addOperation:op];
		[self showProgressPanel];
		
	} else {
		NSLog(@"Can't find %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"makecatalogsPath"]);
	}
}

- (IBAction)updateCatalogs:sender
{
	//[self updateCatalogs];
	MunkiOperation *op = [[[MunkiOperation alloc] initWithCommand:@"makecatalogs" targetURL:self.repoURL arguments:nil] autorelease];
	op.delegate = self;
	[self.operationQueue addOperation:op];
	[self showProgressPanel];
}


- (void)writePackagePropertyListsToDisk
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"Was asked to write package property lists to disk");
	}
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSEntityDescription *packageEntityDescr = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc];
	
    // ===========================================
	// Get all packages and check them for changes
    // ===========================================
	NSArray *allPackages;
	NSFetchRequest *getAllPackages = [[NSFetchRequest alloc] init];
	[getAllPackages setEntity:packageEntityDescr];
	allPackages = [moc executeFetchRequest:getAllPackages error:nil];
	
	for (PackageMO *aPackage in allPackages) {
        
        if ([self.defaults boolForKey:@"debug"]) {
            NSLog(@"Checking pkginfo %@", [(NSURL *)aPackage.packageInfoURL lastPathComponent]);
        }
        
        /*
         Note!
         
         Pkginfo files might contain custom keys added
         by the user or not yet supported by MunkiAdmin. 
         We need to be extra careful not to touch those.
        */
        
        // ===========================================
        // Read the current pkginfo from disk
        // ===========================================
		NSDictionary *infoDictOnDisk = [NSDictionary dictionaryWithContentsOfURL:(NSURL *)aPackage.packageInfoURL];
		NSArray *sortedOriginalKeys = [[infoDictOnDisk allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
        
        // ===========================================
        // Get the PackageMO as a dictionary
        // ===========================================
        NSDictionary *infoDictFromPackage = [aPackage pkgInfoDictionary];
		NSArray *sortedPackageKeys = [[infoDictFromPackage allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
		
        // ===========================================
        // Check for differences in key arrays and log them
        // ===========================================
        NSSet *originalKeysSet = [NSSet setWithArray:sortedOriginalKeys];
        NSSet *newKeysSet = [NSSet setWithArray:sortedPackageKeys];
        NSArray *keysToDelete = [NSArray arrayWithObjects:
                                 @"blocking_applications",
                                 @"description",
                                 @"display_name",
                                 @"force_install_after_date",
                                 @"installed_size",
                                 @"installer_item_hash",
                                 @"installer_item_location",
                                 @"installer_item_size",
                                 @"installer_type",
                                 @"installer_item_size",
                                 @"installer_item_size",
                                 @"maximum_os_version",
                                 @"minimum_munki_version",
                                 @"minimum_os_version",
                                 @"notes",
                                 @"package_path",
                                 @"preinstall_script",
                                 @"preuninstall_script",
                                 @"postinstall_script",
                                 @"postuninstall_script",
                                 @"RestartAction",
                                 @"supported_architectures",
                                 @"uninstall_method",
                                 @"uninstaller_item_location",
                                 @"uninstall_script",
                                 @"version",
                                 nil];
        
        // Determine which keys were removed
        NSMutableSet *removedItems = [NSMutableSet setWithSet:originalKeysSet];
        [removedItems minusSet:newKeysSet];
        
        // Determine which keys were added
        NSMutableSet *addedItems = [NSMutableSet setWithSet:newKeysSet];
        [addedItems minusSet:originalKeysSet];
        
        if ([self.defaults boolForKey:@"debug"]) {
            for (NSString *aKey in [removedItems allObjects]) {
                if (![keysToDelete containsObject:aKey]) {
                    NSLog(@"Key change: \"%@\" found in original pkginfo. Keeping it.", aKey);
                } else {
                    NSLog(@"Key change: \"%@\" deleted by MunkiAdmin", aKey);
                }
                
            }
            for (NSString *aKey in [addedItems allObjects]) {
                NSLog(@"Key change: \"%@\" added by MunkiAdmin", aKey);
            }
        }
        
        // ===========================================
        // Create a new dictionary by merging
        // the original and the new one.
        // 
        // This will be written to disk
        // ===========================================
		NSMutableDictionary *mergedInfoDict = [NSMutableDictionary dictionaryWithDictionary:infoDictOnDisk];
		[mergedInfoDict addEntriesFromDictionary:[aPackage pkgInfoDictionary]];
        
        // ===========================================
        // Remove keys that were deleted by user
        // ===========================================
        for (NSString *aKey in keysToDelete) {
            if (([infoDictFromPackage valueForKey:aKey] == nil) && 
                ([infoDictOnDisk valueForKey:aKey] != nil)) {
                [mergedInfoDict removeObjectForKey:aKey];
            }
        }
        
        // ===========================================
        // Key arrays already differ.
        // User has added new information
        // ===========================================
        NSArray *sortedMergedKeys = [[mergedInfoDict allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
		if (![sortedOriginalKeys isEqualToArray:sortedMergedKeys]) {
			if ([self.defaults boolForKey:@"debug"]) NSLog(@"Keys differ. Writing new pkginfo: %@", [(NSURL *)aPackage.packageInfoURL relativePath]);
			[mergedInfoDict writeToURL:(NSURL *)aPackage.packageInfoURL atomically:YES];
		}
        
        // ===========================================
        // Check for value changes
        // ===========================================
        else {
			/*if ([self.defaults boolForKey:@"debug"]) {
                NSLog(@"%@ No changes in key array. Checking for value changes.", [(NSURL *)aPackage.packageInfoURL lastPathComponent]);
            }*/
            if (![mergedInfoDict isEqualToDictionary:infoDictOnDisk]) {
				if ([self.defaults boolForKey:@"debug"]) {
                    NSLog(@"Values differ. Writing new pkginfo: %@", [(NSURL *)aPackage.packageInfoURL relativePath]);
                }
				[mergedInfoDict writeToURL:(NSURL *)aPackage.packageInfoURL atomically:YES];
			} else {
				if ([self.defaults boolForKey:@"debug"]) {
                    NSLog(@"No changes detected");
                }
			}
		}
	}
	[getAllPackages release];
	
}

- (void)writeManifestPropertyListsToDisk
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"Was asked to write manifest property lists to disk");
	}
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSEntityDescription *packageEntityDescr = [NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:moc];
	
	// Get all packages and check them for changes
	NSArray *allManifests;
	NSFetchRequest *getAllManifests = [[NSFetchRequest alloc] init];
	[getAllManifests setEntity:packageEntityDescr];
	allManifests = [moc executeFetchRequest:getAllManifests error:nil];
	
	for (ManifestMO *aManifest in allManifests) {
		
		NSDictionary *infoDictOnDisk = [NSDictionary dictionaryWithContentsOfURL:(NSURL *)aManifest.manifestURL];
		NSMutableDictionary *mergedInfoDict = [NSMutableDictionary dictionaryWithDictionary:infoDictOnDisk];
		[mergedInfoDict addEntriesFromDictionary:[aManifest manifestInfoDictionary]];
		
		if (![mergedInfoDict isEqualToDictionary:infoDictOnDisk]) {
			NSLog(@"Changes detected in %@. Writing new manifest to disk", [(NSURL *)aManifest.manifestURL relativePath]);
			[mergedInfoDict writeToURL:(NSURL *)aManifest.manifestURL atomically:NO];
		} else {
			//NSLog(@"No changes detected in %@", [(NSURL *)aManifest.manifestURL relativePath]);
		}
	}
	[getAllManifests release];
}

- (IBAction)writeChangesToDisk:sender
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	[self writePackagePropertyListsToDisk];
	[self writeManifestPropertyListsToDisk];
	[self selectRepoAtURL:self.repoURL];
}

# pragma mark -
# pragma mark Reading from the repository


- (IBAction)openRepository:sender
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	NSURL *tempURL = [self chooseRepositoryFolder];
	if (tempURL != nil) {
		[self selectRepoAtURL:tempURL];
	}
}

- (IBAction)reloadRepositoryAction:sender
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	
	[self selectRepoAtURL:self.repoURL];
}

- (void)selectRepoAtURL:(NSURL *)newURL
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"Selecting repo: %@", [newURL relativePath]);
	}
    [self deleteAllManagedObjects];
    
    [self disableAllBindings];
        
    NSError *dirReadError = nil;
	NSArray *selectedDirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[newURL relativePath] error:&dirReadError];
	
	if (selectedDirContents == nil) {
		NSAlert *theAlert = [NSAlert alertWithError:dirReadError];
		[theAlert runModal];
	} else {
		BOOL isRepo = NO;
		for (NSString *repoItem in self.defaultRepoContents) {
			if (![selectedDirContents containsObject:repoItem]) {
				isRepo = NO;
			} else {
				isRepo = YES;
			}
		}
		if (isRepo) {
			self.repoURL = newURL;
			self.pkgsURL = [self.repoURL URLByAppendingPathComponent:@"pkgs"];
			self.pkgsInfoURL = [self.repoURL URLByAppendingPathComponent:@"pkgsinfo"];
			self.catalogsURL = [self.repoURL URLByAppendingPathComponent:@"catalogs"];
			self.manifestsURL = [self.repoURL URLByAppendingPathComponent:@"manifests"];
            
            [self.defaults setURL:self.repoURL forKey:@"selectedRepositoryPath"];
			
			[self scanCurrentRepoForCatalogFiles];
			[self scanCurrentRepoForPackages];
			[self scanCurrentRepoForManifests];
			
            [self showProgressPanel];
		} else {
			NSLog(@"Not a repo!");
            NSAlert *notRepoAlert = [NSAlert alertWithMessageText:@"Invalid repository"
                                                    defaultButton:@"OK"
                                                  alternateButton:@""
                                                      otherButton:@""
                                        informativeTextWithFormat:@"Munki repositories usually contain subdirectories for catalogs, manifests and pkginfo files."];
            [notRepoAlert runModal];
		}
	}
}


- (void)groupPackage:(PackageMO *)aPkg
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSEntityDescription *applicationEntityDescr = [NSEntityDescription entityForName:@"Application" inManagedObjectContext:moc];
	
	NSFetchRequest *fetchForApplications = [[NSFetchRequest alloc] init];
	[fetchForApplications setEntity:applicationEntityDescr];
	NSPredicate *applicationTitlePredicate;
	applicationTitlePredicate = [NSPredicate predicateWithFormat:@"munki_name == %@ AND munki_display_name == %@", aPkg.munki_name, aPkg.munki_display_name];
	
	[fetchForApplications setPredicate:applicationTitlePredicate];
	
	NSUInteger numFoundApplications = [moc countForFetchRequest:fetchForApplications error:nil];
	if (numFoundApplications == 0) {
		ApplicationMO *aNewApplication = [NSEntityDescription insertNewObjectForEntityForName:@"Application" inManagedObjectContext:moc];
		aNewApplication.munki_display_name = aPkg.munki_display_name;
		aNewApplication.munki_name = aPkg.munki_name;
		aNewApplication.munki_description = aPkg.munki_description;
		[aNewApplication addPackagesObject:aPkg];
	} else if (numFoundApplications == 1) {
		ApplicationMO *existingApplication = [[moc executeFetchRequest:fetchForApplications error:nil] objectAtIndex:0];
		[existingApplication addPackagesObject:aPkg];
		
	} else {
		NSLog(@"Found multiple Applications for package. This really shouldn't happen...");
	}
	
	[fetchForApplications release];
}

- (void)configureContainersForPackage:(PackageMO *)aPackage
{
    NSManagedObjectContext *moc = self.managedObjectContext;

    NSFetchRequest *getAllDirectories = [[NSFetchRequest alloc] init];
    [getAllDirectories setEntity:[NSEntityDescription entityForName:@"Directory" inManagedObjectContext:moc]];
    NSArray *allDirectories = [moc executeFetchRequest:getAllDirectories error:nil];
    [getAllDirectories release];
    
    DirectoryMO *basePkginfoDirectory;
    NSFetchRequest *fetchBaseDirectory = [[NSFetchRequest alloc] init];
    [fetchBaseDirectory setEntity:[NSEntityDescription entityForName:@"Directory" inManagedObjectContext:moc]];
    NSPredicate *allPackagesItemPredicate = [NSPredicate predicateWithFormat:@"title == %@", @"All Packages"];
    [fetchBaseDirectory setPredicate:allPackagesItemPredicate];
    NSUInteger foundItems = [moc countForFetchRequest:fetchBaseDirectory error:nil];
    if (foundItems > 0) {
        basePkginfoDirectory = [[moc executeFetchRequest:fetchBaseDirectory error:nil] objectAtIndex:0];
        [aPackage addSourceListItemsObject:basePkginfoDirectory];
    } else {
        basePkginfoDirectory = nil;
    }
    [fetchBaseDirectory release];
    
    NSPredicate *parentPredicate = [NSPredicate predicateWithFormat:@"originalURL == %@", [aPackage.packageInfoURL URLByDeletingLastPathComponent]];
    DirectoryMO *aDir = [[allDirectories filteredArrayUsingPredicate:parentPredicate] objectAtIndex:0];
    [aPackage addSourceListItemsObject:aDir];
}

- (void)configureSourceListDirectoriesSection
{
    PackageSourceListItemMO *directoriesGroupItem = nil;
    NSFetchRequest *groupItemRequest = [[NSFetchRequest alloc] init];
    [groupItemRequest setEntity:[NSEntityDescription entityForName:@"PackageSourceListItem" inManagedObjectContext:self.managedObjectContext]];
    NSPredicate *parentPredicate = [NSPredicate predicateWithFormat:@"title == %@", @"DIRECTORIES"];
    [groupItemRequest setPredicate:parentPredicate];
    NSUInteger foundItems = [self.managedObjectContext countForFetchRequest:groupItemRequest error:nil];
    if (foundItems > 0) {
        directoriesGroupItem = [[self.managedObjectContext executeFetchRequest:groupItemRequest error:nil] objectAtIndex:0];
    } else {
        directoriesGroupItem = [NSEntityDescription insertNewObjectForEntityForName:@"PackageSourceListItem" inManagedObjectContext:self.managedObjectContext];
        directoriesGroupItem.title = @"DIRECTORIES";
        directoriesGroupItem.originalIndexValue = 1;
        directoriesGroupItem.parent = nil;
        directoriesGroupItem.isGroupItemValue = YES;
    }
    [groupItemRequest release];
    
    NSArray *keysToget = [NSArray arrayWithObjects:NSURLNameKey, NSURLLocalizedNameKey, NSURLIsDirectoryKey, nil];
	NSFileManager *fm = [NSFileManager defaultManager];
        
	NSDirectoryEnumerator *pkgsInfoDirEnum = [fm enumeratorAtURL:self.pkgsInfoURL includingPropertiesForKeys:keysToget options:(NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:nil];
	for (NSURL *anURL in pkgsInfoDirEnum)
	{
		NSNumber *isDir;
		[anURL getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
		if ([isDir boolValue]) {
            //NSLog(@"Got directory: %@", [anURL relativePath]);
            
            NSFetchRequest *checkForExistingRequest = [[NSFetchRequest alloc] init];
            [checkForExistingRequest setEntity:[NSEntityDescription entityForName:@"Directory" inManagedObjectContext:self.managedObjectContext]];
            NSPredicate *parentPredicate = [NSPredicate predicateWithFormat:@"originalURL == %@", anURL];
            [checkForExistingRequest setPredicate:parentPredicate];
            NSUInteger foundItems = [self.managedObjectContext countForFetchRequest:checkForExistingRequest error:nil];
            if (foundItems == 0) {
                DirectoryMO *newDirectory = [NSEntityDescription insertNewObjectForEntityForName:@"Directory" inManagedObjectContext:self.managedObjectContext];
                newDirectory.originalURL = anURL;
                newDirectory.originalIndexValue = 10;
                newDirectory.type = @"regular";
                NSString *newTitle;
                [anURL getResourceValue:&newTitle forKey:NSURLNameKey error:nil];
                newDirectory.title = newTitle;
                NSURL *parentDirectory = [anURL URLByDeletingLastPathComponent];
                if ([parentDirectory isEqual:self.pkgsInfoURL]) {
                    newDirectory.parent = directoriesGroupItem;
                } else {
                    NSFetchRequest *parentRequest = [[NSFetchRequest alloc] init];
                    [parentRequest setEntity:[NSEntityDescription entityForName:@"Directory" inManagedObjectContext:self.managedObjectContext]];
                    NSPredicate *parentPredicate = [NSPredicate predicateWithFormat:@"originalURL == %@", parentDirectory];
                    [parentRequest setPredicate:parentPredicate];
                    NSUInteger foundItems = [self.managedObjectContext countForFetchRequest:parentRequest error:nil];
                    if (foundItems > 0) {
                        DirectoryMO *parent = [[self.managedObjectContext executeFetchRequest:parentRequest error:nil] objectAtIndex:0];
                        newDirectory.parent = parent;
                    }
                    [parentRequest release];
                }
            }
            [checkForExistingRequest release];
        }
	}
}

- (void)scanCurrentRepoForPackages
{
	// Scan the current repo for already existing pkginfo files
	// and create a new Package object for each of them
	
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"Scanning selected repo for packages");
	}
	
    PackageSourceListItemMO *newSourceListItem2 = [NSEntityDescription insertNewObjectForEntityForName:@"PackageSourceListItem" inManagedObjectContext:self.managedObjectContext];
    newSourceListItem2.title = @"REPOSITORY";
    newSourceListItem2.originalIndexValue = 0;
    newSourceListItem2.parent = nil;
    newSourceListItem2.isGroupItemValue = YES;
    
    DirectoryMO *newDirectory = [NSEntityDescription insertNewObjectForEntityForName:@"Directory" inManagedObjectContext:self.managedObjectContext];
    newDirectory.originalURL = self.pkgsInfoURL;
    newDirectory.title = @"All Packages";
    newDirectory.type = @"smart";
    newDirectory.parent = newSourceListItem2;
    newDirectory.originalIndexValue = 10;
    
    [self configureSourceListDirectoriesSection];
    
    /*
    PackageSourceListItemMO *newSourceListItem = [NSEntityDescription insertNewObjectForEntityForName:@"PackageSourceListItem" inManagedObjectContext:self.managedObjectContext];
    newSourceListItem.title = @"DIRECTORIES";
    newSourceListItem.originalIndexValue = 1;
    newSourceListItem.parent = nil;
    newSourceListItem.isGroupItemValue = YES;
    */
    
    
	NSArray *keysToget = [NSArray arrayWithObjects:NSURLNameKey, NSURLLocalizedNameKey, NSURLIsDirectoryKey, nil];
	NSFileManager *fm = [NSFileManager defaultManager];
    
    RelationshipScanner *packageRelationships = [RelationshipScanner pkginfoScanner];
    packageRelationships.delegate = self;

	NSDirectoryEnumerator *pkgsInfoDirEnum = [fm enumeratorAtURL:self.pkgsInfoURL includingPropertiesForKeys:keysToget options:(NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:nil];
	for (NSURL *anURL in pkgsInfoDirEnum)
	{
		NSNumber *isDir;
		[anURL getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
		if (![isDir boolValue]) {
			PkginfoScanner *scanOp = [PkginfoScanner scannerWithURL:anURL];
			scanOp.delegate = self;
            [packageRelationships addDependency:scanOp];
			[self.operationQueue addOperation:scanOp];
			
		} else {
            //NSLog(@"Got directory: %@", [anURL relativePath]);
            /*
            DirectoryMO *newDirectory = [NSEntityDescription insertNewObjectForEntityForName:@"Directory" inManagedObjectContext:self.managedObjectContext];
            newDirectory.originalURL = anURL;
            newDirectory.originalIndexValue = 10;
            newDirectory.type = @"regular";
            NSString *newTitle;
            [anURL getResourceValue:&newTitle forKey:NSURLNameKey error:nil];
            newDirectory.title = newTitle;
            NSURL *parentDirectory = [anURL URLByDeletingLastPathComponent];
            if ([parentDirectory isEqual:self.pkgsInfoURL]) {
                newDirectory.parent = newSourceListItem;
            } else {
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
				[request setEntity:[NSEntityDescription entityForName:@"Directory" inManagedObjectContext:self.managedObjectContext]];
				NSPredicate *parentPredicate = [NSPredicate predicateWithFormat:@"originalURL == %@", parentDirectory];
				[request setPredicate:parentPredicate];
				NSUInteger foundItems = [self.managedObjectContext countForFetchRequest:request error:nil];
				if (foundItems > 0) {
					DirectoryMO *parent = [[self.managedObjectContext executeFetchRequest:request error:nil] objectAtIndex:0];
                    NSLog(@"Got parent: %@", parent.title);
                    newDirectory.parent = parent;
				}
				[request release];
            }
             */
        }
	}
    
    [self.operationQueue addOperation:packageRelationships];
}

- (void)scanCurrentRepoForCatalogFiles
{
	// Scan the current repo for already existing catalog files
	// and create a new Catalog object for each of them
	
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"Scanning selected repo for catalogs");
	}
	
	NSArray *keysToget = [NSArray arrayWithObjects:NSURLNameKey, NSURLIsDirectoryKey, nil];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSManagedObjectContext *moc = [self managedObjectContext];
    [[moc undoManager] disableUndoRegistration];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Catalog" inManagedObjectContext:moc];
	
	NSDirectoryEnumerator *catalogsDirEnum = [fm enumeratorAtURL:self.catalogsURL includingPropertiesForKeys:keysToget options:(NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:nil];
	for (NSURL *aCatalogFile in catalogsDirEnum)
	{
		NSNumber *isDir;
		[aCatalogFile getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
		if (![isDir boolValue]) {
			NSString *filename = nil;
			[aCatalogFile getResourceValue:&filename forKey:NSURLNameKey error:nil];
			
			if (![filename isEqualToString:@"all"]) {
				// Check if we already have a catalog with this name
				NSFetchRequest *request = [[NSFetchRequest alloc] init];
				[request setEntity:entityDescription];
				
				NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title == %@", filename];
				[request setPredicate:titlePredicate];
				
				NSUInteger foundItems = [moc countForFetchRequest:request error:nil];
				if (foundItems == 0) {
					CatalogMO *aNewCatalog = [NSEntityDescription insertNewObjectForEntityForName:@"Catalog" inManagedObjectContext:moc];
					aNewCatalog.title = filename;
				}
				[request release];
			}
		}
	}
	NSError *error = nil;
	if (![moc save:&error]) {
		[NSApp presentError:error];
	}
    [[moc undoManager] enableUndoRegistration];
}


- (void)scanCurrentRepoForManifests
{
	// Scan the current repo for already existing manifest files
	// and create a new Manifest object for each of them
	
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"Scanning selected repo for manifests");
	}
	
	NSArray *keysToget = [NSArray arrayWithObjects:NSURLNameKey, NSURLIsDirectoryKey, nil];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSManagedObjectContext *moc = [self managedObjectContext];
    [[moc undoManager] disableUndoRegistration];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:moc];
	
	
	NSDirectoryEnumerator *manifestsDirEnum = [fm enumeratorAtURL:self.manifestsURL includingPropertiesForKeys:keysToget options:(NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:nil];
	for (NSURL *aManifestFile in manifestsDirEnum)
	{
		NSNumber *isDir;
		[aManifestFile getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
		if (![isDir boolValue]) {
			
			NSString *filename = nil;
			[aManifestFile getResourceValue:&filename forKey:NSURLNameKey error:nil];
			NSFetchRequest *request = [[NSFetchRequest alloc] init];
			[request setEntity:entityDescription];
			NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title == %@", filename];
			[request setPredicate:titlePredicate];
			ManifestMO *manifest;
			NSUInteger foundItems = [moc countForFetchRequest:request error:nil];
			if (foundItems == 0) {
				manifest = [NSEntityDescription insertNewObjectForEntityForName:@"Manifest" inManagedObjectContext:moc];
				manifest.title = filename;
				manifest.manifestURL = aManifestFile;
			}
			[request release];
			
		}
	}
	NSError *error = nil;
	if (![moc save:&error]) {
		[NSApp presentError:error];
	}
    [[moc undoManager] enableUndoRegistration];
    
    RelationshipScanner *manifestRelationships = [RelationshipScanner manifestScanner];
    manifestRelationships.delegate = self;
	for (ManifestMO *aManifest in [self allObjectsForEntity:@"Manifest"]) {
		ManifestScanner *scanOp = [[[ManifestScanner alloc] initWithURL:(NSURL *)aManifest.manifestURL] autorelease];
		scanOp.delegate = self;
        [manifestRelationships addDependency:scanOp];
		[self.operationQueue addOperation:scanOp];
	}
    [self.operationQueue addOperation:manifestRelationships];
    
    NSBlockOperation *enableBindingsOp = [NSBlockOperation blockOperationWithBlock:^{
        [self performSelectorOnMainThread:@selector(enableAllBindings) withObject:nil waitUntilDone:YES];
    }];
    [enableBindingsOp addDependency:manifestRelationships];
    [self.operationQueue addOperation:enableBindingsOp];
}

- (void)scanCurrentRepoForIncludedManifests
{
	// Scan the current repo for included manifests
	
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"Scanning selected repo for included manifests");
	}
	
	NSArray *keysToget = [NSArray arrayWithObjects:NSURLNameKey, NSURLIsDirectoryKey, nil];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSManagedObjectContext *moc = [self managedObjectContext];
    [[moc undoManager] disableUndoRegistration];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:moc];
	
	
	NSDirectoryEnumerator *manifestsDirEnum = [fm enumeratorAtURL:self.manifestsURL includingPropertiesForKeys:keysToget options:(NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:nil];
	for (NSURL *aManifestFile in manifestsDirEnum)
	{
		NSNumber *isDir;
		[aManifestFile getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
		if (![isDir boolValue]) {
			NSString *filename = nil;
			[aManifestFile getResourceValue:&filename forKey:NSURLNameKey error:nil];
			
			NSDictionary *manifestInfoDict = [NSDictionary dictionaryWithContentsOfURL:aManifestFile];
			
			// Check if we already have a manifest with this name
			NSFetchRequest *request = [[NSFetchRequest alloc] init];
			[request setEntity:entityDescription];
			
			NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title == %@", filename];
			[request setPredicate:titlePredicate];
			ManifestMO *manifest;
			NSUInteger foundItems = [moc countForFetchRequest:request error:nil];
			if (foundItems == 0) {
				if ([self.defaults boolForKey:@"debug"]) {
					NSLog(@"No match for manifest, creating new with name: %@", filename);
				}
				manifest = [NSEntityDescription insertNewObjectForEntityForName:@"Manifest" inManagedObjectContext:moc];
				manifest.title = filename;
				manifest.manifestURL = aManifestFile;
			} else {
				manifest = [[moc executeFetchRequest:request error:nil] objectAtIndex:0];
				if ([self.defaults boolForKey:@"debug"]) {
					NSLog(@"Found existing manifest %@", manifest.title);
				}
			}

			[request release];
			
			// Parse manifests included_manifests array
			NSArray *includedManifests = [manifestInfoDict objectForKey:@"included_manifests"];
			for (ManifestMO *aManifest in [self allObjectsForEntity:@"Manifest"]) {
				
				ManifestInfoMO *newManifestInfo = [NSEntityDescription insertNewObjectForEntityForName:@"ManifestInfo" inManagedObjectContext:moc];
				newManifestInfo.parentManifest = aManifest;
				newManifestInfo.manifest = manifest;
				
				if ([self.defaults boolForKey:@"debug"]) {
					NSLog(@"Linking nested manifest %@ -> %@", manifest.title, newManifestInfo.parentManifest.title);
				}
				
				if (includedManifests == nil) {
					newManifestInfo.isEnabledForManifestValue = NO;
				} else if ([includedManifests containsObject:aManifest.title]) {
					newManifestInfo.isEnabledForManifestValue = YES;
				} else {
					newManifestInfo.isEnabledForManifestValue = NO;
				}
				if (manifest != aManifest) {
					newManifestInfo.isAvailableForEditingValue = YES;
				} else {
					newManifestInfo.isAvailableForEditingValue = NO;
				}
				
			}
		}
	}
    [[moc undoManager] enableUndoRegistration];
}

# pragma mark -
# pragma mark Core Data default methods

/**
    Returns the support directory for the application, used to store the Core Data
    store file.  This code uses a directory named "MunkiAdmin" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"MunkiAdmin"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The directory for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator) return persistentStoreCoordinator;

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType 
                                                configuration:nil 
                                                URL:url 
                                                options:nil 
                                                error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    

    return persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext) return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];

    return managedObjectContext;
}

/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
	
	/*if ([self.defaults boolForKey:@"CopyAppDescriptionToPackages"]) {
		[self propagateAppDescriptionToVersions];
	}*/
	
	if ([self.defaults boolForKey:@"UpdatePkginfosOnSave"]) {
		[self writePackagePropertyListsToDisk];
	}
	if ([self.defaults boolForKey:@"UpdateManifestsOnSave"]) {
		[self writeManifestPropertyListsToDisk];
	}
	if ([self.defaults boolForKey:@"UpdateCatalogsOnSave"]) {
		[self updateCatalogs];
	} 
	
	[applicationTableView reloadData];
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    if (!managedObjectContext) return NSTerminateNow;

    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![managedObjectContext hasChanges]) return NSTerminateNow;

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
    
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.

        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
                
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;

        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;

    }

    return NSTerminateNow;
}


/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void)dealloc {

    [window release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
	
    [super dealloc];
}

# pragma mark -
# pragma mark NSTabView delegates

- (IBAction)selectViewAction:sender
{
	switch ([sender tag]) {
		case 1:
			if (currentWholeView != [packagesViewController view]) {
				self.selectedViewDescr = @"Packages";
                currentWholeView = [packagesViewController view];
                currentDetailView = nil;
                currentSourceView = nil;
                [mainSegmentedControl setSelectedSegment:0];
				[self changeItemView];
            }
			break;
		case 2:
			if (currentDetailView != self.catalogsDetailView) {
				self.selectedViewDescr = @"Catalogs";
                currentWholeView = self.mainSplitView;
				currentDetailView = catalogsDetailView;
				currentSourceView = catalogsListView;
				[mainSegmentedControl setSelectedSegment:1];
				[self changeItemView];
			}
			break;
		case 3:
			if (currentDetailView != [manifestDetailViewController view]) {
				self.selectedViewDescr = @"Manifests";
                currentWholeView = self.mainSplitView;
				currentDetailView = [manifestDetailViewController view];
				currentSourceView = manifestsListView;
				[mainSegmentedControl setSelectedSegment:2];
				[self changeItemView];
			}
			break;
		default:
			break;
	}
}

- (IBAction)didSelectSegment:sender
{
	switch ([sender selectedSegment]) {
		case 0:
            if (currentWholeView != [packagesViewController view]) {
				self.selectedViewDescr = @"Packages";
                currentDetailView = nil;
                currentSourceView = nil;
                currentWholeView = [packagesViewController view];
				[self changeItemView];
            }
			break;
		case 1:
            if (currentDetailView != self.catalogsDetailView) {
				self.selectedViewDescr = @"Catalogs";
                currentWholeView = self.mainSplitView;
				currentDetailView = catalogsDetailView;
				currentSourceView = catalogsListView;
				[self changeItemView];
            }
			break;
		case 2:
            if (currentDetailView != [manifestDetailViewController view]) {
				self.selectedViewDescr = @"Manifests";
                currentWholeView = self.mainSplitView;
				currentDetailView = [manifestDetailViewController view];
				currentSourceView = manifestsListView;
				[self changeItemView];
            }
			break;
		default:
			break;
	}
}

// Changing subviews code inspired by Apple examples

- (void)removeSubview
{
	// empty selection
	NSArray *subViews = [detailViewPlaceHolder subviews];
	if ([subViews count] > 0)
	{
		[[subViews objectAtIndex:0] removeFromSuperview];
	}
	
	[detailViewPlaceHolder displayIfNeeded];
}

- (void)removeSubviews
{
    NSArray *subViews = [[self.window contentView] subviews];
    for (id aSubView in subViews) {
        [aSubView removeFromSuperview];
    }
    /*
	if ([subViews count] > 0)
	{
		[[subViews objectAtIndex:0] removeFromSuperview];
	}
    */
    
    NSArray *detailSubViews = [detailViewPlaceHolder subviews];
	if ([detailSubViews count] > 0)
	{
		[[detailSubViews objectAtIndex:0] removeFromSuperview];
	}
	
	NSArray *sourceSubViews = [sourceViewPlaceHolder subviews];
	if ([sourceSubViews count] > 0)
	{
		[[sourceSubViews objectAtIndex:0] removeFromSuperview];
	}
    
    //[self.mainSplitView removeFromSuperview];
    //[[self.window contentView] display];
	
	//[sourceViewPlaceHolder display];
	//[detailViewPlaceHolder display];
}

- (void)changeItemView
{
    if (currentWholeView == [packagesViewController view]) {
        // remove the old subview
        [self removeSubviews];
        
        [[self.window contentView] addSubview:[packagesViewController view]];
        [[packagesViewController view] setFrame:[[self.window contentView] frame]];
        [[packagesViewController view] setFrameOrigin:NSMakePoint(0,0)];
        [[packagesViewController view] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [[packagesViewController directoriesOutlineView] expandItem:nil expandChildren:YES];
        [[packagesViewController directoriesOutlineView] reloadData];
        [[packagesViewController packagesArrayController] rearrangeObjects];
    } else {
        // remove the old subview
        [self removeSubviews];
        
        [[self.window contentView] addSubview:self.mainSplitView];
        [self.mainSplitView setFrame:[[self.window contentView] frame]];
        [self.mainSplitView setFrameOrigin:NSMakePoint(0,0)];
        [self.mainSplitView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        // add a spinning progress gear in case populating the icon view takes too long
        NSRect bounds = [detailViewPlaceHolder bounds];
        CGFloat x = (bounds.size.width-32)/2;
        CGFloat y = (bounds.size.height-32)/2;
        NSProgressIndicator* busyGear = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(x, y, 32, 32)];
        [busyGear setStyle:NSProgressIndicatorSpinningStyle];
        [busyGear startAnimation:self];
        [detailViewPlaceHolder addSubview:busyGear];
        //[detailViewPlaceHolder display];
        
        [detailViewPlaceHolder addSubview:currentDetailView];
        [sourceViewPlaceHolder addSubview:currentSourceView];
        
        [busyGear removeFromSuperview];
        [busyGear release];
        
        [currentDetailView setFrame:[[currentDetailView superview] frame]];
        [currentSourceView setFrame:[[currentSourceView superview] frame]];
        
        // make sure our added subview is placed and resizes correctly
        [currentDetailView setFrameOrigin:NSMakePoint(0,0)];
        [currentDetailView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        [currentSourceView setFrameOrigin:NSMakePoint(0,0)];
        [currentSourceView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	}
    self.window.title = [NSString stringWithFormat:@"MunkiAdmin - %@", self.selectedViewDescr];
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem");
	}
	if ([[tabViewItem label] isEqualToString:@"Applications"]) {
		currentDetailView = applicationsDetailView;
	} else if ([[tabViewItem label] isEqualToString:@"Catalogs"]) {
		currentDetailView = catalogsDetailView;
	}
	[self changeItemView];
}

#pragma mark -
#pragma mark NSSplitView delegates

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
	return NO;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex
{
	return NO;
}

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
	// Resize only the right side of the splitview
	
	NSView *left = [[sender subviews] objectAtIndex:0];
	NSView *right = [[sender subviews] objectAtIndex:1];
	float dividerThickness = [sender dividerThickness];
	NSRect newFrame = [sender frame];
	NSRect leftFrame = [left frame];
	NSRect rightFrame = [right frame];
	
	rightFrame.size.height = newFrame.size.height;
	rightFrame.size.width = newFrame.size.width - leftFrame.size.width - dividerThickness;
	rightFrame.origin = NSMakePoint(leftFrame.size.width + dividerThickness, 0);
	
	leftFrame.size.height = newFrame.size.height;
	leftFrame.origin.x = 0;
	
	[left setFrame:leftFrame];
	[right setFrame:rightFrame];
}



@end
