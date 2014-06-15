//
//  MunkiAdmin_AppDelegate.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 11.1.2010.
//

#import "MAMunkiAdmin_AppDelegate.h"
#import "MAPkginfoScanner.h"
#import "MAManifestScanner.h"
#import "MAMunkiOperation.h"
#import "MARelationshipScanner.h"
#import "MAFileCopyOperation.h"
#import "MAManifestDetailView.h"
#import "MASelectPkginfoItemsWindow.h"
#import "MASelectManifestItemsWindow.h"
#import "MAPackageNameEditor.h"
#import "MAAdvancedPackageEditor.h"
#import "MAPredicateEditor.h"
#import "MAPackagesView.h"
#import "MAPkginfoAssimilator.h"
#import "MAMunkiRepositoryManager.h"
#import "MACoreDataManager.h"
#import "ManifestsArrayController.h"

#define kMunkiAdminStatusChangeName @"MunkiAdminDidChangeStatus"

@implementation MAMunkiAdmin_AppDelegate

# pragma mark -
# pragma mark Property Implementation Directives

@dynamic defaults;


# pragma mark -
# pragma mark Helper methods

- (IBAction)openPreferencesAction:sender
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	[self.preferencesController showWindow:self];
}

- (IBAction)showPkginfoInFinderAction:(id)sender
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    NSURL *selectedURL = (NSURL *)[[[[self.packagesViewController packagesArrayController] selectedObjects] lastObject] packageInfoURL];
    if (selectedURL != nil) {
        [[NSWorkspace sharedWorkspace] selectFile:[selectedURL relativePath] inFileViewerRootedAtPath:[self.repoURL relativePath]];
    }
}

- (IBAction)showInstallerInFinderAction:(id)sender
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    NSURL *selectedURL = (NSURL *)[[[[self.packagesViewController packagesArrayController] selectedObjects] lastObject] packageURL];
    if (selectedURL != nil) {
        [[NSWorkspace sharedWorkspace] selectFile:[selectedURL relativePath] inFileViewerRootedAtPath:[self.repoURL relativePath]];
    }
}

- (IBAction)showManifestInFinderAction:(id)sender
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    NSURL *selectedURL = (NSURL *)[[[self.manifestsArrayController selectedObjects] lastObject] manifestURL];
    if (selectedURL != nil) {
        [[NSWorkspace sharedWorkspace] selectFile:[selectedURL relativePath] inFileViewerRootedAtPath:[self.repoURL relativePath]];
    }
}

- (NSUserDefaults *)defaults
{
	return [NSUserDefaults standardUserDefaults];
}

