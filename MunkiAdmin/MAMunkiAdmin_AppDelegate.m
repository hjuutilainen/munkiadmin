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
#import "MASelectPkginfoItemsWindow.h"
#import "MASelectManifestItemsWindow.h"
#import "MAPackageNameEditor.h"
#import "MAAdvancedPackageEditor.h"
#import "MAPackagesView.h"
#import "MAManifestsView.h"
#import "MAPkginfoAssimilator.h"
#import "MAMunkiRepositoryManager.h"
#import "MACoreDataManager.h"
#import "ManifestsArrayController.h"
#import "MAMunkiImportController.h"
#import <DevMateKit/DevMateKit.h>
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

#define kMunkiAdminStatusChangeName @"MunkiAdminDidChangeStatus"

@implementation MAMunkiAdmin_AppDelegate

# pragma mark -
# pragma mark Property Implementation Directives

@dynamic defaults;


# pragma mark -
# pragma mark Helper methods

- (IBAction)openPrivacyPolicy:(id)sender
{
    NSURL *privacyPolicyURL = [NSURL URLWithString:@"https://github.com/hjuutilainen/munkiadmin/wiki/Privacy-Policy"];
    [[NSWorkspace sharedWorkspace] openURL:privacyPolicyURL];
}

- (IBAction)showFeedbackDialog:(id)sender
{
    [DevMateKit showFeedbackDialog:nil inMode:DMFeedbackIndependentMode];
}

- (IBAction)findAction:(id)sender
{
    if (self.currentWholeView == [self.manifestsViewController view]) {
        [self.manifestsViewController toggleManifestsFindView];
    }
}

- (IBAction)openCurrentLogFileAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    if (self.currentFileLogger) {
        DDLogVerbose(@"Current Log File Info: %@", self.currentFileLogger.currentLogFileInfo);
        NSString *currentLogFilePath = self.currentFileLogger.currentLogFileInfo.filePath;
        if ([[NSFileManager defaultManager] fileExistsAtPath:currentLogFilePath]) {
            [[NSWorkspace sharedWorkspace] openFile:currentLogFilePath];
        } else {
            DDLogError(@"Error: File not found %@", currentLogFilePath);
        }
    } else {
        DDLogError(@"Error: No file logger enabled...");
    }
}

- (IBAction)openPreferencesAction:sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
	[self.preferencesController showWindow:self];
}

- (IBAction)openIconBatchExtractorAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    [self.packagesViewController batchExtractIcons];
}

- (IBAction)showPkginfoInFinderAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    NSURL *selectedURL = (NSURL *)[[[[self.packagesViewController packagesArrayController] selectedObjects] lastObject] packageInfoURL];
    if (selectedURL != nil) {
        [[NSWorkspace sharedWorkspace] selectFile:[selectedURL relativePath] inFileViewerRootedAtPath:[self.repoURL relativePath]];
    }
}

- (IBAction)showInstallerInFinderAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    NSURL *selectedURL = (NSURL *)[[[[self.packagesViewController packagesArrayController] selectedObjects] lastObject] packageURL];
    if (selectedURL != nil) {
        [[NSWorkspace sharedWorkspace] selectFile:[selectedURL relativePath] inFileViewerRootedAtPath:[self.repoURL relativePath]];
    }
}

- (IBAction)showManifestInFinderAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
	// Check if /usr/local/munki/makepkginfo exists
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *makepkginfoPath = [self.defaults stringForKey:@"makepkginfoPath"];
	if ([fm fileExistsAtPath:makepkginfoPath]) {
		return YES;
	} else {
		DDLogError(@"Can't find %@. Check the paths to munki tools.", makepkginfoPath);
		return NO;
	}
}

- (BOOL)makecatalogsInstalled
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
	// Check if /usr/local/munki/makecatalogs exists
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *makecatalogsPath = [self.defaults stringForKey:@"makecatalogsPath"];
	if ([fm fileExistsAtPath:makecatalogsPath]) {
		return YES;
	} else {
		DDLogError(@"Can't find %@. Check the paths to munki tools.", makecatalogsPath);
		return NO;
	}
}

- (void)updateSourceList
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    [self.packagesViewController.directoriesTreeController rearrangeObjects];
}

- (void)deleteAllManagedObjects
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
	DDLogDebug(@"Deleting all managed objects (in-memory)");
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    
	[moc processPendingChanges];
    [[moc undoManager] disableUndoRegistration];
	
	for (NSEntityDescription *entDescr in [[self managedObjectModel] entities]) {
		@autoreleasepool {
			NSArray *allObjects = [self allObjectsForEntity:[entDescr name]];
			DDLogDebug(@"Deleting %lu objects from entity: %@", (unsigned long)[allObjects count], [entDescr name]);
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
	NSEntityDescription *entityDescr = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescr];
	NSArray *fetchResults = [[self managedObjectContext] executeFetchRequest:fetchRequest error:nil];
	return fetchResults;
}


- (NSURL *)chooseRepositoryFolder
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	openPanel.title = @"Select a munki Repository";
	openPanel.allowsMultipleSelection = NO;
	openPanel.canChooseDirectories = YES;
	openPanel.canChooseFiles = NO;
	openPanel.resolvesAliases = YES;
	openPanel.directoryURL = [self.defaults URLForKey:@"openRepositoryLastDir"];
    
	if ([openPanel runModal] == NSFileHandlingPanelOKButton)
	{
        [self.defaults setURL:[openPanel URLs][0] forKey:@"openRepositoryLastDir"];
		return [openPanel URLs][0];
	} else {
		return nil;
	}
}

- (NSArray *)chooseFolderForSave
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
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
		return [openPanel URLs][0];
	} else {
		return nil;
	}
}

- (NSURL *)chooseFile
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	openPanel.title = @"Select a File";
	openPanel.allowsMultipleSelection = NO;
	openPanel.canChooseDirectories = NO;
	openPanel.canChooseFiles = YES;
	openPanel.resolvesAliases = YES;
	
	if ([openPanel runModal] == NSFileHandlingPanelOKButton)
	{
		return [openPanel URLs][0];
	} else {
		return nil;
	}
}

- (NSArray *)chooseFiles
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    if ([[MAMunkiRepositoryManager sharedManager] canImportURL:url error:outError]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSURL *)showSavePanelForCopyOperation:(NSString *)fileName
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	savePanel.nameFieldStringValue = fileName;
    if (self.previousPkgSaveURL) {
        MAMunkiRepositoryManager *repoManager = [MAMunkiRepositoryManager sharedManager];
        NSString *relative = [repoManager relativePathToChildURL:self.previousPkgSaveURL parentURL:self.pkgsURL];
        NSURL *pkgsinfoSubURL = [self.pkgsInfoURL URLByAppendingPathComponent:relative];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[pkgsinfoSubURL path] isDirectory:NULL]) {
            savePanel.directoryURL = pkgsinfoSubURL;
        } else {
            savePanel.directoryURL = self.pkgsInfoURL;
        }
    } else {
        savePanel.directoryURL = self.pkgsInfoURL;
    }
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    for (id anUpdatedObject in updatedObjects) {
        DDLogError(@"Updated: %@", anUpdatedObject);
    }
    NSSet *deletedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    for (id aDeletedObject in deletedObjects) {
        DDLogError(@"Deleted: %@", aDeletedObject);
    }
    NSSet *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
    for (id anInsertedObject in insertedObjects) {
        DDLogError(@"Updated: %@", anInsertedObject);
    }
    */
}

- (void)startObservingObjectsForChanges
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(managedObjectsDidChange:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:self.managedObjectContext];
}

- (void)stopObservingObjectsForChanges
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextObjectsDidChangeNotification
                                                  object:self.managedObjectContext];
}

# pragma mark -
# pragma mark Application Startup

