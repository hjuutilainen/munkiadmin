//
//  MunkiAdmin_AppDelegate.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 11.1.2010.
//

#import "MunkiAdmin_AppDelegate.h"

@implementation MunkiAdmin_AppDelegate

# pragma mark -
# pragma mark Property Implementation Directives

@dynamic defaults;
@synthesize applicationsArrayController, allPackagesArrayController, manifestsArrayController;
@synthesize selectedViewDescr;
@synthesize window;
@synthesize progressPanel;
@synthesize mainTabView;
@synthesize mainSplitView;
@synthesize sourceViewPlaceHolder;
@synthesize detailViewPlaceHolder;
@synthesize newManifestCustomView;
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
@synthesize subProgress;
@synthesize defaultRepoContents;
@synthesize selectedViewTag;


# pragma mark -
# pragma mark Helper methods

- (IBAction)openPreferencesAction:sender
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%s", _cmd);
	}
	preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"Preferences"];
	[preferencesController showWindow:self];
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
	
	for (id anObject in [self allObjectsForEntity:@"Application"]) {
		[moc deleteObject:anObject];
	}
	
	for (id anObject in [self allObjectsForEntity:@"ApplicationInfo"]) {
		[moc deleteObject:anObject];
	}
	
	for (id anObject in [self allObjectsForEntity:@"Catalog"]) {
		[moc deleteObject:anObject];
	}
	
	for (id anObject in [self allObjectsForEntity:@"CatalogInfo"]) {
		[moc deleteObject:anObject];
	}
	
	for (id anObject in [self allObjectsForEntity:@"InstallsItem"]) {
		[moc deleteObject:anObject];
	}
	
	for (id anObject in [self allObjectsForEntity:@"Manifest"]) {
		[moc deleteObject:anObject];
	}
	
	for (id anObject in [self allObjectsForEntity:@"ManifestInfo"]) {
		[moc deleteObject:anObject];
	}
	
	for (id anObject in [self allObjectsForEntity:@"Package"]) {
		[moc deleteObject:anObject];
	}
	
	for (id anObject in [self allObjectsForEntity:@"PackageInfo"]) {
		[moc deleteObject:anObject];
	}
	
	for (id anObject in [self allObjectsForEntity:@"Receipt"]) {
		[moc deleteObject:anObject];
	}
	
	[moc processPendingChanges];
}

- (NSArray *)allObjectsForEntity:(NSString *)entityName
{
	NSEntityDescription *entityDescr = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescr];
	NSArray *fetchResults = [[self managedObjectContext] executeFetchRequest:fetchRequest error:nil];
	[fetchRequest release];
	return fetchResults;
}

- (void)checkMaxVersionsForCatalogs
{	
	/*for (ApplicationInfoMO *anAppInfo in [self allObjectsForEntity:@"ApplicationInfo"]) {
	 ManifestMO *manifest = anAppInfo.manifest;
	 NSArray *catalogInfos = [manifest.catalogInfos allObjects];
	 NSMutableArray *enabledCatalogs = [[NSMutableArray alloc] init];
	 for (CatalogInfoMO *aCatInfo in catalogInfos) {
	 if ([aCatInfo isEnabledForManifestValue]) {
	 [enabledCatalogs addObject:aCatInfo];
	 }
	 }
	 
	 NSPredicate *pkgs
	 }*/
	
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
		
		/*for (ApplicationMO *anApplication in [self allObjectsForEntity:@"Application"]) {
		 
		 }
		 
		 for (PackageMO *aPackage in [aCatalog.packages sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByName]]) {
		 NSLog(@"%@:%@-%@", aCatalog.title, aPackage.munki_name, aPackage.munki_version);
		 }*/
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
	openPanel.directoryURL = [NSURL URLWithString:[self.defaults stringForKey:@"openRepositoryLastDir"]];
	
	if ([openPanel runModal] == NSOKButton)
	{
		NSString *lastPath = [[[openPanel URLs] objectAtIndex:0] relativePath];
		[self.defaults setValue:lastPath forKey:@"openRepositoryLastDir"];
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
	
	if ([openPanel runModal] == NSOKButton)
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
	
	if ([openPanel runModal] == NSOKButton)
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
	
	if ([openPanel runModal] == NSOKButton)
	{
		return [openPanel URLs];
	} else {
		return nil;
	}
}

- (NSURL *)showSavePanel
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	savePanel.nameFieldStringValue = @"New Repository";
	if ([savePanel runModal] == NSOKButton)
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
		NSLog(@"%s: Setting up the app", _cmd);
	}
	
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
	
	self.selectedViewTag = 0;
	self.selectedViewDescr = @"Packages";
	currentDetailView = packagesDetailView;
	currentSourceView = packagesListView;
	[self changeItemView];
	
	[self.window center];
	
	// Create an operation queue for later use
	self.operationQueue = [[[NSOperationQueue alloc] init] autorelease];
	[self.operationQueue setMaxConcurrentOperationCount:1];
	self.queueIsRunning = NO;
	[progressIndicator setUsesThreadedAnimation:YES];
		
	// Define default repository contents
	self.defaultRepoContents = [NSArray arrayWithObjects:@"catalogs", @"manifests", @"pkgs", @"pkgsinfo", nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%s", _cmd);
	}
	NSURL *tempURL = [self chooseRepositoryFolder];
	if (tempURL != nil)
		[self selectRepoAtURL:tempURL];
}