- (void)alertMunkiToolNotInstalled:(NSString *)munkitoolName
{
    NSString *alertText = [NSString stringWithFormat:
                           @"Can't find %@.\n\nMake sure munkitools package is installed and a correct path for %@ is set in MunkiAdmin preferences.",
                           munkitoolName,
                           munkitoolName];
    
    NSAlert *munkitoolFailedAlert = [NSAlert alertWithMessageText:@"Munkitools error"
                                                    defaultButton:@"OK"
                                                  alternateButton:@""
                                                      otherButton:@""
                                        informativeTextWithFormat:@"%@", alertText];
    [munkitoolFailedAlert runModal];
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

- (void)updateSourceList
{
    [self.packagesViewController.directoriesTreeController rearrangeObjects];
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
		@autoreleasepool {
			NSArray *allObjects = [self allObjectsForEntity:[entDescr name]];
			if ([self.defaults boolForKey:@"debug"]) NSLog(@"Deleting %lu objects from entity: %@", (unsigned long)[allObjects count], [entDescr name]);
			for (id anObject in allObjects) {
				[moc deleteObject:anObject];
			}
		}
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
	return fetchResults;
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

- (NSArray *)chooseFolderForSave
{
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	openPanel.title = @"Select a save location";
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

- (NSURL *)chooseDestinationDirectoryWithTitle:(NSString *)title message:(NSString *)message
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	openPanel.title = title;
    openPanel.message = message;
	openPanel.allowsMultipleSelection = NO;
	openPanel.canChooseDirectories = YES;
	openPanel.canChooseFiles = NO;
	openPanel.resolvesAliases = YES;
    openPanel.prompt = @"Choose";
    openPanel.directoryURL = self.pkgsInfoURL;
	
	if ([openPanel runModal] == NSFileHandlingPanelOKButton)
	{
		return [[openPanel URLs] objectAtIndex:0];
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
    openPanel.delegate = self;
	openPanel.title = @"Select a File";
	openPanel.allowsMultipleSelection = YES;
	openPanel.canChooseDirectories = NO;
	openPanel.canChooseFiles = YES;
	openPanel.resolvesAliases = YES;
    openPanel.directoryURL = self.pkgsURL;
    [openPanel setAccessoryView:self.makepkginfoOptionsView];
	
	if ([openPanel runModal] == NSFileHandlingPanelOKButton)
	{
		return [openPanel URLs];
	} else {
		return nil;
	}
}

- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError
{
    if ([[MAMunkiRepositoryManager sharedManager] canImportURL:url error:outError]) {
        return YES;
    } else {
        return NO;
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

- (NSURL *)showSavePanelForManifestWithTitle:(NSString *)title filename:(NSString *)filename message:(NSString *)message directoryURL:(NSURL *)url
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	savePanel.nameFieldStringValue = filename;
    if (url) {
        savePanel.directoryURL = url;
    } else {
        savePanel.directoryURL = self.manifestsURL;
    }
    if (message) {
        savePanel.message = message;
    }
    savePanel.title = title;
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

- (void)managedObjectsDidChange:(NSNotification *)notification
{
    /*
     * ===============================================================
     * At the moment we are not using this. Left here as a convenience
     * ===============================================================
     */
    
    /*
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    
    NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    for (id anUpdatedObject in updatedObjects) {
        NSLog(@"Updated: %@", anUpdatedObject);
    }
    NSSet *deletedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    for (id aDeletedObject in deletedObjects) {
        NSLog(@"Deleted: %@", aDeletedObject);
    }
    NSSet *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
    for (id anInsertedObject in insertedObjects) {
        NSLog(@"Updated: %@", anInsertedObject);
    }
    */
}

- (void)startObservingObjectsForChanges
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(managedObjectsDidChange:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:self.managedObjectContext];
}

- (void)stopObservingObjectsForChanges
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextObjectsDidChangeNotification
                                                  object:self.managedObjectContext];
}

# pragma mark -
# pragma mark Application Startup

- (void)awakeFromNib
{	
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@: Setting up the app", NSStringFromSelector(_cmd));
	}
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoManagerDidUndo:) name:NSUndoManagerDidUndoChangeNotification object:nil];
	
    self.packagesViewController = [[MAPackagesView alloc] initWithNibName:@"MAPackagesView" bundle:nil];
    self.manifestDetailViewController = [[MAManifestDetailView alloc] initWithNibName:@"MAManifestDetailView" bundle:nil];
    addItemsWindowController = [[MASelectPkginfoItemsWindow alloc] initWithWindowNibName:@"MASelectPkginfoItemsWindow"];
    selectManifestsWindowController = [[MASelectManifestItemsWindow alloc] initWithWindowNibName:@"MASelectManifestItemsWindow"];
    self.packageNameEditor = [[MAPackageNameEditor alloc] initWithWindowNibName:@"MAPackageNameEditor"];
    advancedPackageEditor = [[MAAdvancedPackageEditor alloc] initWithWindowNibName:@"MAAdvancedPackageEditor"];
    predicateEditor = [[MAPredicateEditor alloc] initWithWindowNibName:@"MAPredicateEditor"];
    pkginfoAssimilator = [[MAPkginfoAssimilator alloc] initWithWindowNibName:@"MAPkginfoAssimilator"];
    self.preferencesController = [[MAPreferences alloc] initWithWindowNibName:@"MAPreferences"];
    
    
	// Configure segmented control
	[self.mainSegmentedControl setSegmentCount:3];
	
    NSImage *packagesIcon = [[NSImage imageNamed:@"packageIcon_32x32"] copy];
	[packagesIcon setSize:NSMakeSize(18, 18)];
	NSImage *catalogsIcon = [[NSImage imageNamed:@"catalogIcon_32x32"] copy];
	[catalogsIcon setSize:NSMakeSize(18, 18)];
	NSImage *manifestsIcon = [[NSImage imageNamed:@"manifestIcon_32x32"] copy];
	[manifestsIcon setSize:NSMakeSize(18, 18)];
	
	[self.mainSegmentedControl setImage:packagesIcon forSegment:0];
	[self.mainSegmentedControl setImage:catalogsIcon forSegment:1];
	[self.mainSegmentedControl setImage:manifestsIcon forSegment:2];
	
	[self.mainTabView setDelegate:self];
	[self.mainSplitView setDelegate:self];
	
	if ([self.defaults integerForKey:@"startupSelectedView"] == 0) {
		self.selectedViewTag = 0;
		self.selectedViewDescr = @"Packages";
        currentWholeView = [self.packagesViewController view];
		[self.mainSegmentedControl setSelectedSegment:0];
	}
	else if ([self.defaults integerForKey:@"startupSelectedView"] == 1) {
		self.selectedViewTag = 1;
		self.selectedViewDescr = @"Catalogs";
		currentDetailView = self.catalogsDetailView;
		currentSourceView = self.catalogsListView;
        currentWholeView = self.mainSplitView;
		[self.mainSegmentedControl setSelectedSegment:1];
	}
	else if ([self.defaults integerForKey:@"startupSelectedView"] == 2) {
		self.selectedViewTag = 2;
		self.selectedViewDescr = @"Manifests";
		currentDetailView = [self.manifestDetailViewController view];
		currentSourceView = self.manifestsListView;
        currentWholeView = self.mainSplitView;
		[self.mainSegmentedControl setSelectedSegment:2];
	}
	else {
		self.selectedViewTag = 0;
		self.selectedViewDescr = @"Packages";
        currentWholeView = [self.packagesViewController view];
		[self.mainSegmentedControl setSelectedSegment:0];
	}
    	
	[self changeItemView];
	
	[self.window center];
	
	// Create an operation queue for later use
	self.operationQueue = [[NSOperationQueue alloc] init];
	[self.operationQueue setMaxConcurrentOperationCount:1];
	self.queueIsRunning = NO;
	[self.progressIndicator setUsesThreadedAnimation:YES];
		
	// Define default repository contents
    self.defaultRepoContents = [NSArray arrayWithObjects:@"catalogs", @"manifests", @"pkgsinfo", nil];
	
	// Set sort descriptors for array controllers
    NSSortDescriptor *sortManifestsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"parentManifest.title" ascending:YES selector:@selector(localizedStandardCompare:)];
	[self.manifestInfosArrayController setSortDescriptors:[NSArray arrayWithObject:sortManifestsByTitle]];
	
    NSSortDescriptor *sortAppProxiesByTitle = [NSSortDescriptor sortDescriptorWithKey:@"parentApplication.munki_name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortAppProxiesByDisplayName = [NSSortDescriptor sortDescriptorWithKey:@"parentApplication.munki_display_name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray *appSorters = [NSArray arrayWithObjects:sortAppProxiesByDisplayName, sortAppProxiesByTitle, nil];
	[self.managedInstallsArrayController setSortDescriptors:appSorters];
	[self.managedUninstallsArrayController setSortDescriptors:appSorters];
	[self.managedUpdatesArrayController setSortDescriptors:appSorters];
	[self.optionalInstallsArrayController setSortDescriptors:appSorters];
    
    NSSortDescriptor *sortInstallsItems = [NSSortDescriptor sortDescriptorWithKey:@"munki_path" ascending:YES];
    [self.installsItemsArrayController setSortDescriptors:[NSArray arrayWithObject:sortInstallsItems]];
    
    NSSortDescriptor *sortItemsToCopyByDestPath = [NSSortDescriptor sortDescriptorWithKey:@"munki_destination_path" ascending:YES];
    NSSortDescriptor *sortItemsToCopyBySource = [NSSortDescriptor sortDescriptorWithKey:@"munki_source_item" ascending:YES];
    [self.itemsToCopyArrayController setSortDescriptors:[NSArray arrayWithObjects:sortItemsToCopyByDestPath, sortItemsToCopyBySource, nil]];
    
    NSSortDescriptor *sortReceiptsByPackageID = [NSSortDescriptor sortDescriptorWithKey:@"munki_packageid" ascending:YES];
    NSSortDescriptor *sortReceiptsByName = [NSSortDescriptor sortDescriptorWithKey:@"munki_name" ascending:YES];
    [self.receiptsArrayController setSortDescriptors:[NSArray arrayWithObjects:sortReceiptsByPackageID, sortReceiptsByName, nil]];
	
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    [dnc addObserver:self selector:@selector(didReceiveSharedPkginfo:) name:@"SUSInspectorPostedSharedPkginfo" object:nil suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
}

- (NSString *)safeFilenameFromString:(NSString *)aFileName
{
    // Do a lossy conversion
    NSData *data = [aFileName dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *tmpString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // Remove the characters we don't want
    NSCharacterSet *illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@":/\\?%*|\"<>#,"];
    tmpString = [[tmpString componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
    
    // Replace "/" characters with a "-"
    tmpString = [tmpString stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    
    // Remove adjacent dashes
    tmpString = [tmpString stringByReplacingOccurrencesOfString:@"--+" withString:@"-" options:NSRegularExpressionSearch range:NSMakeRange(0, [tmpString length])];
    
    return tmpString;
}

- (BOOL)processSingleSharedObject:(NSDictionary *)object saveDirectoryURL:(NSURL *)saveDirectory
{
    /*
     Get the filename hint and the pkginfo
     */
    NSString *filenameHint = [object objectForKey:@"filename"];
    NSString *safeFilenameHint = [self safeFilenameFromString:filenameHint];
    
    NSDictionary *pkginfo = [object objectForKey:@"pkginfo"];
    
    /*
     Write the pkginfo
     */
    NSURL *saveURL = [saveDirectory URLByAppendingPathComponent:safeFilenameHint];
    BOOL saved = [pkginfo writeToURL:saveURL atomically:YES];
    if (!saved) {
        NSLog(@"Error: Failed to write %@...", [saveURL path]);
        return NO;
    }
    
    /*
     Create a scanner job but run it without an operation queue
     */
    MAPkginfoScanner *scanOp = [MAPkginfoScanner scannerWithURL:saveURL];
    scanOp.canModify = YES;
    scanOp.delegate = self;
    [scanOp start];
    
    /*
     Fetch the newly created package
     */
    NSFetchRequest *fetchForPackage = [[NSFetchRequest alloc] init];
    [fetchForPackage setEntity:[NSEntityDescription entityForName:@"Package" inManagedObjectContext:self.managedObjectContext]];
    NSPredicate *pkgPred;
    pkgPred = [NSPredicate predicateWithFormat:@"packageInfoURL == %@", saveURL];
    [fetchForPackage setPredicate:pkgPred];
    
    NSUInteger numFoundPkgs = [self.managedObjectContext countForFetchRequest:fetchForPackage error:nil];
    if (numFoundPkgs == 0) {
        // Didn't find anything
    }
    else if (numFoundPkgs == 1) {
        PackageMO *createdPkg = [[self.managedObjectContext executeFetchRequest:fetchForPackage error:nil] objectAtIndex:0];
        
        // Select the newly created package
        [[self.packagesViewController packagesArrayController] setSelectedObjects:[NSArray arrayWithObject:createdPkg]];
        
        // Run the assimilator
        if ([self.defaults boolForKey:@"assimilate_enabled"]) {
            MAMunkiRepositoryManager *repoManager = [MAMunkiRepositoryManager sharedManager];
            [repoManager assimilatePackageWithPreviousVersion:createdPkg keys:repoManager.pkginfoAssimilateKeysForAuto];
        }
    }
    else {
        // Found multiple matches for a single URL
    }
    
    return YES;
}

- (void)processSharedPayloadDictionaries:(NSArray *)payloadDictionaries
{
    if (!payloadDictionaries) {
        return;
    }
    
    /*
     Check each of the payload objects
     */
    __block BOOL allValid = YES;
    [payloadDictionaries enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        
        /*
         Make sure this item has "filename" and "pkginfo" keys and make sure they are valid
         */
        BOOL hasFilename = ([obj objectForKey:@"filename"]) ? TRUE : FALSE;
        BOOL hasPkginfo = ([obj objectForKey:@"pkginfo"]) ? TRUE : FALSE;
        
        if (!hasFilename || !hasPkginfo) {
            NSLog(@"Error: Pkginfo from notification object is not valid...");
            allValid = NO;
            *stop = YES;
        }
        
        id filenameHint = [obj objectForKey:@"filename"];
        if (![filenameHint isKindOfClass:[NSString class]]) {
            NSLog(@"Error: Object for key \"filename\" is not a string...");
            allValid = NO;
            *stop = YES;
        }
        
        id pkginfo = [obj objectForKey:@"pkginfo"];
        if (![pkginfo isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Error: Object for key \"pkginfo\" is not a dictionary...");
            allValid = NO;
            *stop = YES;
        }
    }];
    
    /*
     Bail out if the received objects are not valid
     */
    if (!allValid) {
        return;
    }
    
    
    /*
     Choose a directory for the pkginfo files
     */
    NSString *openPanelTitle = @"Choose Location";
    NSString *messageText = [NSString stringWithFormat:@"MunkiAdmin received %li pkginfo objects from SUS Inspector. Choose a location to save them.", (unsigned long)[payloadDictionaries count]];
    __weak NSURL *saveDirectory = [self chooseDestinationDirectoryWithTitle:openPanelTitle message:messageText];
    if (!saveDirectory) {
        return;
    }
    
    /*
     Rescan the main pkginfo dir for any newly created directories
     */
    [[MACoreDataManager sharedManager] configureSourceListDirectoriesSection:self.managedObjectContext];
    
    
    /*
     Process each of the payload objects
     */
    __block BOOL wroteAll = YES;
    [payloadDictionaries enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        if (![self processSingleSharedObject:obj saveDirectoryURL:saveDirectory]) {
            NSLog(@"Error: Object for key \"pkginfo\" is not a dictionary...");
            wroteAll = NO;
            *stop = YES;
        }
    }];
    
    /*
     Check if we successfully wrote everything
     */
    if (!wroteAll) {
        return;
    }
    
    // We need to do a relationship scan after creating a pkginfo file
    MARelationshipScanner *packageRelationships = [MARelationshipScanner pkginfoScanner];
    packageRelationships.delegate = self;
    [self.operationQueue addOperation:packageRelationships];
    
    // Create a block operation to re-enable bindings
    NSBlockOperation *enableBindingsOp = [NSBlockOperation blockOperationWithBlock:^{
        [self performSelectorOnMainThread:@selector(enableAllBindings) withObject:nil waitUntilDone:YES];
    }];
    [enableBindingsOp addDependency:packageRelationships];
    [self.operationQueue addOperation:enableBindingsOp];
    
    // Trigger the progress panel
    [self showProgressPanel];
}

- (void)didReceiveSharedPkginfo:(NSNotification *)aNotification
{
    /*
     Make MunkiAdmin the top-most app
     */
    [NSApp activateIgnoringOtherApps:YES];
    
    /*
     Get the payload dictionaries from the notification and make sure it's safe to use
     */
    id payloadDictionaries = [[aNotification userInfo] objectForKey:@"payloadDictionaries"];
    if ((payloadDictionaries != nil) && ([payloadDictionaries isKindOfClass:[NSArray class]])) {
        
        NSArray *items = [NSArray arrayWithArray:payloadDictionaries];
        [self processSharedPayloadDictionaries:items];
        
    } else {
        NSLog(@"Error: Objects not in expected format...");
        NSLog(@"UserInfo: %@", [[aNotification userInfo] description]);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // Update version information if paths have changed
    if (([keyPath isEqualToString:@"values.makepkginfoPath"]) ||
        ([keyPath isEqualToString:@"values.makecatalogsPath"]))
    {
        [[MAMunkiRepositoryManager sharedManager] updateMunkiVersions];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    
    // Observe user defaults for changes in makepkginfo and makecatalogs paths
    NSUserDefaultsController *dc = [NSUserDefaultsController sharedUserDefaultsController];
    [dc addObserver:self forKeyPath:@"values.makepkginfoPath" options:NSKeyValueObservingOptionNew context:NULL];
    [dc addObserver:self forKeyPath:@"values.makecatalogsPath" options:NSKeyValueObservingOptionNew context:NULL];
    
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
		[self.progressIndicator setDoubleValue:[self.progressIndicator maxValue]];
		[NSApp endSheet:self.progressPanel];
		[self.progressPanel close];
		[self.progressIndicator stopAnimation:self];
        [self postStatusUpdateReadyToReceive:YES];
	}
	
	else {
		// Update progress
		self.queueStatusDescription = [NSString stringWithFormat:@"%i items remaining", numOp - 1];
		if (numOp == 1) {
			[self.progressIndicator setIndeterminate:YES];
			[self.progressIndicator startAnimation:self];
		} else {
			[self.progressIndicator setIndeterminate:NO];
			double currentProgress = [self.progressIndicator maxValue] - (double)numOp + 1;
			[self.progressIndicator setDoubleValue:currentProgress];
		}
		
		// Get the currently running operation
		//id firstOpItem = [[self.operationQueue operations] objectAtIndex:0];
        
        for (id firstOpItem in [self.operationQueue operations]) {
            if ([firstOpItem isExecuting]) {
                // Running item is PkginfoScanner
                if ([firstOpItem isKindOfClass:[MAPkginfoScanner class]]) {
                    self.currentStatusDescription = [NSString stringWithFormat:@"%@", [firstOpItem fileName]];
                    self.jobDescription = @"Scanning Packages";
                }
                
                // Running item is ManifestScanner
                else if ([firstOpItem isKindOfClass:[MAManifestScanner class]]) {
                    self.currentStatusDescription = [NSString stringWithFormat:@"%@", [firstOpItem fileName]];
                    self.jobDescription = @"Scanning Manifests";
                }
                
                // Running item is MunkiOperation
                else if ([firstOpItem isKindOfClass:[MAMunkiOperation class]]) {
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
                else if ([firstOpItem isKindOfClass:[MAFileCopyOperation class]]) {
                    self.jobDescription = @"Copying";
                    self.currentStatusDescription = [NSString stringWithFormat:@"%@", [[firstOpItem sourceURL] lastPathComponent]];
                }
                
                // Running item is MunkiOperation
                else if ([firstOpItem isKindOfClass:[MARelationshipScanner class]]) {
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
	self.operationTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
													  target:self
													selector:@selector(checkOperations:)
													userInfo:nil
													 repeats:YES];
}

- (void)showProgressPanel
{
	[NSApp beginSheet:self.progressPanel
	   modalForWindow:self.window modalDelegate:nil 
	   didEndSelector:nil contextInfo:nil];
	[self.progressIndicator setDoubleValue:0.0];
	[self.progressIndicator setMaxValue:[self.operationQueue operationCount]];
	[self.progressIndicator startAnimation:self];
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
    ManifestMO *selectedManifest = [[self.manifestsArrayController selectedObjects] objectAtIndex:0];
    
    /*
     Ask for a new location and name
     */
    NSURL *currentURL = (NSURL *)selectedManifest.manifestURL;
    NSString *newFilename = [selectedManifest fileName];
    NSString *message = NSLocalizedString(([NSString stringWithFormat:@"Choose a new location and name for \"%@\".", [selectedManifest fileName]]), nil);
    
    NSURL *newURL = [self showSavePanelForManifestWithTitle:@"Move or rename a manifest"
                                                   filename:newFilename
                                                    message:message
                                               directoryURL:[currentURL URLByDeletingLastPathComponent]];
    if (!newURL) {
        if ([self.defaults boolForKey:@"debug"]) NSLog(@"User cancelled move/rename operation");
        return;
    }
    
    /*
     The actual renaming is handled by MunkiRepositoryManager
     */
    [[MAMunkiRepositoryManager sharedManager] moveManifest:selectedManifest toURL:newURL cascade:YES];
    
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
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    
    ManifestMO *selectedManifest = [[self.manifestsArrayController selectedObjects] objectAtIndex:0];
    
    NSURL *currentURL = (NSURL *)selectedManifest.manifestURL;
    NSString *newFilename = [selectedManifest fileName];
    NSString *message = NSLocalizedString(@"Choose a location and name for the duplicated manifest.", nil);
    
    NSURL *newURL = [self showSavePanelForManifestWithTitle:@"Duplicate manifest"
                                                   filename:newFilename
                                                    message:message
                                               directoryURL:nil];
    if (!newURL) {
        if ([self.defaults boolForKey:@"debug"]) NSLog(@"User cancelled duplicate operation");
        return;
    }
    
    if ([[NSFileManager defaultManager] copyItemAtURL:currentURL toURL:newURL error:nil]) {
        
        MARelationshipScanner *manifestRelationships = [MARelationshipScanner manifestScanner];
        manifestRelationships.delegate = self;
        
        MAManifestScanner *scanOp = [[MAManifestScanner alloc] initWithURL:newURL];
        scanOp.delegate = self;
        [manifestRelationships addDependency:scanOp];
        [self.operationQueue addOperation:scanOp];
        [self.operationQueue addOperation:manifestRelationships];
        
        [self showProgressPanel];
    } else {
        NSLog(@"Failed to copy manifest on disk");
    }
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
	
	NSArray *selectedManifests = [self.manifestsArrayController selectedObjects];
    
	// Configure the dialog
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Delete"];
    [alert addButtonWithTitle:@"Cancel"];
    
    NSString *messageText;
    NSString *informativeText;
    if ([selectedManifests count] > 1) {
        messageText = @"Delete manifests";
        informativeText = [NSString stringWithFormat:
                           @"Are you sure you want to delete %lu manifests? MunkiAdmin will move the selected manifest files to trash and remove all references to them in other manifests.",
                           (unsigned long)[selectedManifests count]];
    } else if ([selectedManifests count] == 1) {
        messageText = [NSString stringWithFormat:@"Delete manifest \"%@\"", [[selectedManifests objectAtIndex:0] title]];
        informativeText = [NSString stringWithFormat:
                           @"Are you sure you want to delete manifest \"%@\"? MunkiAdmin will move the manifest file to trash and remove all references to it in other manifests.",
                           [[selectedManifests objectAtIndex:0] title]];
    } else {
        NSLog(@"No manifests selected, can't delete anything...");
        return;
    }
    [alert setMessageText:messageText];
    [alert setInformativeText:informativeText];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert setShowsSuppressionButton:NO];
	
	NSInteger result = [alert runModal];
	if (result == NSAlertFirstButtonReturn) {
        [[self.managedObjectContext undoManager] beginUndoGrouping];
        [[self.managedObjectContext undoManager] setActionName:messageText];
		for (ManifestMO *aManifest in selectedManifests) {
            [[MAMunkiRepositoryManager sharedManager] removeManifest:aManifest withReferences:YES];
		}
        [[self.managedObjectContext undoManager] endUndoGrouping];
	}
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
    
    NSString *newFilename = NSLocalizedString(@"new-manifest", nil);
    NSString *message = NSLocalizedString(@"Choose a location and name for the new manifest. Location should be within your manifests directory.", nil);
    
    NSURL *newURL = [self showSavePanelForManifestWithTitle:@"Create manifest"
                                                   filename:newFilename
                                                    message:message
                                               directoryURL:nil];
    if (!newURL) {
        if ([self.defaults boolForKey:@"debug"]) NSLog(@"User cancelled new manifest creation");
        return;
    }
    
    ManifestMO *newManifest = [[MACoreDataManager sharedManager] createManifestWithURL:newURL inManagedObjectContext:self.managedObjectContext];
    [self.managedObjectContext save:nil];
    
    MARelationshipScanner *manifestRelationships = [MARelationshipScanner manifestScanner];
    manifestRelationships.delegate = self;
    
    MAManifestScanner *scanOp = [[MAManifestScanner alloc] initWithURL:(NSURL *)newManifest.manifestURL];
    scanOp.delegate = self;
    [manifestRelationships addDependency:scanOp];
    [self.operationQueue addOperation:scanOp];
    [self.operationQueue addOperation:manifestRelationships];
    
    [self showProgressPanel];
}

- (IBAction)createNewManifestAction:sender
{
	[self createNewManifest];
}


# pragma mark - Modifying packages

- (void)packageNameEditorDidFinish:(id)sender returnCode:(int)returnCode object:(id)object
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    for (PackageMO *aPackage in [[MAMunkiRepositoryManager sharedManager] modifiedPackagesSinceLastSave]) {
        aPackage.hasUnstagedChangesValue = YES;
    }
    if (self.packageNameEditor.packageToRename) {
        [[[self managedObjectContext] undoManager] setActionName:[NSString stringWithFormat:@"Rename to \"%@\"", [self.packageNameEditor.packageToRename munki_name]]];
    }
    [[[self managedObjectContext] undoManager] endUndoGrouping];
    if (returnCode == NSOKButton) return;
    [[[self managedObjectContext] undoManager] undo];
}


- (void)renameSelectedPackages
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    
    PackageMO *firstSelected = [[[self.packagesViewController packagesArrayController] selectedObjects] objectAtIndex:0];
    
    if (!firstSelected) return;
    
    [[[self managedObjectContext] undoManager] beginUndoGrouping];
    [[[self managedObjectContext] undoManager] setActionName:[NSString stringWithFormat:@"Rename \"%@\"", firstSelected.munki_name]];
    
    self.packageNameEditor.packageToRename = firstSelected;
    [self.packageNameEditor configureRenameOperation];
    SEL endSelector = @selector(packageNameEditorDidFinish:returnCode:object:);
    [NSApp beginSheet:[self.packageNameEditor window]
	   modalForWindow:[self window] modalDelegate:self
	   didEndSelector:endSelector contextInfo:nil];
    
}

- (IBAction)renameSelectedPackagesAction:sender
{
    [self renameSelectedPackages];
}


- (void)deleteSelectedPackages
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	
	NSArray *selectedPackages = [[self.packagesViewController packagesArrayController] selectedObjects];
	
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
            [[MAMunkiRepositoryManager sharedManager] removePackage:aPackage withInstallerItem:YES withReferences:YES];
		}
	}
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
        
        [[MACoreDataManager sharedManager] createCatalogWithTitle:[textField stringValue] inManagedObjectContext:self.managedObjectContext];
		
    } else if ( result == NSAlertSecondButtonReturn ) {
        
    }
}