- (void)awakeFromNib
{
    [self configureLogging];
    
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    DDLogError(@"Starting MunkiAdmin version %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]);
    
    self.repositoryHasUnstagedChanges = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoManagerDidUndo:) name:NSUndoManagerDidUndoChangeNotification object:nil];
	
    self.packagesViewController = [[MAPackagesView alloc] initWithNibName:@"MAPackagesView" bundle:nil];
    self.manifestsViewController = [[MAManifestsView alloc] initWithNibName:@"MAManifestsView" bundle:nil];
    addItemsWindowController = [[MASelectPkginfoItemsWindow alloc] initWithWindowNibName:@"MASelectPkginfoItemsWindow"];
    selectManifestsWindowController = [[MASelectManifestItemsWindow alloc] initWithWindowNibName:@"MASelectManifestItemsWindow"];
    self.packageNameEditor = [[MAPackageNameEditor alloc] initWithWindowNibName:@"MAPackageNameEditor"];
    advancedPackageEditor = [[MAAdvancedPackageEditor alloc] initWithWindowNibName:@"MAAdvancedPackageEditor"];
    pkginfoAssimilator = [[MAPkginfoAssimilator alloc] initWithWindowNibName:@"MAPkginfoAssimilator"];
    self.preferencesController = [[MAPreferences alloc] initWithWindowNibName:@"MAPreferences"];
    self.munkiImportController = [[MAMunkiImportController alloc] initWithWindowNibName:@"MAMunkiImportController"];
    
    
    [[self.searchToolbarButton image] setSize:NSMakeSize(18, 18)];
    [[self.reloadToolbarButton image] setSize:NSMakeSize(18, 18)];
    
	// Configure segmented control
	[self.mainSegmentedControl setSegmentCount:3];
	
    NSSize toolbarIconSize = NSMakeSize(18, 18);
    NSImage *packagesIcon = [NSImage imageNamed:@"appstoreTemplate"];
	[packagesIcon setSize:toolbarIconSize];
	NSImage *catalogsIcon = [NSImage imageNamed:@"layersTemplate"];
    [catalogsIcon setSize:toolbarIconSize];
	NSImage *manifestsIcon = [NSImage imageNamed:@"document"];
    [manifestsIcon setTemplate:YES];
	[manifestsIcon setSize:toolbarIconSize];
	
	[self.mainSegmentedControl setImage:packagesIcon forSegment:0];
	[self.mainSegmentedControl setImage:catalogsIcon forSegment:1];
	[self.mainSegmentedControl setImage:manifestsIcon forSegment:2];
	
	[self.mainTabView setDelegate:self];
	[self.mainSplitView setDelegate:self];
	
	if ([self.defaults integerForKey:@"startupSelectedView"] == 0) {
		self.selectedViewTag = 0;
		self.selectedViewDescr = @"Packages";
        self.currentWholeView = [self.packagesViewController view];
		[self.mainSegmentedControl setSelectedSegment:0];
	}
	else if ([self.defaults integerForKey:@"startupSelectedView"] == 1) {
		self.selectedViewTag = 1;
		self.selectedViewDescr = @"Catalogs";
		self.currentDetailView = self.catalogsDetailView;
		self.currentSourceView = self.catalogsListView;
        self.currentWholeView = self.mainSplitView;
		[self.mainSegmentedControl setSelectedSegment:1];
	}
	else if ([self.defaults integerForKey:@"startupSelectedView"] == 2) {
		self.selectedViewTag = 2;
        self.selectedViewDescr = @"Manifests";
        self.currentDetailView = nil;
        self.currentSourceView = nil;
        self.currentWholeView = [self.manifestsViewController view];
		[self.mainSegmentedControl setSelectedSegment:2];
	}
	else {
		self.selectedViewTag = 0;
		self.selectedViewDescr = @"Packages";
        self.currentWholeView = [self.packagesViewController view];
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
    self.defaultRepoContents = @[@"catalogs", @"manifests", @"pkgsinfo"];
	
	// Set sort descriptors for array controllers
    NSSortDescriptor *sortManifestsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"parentManifest.title" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.manifestInfosArrayController setSortDescriptors:@[sortManifestsByTitle]];
	
    NSSortDescriptor *sortAppProxiesByTitle = [NSSortDescriptor sortDescriptorWithKey:@"parentApplication.munki_name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortAppProxiesByDisplayName = [NSSortDescriptor sortDescriptorWithKey:@"parentApplication.munki_display_name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray *appSorters = @[sortAppProxiesByDisplayName, sortAppProxiesByTitle];
	[self.managedInstallsArrayController setSortDescriptors:appSorters];
	[self.managedUninstallsArrayController setSortDescriptors:appSorters];
	[self.managedUpdatesArrayController setSortDescriptors:appSorters];
	[self.optionalInstallsArrayController setSortDescriptors:appSorters];
    
    NSSortDescriptor *sortInstallsItems = [NSSortDescriptor sortDescriptorWithKey:@"munki_path" ascending:YES];
    [self.installsItemsArrayController setSortDescriptors:@[sortInstallsItems]];
    
    NSSortDescriptor *sortItemsToCopyByDestPath = [NSSortDescriptor sortDescriptorWithKey:@"munki_destination_path" ascending:YES];
    NSSortDescriptor *sortItemsToCopyBySource = [NSSortDescriptor sortDescriptorWithKey:@"munki_source_item" ascending:YES];
    [self.itemsToCopyArrayController setSortDescriptors:@[sortItemsToCopyByDestPath, sortItemsToCopyBySource]];
    
    NSSortDescriptor *sortReceiptsByPackageID = [NSSortDescriptor sortDescriptorWithKey:@"munki_packageid" ascending:YES];
    NSSortDescriptor *sortReceiptsByName = [NSSortDescriptor sortDescriptorWithKey:@"munki_name" ascending:YES];
    [self.receiptsArrayController setSortDescriptors:@[sortReceiptsByPackageID, sortReceiptsByName]];
	
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    [dnc addObserver:self selector:@selector(didReceiveSharedPkginfo:) name:@"SUSInspectorPostedSharedPkginfo" object:nil suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [self.window setIsVisible:YES];
    return YES;
}

- (NSString *)safeFilenameFromString:(NSString *)aFileName
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    /*
     Get the filename hint and the pkginfo
     */
    NSString *filenameHint = object[@"filename"];
    NSString *safeFilenameHint = [self safeFilenameFromString:filenameHint];
    
    NSDictionary *pkginfo = object[@"pkginfo"];
    
    /*
     Write the pkginfo
     */
    NSURL *saveURL = [saveDirectory URLByAppendingPathComponent:safeFilenameHint];
    BOOL atomicWrites = [[NSUserDefaults standardUserDefaults] boolForKey:@"atomicWrites"];
    BOOL saved = [pkginfo writeToURL:saveURL atomically:atomicWrites];
    if (!saved) {
        DDLogError(@"Error: Failed to write %@...", [saveURL path]);
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
        PackageMO *createdPkg = [self.managedObjectContext executeFetchRequest:fetchForPackage error:nil][0];
        
        // Select the newly created package
        [[self.packagesViewController packagesArrayController] setSelectedObjects:@[createdPkg]];
        
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
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
        BOOL hasFilename = (obj[@"filename"]) ? TRUE : FALSE;
        BOOL hasPkginfo = (obj[@"pkginfo"]) ? TRUE : FALSE;
        
        if (!hasFilename || !hasPkginfo) {
            DDLogError(@"Error: Pkginfo from notification object is not valid...");
            allValid = NO;
            *stop = YES;
        }
        
        id filenameHint = obj[@"filename"];
        if (![filenameHint isKindOfClass:[NSString class]]) {
            DDLogError(@"Error: Object for key \"filename\" is not a string...");
            allValid = NO;
            *stop = YES;
        }
        
        id pkginfo = obj[@"pkginfo"];
        if (![pkginfo isKindOfClass:[NSDictionary class]]) {
            DDLogError(@"Error: Object for key \"pkginfo\" is not a dictionary...");
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
            DDLogError(@"Error: Object for key \"pkginfo\" is not a dictionary...");
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
    
    [self disableAllBindings];
    
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    /*
     Make MunkiAdmin the top-most app
     */
    [NSApp activateIgnoringOtherApps:YES];
    
    /*
     Get the payload dictionaries from the notification and make sure it's safe to use
     */
    id payloadDictionaries = [aNotification userInfo][@"payloadDictionaries"];
    if ((payloadDictionaries != nil) && ([payloadDictionaries isKindOfClass:[NSArray class]])) {
        
        NSArray *items = [NSArray arrayWithArray:payloadDictionaries];
        [self processSharedPayloadDictionaries:items];
        
    } else {
        DDLogError(@"Error: Objects not in expected format...");
        DDLogError(@"UserInfo: %@", [[aNotification userInfo] description]);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    // Update version information if paths have changed
    if (([keyPath isEqualToString:@"values.makepkginfoPath"]) ||
        ([keyPath isEqualToString:@"values.makecatalogsPath"]))
    {
        [[MAMunkiRepositoryManager sharedManager] updateMunkiVersions];
    }
}

- (DDLogLevel)ddLogLevelFromInteger:(NSInteger)i
{
    DDLogLevel level = DDLogLevelWarning;
    switch (i) {
        case 0:
            level = DDLogLevelOff;
            break;
        case 1:
            level = DDLogLevelError;
            break;
        case 2:
            level = DDLogLevelWarning;
            break;
        case 3:
            level = DDLogLevelInfo;
            break;
        case 4:
            level = DDLogLevelDebug;
            break;
        case 5:
            level = DDLogLevelVerbose;
            break;
        default:
            level = DDLogLevelWarning;
            break;
    }
    return level;
}

- (void)configureLogging
{
    /*
     Log to ASL
     */
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"logToSyslog"]) {
        [DDLog addLogger:[DDASLLogger sharedInstance]];
    }
    
    /*
     Log to Xcode (if available)
     */
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    /*
     Log to ~/Library/Logs/MunkiAdmin/
     */
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"logToFile"]) {
        DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
        fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        fileLogger.maximumFileSize = 1024 * 1024 * 10; // rolling based solely on rollingFrequency above
        NSNumber *maximumNumberOfLogFiles = [[NSUserDefaults standardUserDefaults] objectForKey:@"maximumNumberOfLogFiles"];
        fileLogger.logFileManager.maximumNumberOfLogFiles = [maximumNumberOfLogFiles unsignedIntegerValue];
        [fileLogger rollLogFileWithCompletionBlock:nil];
        self.currentFileLogger = fileLogger;
        [DDLog addLogger:fileLogger];
    }
    
    NSNumber *logLevel = [[NSUserDefaults standardUserDefaults] objectForKey:@"logLevel"];
    if (logLevel) {
        ddLogLevel = [self ddLogLevelFromInteger:[logLevel integerValue]];
    }
    
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
#if DEBUG
    DDLogError(@"Running in DEBUG mode...");