# pragma mark -
# pragma mark NSOperationQueue specific

- (void)checkOperations:(NSTimer *)timer
{	
	int numOp = [[self.operationQueue operations] count];
	
    if (numOp < 1) {
		[timer invalidate];
		self.queueIsRunning = NO;
		self.currentStatusDescription = @"Done";
		[progressIndicator setDoubleValue:[progressIndicator maxValue]];
		[NSApp endSheet:progressPanel];
		[progressPanel close];
		[progressIndicator stopAnimation:self];
	} else {
		double currentProgress = ([progressIndicator maxValue] - (double)numOp) + subProgress;
		[progressIndicator setDoubleValue:currentProgress];
	}

}

- (void)startOperationTimer
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%s", _cmd);
	}
	
	NSTimer *operationTimer;
	operationTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
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

# pragma mark -
# pragma mark Modifying the repository

- (void)renameSelectedManifest
{
	ManifestMO *selMan = [[manifestsArrayController selectedObjects] objectAtIndex:0];
	
	// Configure the dialog
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Rename"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Rename Manifest"];
    [alert setInformativeText:[NSString stringWithFormat:@"Rename %@ to:", selMan.title]];
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
	[self renameSelectedManifest];
}

- (void)deleteSelectedManifests
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%s", _cmd);
	}
	
	NSArray *selectedManifests = [manifestsArrayController selectedObjects];
	NSManagedObjectContext *moc = [self managedObjectContext];
	// Configure the dialog
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Delete"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Delete Manifests"];
    [alert setInformativeText:[NSString stringWithFormat:@"Are you sure you want to delete %i manifest(s)? This can't be undone.", [selectedManifests count]]];
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
	[self deleteSelectedManifests];
}

- (void)deleteSelectedPackages
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%s", _cmd);
	}
	
	NSArray *selectedPackages = [allPackagesArrayController selectedObjects];
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
								   @"Are you sure you want to delete %i packages and their packageinfo files from the repository? This cannot be undone.", 
								   [selectedPackages count]]];
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

- (void)createNewManifest
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%s", _cmd);
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
    [alert setAccessoryView:newManifestCustomView];
	
	// Make the accessory view first responder
	[alert layout];
	[[alert window] makeFirstResponder:newManifestCustomView];
	
	// Display the dialog and act accordingly
    NSInteger result = [alert runModal];
    if (result == NSAlertFirstButtonReturn) {
		NSManagedObjectContext *moc = [self managedObjectContext];
        ManifestMO *manifest;
		manifest = [NSEntityDescription insertNewObjectForEntityForName:@"Manifest" inManagedObjectContext:moc];
		manifest.title = [newManifestCustomView stringValue];
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
		
		for (ApplicationMO *anApplication in [self allObjectsForEntity:@"Application"]) {
			ApplicationInfoMO *newApplicationInfo = [NSEntityDescription insertNewObjectForEntityForName:@"ApplicationInfo" inManagedObjectContext:moc];
			[anApplication addManifestsObject:manifest];
			newApplicationInfo.manifest = manifest;
			newApplicationInfo.munki_name = anApplication.munki_name;
			[anApplication addApplicationInfosObject:newApplicationInfo];
			newApplicationInfo.isEnabledForManifestValue = NO;
		}
		
    } else if ( result == NSAlertSecondButtonReturn ) {
        
    }
    [alert release];
}

- (IBAction)createNewManifestAction:sender
{
	[self createNewManifest];
}

- (void)createNewCatalog
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%s", _cmd);
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
	for (ApplicationInfoMO *appInfo in [selectedManifest applicationInfos]) {
		appInfo.isEnabledForManifestValue = YES;
	}
}

- (IBAction)enableAllPackagesForManifestAction:sender
{
	[self enableAllPackagesForManifest];
}

- (void)disableAllPackagesForManifest
{
	ManifestMO *selectedManifest = [[manifestsArrayController selectedObjects] objectAtIndex:0];
	for (ApplicationInfoMO *appInfo in [selectedManifest applicationInfos]) {
		appInfo.isEnabledForManifestValue = NO;
	}
}

- (IBAction)disableAllPackagesForManifestAction:sender
{
	[self disableAllPackagesForManifest];
}

- (IBAction)createNewRepository:sender
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%s", _cmd);
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