- (IBAction)createNewCatalogAction:sender
{
	[self createNewCatalog];
}

- (void)enableAllPackagesForManifest
{
	ManifestMO *selectedManifest = [[self.manifestsArrayController selectedObjects] objectAtIndex:0];
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
	ManifestMO *selectedManifest = [[self.manifestsArrayController selectedObjects] objectAtIndex:0];
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
        BOOL iconsDirCreated = [fm createDirectoryAtPath:[newRepoPath stringByAppendingPathComponent:@"icons"] withIntermediateDirectories:YES attributes:nil error:nil];
		BOOL manifestsDirCreated = [fm createDirectoryAtPath:[newRepoPath stringByAppendingPathComponent:@"manifests"] withIntermediateDirectories:YES attributes:nil error:nil];
		BOOL pkgsDirCreated = [fm createDirectoryAtPath:[newRepoPath stringByAppendingPathComponent:@"pkgs"] withIntermediateDirectories:YES attributes:nil error:nil];
		BOOL pkgsinfoDirCreated = [fm createDirectoryAtPath:[newRepoPath stringByAppendingPathComponent:@"pkgsinfo"] withIntermediateDirectories:YES attributes:nil error:nil];
		if (catalogsDirCreated && iconsDirCreated && manifestsDirCreated && pkgsDirCreated && pkgsinfoDirCreated) {
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
	}
	else {
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Can't assimilate. %lu results found for package search", (unsigned long)numFoundPkgs);
	}

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
            [[MACoreDataManager sharedManager] configureSourceListDirectoriesSection:self.managedObjectContext];
            
            // Create a scanner job but run it without an operation queue
            MAPkginfoScanner *scanOp = [MAPkginfoScanner scannerWithURL:newPkginfoURL];
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
                
                // Select the newly created package
                [[self.packagesViewController packagesArrayController] setSelectedObjects:[NSArray arrayWithObject:createdPkg]];
                
                // Run the assimilator
                if ([self.defaults boolForKey:@"assimilate_enabled"]) {
                    MAMunkiRepositoryManager *repoManager = [MAMunkiRepositoryManager sharedManager];
                    [repoManager assimilatePackageWithPreviousVersion:createdPkg keys:repoManager.pkginfoAssimilateKeysForAuto];
                }
                
                /*
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[self managedObjectContext] undoManager] beginUndoGrouping];
                    [[[self managedObjectContext] undoManager] setActionName:[NSString stringWithFormat:@"Assimilating \"%@\"", [createdPkg titleWithVersion]]];
                    [pkginfoAssimilator beginEditSessionWithObject:createdPkg source:nil delegate:self];
                });
                 */
            }
            else {
                // Found multiple matches for a single URL
            }
            
            
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
    [[self.packagesViewController packagesArrayController] setManagedObjectContext:[self managedObjectContext]];
    [[self.packagesViewController packagesArrayController] setEntityName:@"Package"];
    if ([[self.packagesViewController packagesArrayController] fetchWithRequest:nil merge:YES error:nil]) {
        [[self.packagesViewController packagesArrayController] setAutomaticallyPreparesContent:YES];
        [[self.packagesViewController packagesArrayController] setSelectionIndex:0];
    }
    [[self.packagesViewController directoriesTreeController] setManagedObjectContext:[self managedObjectContext]];
    [[self.packagesViewController directoriesTreeController] setEntityName:@"PackageSourceListItem"];
    if ([[self.packagesViewController directoriesTreeController] fetchWithRequest:nil merge:YES error:nil]) {
        [[self.packagesViewController directoriesTreeController] setAutomaticallyPreparesContent:YES];
        [[self.packagesViewController directoriesOutlineView] expandItem:nil expandChildren:YES];
        NSUInteger defaultIndexes[] = {0,0};
        [[self.packagesViewController directoriesTreeController] setSelectionIndexPath:[NSIndexPath indexPathWithIndexes:defaultIndexes length:2]];
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
    [[self.packagesViewController packagesArrayController] setManagedObjectContext:nil];
    [[self.packagesViewController directoriesTreeController] setManagedObjectContext:nil];
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
        [[self.packagesViewController directoriesOutlineView] expandItem:nil expandChildren:YES];
        NSUInteger defaultIndexes[] = {0,0};
        [[self.packagesViewController directoriesTreeController] setSelectionIndexPath:[NSIndexPath indexPathWithIndexes:defaultIndexes length:2]];
    }
}