#else
    
    /*
     DevMate preference key names
     */
    NSString *analyticsPermissionKeyName = @"DevMateAnalyticsPermissionAsked";
    NSString *analyticsEnabledKeyName = @"DevMateAnalyticsEnabled";
    NSString *issuesEnabledKeyName = @"DevMateIssuesEnabled";
    
    /*
     Ask permission to send usage data to DevMate
     */
    if (![userDefaults boolForKey:analyticsPermissionKeyName]) {
        DDLogVerbose(@"User has not been asked about analytics. Presenting dialog...");
        NSAlert *askAnalyticsPermission = [[NSAlert alloc] init];
        askAnalyticsPermission.messageText = @"Send anonymous system profile?";
        askAnalyticsPermission.informativeText = @"MunkiAdmin uses DevMate and includes the option to send anonymous system profile every time the app is launched. The information sent to DevMate is not personally identifiable and does not include any information about your munki repository.\n\nDetails included in the profile:\n• MunkiAdmin version\n• OS X version and language\n• CPU and GPU models\n• Machine model\n• The amount of RAM and free disk space\n\n";
        [askAnalyticsPermission addButtonWithTitle:@"Send"];
        [askAnalyticsPermission addButtonWithTitle:@"Don't Send"];
        NSInteger result = [askAnalyticsPermission runModal];
        if (result == NSAlertFirstButtonReturn) {
            DDLogVerbose(@"User granted permission to use analytics.");
            [userDefaults setBool:YES forKey:analyticsEnabledKeyName];
        } else {
            DDLogVerbose(@"User did not give permission to use analytics.");
            [userDefaults setBool:NO forKey:analyticsEnabledKeyName];
        }
        
        [userDefaults setBool:YES forKey:analyticsPermissionKeyName];
    }
    
    /*
     Send tracking report if allowed
     */
    if ([userDefaults boolForKey:analyticsEnabledKeyName]) {
        DDLogVerbose(@"User has granted permission to use analytics. Sending report...");
        [DevMateKit sendTrackingReport:nil delegate:nil];
    }
    
    /*
     Setup DevMate crash reports
     */
    if ([userDefaults boolForKey:issuesEnabledKeyName]) {
        [DevMateKit setupIssuesController:nil reportingUnhandledIssues:YES];
    }
    
#endif
    
    [[MAMunkiRepositoryManager sharedManager] updateMunkiVersions];
    
    // Observe user defaults for changes in makepkginfo and makecatalogs paths
    NSUserDefaultsController *dc = [NSUserDefaultsController sharedUserDefaultsController];
    [dc addObserver:self forKeyPath:@"values.makepkginfoPath" options:NSKeyValueObservingOptionNew context:NULL];
    [dc addObserver:self forKeyPath:@"values.makecatalogsPath" options:NSKeyValueObservingOptionNew context:NULL];
    
    // Select a repository
    if ([userDefaults integerForKey:@"startupWhatToDo"] == 1) {
        NSURL *tempURL = [self chooseRepositoryFolder];
        if (tempURL != nil) {
            [self selectRepoAtURL:tempURL];
        }
    }
    
    // Open previous repository
    else if ([userDefaults integerForKey:@"startupWhatToDo"] == 2) {
        
        /*
         Dirty hack to resolve "Cannot perform operation without a managed object context" exceptions.
         Delay the repo selection by 0.5 seconds. I'm not proud of this...
         
         TODO: Shouldn't need to delay repo selection on startup
         */
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSURL *tempURL = [[NSUserDefaults standardUserDefaults] URLForKey:@"selectedRepositoryPath"];
            if (tempURL != nil) {
                [self selectRepoAtURL:tempURL];
            }
        });
    }
    // Do nothing
    else if ([userDefaults integerForKey:@"startupWhatToDo"] == 0) {
        
    }
	
}


# pragma mark -
# pragma mark NSOperationQueue specific

- (void)checkOperations:(NSTimer *)timer
{
    //DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
	NSUInteger numOp = [self.operationQueue operationCount];
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
		self.queueStatusDescription = [NSString stringWithFormat:@"%lu items remaining", numOp - 1];
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
                    self.currentStatusDescription = [NSString stringWithFormat:@"%@", [(MAPkginfoScanner *)firstOpItem fileName]];
                    self.jobDescription = @"Scanning Packages...";
                }
                
                // Running item is ManifestScanner
                else if ([firstOpItem isKindOfClass:[MAManifestScanner class]]) {
                    self.currentStatusDescription = [NSString stringWithFormat:@"%@", [(MAManifestScanner *)firstOpItem fileName]];
                    self.jobDescription = @"Scanning Manifests...";
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
                
                // Running item is MAFileCopyOperation
                else if ([firstOpItem isKindOfClass:[MAFileCopyOperation class]]) {
                    self.jobDescription = @"Copying...";
                    self.currentStatusDescription = [NSString stringWithFormat:@"%@", [[firstOpItem sourceURL] lastPathComponent]];
                }
                
                // Running item is MARelationshipScanner
                else if ([firstOpItem isKindOfClass:[MARelationshipScanner class]]) {
                    self.jobDescription = @"Analyzing...";
                    self.currentStatusDescription = [NSString stringWithFormat:@"%@", [firstOpItem currentJobDescription]];
                }
            }
        }
	}
}

- (void)startOperationTimer
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
	self.operationTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
													  target:self
													selector:@selector(checkOperations:)
													userInfo:nil
													 repeats:YES];
}

- (void)showProgressPanel
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
	self.queueIsRunning = NO;
	self.currentStatusDescription = @"Canceling all operations";
	DDLogDebug(@"%@", self.currentStatusDescription);
	[self.operationQueue cancelAllOperations];
}

# pragma mark - Modifying manifests

- (void)renameSelectedManifest
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    ManifestMO *selectedManifest = [self.manifestsArrayController selectedObjects][0];
    
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
        DDLogDebug(@"User cancelled move/rename operation");
        return;
    }
    
    /*
     Let URLByResolvingSymlinksInPath work on directory since file is not created yet
     */
    newURL = [[[newURL URLByDeletingLastPathComponent] URLByResolvingSymlinksInPath] URLByAppendingPathComponent: [newURL lastPathComponent]];

    /*
     The actual renaming is handled by MunkiRepositoryManager
     */
    [[MAMunkiRepositoryManager sharedManager] moveManifest:selectedManifest toURL:newURL cascade:YES];
    
}