- (IBAction)addNewPackage:sender
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%s", _cmd);
	}
	
	if ([self makepkginfoInstalled]) {
	
		NSArray *filesToAdd = [self chooseFiles];
		if (filesToAdd) {
			if ([self.defaults boolForKey:@"debug"]) NSLog(@"Adding %i files to repository", [filesToAdd count]);
			[progressIndicator setMaxValue:(double)[filesToAdd count]];
			[self showProgressPanel];
		}
		for (NSURL *fileToAdd in filesToAdd) {
			if (fileToAdd != nil) {
				
				NSBlockOperation *theOp = [NSBlockOperation blockOperationWithBlock: ^{
					self.subProgress = 0.1;
					NSTask *makepkginfoTask = [[[NSTask alloc] init] autorelease];
					NSPipe *makepkginfoPipe = [NSPipe pipe];
					NSFileHandle *filehandle = [makepkginfoPipe fileHandleForReading];
					self.subProgress = 0.2;
					
					self.currentStatusDescription = [NSString stringWithFormat:@"%@: Running makepkginfo", [[fileToAdd relativePath] lastPathComponent]];
					if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@", self.currentStatusDescription);
					
					NSString *launchPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"makepkginfoPath"];
					[makepkginfoTask setLaunchPath:launchPath];
					[makepkginfoTask setArguments:[NSArray arrayWithObject:[fileToAdd relativePath]]];
					[makepkginfoTask setStandardOutput:makepkginfoPipe];
					[makepkginfoTask launch];
					self.subProgress = 0.3;
					
					NSData *makepkginfoTaskData = [filehandle readDataToEndOfFile];
					self.subProgress = 0.4;
					
					NSString *error;
					NSPropertyListFormat format;
					id plist;
					self.subProgress = 0.5;
					
					self.currentStatusDescription = [NSString stringWithFormat:@"%@: Parsing command output", [[fileToAdd relativePath] lastPathComponent]];
					if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@", self.currentStatusDescription);
					plist = [NSPropertyListSerialization propertyListFromData:makepkginfoTaskData
															 mutabilityOption:NSPropertyListImmutable
																	   format:&format
															 errorDescription:&error];
					self.subProgress = 0.6;
					
					if (!plist) {
						self.subProgress = 0.9;
						if ([self.defaults boolForKey:@"debug"]) {
							NSLog(@"%@", [error description]);
							[error release];
						}
						
					} else {
						if ([self.defaults boolForKey:@"debug"]) NSLog(@"Got new dictionary from makepkginfo");
						self.currentStatusDescription = [NSString stringWithFormat:@"%@: Creating new package", [[fileToAdd relativePath] lastPathComponent]];
						if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@", self.currentStatusDescription);
						
						PackageMO *newPkg = [self newPackageWithProperties:plist];
						self.subProgress = 0.7;
						NSURL *pkginfoURL = [self.pkgsInfoURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", newPkg.munki_name, newPkg.munki_version]];
						pkginfoURL = [pkginfoURL URLByAppendingPathExtension:@"plist"];
						newPkg.packageInfoURL = pkginfoURL;
						
						if ([self.defaults boolForKey:@"debug"]) NSLog(@"pkginfoURL: %@", [(NSURL *)newPkg.packageInfoURL relativePath]);
						NSURL *destinationURL = [self.pkgsURL URLByAppendingPathComponent:[fileToAdd lastPathComponent]];
						newPkg.packageURL = destinationURL;
						if ([self.defaults boolForKey:@"debug"]) NSLog(@"packageURL: %@", [(NSURL *)newPkg.packageURL relativePath]);
						
						self.subProgress = 0.8;
						self.currentStatusDescription = [NSString stringWithFormat:@"%@: Copying item to repository", [[fileToAdd relativePath] lastPathComponent]];
						if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@", self.currentStatusDescription);
						
						NSError *copyError = nil;
						if ([[NSFileManager defaultManager] copyItemAtURL:fileToAdd toURL:destinationURL error:&copyError]) {
							self.subProgress = 0.9;
							if ([self.defaults boolForKey:@"debug"]) NSLog(@"Copied package to repository");
						} else {
							if ([self.defaults boolForKey:@"debug"]) NSLog(@"Copy failed: %@", [copyError localizedDescription]);
						}
					}
				}];
				
				[self.operationQueue addOperation:theOp];
				
			}
		}
	} else {
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Can't find %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"makepkginfoPath"]);
	}
}