- (void)postStatusUpdateReadyToReceive:(BOOL)readyToReceive
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSEntityDescription *entityDescr = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescr];
    NSPredicate *appleUpdates = [NSPredicate predicateWithFormat:@"munki_installer_type == %@", @"apple_update_metadata"];
    [fetchRequest setPredicate:appleUpdates];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"munki_name"]];
	NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:nil];
    NSArray *appleUpdateNames = [fetchResults valueForKeyPath:@"munki_name"];
    
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    [dnc postNotificationName:kMunkiAdminStatusChangeName
                       object:nil
                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:readyToReceive], @"readyToReceive", appleUpdateNames, @"appleUpdateMetadataNames", nil]
           deliverImmediately:YES];
}

- (void)mergeChanges:(NSNotification*)notification
{
	NSAssert([NSThread mainThread], @"Not on the main thread");
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"Merging changes in main thread");
	}
	[[self managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
}

# pragma mark - Pkginfo Assimilator IBActions

- (void)pkginfoAssimilatorDidFinish:(id)sender returnCode:(int)returnCode object:(id)object
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    [self.managedObjectContext refreshObject:[pkginfoAssimilator targetPkginfo] mergeChanges:YES];
    for (PackageMO *aPackage in [[MAMunkiRepositoryManager sharedManager] modifiedPackagesSinceLastSave]) {
        aPackage.hasUnstagedChangesValue = YES;
    }
    [[[self managedObjectContext] undoManager] endUndoGrouping];
    if (returnCode == NSOKButton) return;
    [[[self managedObjectContext] undoManager] undo];
}