- (IBAction)renameSelectedManifestAction:sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
	[self renameSelectedManifest];
}

- (void)duplicateSelectedManifest
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    if ([[self.manifestsArrayController selectedObjects] count] == 0) {
        DDLogError(@"No manifest selected...");
        return;
    }
    
    ManifestMO *selectedManifest = [self.manifestsArrayController selectedObjects][0];
    
    NSURL *currentURL = (NSURL *)selectedManifest.manifestURL;
    NSString *newFilename = [selectedManifest fileName];
    NSString *message = NSLocalizedString(@"Choose a location and name for the duplicated manifest.", nil);
    
    NSURL *newURL = [self showSavePanelForManifestWithTitle:@"Duplicate manifest"
                                                   filename:newFilename
                                                    message:message
                                               directoryURL:nil];
    if (!newURL) {
        DDLogError(@"User cancelled duplicate operation");
        return;
    }
    
    /*
     Let URLByResolvingSymlinksInPath work on directory since file is not created yet
     */
    newURL = [[[newURL URLByDeletingLastPathComponent] URLByResolvingSymlinksInPath] URLByAppendingPathComponent: [newURL lastPathComponent]];

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
        DDLogError(@"Failed to copy manifest on disk");
    }
}

- (IBAction)duplicateSelectedManifestAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    [self duplicateSelectedManifest];
}

- (void)deleteSelectedManifests
{
	DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
	
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
        messageText = [NSString stringWithFormat:@"Delete manifest \"%@\"", [selectedManifests[0] title]];
        informativeText = [NSString stringWithFormat:
                           @"Are you sure you want to delete manifest \"%@\"? MunkiAdmin will move the manifest file to trash and remove all references to it in other manifests.",
                           [selectedManifests[0] title]];
    } else {
        DDLogError(@"No manifests selected, can't delete anything...");
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
	[self deleteSelectedManifests];
}

- (void)createNewManifest
{
	DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    NSString *newFilename = NSLocalizedString(@"new-manifest", nil);
    NSString *message = NSLocalizedString(@"Choose a location and name for the new manifest. Location should be within your manifests directory.", nil);
    
    NSURL *newURL = [self showSavePanelForManifestWithTitle:@"Create manifest"
                                                   filename:newFilename
                                                    message:message
                                               directoryURL:nil];
    if (!newURL) {
        DDLogError(@"User cancelled new manifest creation");
        return;
    }
    
    /*
     Let URLByResolvingSymlinksInPath work on directory since file is not created yet
     */
    newURL = [[[newURL URLByDeletingLastPathComponent] URLByResolvingSymlinksInPath] URLByAppendingPathComponent: [newURL lastPathComponent]];

    ManifestMO *newManifest = [[MACoreDataManager sharedManager] createManifestWithURL:[newURL URLByResolvingSymlinksInPath] inManagedObjectContext:self.managedObjectContext];
    if (!newManifest) {
        DDLogError(@"Failed to create manifest");
    }
    
}

- (IBAction)createNewManifestAction:sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
	[self createNewManifest];
}

- (IBAction)importManifestsFromFileAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    [self.manifestsViewController importManifestsFromFile];
}

# pragma mark - Modifying packages

- (void)packageNameEditorDidFinish:(id)sender returnCode:(int)returnCode object:(id)object
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    PackageMO *firstSelected = [[self.packagesViewController packagesArrayController] selectedObjects][0];
    
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    [self renameSelectedPackages];
}


- (void)deleteSelectedPackages
{
	DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
	
	NSArray *selectedPackages = [[self.packagesViewController packagesArrayController] selectedObjects];
	
	// Configure the dialog
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Delete"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Delete Packages"];
	if ([selectedPackages count] == 1) {
		PackageMO *singlePackage = selectedPackages[0];
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
        [[MAMunkiRepositoryManager sharedManager] removePackages:selectedPackages withInstallerItem:YES withReferences:YES];
	}
}

- (IBAction)deleteSelectedPackagesAction:sender
{
	[self deleteSelectedPackages];
}

- (void)createNewCatalog
{
	DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
	
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
	[self createNewCatalog];
}

- (void)enableAllPackagesForManifest
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
	ManifestMO *selectedManifest = [self.manifestsArrayController selectedObjects][0];
	for (ManagedInstallMO *managedInstall in [selectedManifest managedInstalls]) {
		managedInstall.isEnabledValue = YES;
	}
}

- (IBAction)enableAllPackagesForManifestAction:sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
	[self enableAllPackagesForManifest];
}

- (void)disableAllPackagesForManifest
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
	ManifestMO *selectedManifest = [self.manifestsArrayController selectedObjects][0];
	for (ManagedInstallMO *managedInstall in [selectedManifest managedInstalls]) {
		managedInstall.isEnabledValue = NO;
	}
}

- (IBAction)disableAllPackagesForManifestAction:sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
	[self disableAllPackagesForManifest];
}

# pragma mark - Modifying repository

- (IBAction)createNewRepository:sender
{
	DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
	
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
			DDLogError(@"Can't create repository: %@", newRepoPath);
		}
	}
}

- (void)assimilatePackageProperties:(NSDictionary *)aPkgProps
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
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
		
		PackageMO *aPkg = [moc executeFetchRequest:fetchForPackage error:nil][0];
		
		NSFetchRequest *fetchForApplications = [[NSFetchRequest alloc] init];
		[fetchForApplications setEntity:applicationEntityDescr];
		NSPredicate *applicationTitlePredicate;
		applicationTitlePredicate = [NSPredicate predicateWithFormat:@"munki_name like[cd] %@", aPkg.munki_name];
		
		[fetchForApplications setPredicate:applicationTitlePredicate];
		
		NSUInteger numFoundApplications = [moc countForFetchRequest:fetchForApplications error:nil];
		if (numFoundApplications == 0) {
			// No matching Applications found.
			DDLogError(@"Assimilator found zero matching Applications for package.");
		} else if (numFoundApplications == 1) {
			ApplicationMO *existingApplication = [moc executeFetchRequest:fetchForApplications error:nil][0];
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
			DDLogError(@"Assimilator found multiple matching Applications for package. Can't decide on my own...");
		}
	}
	else {
		DDLogError(@"Can't assimilate. %lu results found for package search", (unsigned long)numFoundPkgs);
	}

}


# pragma mark - Callbacks

- (void)makepkginfoDidFinish:(NSDictionary *)pkginfoPlist
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
	// Callback from makepkginfo
    
    if (pkginfoPlist) {
        
        // Extract a name for the new pkginfo item
        NSString *name = pkginfoPlist[@"name"];
        NSString *version = pkginfoPlist[@"version"];
        NSString *newBaseName = [name stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        NSString *newNameAndVersion = [NSString stringWithFormat:@"%@-%@", newBaseName, version];
        NSString *newPkginfoTitle = [newNameAndVersion stringByAppendingPathExtension:@"plist"];
        
        // Ask the user to save
        NSURL *newPkginfoURL = [self showSavePanelForPkginfo:newPkginfoTitle];
        
        // Write the pkginfo to disk and add it to our datastore
        BOOL atomicWrites = [[NSUserDefaults standardUserDefaults] boolForKey:@"atomicWrites"];
        BOOL saved = [pkginfoPlist writeToURL:newPkginfoURL atomically:atomicWrites];
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
                PackageMO *createdPkg = [self.managedObjectContext executeFetchRequest:fetchForPackage error:nil][0];
                
                // Select the newly created package
                [[self.packagesViewController packagesArrayController] setSelectedObjects:@[createdPkg]];
                
                MAMunkiRepositoryManager *repoManager = [MAMunkiRepositoryManager sharedManager];
                
                // Run the assimilator
                if ([self.defaults boolForKey:@"assimilate_enabled"]) {
                    [repoManager assimilatePackageWithPreviousVersion:createdPkg keys:repoManager.pkginfoAssimilateKeysForAuto];
                }
                
                repoManager.makecatalogsRunNeeded = NO;
            }
            else {
                // Found multiple matches for a single URL
            }
            
            
        }
    } else {
        DDLogError(@"makepkginfo failed!");
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
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
    
    [self.manifestsViewController updateSourceListData];
    
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
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
    [fetchRequest setPropertiesToFetch:@[@"munki_name"]];
	NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:nil];
    NSArray *appleUpdateNames = [fetchResults valueForKeyPath:@"munki_name"];
    
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    [dnc postNotificationName:kMunkiAdminStatusChangeName
                       object:nil
                     userInfo:@{@"readyToReceive" : @(readyToReceive), @"appleUpdateMetadataNames" : appleUpdateNames}
           deliverImmediately:YES];
}