- (IBAction)addNewInstallsItem:sender
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%s", _cmd);
	}
	NSArray *selectedPackages = [allPackagesArrayController selectedObjects];
	NSArray *filesToAdd = [self chooseFiles];
	if (filesToAdd) {
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Adding %i installs items", [filesToAdd count]);
		[self showProgressPanel];
	}
	for (NSURL *fileToAdd in filesToAdd) {
		if (fileToAdd != nil) {
			
			NSBlockOperation *theOp = [NSBlockOperation blockOperationWithBlock: ^{
				
				NSArray *selection = [[[NSArray alloc] initWithArray:selectedPackages] autorelease];
				NSTask *makepkginfoTask = [[[NSTask alloc] init] autorelease];
				NSPipe *makepkginfoPipe = [NSPipe pipe];
				NSFileHandle *filehandle = [makepkginfoPipe fileHandleForReading];;
				
				[makepkginfoTask setLaunchPath:@"/usr/local/munki/makepkginfo"];
				[makepkginfoTask setArguments:[NSArray arrayWithObjects:@"--file", [fileToAdd relativePath], nil]];
				[makepkginfoTask setStandardOutput:makepkginfoPipe];
				[makepkginfoTask launch];
				
				NSData *makepkginfoTaskData = [filehandle readDataToEndOfFile];
				
				NSString *error;
				NSPropertyListFormat format;
				id plist;
				
				plist = [NSPropertyListSerialization propertyListFromData:makepkginfoTaskData
														 mutabilityOption:NSPropertyListImmutable
																   format:&format
														 errorDescription:&error];
				if (!plist) {
					if ([self.defaults boolForKey:@"debug"]) {
						NSLog(@"%@", [error description]);
						[error release];
					}
				} else {
					if ([self.defaults boolForKey:@"debug"]) NSLog(@"Got new dictionary from makepkginfo");
					for (PackageMO *aPackage in selection) {
						InstallsItemMO *newInstallsItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallsItem" inManagedObjectContext:self.managedObjectContext];
						NSDictionary *installsItemProps = [[plist objectForKey:@"installs"] objectAtIndex:0];
						newInstallsItem.munki_CFBundleIdentifier = [installsItemProps objectForKey:@"CFBundleIdentifier"];
						newInstallsItem.munki_CFBundleName = [installsItemProps objectForKey:@"CFBundleName"];
						newInstallsItem.munki_CFBundleShortVersionString = [installsItemProps objectForKey:@"CFBundleShortVersionString"];
						newInstallsItem.munki_path = [installsItemProps objectForKey:@"path"];
						newInstallsItem.munki_type = [installsItemProps objectForKey:@"type"];
						newInstallsItem.munki_md5checksum = [installsItemProps objectForKey:@"md5checksum"];
						[aPackage addInstallsItemsObject:newInstallsItem];
					}
					
				}
			}];
			[self.operationQueue addOperation:theOp];
		}
	}
}

- (void)propagateAppDescriptionToVersions
{
	for (ApplicationMO *anApp in [applicationsArrayController selectedObjects]) {
		for (PackageMO *aPackage in anApp.packages) {
			aPackage.munki_description = anApp.munki_description;
		}
	}
	[self writePackagePropertyListsToDisk];
}

- (IBAction)propagateAppDescriptionToVersions:sender
{
	[self propagateAppDescriptionToVersions];
}

# pragma mark -
# pragma mark Writing to the repository

- (void)updateCatalogs
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%s", _cmd);
	}
	
	// Run makecatalogs against the current repo
	if ([self makecatalogsInstalled]) {
		NSBlockOperation *theOp = [NSBlockOperation blockOperationWithBlock: ^{
			self.queueIsRunning = YES;
			self.subProgress = 0.1;
			self.currentStatusDescription = @"Running makecatalogs";
			NSTask *makecatalogsTask = [[[NSTask alloc] init] autorelease];
			NSPipe *makecatalogsPipe = [NSPipe pipe];
			NSFileHandle *filehandle = [makecatalogsPipe fileHandleForReading];
			self.subProgress = 0.2;
			
			NSString *launchPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"makecatalogsPath"];
			[makecatalogsTask setLaunchPath:launchPath];
			[makecatalogsTask setArguments:[NSArray arrayWithObject:[self.repoURL relativePath]]];
			[makecatalogsTask setStandardOutput:makecatalogsPipe];
			[makecatalogsTask launch];
			self.subProgress = 0.3;
			
			NSData *makecatalogsTaskData = [filehandle readDataToEndOfFile];
			self.subProgress = 0.6;
			
			NSString *makecatalogsResults;
			makecatalogsResults = [[[NSString alloc] initWithData:makecatalogsTaskData encoding:NSUTF8StringEncoding] autorelease];
			self.subProgress = 0.9;
		}];
		[self showProgressPanel];
		[self.operationQueue addOperation:theOp];
	} else {
		NSLog(@"Can't find %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"makecatalogsPath"]);
	}
}

- (IBAction)updateCatalogs:sender
{
	[self updateCatalogs];
}