- (IBAction)startPkginfoAssimilatorAction:(id)sender
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    if (currentWholeView == [self.packagesViewController view]) {
        
        PackageMO *object = [[[self.packagesViewController packagesArrayController] selectedObjects] lastObject];
        if (!object) return;
        
        [[[self managedObjectContext] undoManager] beginUndoGrouping];
        [[[self managedObjectContext] undoManager] setActionName:[NSString stringWithFormat:@"Assimilating \"%@\"", [object titleWithVersion]]];
        
        [pkginfoAssimilator beginEditSessionWithObject:object source:nil delegate:self];
        
        NSPredicate *denySelfPred = [NSPredicate predicateWithFormat:@"SELF != %@", object];
        [pkginfoAssimilator.allPackagesArrayController setFilterPredicate:denySelfPred];
    }
}

# pragma mark - Advanced package editor IBActions

- (void)packageEditorDidFinish:(id)sender returnCode:(int)returnCode object:(id)object
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    [self.managedObjectContext refreshObject:[advancedPackageEditor pkginfoToEdit] mergeChanges:YES];
    for (PackageMO *aPackage in [[MAMunkiRepositoryManager sharedManager] modifiedPackagesSinceLastSave]) {
        aPackage.hasUnstagedChangesValue = YES;
    }
    [[[self managedObjectContext] undoManager] endUndoGrouping];
    if (returnCode == NSOKButton) return;
    [[[self managedObjectContext] undoManager] undo];
}

- (IBAction)selectNextPackageForEditing:(id)sender
{
    // Commit any changes
    [advancedPackageEditor commitChangesToCurrentPackage];
    
    // Change selection
    NSIndexSet *currentIndexes = [[self.packagesViewController packagesArrayController] selectionIndexes];
    if ([currentIndexes lastIndex] < [[[self.packagesViewController packagesArrayController] arrangedObjects] count] - 1) {
        [[self.packagesViewController packagesArrayController] setSelectionIndex:[currentIndexes lastIndex]+1];
        
        // Populate new values
        PackageMO *object = [[[self.packagesViewController packagesArrayController] selectedObjects] objectAtIndex:0];
        [advancedPackageEditor setPkginfoToEdit:object];
        [advancedPackageEditor setDefaultValuesFromPackage:object];
    }
}