- (void)mergeChanges:(NSNotification*)notification
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    DDLogError(@"### Error: mergeChanges notification received: %@", [notification description]);
    
	NSAssert([NSThread mainThread], @"Not on the main thread");
	[[self managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
}

# pragma mark - Pkginfo Assimilator IBActions

- (void)pkginfoAssimilatorDidFinish:(id)sender returnCode:(int)returnCode object:(id)object
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    if (self.currentWholeView == [self.packagesViewController view]) {
        
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    [[[self managedObjectContext] undoManager] endUndoGrouping];
    if (returnCode == NSOKButton) return;
    [[[self managedObjectContext] undoManager] undo];
}

- (IBAction)selectNextPackageForEditing:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    // Commit any changes
    [advancedPackageEditor endEditingInWindow];
    [advancedPackageEditor commitChangesToCurrentPackage];
    
    // Change selection
    NSIndexSet *currentIndexes = [[self.packagesViewController packagesArrayController] selectionIndexes];
    if ([currentIndexes lastIndex] < [[[self.packagesViewController packagesArrayController] arrangedObjects] count] - 1) {
        [[self.packagesViewController packagesArrayController] setSelectionIndex:[currentIndexes lastIndex]+1];
        
        // Populate new values
        PackageMO *object = [[self.packagesViewController packagesArrayController] selectedObjects][0];
        [advancedPackageEditor setPkginfoToEdit:object];
        [advancedPackageEditor setDefaultValuesFromPackage:object];
    }
}

- (IBAction)selectPreviousPackageForEditing:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    // Commit any changes
    [advancedPackageEditor endEditingInWindow];
    [advancedPackageEditor commitChangesToCurrentPackage];
    
    // Change selection
    NSIndexSet *currentIndexes = [[self.packagesViewController packagesArrayController] selectionIndexes];
    if ([currentIndexes lastIndex] > 0) {
        [[self.packagesViewController packagesArrayController] setSelectionIndex:([currentIndexes lastIndex] - 1)];
        
        // Populate new values
        PackageMO *object = [[self.packagesViewController packagesArrayController] selectedObjects][0];
        [advancedPackageEditor setPkginfoToEdit:object];
        [advancedPackageEditor setDefaultValuesFromPackage:object];
    }
}

- (IBAction)getInfoAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    if (self.currentWholeView == [self.packagesViewController view]) {
        
        PackageMO *object = [[[self.packagesViewController packagesArrayController] selectedObjects] lastObject];
        if (!object) return;
        
        [[[self managedObjectContext] undoManager] beginUndoGrouping];
        [[[self managedObjectContext] undoManager] setActionName:[NSString stringWithFormat:@"Editing \"%@\"", [object titleWithVersion]]];
        
        [advancedPackageEditor beginEditSessionWithObject:object delegate:self];
        
        if ([sender isKindOfClass:[NSButton class]]) {
            switch ([(NSButton *)sender tag]) {
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
    } else if (self.currentWholeView == [self.manifestsViewController view]) {
        [self.manifestsViewController openEditorForAllSelectedManifests];
    }
}


# pragma mark - NSUndoManager notifications

- (void)undoManagerDidUndo:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
}


# pragma mark - pkginfo

- (void)setupCopyOperation:(MAFileCopyOperation *)copyOp withDependingOperation:(MAMunkiOperation *)depOp
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    [depOp addDependency:copyOp];
    copyOp.delegate = self;
}

- (void)setupMakepkginfoOperation:(MAMunkiOperation *)theOp withDependingOperation:(MARelationshipScanner *)relScan
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    [relScan addDependency:theOp];
    theOp.delegate = self;
}