- (void)writePackagePropertyListsToDisk
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"Was asked to write package property lists to disk");
	}
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSEntityDescription *packageEntityDescr = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc];
	
	// Get all packages and check them for changes
	NSArray *allPackages;
	NSFetchRequest *getAllPackages = [[NSFetchRequest alloc] init];
	[getAllPackages setEntity:packageEntityDescr];
	allPackages = [moc executeFetchRequest:getAllPackages error:nil];
	
	for (PackageMO *aPackage in allPackages) {
		
		NSDictionary *infoDictOnDisk = [NSDictionary dictionaryWithContentsOfURL:(NSURL *)aPackage.packageInfoURL];
		NSMutableDictionary *mergedInfoDict = [NSMutableDictionary dictionaryWithDictionary:infoDictOnDisk];
		[mergedInfoDict addEntriesFromDictionary:[aPackage pkgInfoDictionary]];
		
		if (![mergedInfoDict isEqualToDictionary:infoDictOnDisk]) {
			if ([self.defaults boolForKey:@"debug"]) {
				NSLog(@"Changes detected in %@. Writing new pkginfo", [(NSURL *)aPackage.packageInfoURL relativePath]);
			}
			[mergedInfoDict writeToURL:(NSURL *)aPackage.packageInfoURL atomically:NO];
		} else {
			//NSLog(@"No changes detected in %@", [(NSURL *)aPackage.packageInfoURL relativePath]);
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
		NSLog(@"%s", _cmd);
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
		NSLog(@"%s", _cmd);
	}
	NSURL *tempURL = [self chooseRepositoryFolder];
	if (tempURL != nil) {
		[self selectRepoAtURL:tempURL];
	}
}

- (IBAction)reloadRepositoryAction:sender
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"%s", _cmd);
	}
	
	[self selectRepoAtURL:self.repoURL];
}

- (void)selectRepoAtURL:(NSURL *)newURL
{
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"Selecting repo: %@", [newURL relativePath]);
	}
	[self deleteAllManagedObjects];
	NSError *dirReadError = nil;
	NSArray *selectedDirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[newURL relativePath] error:&dirReadError];
	
	if (selectedDirContents == nil) {
		NSAlert *theAlert = [NSAlert alertWithError:dirReadError];
		[theAlert runModal];
	} else {
		BOOL isRepo;
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
			
			[self scanCurrentRepoForCatalogs];
			[self scanCurrentRepoForPackages];
			[self scanCurrentRepoForManifests];
			[self scanCurrentRepoForIncludedManifests];
			//[self checkMaxVersionsForCatalogs];
		} else {
			NSLog(@"Not a repo!");
		}
	}
}