- (IBAction)selectPreviousPackageForEditing:(id)sender
{
    // Commit any changes
    [advancedPackageEditor commitChangesToCurrentPackage];
    
    // Change selection
    NSIndexSet *currentIndexes = [[self.packagesViewController packagesArrayController] selectionIndexes];
    if ([currentIndexes lastIndex] > 0) {
        [[self.packagesViewController packagesArrayController] setSelectionIndex:([currentIndexes lastIndex] - 1)];
        
        // Populate new values
        PackageMO *object = [[[self.packagesViewController packagesArrayController] selectedObjects] objectAtIndex:0];
        [advancedPackageEditor setPkginfoToEdit:object];
        [advancedPackageEditor setDefaultValuesFromPackage:object];
    }
}

- (IBAction)getInfoAction:(id)sender
{
    if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    
    if (currentWholeView == [self.packagesViewController view]) {
        
        PackageMO *object = [[[self.packagesViewController packagesArrayController] selectedObjects] lastObject];
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
    
    NSArray *selectedManifests = [self.manifestsArrayController selectedObjects];
    NSArray *selectedConditionalItems = [[self.manifestDetailViewController conditionsTreeController] selectedObjects];
    
    for (ManifestMO *selectedManifest in selectedManifests) {
        if ([[[self.manifestDetailViewController conditionsTreeController] selectedObjects] count] == 0) {
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
    
    ManifestMO *selectedManifest = [[self.manifestsArrayController selectedObjects] objectAtIndex:0];
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
    ConditionalItemMO *selectedCondition = [[self.manifestDetailViewController.conditionsTreeController selectedObjects] lastObject];
    
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
    ManifestMO *selectedManifest = [[self.manifestsArrayController selectedObjects] objectAtIndex:0];
    
    for (ConditionalItemMO *aConditionalItem in [self.manifestDetailViewController.conditionsTreeController selectedObjects]) {
        [self.managedObjectContext deleteObject:aConditionalItem];
    }
    [self.managedObjectContext refreshObject:selectedManifest mergeChanges:YES];
}

- (IBAction)addNewIncludedManifestAction:(id)sender
{
    [NSApp beginSheet:[selectManifestsWindowController window] 
	   modalForWindow:self.window modalDelegate:nil 
	   didEndSelector:nil contextInfo:nil];
    
    ManifestMO *selectedManifest = [[self.manifestsArrayController selectedObjects] objectAtIndex:0];
    NSMutableArray *tempPredicates = [[NSMutableArray alloc] init];
    
    for (StringObjectMO *aNestedManifest in [selectedManifest includedManifestsFaster]) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"title != %@", aNestedManifest.title];
        [tempPredicates addObject:newPredicate];
    }
    NSPredicate *denySelfPred = [NSPredicate predicateWithFormat:@"title != %@", selectedManifest.title];
    [tempPredicates addObject:denySelfPred];
    NSPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates:tempPredicates];
    [selectManifestsWindowController setOriginalPredicate:compPred];
    [selectManifestsWindowController updateSearchPredicate];
}

- (IBAction)removeIncludedManifestAction:(id)sender
{
    ManifestMO *selectedManifest = [[self.manifestsArrayController selectedObjects] objectAtIndex:0];
    
    for (StringObjectMO *anIncludedManifest in [self.manifestDetailViewController.includedManifestsController selectedObjects]) {
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
    
    ManifestMO *selectedManifest = [[self.manifestsArrayController selectedObjects] objectAtIndex:0];
    NSMutableArray *tempPredicates = [[NSMutableArray alloc] init];
    
    for (StringObjectMO *aManagedInstall in [selectedManifest managedInstallsFaster]) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"munki_name != %@", aManagedInstall.title];
        [tempPredicates addObject:newPredicate];
    }
    NSPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates:tempPredicates];
    [addItemsWindowController setHideAddedPredicate:compPred];
    [addItemsWindowController updateGroupedSearchPredicate];
    [addItemsWindowController updateIndividualSearchPredicate];
}

- (IBAction)removeManagedInstallAction:(id)sender
{
    ManifestMO *selectedManifest = [[self.manifestsArrayController selectedObjects] objectAtIndex:0];
    
    for (StringObjectMO *aManagedInstall in [self.manifestDetailViewController.managedInstallsController selectedObjects]) {
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
    
    ManifestMO *selectedManifest = [[self.manifestsArrayController selectedObjects] objectAtIndex:0];
    NSMutableArray *tempPredicates = [[NSMutableArray alloc] init];
    
    for (StringObjectMO *aManagedUninstall in [selectedManifest managedUninstallsFaster]) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"munki_name != %@", aManagedUninstall.title];
        [tempPredicates addObject:newPredicate];
    }
    NSPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates:tempPredicates];
    [addItemsWindowController setHideAddedPredicate:compPred];
    [addItemsWindowController updateGroupedSearchPredicate];
    [addItemsWindowController updateIndividualSearchPredicate];
}

- (IBAction)removeManagedUninstallAction:(id)sender
{
    ManifestMO *selectedManifest = [[self.manifestsArrayController selectedObjects] objectAtIndex:0];
    
    for (StringObjectMO *aManagedUninstall in [self.manifestDetailViewController.managedUninstallsController selectedObjects]) {
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
    
    ManifestMO *selectedManifest = [[self.manifestsArrayController selectedObjects] objectAtIndex:0];
    NSMutableArray *tempPredicates = [[NSMutableArray alloc] init];
    
    for (StringObjectMO *aManagedUpdate in [selectedManifest managedUpdatesFaster]) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"munki_name != %@", aManagedUpdate.title];
        [tempPredicates addObject:newPredicate];
    }
    NSPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates:tempPredicates];
    [addItemsWindowController setHideAddedPredicate:compPred];
    [addItemsWindowController updateGroupedSearchPredicate];
    [addItemsWindowController updateIndividualSearchPredicate];
}

- (IBAction)removeManagedUpdateAction:(id)sender
{
    ManifestMO *selectedManifest = [[self.manifestsArrayController selectedObjects] objectAtIndex:0];
    
    for (StringObjectMO *aManagedUpdate in [self.manifestDetailViewController.managedUpdatesController selectedObjects]) {
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
    
    ManifestMO *selectedManifest = [[self.manifestsArrayController selectedObjects] objectAtIndex:0];
    NSMutableArray *tempPredicates = [[NSMutableArray alloc] init];
    
    for (StringObjectMO *anOptionalInstall in [selectedManifest optionalInstallsFaster]) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"munki_name != %@", anOptionalInstall.title];
        [tempPredicates addObject:newPredicate];
    }
    NSPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates:tempPredicates];
    [addItemsWindowController setHideAddedPredicate:compPred];
    [addItemsWindowController updateGroupedSearchPredicate];
    [addItemsWindowController updateIndividualSearchPredicate];
}

- (IBAction)removeOptionalInstallAction:(id)sender
{
    ManifestMO *selectedManifest = [[self.manifestsArrayController selectedObjects] objectAtIndex:0];
    
    for (StringObjectMO *anOptionalInstall in [self.manifestDetailViewController.optionalInstallsController selectedObjects]) {
        [self.managedObjectContext deleteObject:anOptionalInstall];
    }
    [self.managedObjectContext refreshObject:selectedManifest mergeChanges:YES];
}