- (void)addNewPackagesFromFileURLs:(NSArray *)filesToAdd
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    DDLogDebug(@"Adding %lu files to repository", (unsigned long)[filesToAdd count]);
    
    [self disableAllBindings];
    
    MARelationshipScanner *packageRelationships = [MARelationshipScanner pkginfoScanner];
    packageRelationships.delegate = self;
    
    NSMutableArray *operationsToAdd = [[NSMutableArray alloc] init];
    for (NSURL *fileToAdd in filesToAdd) {
        if (fileToAdd != nil) {
            MAMunkiOperation *makepkginfoOperation;
            
            if (![[fileToAdd relativePath] hasPrefix:[self.pkgsURL relativePath]]) {
                if (([self.defaults boolForKey:@"CopyPkgsToRepo"]) && ([[NSFileManager defaultManager] fileExistsAtPath:[self.pkgsURL relativePath]])) {
                    
                    DDLogDebug(@"%@ not within %@ -> Should copy", [fileToAdd relativePath], [self.pkgsURL relativePath]);
                    
                    NSURL *newTarget = [self showSavePanelForCopyOperation:[[fileToAdd relativePath] lastPathComponent]];
                    if (newTarget) {
                        self.previousPkgSaveURL = [newTarget URLByDeletingLastPathComponent];
                        
                        makepkginfoOperation = [MAMunkiOperation makepkginfoOperationWithSource:fileToAdd];
                        makepkginfoOperation.delegate = self;
                        
                        NSString *newRelativePath = [[MAMunkiRepositoryManager sharedManager] relativePathToChildURL:newTarget parentURL:self.pkgsURL];
                        makepkginfoOperation.pkginfoAdditions = @{@"installer_item_location": newRelativePath};
                        
                        MAFileCopyOperation *copyOperation = [MAFileCopyOperation fileCopySourceURL:fileToAdd toTargetURL:newTarget];
                        copyOperation.delegate = self;
                        
                        [copyOperation addDependency:makepkginfoOperation];
                        [packageRelationships addDependency:copyOperation];
                        
                        [operationsToAdd addObject:makepkginfoOperation];
                        [operationsToAdd addObject:copyOperation];
                        
                    } else {
                        DDLogDebug(@"User chose to cancel the copy operation for %@. Bailing out...", [fileToAdd relativePath]);
                    }
                    
                } else {
                    makepkginfoOperation = [MAMunkiOperation makepkginfoOperationWithSource:fileToAdd];
                    [self setupMakepkginfoOperation:makepkginfoOperation withDependingOperation:packageRelationships];
                    [operationsToAdd addObject:makepkginfoOperation];
                }
                
            } else {
                makepkginfoOperation = [MAMunkiOperation makepkginfoOperationWithSource:fileToAdd];
                [self setupMakepkginfoOperation:makepkginfoOperation withDependingOperation:packageRelationships];
                [operationsToAdd addObject:makepkginfoOperation];
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
        DDLogDebug(@"Re-enabling all bindings...");
        NSBlockOperation *enableBindingsOp = [NSBlockOperation blockOperationWithBlock:^{
            [self performSelectorOnMainThread:@selector(enableAllBindings) withObject:nil waitUntilDone:YES];
        }];
        [self.operationQueue addOperation:enableBindingsOp];
    }
}

- (IBAction)addNewPackage:sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
	
    if ([self.defaults boolForKey:@"importWithMunkiimport"]) {
        NSWindow *window = [self.munkiImportController window];
        [self.munkiImportController resetStatus];
        NSInteger result = [NSApp runModalForWindow:window];
        if (result == NSModalResponseOK) {
            
        }
    } else {
        if ([self makepkginfoInstalled]) {
            NSArray *filesToAdd = [self chooseFilesForMakepkginfo];
            if (filesToAdd) {
                [self addNewPackagesFromFileURLs:filesToAdd];
            }
        } else {
            DDLogDebug(@"Can't find %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"makepkginfoPath"]);
            [self alertMunkiToolNotInstalled:@"makepkginfo"];
        }
    }
}


- (IBAction)addNewInstallsItem:sender
{
	DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
	if ([self makepkginfoInstalled]) {
		NSArray *filesToAdd = [self chooseFiles];
		if (filesToAdd) {
			DDLogDebug(@"Adding %lu installs items", (unsigned long)[filesToAdd count]);
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
		DDLogDebug(@"Can't find %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"makepkginfoPath"]);
        [self alertMunkiToolNotInstalled:@"makepkginfo"];
	}
}

# pragma mark -
# pragma mark Writing to the repository

- (NSString *)cleanMakecatalogsMessage:(NSString *)message
{
    NSString *cleanedString = message;
    cleanedString = [cleanedString stringByReplacingOccurrencesOfString:[self.repoURL path] withString:@""];
    return [cleanedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)updateCatalogsInline
{
    NSTask *task = [[NSTask alloc] init];
    NSString *launchPath = [self.defaults stringForKey:@"makecatalogsPath"];
    task.launchPath = launchPath;
    
    NSMutableDictionary *defaultEnv = [[NSMutableDictionary alloc] initWithDictionary:[[NSProcessInfo processInfo] environment]];
    [defaultEnv setObject:@"YES" forKey:@"NSUnbufferedIO"] ;
    task.environment = defaultEnv;
    
    /*
     Check the "Disable sanity checks" preference
     */
    if ([self.defaults boolForKey:@"makecatalogsForceEnabled"]) {
        task.arguments = @[@"--force", [self.repoURL path]];
    } else {
        task.arguments = @[[self.repoURL path]];
    }
    DDLogDebug(@"Running %@ with arguments: %@", task.launchPath, task.arguments);
    
    
    MAMunkiAdmin_AppDelegate * __weak weakSelf = self;
    
    __block NSMutableString *standardOutput = [NSMutableString new];
    task.standardOutput = [NSPipe pipe];
    [[task.standardOutput fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
        NSData *data = [file availableData];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [standardOutput appendString:string];
        NSString *cleanedString = [self cleanMakecatalogsMessage:string];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (cleanedString.length > 0) {
                DDLogVerbose(@"%@", cleanedString);
                [weakSelf setCurrentStatusDescription:cleanedString];
            }
        });
    }];
    
    __block NSMutableString *standardError = [[NSMutableString alloc] init];
    task.standardError = [NSPipe pipe];
    [[task.standardError fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
        NSData *data = [file availableData];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *cleanedString = [self cleanMakecatalogsMessage:string];
        DDLogError(@"%@", cleanedString);
        [standardError appendString:cleanedString];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setCurrentStatusDescription:cleanedString];
        });
    }];
    
    [task setTerminationHandler:^(NSTask *aTask) {
        
        [aTask.standardOutput fileHandleForReading].readabilityHandler = nil;
        [aTask.standardError fileHandleForReading].readabilityHandler = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSApp endSheet:weakSelf.progressPanel];
            [weakSelf.progressPanel close];
            [weakSelf.progressIndicator stopAnimation:self];
            [weakSelf postStatusUpdateReadyToReceive:YES];
            
            int exitCode = aTask.terminationStatus;
            if (exitCode == 0) {
                DDLogDebug(@"makecatalogs succeeded.");
                
                /*
                 Check warnings
                 */
                if (standardError.length != 0) {
                    // Check for warnings in makecatalogs stderr
                    NSRange range = NSMakeRange(0, standardError.length);
                    __block NSMutableString *warnings = [NSMutableString new];
                    [standardError enumerateSubstringsInRange:range
                                                       options:NSStringEnumerationByParagraphs
                                                    usingBlock:^(NSString * _Nullable paragraph, NSRange paragraphRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                                                        if ([paragraph hasPrefix:@"WARNING: "]) {
                                                            [warnings appendFormat:@"\n%@", paragraph];
                                                        }
                                                    }];
                    if (warnings.length != 0) {
                        DDLogDebug(@"makecatalogs produced warnings.");
                        NSString *description = @"Updating catalogs produced warnings";
                        NSString *recoverySuggestion = [NSString stringWithFormat:@"%@.", warnings];
                        NSString *alertSuppressionKey = @"makecatalogsWarningsSuppressed";
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        
                        if ([defaults boolForKey: alertSuppressionKey]) {
                            DDLogDebug(@"Warnings from makecatalogs suppressed");
                        } else {
                            NSAlert *anAlert = [[NSAlert alloc] init];
                            anAlert.messageText = description;
                            anAlert.informativeText = recoverySuggestion;
                            anAlert.showsSuppressionButton = YES;
                            [anAlert runModal];
                            if (anAlert.suppressionButton.state == NSOnState) {
                                [defaults setBool:YES forKey:alertSuppressionKey];
                            }
                        }
                    }
                }
                
            } else {
                DDLogError(@"makecatalogs exited with code %i", exitCode);
                NSString *description = @"Updating catalogs failed";
                NSString *recoverySuggestion = [NSString stringWithFormat:@"makecatalogs exited with code %i.\n\n%@", exitCode, standardError];
                NSString *alertSuppressionKey = @"makecatalogsErrorsSuppressed";
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                
                if ([defaults boolForKey: alertSuppressionKey]) {
                    DDLogDebug(@"Errors from makecatalogs suppressed");
                } else {
                    NSAlert *anAlert = [[NSAlert alloc] init];
                    anAlert.messageText = description;
                    anAlert.informativeText = recoverySuggestion;
                    anAlert.showsSuppressionButton = YES;
                    [anAlert runModal];
                    if (anAlert.suppressionButton.state == NSOnState) {
                        [defaults setBool:YES forKey:alertSuppressionKey];
                    }
                }
            }
        });
        
    }];
    
    [NSApp beginSheet:self.progressPanel
       modalForWindow:self.window modalDelegate:nil
       didEndSelector:nil contextInfo:nil];
    self.jobDescription = @"Running makecatalogs";
    [self.progressIndicator setIndeterminate:YES];
    [self.progressIndicator startAnimation:self];
    
    [task launch];
}

- (void)updateCatalogs
{
	DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
	
	// Run makecatalogs against the current repo
	if ([self makecatalogsInstalled]) {
		
        /*
        NSString *munkitoolsVersion = [MAMunkiRepositoryManager sharedManager].makecatalogsVersion;
        MAMunkiOperation *op = [[MAMunkiOperation alloc] initWithCommand:@"makecatalogs" targetURL:self.repoURL arguments:nil munkitoolsVersion:munkitoolsVersion];
		op.delegate = self;
		[self.operationQueue addOperation:op];
		[self showProgressPanel];
        */
        
        [self updateCatalogsInline];
		
	} else {
		DDLogDebug(@"Can't find %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"makecatalogsPath"]);
        [self alertMunkiToolNotInstalled:@"makecatalogs"];
	}
}

- (IBAction)updateCatalogs:sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
	// Run makecatalogs against the current repo
	if ([self makecatalogsInstalled]) {
        /*
        NSString *munkitoolsVersion = [MAMunkiRepositoryManager sharedManager].makecatalogsVersion;
        MAMunkiOperation *op = [[MAMunkiOperation alloc] initWithCommand:@"makecatalogs" targetURL:self.repoURL arguments:nil munkitoolsVersion:munkitoolsVersion];
        op.delegate = self;
        [self.operationQueue addOperation:op];
        [self showProgressPanel];
         */
        
        [self updateCatalogsInline];
        
    } else {
        DDLogError(@"Can't find %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"makecatalogsPath"]);
        [self alertMunkiToolNotInstalled:@"makecatalogs"];
    }
}


- (IBAction)writeChangesToDisk:sender
{
	DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    BOOL didWritePkginfos, didwriteManifests;
	[[MAMunkiRepositoryManager sharedManager] writePackagePropertyListsToDisk:&didWritePkginfos];
    [[MAMunkiRepositoryManager sharedManager] writeManifestPropertyListsToDisk:&didwriteManifests];
	[self selectRepoAtURL:self.repoURL];
}


# pragma mark -
# pragma mark Main window toolbar IBActions

- (IBAction)searchRepositoryAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    /*
     Check which view we're currently in and activate the correct search field
     */
    if (self.currentWholeView == [self.packagesViewController view]) {
        // Packages view
        DDLogVerbose(@"Should focus on packages search");
        [[self.packagesViewController.packagesSearchField window] makeFirstResponder:self.packagesViewController.packagesSearchField];
    
    } else if (self.currentDetailView == self.catalogsDetailView) {
        // Catalogs view
        DDLogVerbose(@"Should focus on catalogs search");
        [[self.catalogContentSearchField window] makeFirstResponder:self.catalogContentSearchField];
    
    } else if (self.currentWholeView == [self.manifestsViewController view]) {
        // Manifests view
        DDLogVerbose(@"Should focus on manifest search");
        [self.manifestsViewController toggleManifestsFindView];
    }
}