- (PackageMO *)newPackageWithProperties:(NSDictionary *)properties
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSEntityDescription *catalogEntityDescr = [NSEntityDescription entityForName:@"Catalog" inManagedObjectContext:moc];
	NSEntityDescription *applicationEntityDescr = [NSEntityDescription entityForName:@"Application" inManagedObjectContext:moc];
	NSEntityDescription *manifestEntityDescr = [NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:moc];
	
	// Get all Catalog managed objects for later use
	NSArray *allCatalogs;
	NSFetchRequest *getAllCatalogs = [[NSFetchRequest alloc] init];
	[getAllCatalogs setEntity:catalogEntityDescr];
	allCatalogs = [moc executeFetchRequest:getAllCatalogs error:nil];
	[getAllCatalogs release];
	
	// Get all Application managed objects for later use
	NSArray *allApplications;
	NSFetchRequest *getAllApplications = [[NSFetchRequest alloc] init];
	[getAllApplications setEntity:applicationEntityDescr];
	allApplications = [moc executeFetchRequest:getAllApplications error:nil];
	[getAllApplications release];
	
	// Get all Manifest managed objects for later use
	NSArray *allManifests;
	NSFetchRequest *getAllManifests = [[NSFetchRequest alloc] init];
	[getAllManifests setEntity:manifestEntityDescr];
	allManifests = [moc executeFetchRequest:getAllManifests error:nil];
	[getAllManifests release];

	
	PackageMO *aNewPackage = [NSEntityDescription insertNewObjectForEntityForName:@"Package" inManagedObjectContext:moc];
	
	// Get standard munki attributes from the property list file
	NSString *name = [properties objectForKey:@"name"];
	if (name != nil) {
		aNewPackage.munki_name = [properties objectForKey:@"name"];
	} else {
		NSLog(@"Key \"name\" not found in package properties. Can't continue.");
		return nil;
	}
	
	NSString *display_name = [properties objectForKey:@"display_name"];
	aNewPackage.munki_display_name = (display_name != nil) ? display_name : aNewPackage.munki_name;
	NSString *description = [properties objectForKey:@"description"];
	aNewPackage.munki_description = (description != nil) ? description : @"";
	NSNumber *installer_size = [properties objectForKey:@"installed_size"];
	aNewPackage.munki_installed_size = (installer_size != nil) ? installer_size : [NSNumber numberWithInt:0];
	NSNumber *autoremove = [properties objectForKey:@"autoremove"];
	aNewPackage.munki_autoremove = (autoremove != nil) ? autoremove : [NSNumber numberWithBool:NO];
	NSString *installer_item_location = [properties objectForKey:@"installer_item_location"];
	aNewPackage.munki_installer_item_location = (installer_item_location != nil) ? installer_item_location : @"";
	NSNumber *installer_item_size = [properties objectForKey:@"installer_item_size"];
	aNewPackage.munki_installer_item_size = (installer_item_size != nil) ? installer_item_size : [NSNumber numberWithInt:0];
	NSString *minimum_os_version = [properties objectForKey:@"minimum_os_version"];
	aNewPackage.munki_minimum_os_version = (minimum_os_version != nil) ? minimum_os_version : @"";
	NSString *uninstall_method = [properties objectForKey:@"uninstall_method"];
	aNewPackage.munki_uninstall_method = (uninstall_method != nil) ? uninstall_method : @"";
	NSNumber *uninstallable = [properties objectForKey:@"uninstallable"];
	aNewPackage.munki_uninstallable = (uninstallable != nil) ? uninstallable : [NSNumber numberWithBool:NO];
	NSString *version = [properties objectForKey:@"version"];
	aNewPackage.munki_version = (version != nil) ? version : @"";
	NSString *installer_type = [properties objectForKey:@"installer_type"];
	aNewPackage.munki_installer_type = (installer_type != nil) ? installer_type : @"";
	
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"Creating a new package object with name: %@, version: %@", name, version);
	}
	if ([self.defaults boolForKey:@"debugLogAllProperties"]) {
		NSLog(@"Creating a new package object with properties: %@", [properties description]);
	}
	
	// Get receipts
	NSArray *itemReceipts = [properties objectForKey:@"receipts"];
	for (NSDictionary *aReceipt in itemReceipts) {
		ReceiptMO *aNewReceipt = [NSEntityDescription insertNewObjectForEntityForName:@"Receipt" inManagedObjectContext:moc];
		aNewReceipt.munki_filename = [aReceipt objectForKey:@"filename"];
		aNewReceipt.munki_installed_size = [aReceipt objectForKey:@"installed_size"];
		aNewReceipt.munki_packageid = [aReceipt objectForKey:@"packageid"];
		aNewReceipt.munki_version = [aReceipt objectForKey:@"version"];
		aNewReceipt.package = aNewPackage;
	}
	
	// Get installs items
	NSArray *installItems = [properties objectForKey:@"installs"];
	for (NSDictionary *anInstall in installItems) {
		InstallsItemMO *aNewInstallsItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallsItem" inManagedObjectContext:moc];
		aNewInstallsItem.munki_CFBundleIdentifier = [anInstall objectForKey:@"CFBundleIdentifier"];
		aNewInstallsItem.munki_CFBundleName = [anInstall objectForKey:@"CFBundleName"];
		aNewInstallsItem.munki_CFBundleShortVersionString = [anInstall objectForKey:@"CFBundleShortVersionString"];
		aNewInstallsItem.munki_path = [anInstall objectForKey:@"path"];
		aNewInstallsItem.munki_type = [anInstall objectForKey:@"type"];
		[aNewInstallsItem addPackagesObject:aNewPackage];
	}
	
	// Get catalogs
	NSArray *catalogs = [properties objectForKey:@"catalogs"];
	
	// Loop through Catalog managed objects
	for (CatalogMO *aCatalog in allCatalogs) {
		CatalogInfoMO *newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:moc];
		newCatalogInfo.package = aNewPackage;
		newCatalogInfo.catalog.title = aCatalog.title;
		
		[aCatalog addPackagesObject:aNewPackage];
		[aCatalog addCatalogInfosObject:newCatalogInfo];
		
		PackageInfoMO *newPackageInfo = [NSEntityDescription insertNewObjectForEntityForName:@"PackageInfo" inManagedObjectContext:moc];
		newPackageInfo.catalog = aCatalog;
		newPackageInfo.title = [aNewPackage.munki_display_name stringByAppendingFormat:@" %@", aNewPackage.munki_version];
		newPackageInfo.package = aNewPackage;
		
		if ([catalogs containsObject:aCatalog.title]) {
			newCatalogInfo.isEnabledForPackageValue = YES;
			newPackageInfo.isEnabledForCatalogValue = YES;
		} else {
			newCatalogInfo.isEnabledForPackageValue = NO;
			newPackageInfo.isEnabledForCatalogValue = NO;
		}
	}
	
	for (NSString *aCatalog in catalogs) {
		// Check if we already have a catalog with this name
		NSFetchRequest *fetchForCatalogs = [[NSFetchRequest alloc] init];
		[fetchForCatalogs setEntity:catalogEntityDescr];
		
		NSPredicate *catalogTitlePredicate = [NSPredicate predicateWithFormat:@"title like[cd] %@", aCatalog];
		[fetchForCatalogs setPredicate:catalogTitlePredicate];
		
		NSUInteger numFoundCatalogs = [moc countForFetchRequest:fetchForCatalogs error:nil];
		if (numFoundCatalogs == 0) {
			//NSLog(@"Creating a new catalog %@", aCatalog);
			CatalogMO *aNewCatalog = [NSEntityDescription insertNewObjectForEntityForName:@"Catalog" inManagedObjectContext:moc];
			aNewCatalog.title = aCatalog;
			[aNewCatalog addPackagesObject:aNewPackage];
			CatalogInfoMO *newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:moc];
			newCatalogInfo.package = aNewPackage;
			newCatalogInfo.catalog.title = aNewCatalog.title;
			newCatalogInfo.isEnabledForPackageValue = YES;
			[aNewCatalog addCatalogInfosObject:newCatalogInfo];
		}
		[fetchForCatalogs release];
	}
	
	// Create "Applications" from packages which have the same munki_name property
	for (ApplicationMO *anApplication in allApplications) {
		if ([aNewPackage.munki_name isEqualToString:anApplication.munki_name]) {
			//[anApplication addPackagesObject:aNewPackage];
		}
	}
	
	NSFetchRequest *fetchForApplications = [[NSFetchRequest alloc] init];
	[fetchForApplications setEntity:applicationEntityDescr];
	NSPredicate *applicationTitlePredicate = [NSPredicate predicateWithFormat:@"munki_name like[cd] %@", aNewPackage.munki_name];
	[fetchForApplications setPredicate:applicationTitlePredicate];
	
	NSUInteger numFoundApplications = [moc countForFetchRequest:fetchForApplications error:nil];
	if (numFoundApplications == 0) {
		ApplicationMO *aNewApplication = [NSEntityDescription insertNewObjectForEntityForName:@"Application" inManagedObjectContext:moc];
		aNewApplication.munki_display_name = aNewPackage.munki_display_name;
		aNewApplication.munki_name = aNewPackage.munki_name;
		aNewApplication.munki_description = aNewPackage.munki_description;
		[aNewApplication addPackagesObject:aNewPackage];
	} else if (numFoundApplications == 1) {
		ApplicationMO *existingApplication = [[moc executeFetchRequest:fetchForApplications error:nil] objectAtIndex:0];
		if ([existingApplication hasCommonDescription]) {
			aNewPackage.munki_description = [[existingApplication.packages anyObject] munki_description];
		}
		[existingApplication addPackagesObject:aNewPackage];
		aNewPackage.munki_display_name = existingApplication.munki_display_name;
		
	} else {
		NSLog(@"Found multiple Applications for package. This really shouldn't happen...");
	}

	[fetchForApplications release];
	
	return aNewPackage;
}