- (IBAction)processAddNestedManifestAction:(id)sender
{
    NSString *selectedTabViewLabel = [[[selectManifestsWindowController tabView] selectedTabViewItem] label];
    for (ManifestMO *selectedManifest in [self.manifestsArrayController selectedObjects]) {
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
    for (ManifestMO *selectedManifest in [self.manifestsArrayController selectedObjects]) {
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

- (void)setupCopyOperation:(MAFileCopyOperation *)copyOp withDependingOperation:(MAMunkiOperation *)depOp
{
    [depOp addDependency:copyOp];
    copyOp.delegate = self;
}

- (void)setupMakepkginfoOperation:(MAMunkiOperation *)theOp withDependingOperation:(MARelationshipScanner *)relScan
{
    [relScan addDependency:theOp];
    theOp.delegate = self;
}

- (void)addNewPackagesFromFileURLs:(NSArray *)filesToAdd
{
    if ([self.defaults boolForKey:@"debug"]) NSLog(@"Adding %lu files to repository", (unsigned long)[filesToAdd count]);
    
    [self disableAllBindings];
    
    MARelationshipScanner *packageRelationships = [MARelationshipScanner pkginfoScanner];
    packageRelationships.delegate = self;
    
    NSMutableArray *operationsToAdd = [[NSMutableArray alloc] init];
    for (NSURL *fileToAdd in filesToAdd) {
        if (fileToAdd != nil) {
            MAMunkiOperation *theOp;
            
            if (![[fileToAdd relativePath] hasPrefix:[self.pkgsURL relativePath]]) {
                if (([self.defaults boolForKey:@"CopyPkgsToRepo"]) &&
                    ([[NSFileManager defaultManager] fileExistsAtPath:[self.pkgsURL relativePath]])) {
                    if ([self.defaults boolForKey:@"debug"])
                        NSLog(@"%@ not within %@ -> Should copy", [fileToAdd relativePath], [self.pkgsURL relativePath]);
                    NSURL *newTarget = [self showSavePanelForCopyOperation:[[fileToAdd relativePath] lastPathComponent]];
                    if (newTarget) {
                        MAFileCopyOperation *copyOp = [MAFileCopyOperation fileCopySourceURL:fileToAdd toTargetURL:newTarget];
                        theOp = [MAMunkiOperation makepkginfoOperationWithSource:newTarget];
                        [self setupCopyOperation:copyOp withDependingOperation:theOp];
                        [self setupMakepkginfoOperation:theOp withDependingOperation:packageRelationships];
                        [operationsToAdd addObject:copyOp];
                        [operationsToAdd addObject:theOp];
                    } else {
                        if ([self.defaults boolForKey:@"debug"])
                            NSLog(@"User chose to cancel the copy operation for %@. Bailing out...", [fileToAdd relativePath]);
                    }
                    
                } else {
                    theOp = [MAMunkiOperation makepkginfoOperationWithSource:fileToAdd];
                    [self setupMakepkginfoOperation:theOp withDependingOperation:packageRelationships];
                    [operationsToAdd addObject:theOp];
                }
                
            } else {
                theOp = [MAMunkiOperation makepkginfoOperationWithSource:fileToAdd];
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

- (IBAction)addNewPackage:sender
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	
	if ([self makepkginfoInstalled]) {
		NSArray *filesToAdd = [self chooseFilesForMakepkginfo];
		if (filesToAdd) {
			[self addNewPackagesFromFileURLs:filesToAdd];
		}
	} else {
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Can't find %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"makepkginfoPath"]);
        [self alertMunkiToolNotInstalled:@"makepkginfo"];
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
					MAMunkiOperation *theOp = [MAMunkiOperation installsItemFromURL:fileToAdd];
					theOp.delegate = self;
					[self.operationQueue addOperation:theOp];
				}
			}
			[self showProgressPanel];
		}
	} else {
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Can't find %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"makepkginfoPath"]);
        [self alertMunkiToolNotInstalled:@"makepkginfo"];
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
		
		MAMunkiOperation *op = [MAMunkiOperation makecatalogsOperationWithTarget:self.repoURL];
		op.delegate = self;
		[self.operationQueue addOperation:op];
		[self showProgressPanel];
		
	} else {
		NSLog(@"Can't find %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"makecatalogsPath"]);
        [self alertMunkiToolNotInstalled:@"makecatalogs"];
	}
}

- (IBAction)updateCatalogs:sender
{
	// Run makecatalogs against the current repo
	if ([self makecatalogsInstalled]) {
        MAMunkiOperation *op = [[MAMunkiOperation alloc] initWithCommand:@"makecatalogs" targetURL:self.repoURL arguments:nil];
        op.delegate = self;
        [self.operationQueue addOperation:op];
        [self showProgressPanel];
    } else {
        NSLog(@"Can't find %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"makecatalogsPath"]);
        [self alertMunkiToolNotInstalled:@"makecatalogs"];
    }
}


- (IBAction)writeChangesToDisk:sender
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	[[MAMunkiRepositoryManager sharedManager] writePackagePropertyListsToDisk];
	[[MAMunkiRepositoryManager sharedManager] writeManifestPropertyListsToDisk];
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

- (BOOL)resetPersistentStore
{
    /*
     Delete all existing stores
     */
    for (NSPersistentStore *aStore in self.persistentStoreCoordinator.persistentStores) {
        NSError *removeError = nil;
        if (![self.persistentStoreCoordinator removePersistentStore:aStore error:&removeError]) {
            [[NSApplication sharedApplication] presentError:removeError];
            return NO;
        }
    }
    
    /*
     Create a new in-memory store
     */
    NSError *addError = nil;
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                       configuration:nil
                                                                 URL:nil
                                                             options:nil
                                                               error:&addError]){
        [[NSApplication sharedApplication] presentError:addError];
        _persistentStoreCoordinator = nil;
        return NO;
    }
    return YES;
}

- (void)selectRepoAtURL:(NSURL *)newURL
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"Selecting repo: %@", [newURL relativePath]);
	}
    
    [self stopObservingObjectsForChanges];
    [self disableAllBindings];
    
    /*
     This is much faster than deleting everything individually
     */
    if (![self resetPersistentStore]) {
        return;
    }
    
    
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
            self.iconsURL = [self.repoURL URLByAppendingPathComponent:@"icons"];
            
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
	
}


- (void)scanCurrentRepoForPackages
{
    /*
     Scan the current repo for already existing pkginfo files
     and create a new Package object for each of them
	*/
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"Scanning selected repo for packages");
	}
	
    /*
     Setup the REPOSITORIES section for side bar
     */
    [[MACoreDataManager sharedManager] configureSourceListRepositorySection:self.managedObjectContext];
    
    /*
     Setup the DIRECTORIES section for side bar
     */
    [[MACoreDataManager sharedManager] configureSourceListDirectoriesSection:self.managedObjectContext];
    
    /*
     Setup the INSTALLER TYPES section for side bar
     */
    [[MACoreDataManager sharedManager] configureSourceListInstallerTypesSection:self.managedObjectContext];
    
	NSArray *keysToget = [NSArray arrayWithObjects:NSURLNameKey, NSURLLocalizedNameKey, NSURLIsDirectoryKey, nil];
	NSFileManager *fm = [NSFileManager defaultManager];
    
    MARelationshipScanner *packageRelationships = [MARelationshipScanner pkginfoScanner];
    packageRelationships.delegate = self;

	NSDirectoryEnumerator *pkgsInfoDirEnum = [fm enumeratorAtURL:self.pkgsInfoURL includingPropertiesForKeys:keysToget options:(NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:nil];
	for (NSURL *anURL in pkgsInfoDirEnum)
	{
		NSNumber *isDir;
		[anURL getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
		if (![isDir boolValue]) {
			MAPkginfoScanner *scanOp = [MAPkginfoScanner scannerWithURL:anURL];
			scanOp.delegate = self;
            [packageRelationships addDependency:scanOp];
			[self.operationQueue addOperation:scanOp];
			
		} else {
            //NSLog(@"Got directory: %@", [anURL relativePath]);
        }
	}
    
    [self.operationQueue addOperation:packageRelationships];
}

- (void)scanCurrentRepoForCatalogFiles
{
    /*
     Scan the current repo for already existing catalog files
     and create a new Catalog object for each of them
     */
	
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
    /*
	 Scan the current repo for already existing manifest files
	 and create a new Manifest object for each of them
     */
	
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
			
            /*
             Manifest name should be the relative path from manifests subdirectory
             */
            NSArray *manifestComponents = [aManifestFile pathComponents];
            NSArray *manifestDirComponents = [self.manifestsURL pathComponents];
            NSMutableArray *relativePathComponents = [NSMutableArray arrayWithArray:manifestComponents];
            [relativePathComponents removeObjectsInArray:manifestDirComponents];
            NSString *manifestRelativePath = [relativePathComponents componentsJoinedByString:@"/"];
            
			NSFetchRequest *request = [[NSFetchRequest alloc] init];
			[request setEntity:entityDescription];
			NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title == %@", manifestRelativePath];
			[request setPredicate:titlePredicate];
			ManifestMO *manifest;
			NSUInteger foundItems = [moc countForFetchRequest:request error:nil];
			if (foundItems == 0) {
				manifest = [NSEntityDescription insertNewObjectForEntityForName:@"Manifest" inManagedObjectContext:moc];
				manifest.title = manifestRelativePath;
				manifest.manifestURL = aManifestFile;
			}
			
		}
	}
	NSError *error = nil;
	if (![moc save:&error]) {
		[NSApp presentError:error];
	}
    [[moc undoManager] enableUndoRegistration];
    
    MARelationshipScanner *manifestRelationships = [MARelationshipScanner manifestScanner];
    manifestRelationships.delegate = self;
	for (ManifestMO *aManifest in [self allObjectsForEntity:@"Manifest"]) {
		MAManifestScanner *scanOp = [[MAManifestScanner alloc] initWithURL:(NSURL *)aManifest.manifestURL];
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
    
    NSBlockOperation *startObservingChangesOp = [NSBlockOperation blockOperationWithBlock:^{
        [self performSelectorOnMainThread:@selector(startObservingObjectsForChanges) withObject:nil waitUntilDone:YES];
    }];
    [startObservingChangesOp addDependency:enableBindingsOp];
    [self.operationQueue addOperation:startObservingChangesOp];
}