- (IBAction)searchManifestsAction:(id)sender
{
    if (self.currentDetailView != [self.manifestsViewController view]) {
        
        /*
         Change the view
         */
        self.selectedViewDescr = @"Manifests";
        self.currentDetailView = nil;
        self.currentSourceView = nil;
        self.currentWholeView = [self.manifestsViewController view];
        [self.mainSegmentedControl setSelectedSegment:2];
        [self changeItemView];
        
        PackageMO *selectedPackage = [self.packagesViewController.packagesArrayController selectedObjects][0];
        
        /*
         Create a predicate for the selected package name. We need to wrap it in a compound predicate
         to properly display it in the search view (the 'Any|All|None' selection would be missing).
         */
        NSPredicate *containsMunkiName = [NSPredicate predicateWithFormat:@"allPackageStrings CONTAINS[cd] %@", selectedPackage.munki_name];
        NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[containsMunkiName]];
        
        [self.manifestsViewController showFindViewWithPredicate:compoundPredicate];
    }
}


# pragma mark -
# pragma mark Reading from the repository


- (IBAction)openRepository:sender
{
	DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
	NSURL *tempURL = [self chooseRepositoryFolder];
	if (tempURL != nil) {
		[self selectRepoAtURL:tempURL];
	}
}

- (IBAction)reloadRepositoryAction:sender
{
	DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    BOOL hasUnstagedChanges = [[MAMunkiRepositoryManager sharedManager] repositoryHasUnstagedChanges];
    if (hasUnstagedChanges) {
        DDLogVerbose(@"Repository has unstaged changes. Should ask for confirmation.");
        NSString *question = NSLocalizedString(@"Changes have not been saved yet. Reload anyway?", @"Reload without saves error question message");
        NSString *info = NSLocalizedString(@"Reloading now will lose any changes you have made since the last successful save", @"Reload without saves error question info");
        NSString *reloadButton = NSLocalizedString(@"Reload anyway", @"Reload anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:reloadButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertFirstButtonReturn) {
            DDLogVerbose(@"User chose to reload without saving.");
            [self selectRepoAtURL:self.repoURL];
        } else {
            DDLogVerbose(@"User cancelled reloading.");
        }
    } else {
        DDLogVerbose(@"Repository has no unstaged changes. Reloading...");
        [self selectRepoAtURL:self.repoURL];
    }
}

- (BOOL)resetPersistentStore
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
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
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
	DDLogDebug(@"Opening repository at %@", [newURL path]);
    
    [self stopObservingObjectsForChanges];
    [[self.managedObjectContext undoManager] disableUndoRegistration];
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
			self.repoURL = [newURL URLByResolvingSymlinksInPath];
			self.pkgsURL = [[self.repoURL URLByAppendingPathComponent:@"pkgs"] URLByResolvingSymlinksInPath];
			self.pkgsInfoURL = [[self.repoURL URLByAppendingPathComponent:@"pkgsinfo"] URLByResolvingSymlinksInPath];
			self.catalogsURL = [[self.repoURL URLByAppendingPathComponent:@"catalogs"] URLByResolvingSymlinksInPath];
			self.manifestsURL = [[self.repoURL URLByAppendingPathComponent:@"manifests"] URLByResolvingSymlinksInPath];
            self.iconsURL = [[self.repoURL URLByAppendingPathComponent:@"icons"] URLByResolvingSymlinksInPath];
            
            [self.defaults setURL:self.repoURL forKey:@"selectedRepositoryPath"];
            
			[self scanCurrentRepoForCatalogFiles];
            [self scanCurrentRepoForPackages];
			[self scanCurrentRepoForManifests];
			
            [self showProgressPanel];
		} else {
			DDLogError(@"Not a repo!");
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
		ApplicationMO *existingApplication = [moc executeFetchRequest:fetchForApplications error:nil][0];
		[existingApplication addPackagesObject:aPkg];
		
	} else {
		DDLogError(@"Found multiple Applications for package. This really shouldn't happen...");
	}
	
}