- (void)scanCurrentRepoForPackages
{
	// Scan the current repo for already existing pkginfo files
	// and create a new Package object for each of them
	
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"Scanning selected repo for packages");
	}
	
	NSArray *keysToget = [NSArray arrayWithObjects:NSURLNameKey, NSURLLocalizedNameKey, NSURLIsDirectoryKey, nil];
	NSFileManager *fm = [NSFileManager defaultManager];

	NSDirectoryEnumerator *pkgsInfoDirEnum = [fm enumeratorAtURL:self.pkgsInfoURL includingPropertiesForKeys:keysToget options:(NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:nil];
	for (NSURL *aPkgInfoFile in pkgsInfoDirEnum)
	{
		NSNumber *isDir;
		[aPkgInfoFile getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
		if (![isDir boolValue]) {
			NSDictionary *packageInfoDict = [NSDictionary dictionaryWithContentsOfURL:aPkgInfoFile];
			NSString *filename = nil;
			[aPkgInfoFile getResourceValue:&filename forKey:NSURLLocalizedNameKey error:nil];
			
			PackageMO *aNewPackage = [self newPackageWithProperties:packageInfoDict];
			// Set other info
			aNewPackage.packageInfoURL = aPkgInfoFile;
			aNewPackage.packageURL = [self.pkgsURL URLByAppendingPathComponent:aNewPackage.munki_installer_item_location];
		}
	}
}

- (void)scanCurrentRepoForCatalogs
{
	// Scan the current repo for already existing catalog files
	// and create a new Catalog object for each of them
	
	if ([self.defaults boolForKey:@"debug"]) {
		NSLog(@"Scanning selected repo for catalogs");
	}
	
	NSArray *keysToget = [NSArray arrayWithObjects:NSURLNameKey, NSURLIsDirectoryKey, nil];
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
				[request release];
			}
		}
	}
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
				manifest = [NSEntityDescription insertNewObjectForEntityForName:@"Manifest" inManagedObjectContext:moc];
				manifest.title = filename;
				manifest.manifestURL = aManifestFile;
			}
			[request release];
			
			// Parse manifests catalog array
			NSArray *catalogs = [manifestInfoDict objectForKey:@"catalogs"];
			for (CatalogMO *aCatalog in [self allObjectsForEntity:@"Catalog"]) {
				CatalogInfoMO *newCatalogInfo;
				newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:moc];
				newCatalogInfo.catalog.title = aCatalog.title;
				[aCatalog addManifestsObject:manifest];
				newCatalogInfo.manifest = manifest;
				[aCatalog addCatalogInfosObject:newCatalogInfo];
				
				if ([catalogs containsObject:aCatalog.title]) {
					newCatalogInfo.isEnabledForManifestValue = YES;
				} else {
					newCatalogInfo.isEnabledForManifestValue = NO;
				}
			}
			
			// Parse manifests managed_installs array
			NSArray *managedInstalls = [manifestInfoDict objectForKey:@"managed_installs"];
			for (ApplicationMO *anApplication in [self allObjectsForEntity:@"Application"]) {
				ApplicationInfoMO *newApplicationInfo = [NSEntityDescription insertNewObjectForEntityForName:@"ApplicationInfo" inManagedObjectContext:moc];
				[anApplication addManifestsObject:manifest];
				newApplicationInfo.manifest = manifest;
				newApplicationInfo.munki_name = anApplication.munki_name;
				[anApplication addApplicationInfosObject:newApplicationInfo];
				
				if ([managedInstalls containsObject:anApplication.munki_name]) {
					newApplicationInfo.isEnabledForManifestValue = YES;
				} else {
					newApplicationInfo.isEnabledForManifestValue = NO;
				}
			}
			
			// Parse included_manifests array
			/*NSArray *includedManifests = [manifestInfoDict objectForKey:@"included_manifests"];			
			if (includedManifests != nil) {
				for (ManifestMO *aManifest in [self allObjectsForEntity:@"Manifest"]) {
					ManifestInfoMO *newManifestInfo = [NSEntityDescription insertNewObjectForEntityForName:@"ManifestInfo" inManagedObjectContext:moc];
					newManifestInfo.manifest = aManifest;
					[aManifest addIncludedManifestsObject:newManifestInfo];
					
					if ([includedManifests containsObject:aManifest.title]) {
						newManifestInfo.isEnabledForManifestValue = YES;
					} else {
						newManifestInfo.isEnabledForManifestValue = NO;
					}
				}
			}*/
		}
	}
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
			//if (includedManifests != nil) {
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
			//}
		}
	}
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
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
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
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
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
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
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
			if (currentSourceView != packagesListView) {
				self.selectedViewDescr = @"Packages";
				currentDetailView = packagesDetailView;
				currentSourceView = packagesListView;
				[mainSegmentedControl setSelectedSegment:0];
				[self changeItemView];
			}
			break;
		case 2:
			if (currentSourceView != catalogsListView) {
				self.selectedViewDescr = @"Catalogs";
				currentDetailView = catalogsDetailView;
				currentSourceView = catalogsListView;
				[mainSegmentedControl setSelectedSegment:1];
				[self changeItemView];
			}
			break;
		case 3:
			if (currentSourceView != manifestsListView) {
				self.selectedViewDescr = @"Manifests";
				currentDetailView = manifestsDetailView;
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
			if (currentSourceView != packagesListView) {
				self.selectedViewDescr = @"Packages";
				currentDetailView = packagesDetailView;
				currentSourceView = packagesListView;
				[self changeItemView];
			}
			break;
		case 1:
			if (currentSourceView != catalogsListView) {
				self.selectedViewDescr = @"Catalogs";
				currentDetailView = catalogsDetailView;
				currentSourceView = catalogsListView;
				[self changeItemView];
			}
			break;
		case 2:
			if (currentSourceView != manifestsListView) {
				self.selectedViewDescr = @"Manifests";
				currentDetailView = manifestsDetailView;
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
	[sourceViewPlaceHolder displayIfNeeded];
	[detailViewPlaceHolder displayIfNeeded];
}

- (void)changeItemView
{
	// remove the old subview
	[self removeSubviews];
	
	// add a spinning progress gear in case populating the icon view takes too long
	NSRect bounds = [detailViewPlaceHolder bounds];
	CGFloat x = (bounds.size.width-32)/2;
	CGFloat y = (bounds.size.height-32)/2;
	NSProgressIndicator* busyGear = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(x, y, 32, 32)];
	[busyGear setStyle:NSProgressIndicatorSpinningStyle];
	[busyGear startAnimation:self];
	[detailViewPlaceHolder addSubview:busyGear];
	[detailViewPlaceHolder displayIfNeeded];
	
	[detailViewPlaceHolder addSubview:currentDetailView];
	[sourceViewPlaceHolder addSubview:currentSourceView];
	
	[busyGear removeFromSuperview];
	
	[currentDetailView setFrame:[[currentDetailView superview] frame]];
	[currentSourceView setFrame:[[currentSourceView superview] frame]];
	
	// make sure our added subview is placed and resizes correctly
	[currentDetailView setFrameOrigin:NSMakePoint(0,0)];
	[currentDetailView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	
	[currentSourceView setFrameOrigin:NSMakePoint(0,0)];
	[currentSourceView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	
	self.window.title = [NSString stringWithFormat:@"MunkiAdmin - %@", self.selectedViewDescr];
	
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
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