- (void)scanCurrentRepoForIncludedManifests
{
	/*
     Scan the current repo for included manifests
     */
    
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

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

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

    if (_managedObjectModel) return _managedObjectModel;
	
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The directory for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (_persistentStoreCoordinator) return _persistentStoreCoordinator;

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
    
    //NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                configuration:nil 
                                                URL:nil
                                                options:nil 
                                                error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        _persistentStoreCoordinator = nil;
        return nil;
    }    

    return _persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (_managedObjectContext) return _managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator: coordinator];

    return _managedObjectContext;
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
	
	if ([self.defaults boolForKey:@"UpdatePkginfosOnSave"]) {
		[[MAMunkiRepositoryManager sharedManager] writePackagePropertyListsToDisk];
	}
	if ([self.defaults boolForKey:@"UpdateManifestsOnSave"]) {
		[[MAMunkiRepositoryManager sharedManager] writeManifestPropertyListsToDisk];
	}
	if ([self.defaults boolForKey:@"UpdateCatalogsOnSave"]) {
		[self updateCatalogs];
	}
    
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
	
	[self.applicationTableView reloadData];
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    /*
     This is not foolproof in any way but should catch most of the scenarios
     */
    if ([_managedObjectContext hasChanges]) {
        NSString *question = NSLocalizedString(@"Changes have not been saved yet. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertSecondButtonReturn) {
            return NSTerminateCancel;
        } else {
            return NSTerminateNow;
        }
    }
    return NSTerminateNow;
}


/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void)dealloc {
    
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    [dnc removeObserver:self name:nil object:nil];
    
	
}

# pragma mark -
# pragma mark NSTabView delegates

- (IBAction)selectViewAction:sender
{
	switch ([sender tag]) {
		case 1:
			if (currentWholeView != [self.packagesViewController view]) {
				self.selectedViewDescr = @"Packages";
                currentWholeView = [self.packagesViewController view];
                currentDetailView = nil;
                currentSourceView = nil;
                [self.mainSegmentedControl setSelectedSegment:0];
				[self changeItemView];
            }
			break;
		case 2:
			if (currentDetailView != self.catalogsDetailView) {
				self.selectedViewDescr = @"Catalogs";
                currentWholeView = self.mainSplitView;
				currentDetailView = self.catalogsDetailView;
				currentSourceView = self.catalogsListView;
				[self.mainSegmentedControl setSelectedSegment:1];
				[self changeItemView];
			}
			break;
		case 3:
			if (currentDetailView != [self.manifestDetailViewController view]) {
				self.selectedViewDescr = @"Manifests";
                currentWholeView = self.mainSplitView;
				currentDetailView = [self.manifestDetailViewController view];
				currentSourceView = self.manifestsListView;
				[self.mainSegmentedControl setSelectedSegment:2];
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
            if (currentWholeView != [self.packagesViewController view]) {
				self.selectedViewDescr = @"Packages";
                currentDetailView = nil;
                currentSourceView = nil;
                currentWholeView = [self.packagesViewController view];
				[self changeItemView];
            }
			break;
		case 1:
            if (currentDetailView != self.catalogsDetailView) {
				self.selectedViewDescr = @"Catalogs";
                currentWholeView = self.mainSplitView;
				currentDetailView = self.catalogsDetailView;
				currentSourceView = self.catalogsListView;
				[self changeItemView];
            }
			break;
		case 2:
            if (currentDetailView != [self.manifestDetailViewController view]) {
				self.selectedViewDescr = @"Manifests";
                currentWholeView = self.mainSplitView;
				currentDetailView = [self.manifestDetailViewController view];
				currentSourceView = self.manifestsListView;
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
	NSArray *subViews = [self.detailViewPlaceHolder subviews];
	if ([subViews count] > 0)
	{
		[[subViews objectAtIndex:0] removeFromSuperview];
	}
	
	[self.detailViewPlaceHolder displayIfNeeded];
}

- (void)removeSubviews
{
    NSArray *subViews = [[self.window contentView] subviews];
    for (id aSubView in subViews) {
        [aSubView removeFromSuperview];
    }
    
    NSArray *detailSubViews = [self.detailViewPlaceHolder subviews];
	if ([detailSubViews count] > 0)
	{
		[[detailSubViews objectAtIndex:0] removeFromSuperview];
	}
	
	NSArray *sourceSubViews = [self.sourceViewPlaceHolder subviews];
	if ([sourceSubViews count] > 0)
	{
		[[sourceSubViews objectAtIndex:0] removeFromSuperview];
	}
}

- (void)changeItemView
{
    if (currentWholeView == [self.packagesViewController view]) {
        // remove the old subview
        [self removeSubviews];
        
        [[self.window contentView] addSubview:[self.packagesViewController view]];
        [[self.packagesViewController view] setFrame:[[self.window contentView] frame]];
        [[self.packagesViewController view] setFrameOrigin:NSMakePoint(0,0)];
        [[self.packagesViewController view] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        //[[self.packagesViewController directoriesOutlineView] expandItem:nil expandChildren:YES];
        //[[self.packagesViewController directoriesOutlineView] reloadData];
        //[[self.packagesViewController packagesArrayController] rearrangeObjects];
    } else {
        // remove the old subview
        [self removeSubviews];
        
        [[self.window contentView] addSubview:self.mainSplitView];
        [self.mainSplitView setFrame:[[self.window contentView] frame]];
        [self.mainSplitView setFrameOrigin:NSMakePoint(0,0)];
        [self.mainSplitView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        // add a spinning progress gear in case populating the icon view takes too long
        NSRect bounds = [self.detailViewPlaceHolder bounds];
        CGFloat x = (bounds.size.width-32)/2;
        CGFloat y = (bounds.size.height-32)/2;
        NSProgressIndicator* busyGear = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(x, y, 32, 32)];
        [busyGear setStyle:NSProgressIndicatorSpinningStyle];
        [busyGear startAnimation:self];
        [self.detailViewPlaceHolder addSubview:busyGear];
        //[detailViewPlaceHolder display];
        
        [self.detailViewPlaceHolder addSubview:currentDetailView];
        [self.sourceViewPlaceHolder addSubview:currentSourceView];
        
        [busyGear removeFromSuperview];
        
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
		currentDetailView = self.applicationsDetailView;
	} else if ([[tabViewItem label] isEqualToString:@"Catalogs"]) {
		currentDetailView = self.catalogsDetailView;
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