- (void)scanCurrentRepoForPackages
{
    /*
     Scan the current repo for already existing pkginfo files
     and create a new Package object for each of them
	*/
	DDLogDebug(@"Scanning selected repo for packages");
	
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
    
	NSArray *keysToget = @[NSURLNameKey, NSURLLocalizedNameKey, NSURLIsDirectoryKey, NSURLIsRegularFileKey];
	NSFileManager *fm = [NSFileManager defaultManager];
    
    MARelationshipScanner *packageRelationships = [MARelationshipScanner pkginfoScanner];
    packageRelationships.delegate = self;

	NSDirectoryEnumerator *pkgsInfoDirEnum = [fm enumeratorAtURL:self.pkgsInfoURL includingPropertiesForKeys:keysToget options:(NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:nil];
	for (NSURL *anURL in pkgsInfoDirEnum)
	{
		NSNumber *isRegularFile;
		[anURL getResourceValue:&isRegularFile forKey:NSURLIsRegularFileKey error:nil];
		if ([isRegularFile boolValue]) {
			MAPkginfoScanner *scanOp = [MAPkginfoScanner scannerWithURL:anURL];
			scanOp.delegate = self;
            [packageRelationships addDependency:scanOp];
			[self.operationQueue addOperation:scanOp];
			
		} else {
            NSNumber *isDir;
            [anURL getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
            if (![isDir boolValue]) {
                DDLogError(@"Not a regular file: %@", [anURL path]);
            }
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
	DDLogDebug(@"Scanning selected repo for catalogs");
	
	NSArray *keysToget = @[NSURLNameKey, NSURLIsDirectoryKey];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSManagedObjectContext *moc = [self managedObjectContext];
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
}


- (void)scanCurrentRepoForManifests
{
    /*
	 Scan the current repo for already existing manifest files
	 and create a new Manifest object for each of them
     */
	DDLogDebug(@"Scanning selected repo for manifests");
	
	NSArray *keysToget = @[NSURLNameKey, NSURLIsDirectoryKey];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSManagedObjectContext *moc = [self managedObjectContext];
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
            NSString *manifestRelativePath = [[MAMunkiRepositoryManager sharedManager] relativePathToChildURL:aManifestFile parentURL:self.manifestsURL];
            
			NSFetchRequest *request = [[NSFetchRequest alloc] init];
			[request setEntity:entityDescription];
			NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title == %@", manifestRelativePath];
			[request setPredicate:titlePredicate];
			ManifestMO *manifest;
			NSUInteger foundItems = [moc countForFetchRequest:request error:nil];
			if (foundItems == 0) {
				manifest = [NSEntityDescription insertNewObjectForEntityForName:@"Manifest" inManagedObjectContext:moc];
				manifest.title = manifestRelativePath;
				manifest.manifestURL = [aManifestFile URLByResolvingSymlinksInPath];
                manifest.manifestParentDirectoryURL = [aManifestFile URLByDeletingLastPathComponent];
			}
			
		}
	}
    
    MARelationshipScanner *manifestRelationships = [MARelationshipScanner manifestScanner];
    manifestRelationships.delegate = self;
	for (ManifestMO *aManifest in [self allObjectsForEntity:@"Manifest"]) {
		MAManifestScanner *scanOp = [[MAManifestScanner alloc] initWithURL:(NSURL *)aManifest.manifestURL];
		scanOp.delegate = self;
        scanOp.manifestID = aManifest.objectID;
        [manifestRelationships addDependency:scanOp];
		[self.operationQueue addOperation:scanOp];
	}
    [self.operationQueue addOperation:manifestRelationships];
    
    NSBlockOperation *enableBindingsOp = [NSBlockOperation blockOperationWithBlock:^{
        [self performSelectorOnMainThread:@selector(enableAllBindings) withObject:nil waitUntilDone:YES];
    }];
    [enableBindingsOp addDependency:manifestRelationships];
    [self.operationQueue addOperation:enableBindingsOp];
    
    
    NSBlockOperation *saveMainContext = [NSBlockOperation blockOperationWithBlock:^{
        [self.managedObjectContext performBlockAndWait:^{
            [self.managedObjectContext commitEditing];
            [self.managedObjectContext save:nil];
            [[self.managedObjectContext undoManager] enableUndoRegistration];
        }];
    }];
    [saveMainContext addDependency:enableBindingsOp];
    [self.operationQueue addOperation:saveMainContext];
    
    
    NSBlockOperation *startObservingChangesOp = [NSBlockOperation blockOperationWithBlock:^{
        [self performSelectorOnMainThread:@selector(startObservingObjectsForChanges) withObject:nil waitUntilDone:YES];
    }];
    [startObservingChangesOp addDependency:saveMainContext];
    [self.operationQueue addOperation:startObservingChangesOp];
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
    NSString *basePath = ([paths count] > 0) ? paths[0] : NSTemporaryDirectory();
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
        DDLogError(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            DDLogError(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
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
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
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
 
- (IBAction)saveAction:(id)sender {
    
    MAMunkiRepositoryManager *repoManager = [MAMunkiRepositoryManager sharedManager];
    NSSet *modifiedPackages = [repoManager modifiedPackagesSinceLastSave];
    NSSet *modifiedManifests = [repoManager modifiedManifestsSinceLastSave];
    DDLogDebug(@"Modified manifests: %lu, pkginfos: %lu", (unsigned long)[modifiedManifests count], (unsigned long)[modifiedPackages count]);
    
    /*
     Save the managed object context before writing to repository
     */
    if (![[self managedObjectContext] commitEditing]) {
        DDLogError(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    } else {
        /*
         Write pkginfos and manifests only if managed object context saved
         */
        
        for (PackageMO *aPackage in modifiedPackages) {
            aPackage.hasUnstagedChanges = @YES;
        }
        for (ManifestMO *aManifest in modifiedManifests) {
            aManifest.hasUnstagedChanges = @YES;
        }
        
        BOOL saveSucceeded;
        BOOL didWritePkginfos;
        BOOL didWriteManifests;
        [repoManager writeRepositoryChangesToDisk:&saveSucceeded didWritePkginfos:&didWritePkginfos didWriteManifests:&didWriteManifests];
        if (saveSucceeded) {
            
            if ([self.defaults boolForKey:@"UpdateCatalogsOnSave"]) {
                if ([self.defaults boolForKey:@"makecatalogsOnlyIfNeeded"]) {
                    if (didWritePkginfos || [repoManager makecatalogsRunNeeded]) {
                        [self updateCatalogs];
                        repoManager.makecatalogsRunNeeded = NO;
                    } else {
                        DDLogError(@"Skipped makecatalogs since no pkginfos were changed...");
                    }
                } else {
                    [self updateCatalogs];
                    repoManager.makecatalogsRunNeeded = NO;
                }
            }
            
            /*
             Save the in-memory context once more because we've modified the unstaged boolean values.
             */
            [[self managedObjectContext] save:nil];
            
        } else {
            
        }
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
    
    BOOL hasUnstagedChanges = [[MAMunkiRepositoryManager sharedManager] repositoryHasUnstagedChanges];
    NSApplicationTerminateReply reply = NSTerminateNow;
    
    if (hasUnstagedChanges) {
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
            reply = NSTerminateCancel;
        } else {
            reply = NSTerminateNow;
        }
    }
    if (reply == NSTerminateNow) {
        DDLogError(@"Terminating MunkiAdmin version %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]);
    }
    return reply;
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

- (IBAction)selectViewAction:(id)sender
{
	switch ([(NSTabView *)sender tag]) {
		case 1:
			if (self.currentWholeView != [self.packagesViewController view]) {
				self.selectedViewDescr = @"Packages";
                self.currentWholeView = [self.packagesViewController view];
                self.currentDetailView = nil;
                self.currentSourceView = nil;
                [self.mainSegmentedControl setSelectedSegment:0];
				[self changeItemView];
            }
			break;
		case 2:
			if (self.currentDetailView != self.catalogsDetailView) {
				self.selectedViewDescr = @"Catalogs";
                self.currentWholeView = self.mainSplitView;
				self.currentDetailView = self.catalogsDetailView;
				self.currentSourceView = self.catalogsListView;
				[self.mainSegmentedControl setSelectedSegment:1];
				[self changeItemView];
			}
			break;
        case 3:
            if (self.currentDetailView != [self.manifestsViewController view]) {
                self.selectedViewDescr = @"Manifests";
                self.currentDetailView = nil;
                self.currentSourceView = nil;
                self.currentWholeView = [self.manifestsViewController view];
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
            if (self.currentWholeView != [self.packagesViewController view]) {
				self.selectedViewDescr = @"Packages";
                self.currentDetailView = nil;
                self.currentSourceView = nil;
                self.currentWholeView = [self.packagesViewController view];
				[self changeItemView];
            }
			break;
		case 1:
            if (self.currentDetailView != self.catalogsDetailView) {
				self.selectedViewDescr = @"Catalogs";
                self.currentWholeView = self.mainSplitView;
				self.currentDetailView = self.catalogsDetailView;
				self.currentSourceView = self.catalogsListView;
				[self changeItemView];
            }
			break;
        case 2:
            if (self.currentDetailView != [self.manifestsViewController view]) {
                self.selectedViewDescr = @"Manifests";
                self.currentDetailView = nil;
                self.currentSourceView = nil;
                self.currentWholeView = [self.manifestsViewController view];
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
		[subViews[0] removeFromSuperview];
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
		[detailSubViews[0] removeFromSuperview];
	}
	
	NSArray *sourceSubViews = [self.sourceViewPlaceHolder subviews];
	if ([sourceSubViews count] > 0)
	{
		[sourceSubViews[0] removeFromSuperview];
	}
}

- (void)changeItemView
{
    if (self.currentWholeView == [self.packagesViewController view]) {
        // remove the old subview
        [self removeSubviews];
        
        [[self.window contentView] addSubview:[self.packagesViewController view]];
        [[self.packagesViewController view] setFrame:[[self.window contentView] frame]];
        [[self.packagesViewController view] setFrameOrigin:NSMakePoint(0,0)];
        [[self.packagesViewController view] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        //[[self.packagesViewController directoriesOutlineView] expandItem:nil expandChildren:YES];
        //[[self.packagesViewController directoriesOutlineView] reloadData];
        //[[self.packagesViewController packagesArrayController] rearrangeObjects];
    
    } else if (self.currentWholeView == [self.manifestsViewController view]) {
        // remove the old subview
        [self removeSubviews];
        
        [[self.window contentView] addSubview:[self.manifestsViewController view]];
        [[self.manifestsViewController view] setFrame:[[self.window contentView] frame]];
        [[self.manifestsViewController view] setFrameOrigin:NSMakePoint(0,0)];
        [[self.manifestsViewController view] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        //[self.manifestsViewController.sourceList reloadData];
        
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
        
        [self.detailViewPlaceHolder addSubview:self.currentDetailView];
        [self.sourceViewPlaceHolder addSubview:self.currentSourceView];
        
        [busyGear removeFromSuperview];
        
        [self.currentDetailView setFrame:[[self.currentDetailView superview] frame]];
        [self.currentSourceView setFrame:[[self.currentSourceView superview] frame]];
        
        // make sure our added subview is placed and resizes correctly
        [self.currentDetailView setFrameOrigin:NSMakePoint(0,0)];
        [self.currentDetailView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        [self.currentSourceView setFrameOrigin:NSMakePoint(0,0)];
        [self.currentSourceView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	}
    [self.window recalculateKeyViewLoop];
    self.window.title = [NSString stringWithFormat:@"MunkiAdmin - %@", self.selectedViewDescr];
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    DDLogDebug(@"- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem");
	if ([[tabViewItem label] isEqualToString:@"Applications"]) {
		self.currentDetailView = self.applicationsDetailView;
	} else if ([[tabViewItem label] isEqualToString:@"Catalogs"]) {
		self.currentDetailView = self.catalogsDetailView;
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
	
	NSView *left = [sender subviews][0];
	NSView *right = [sender subviews][1];
	CGFloat dividerThickness = [sender dividerThickness];
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
