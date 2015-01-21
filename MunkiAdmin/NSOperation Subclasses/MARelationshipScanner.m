//
//  RelationshipScanner.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 1.11.2011.
//

#import "MARelationshipScanner.h"
#import "DataModelHeaders.h"
#import "MACoreDataManager.h"
#import "MAMunkiAdmin_AppDelegate.h"
#import "MAMunkiRepositoryManager.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

@implementation MARelationshipScanner

- (NSUserDefaults *)defaults
{
	return [NSUserDefaults standardUserDefaults];
}

+ (id)pkginfoScanner
{
    DDLogDebug(@"Initializing pkginfo relationship operation");
	return [[self alloc] initWithMode:0];
}

+ (id)manifestScanner
{
    DDLogDebug(@"Initializing manifest relationship operation");
	return [[self alloc] initWithMode:1];
}

- (id)initWithMode:(NSInteger)mode {
	if ((self = [super init])) {
		_operationMode = mode;
		_currentJobDescription = @"Initializing relationship operation";
		
	}
	return self;
}


- (void)contextDidSave:(NSNotification*)notification
{
	[[self delegate] performSelectorOnMainThread:@selector(mergeChanges:)
									  withObject:notification
								   waitUntilDone:YES];
}

- (id)matchingAppOrPkgForString:(NSString *)aString
{
    NSPredicate *appPred = [NSPredicate predicateWithFormat:@"munki_name == %@", aString];
    NSUInteger foundIndex = [self.allApplications indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [appPred evaluateWithObject:obj];
    }];
    if (foundIndex != NSNotFound) {
        return [self.allApplications objectAtIndex:foundIndex];
    } else {
        NSPredicate *pkgPred = [NSPredicate predicateWithFormat:@"titleWithVersion == %@", aString];
        NSUInteger foundPkgIndex = [self.allPackages indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [pkgPred evaluateWithObject:obj];
        }];
        if (foundPkgIndex != NSNotFound) {
            return [self.allPackages objectAtIndex:foundPkgIndex];
        } else {
            return nil;
        }
    }
}

- (id)matchingCatalogForString:(NSString *)aString
{
    NSPredicate *catalogTitlePredicate = [NSPredicate predicateWithFormat:@"title == %@", aString];
    NSUInteger foundIndex = [self.allCatalogs indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [catalogTitlePredicate evaluateWithObject:obj];
    }];
    if (foundIndex != NSNotFound) {
        return [self.allCatalogs objectAtIndex:foundIndex];
    } else {
        return nil;
    }
}

- (void)scanManifests
{
    // Configure the context
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
    [moc setPersistentStoreCoordinator:[[self delegate] persistentStoreCoordinator]];
    [moc setUndoManager:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:moc];
    NSEntityDescription *catalogEntityDescr = [NSEntityDescription entityForName:@"Catalog" inManagedObjectContext:moc];
    NSEntityDescription *manifestEntityDescr = [NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:moc];
    NSEntityDescription *applicationEntityDescr = [NSEntityDescription entityForName:@"Application" inManagedObjectContext:moc];
    NSEntityDescription *packageEntityDescr = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc];
    
    
    // Get some objects for later use
    
    NSFetchRequest *getManifests = [[NSFetchRequest alloc] init];
    [getManifests setEntity:manifestEntityDescr];
    self.allManifests = [moc executeFetchRequest:getManifests error:nil];
    
    NSFetchRequest *getApplications = [[NSFetchRequest alloc] init];
    [getApplications setEntity:applicationEntityDescr];
    self.allApplications = [moc executeFetchRequest:getApplications error:nil];
    
    NSFetchRequest *getAllCatalogs = [[NSFetchRequest alloc] init];
    [getAllCatalogs setEntity:catalogEntityDescr];
    self.allCatalogs = [moc executeFetchRequest:getAllCatalogs error:nil];
    
    NSFetchRequest *getPackages = [[NSFetchRequest alloc] init];
    [getPackages setEntity:packageEntityDescr];
    self.allPackages = [moc executeFetchRequest:getPackages error:nil];
    
    
    // Loop through all known manifest objects
    // and configure contents for each
    DDLogDebug(@"Processing %lu manifests...", [self.allManifests count]);
    [self.allManifests enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        self.currentJobDescription = [NSString stringWithFormat:@"Processing %lu/%lu", (unsigned long)idx+1, (unsigned long)[self.allManifests count]];
        ManifestMO *currentManifest = (ManifestMO *)obj;
        NSDictionary *originalManifestDict = (NSDictionary *)currentManifest.originalManifest;
        
        
        NSArray *existingCatalogTitles = [[currentManifest.catalogInfos valueForKeyPath:@"catalog.title"] allObjects];
        NSArray *newCatalogTitles = [self.allCatalogs valueForKeyPath:@"title"];
        
        // Loop through all known catalog objects and configure
        // them for this manifest
        
        if (![existingCatalogTitles isEqualToArray:newCatalogTitles]) {
            
            // Delete the old catalogs
            for (CatalogInfoMO *aCatInfo in currentManifest.catalogInfos) {
                [moc deleteObject:aCatInfo];
            }
            
            NSArray *catalogs = [originalManifestDict objectForKey:@"catalogs"];
            for (CatalogMO *aCatalog in self.allCatalogs) {
                NSString *catalogTitle = [aCatalog title];
                CatalogInfoMO *newCatalogInfo;
                newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:moc];
                newCatalogInfo.catalog.title = catalogTitle;
                [aCatalog addManifestsObject:currentManifest];
                newCatalogInfo.manifest = currentManifest;
                [aCatalog addCatalogInfosObject:newCatalogInfo];
                
                if (catalogs == nil) {
                    DDLogVerbose(@"%@: catalog %@ --> disabled", currentManifest.fileName, aCatalog.title);
                    newCatalogInfo.isEnabledForManifestValue = NO;
                    newCatalogInfo.originalIndexValue = 0;
                    newCatalogInfo.indexInManifestValue = 0;
                } else if ([catalogs containsObject:catalogTitle]) {
                    DDLogVerbose(@"%@: catalog %@ --> enabled", currentManifest.fileName, aCatalog.title);
                    newCatalogInfo.isEnabledForManifestValue = YES;
                    newCatalogInfo.originalIndex = [NSNumber numberWithUnsignedInteger:[catalogs indexOfObject:catalogTitle]];
                    newCatalogInfo.indexInManifest = [NSNumber numberWithUnsignedInteger:[catalogs indexOfObject:catalogTitle]];
                } else {
                    DDLogVerbose(@"%@: catalog %@ --> disabled", currentManifest.fileName, aCatalog.title);
                    newCatalogInfo.isEnabledForManifestValue = NO;
                    newCatalogInfo.originalIndex = [NSNumber numberWithUnsignedInteger:([catalogs count] + 1)];
                    newCatalogInfo.indexInManifest = [NSNumber numberWithUnsignedInteger:([catalogs count] + 1)];
                }
            }
        }
        
        
        // StringObjects are created during the initial manifest scan.
        // Now loop through them and link them to an existing
        // PackageMO or ApplicationMO object
        
        for (StringObjectMO *aManagedInstall in currentManifest.managedInstallsFaster) {
            DDLogVerbose(@"%@: linking managed_install object %@", currentManifest.fileName, aManagedInstall.title);
            id matchingObject = [self matchingAppOrPkgForString:aManagedInstall.title];
            if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
                aManagedInstall.originalApplication = matchingObject;
            } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
                aManagedInstall.originalPackage = matchingObject;
            }
        }
        for (StringObjectMO *aManagedUninstall in currentManifest.managedUninstallsFaster) {
            DDLogVerbose(@"%@: linking managed_uninstall object %@", currentManifest.fileName, aManagedUninstall.title);
            id matchingObject = [self matchingAppOrPkgForString:aManagedUninstall.title];
            if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
                aManagedUninstall.originalApplication = matchingObject;
            } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
                aManagedUninstall.originalPackage = matchingObject;
            }
        }
        for (StringObjectMO *aManagedUpdate in currentManifest.managedUpdatesFaster) {
            DDLogVerbose(@"%@: linking managed_update object %@", currentManifest.fileName, aManagedUpdate.title);
            id matchingObject = [self matchingAppOrPkgForString:aManagedUpdate.title];
            if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
                aManagedUpdate.originalApplication = matchingObject;
            } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
                aManagedUpdate.originalPackage = matchingObject;
            }
        }
        for (StringObjectMO *anOptionalInstall in currentManifest.optionalInstallsFaster) {
            DDLogVerbose(@"%@: linking optional_install object %@", currentManifest.fileName, anOptionalInstall.title);
            id matchingObject = [self matchingAppOrPkgForString:anOptionalInstall.title];
            if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
                anOptionalInstall.originalApplication = matchingObject;
            } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
                anOptionalInstall.originalPackage = matchingObject;
            }
        }
    }];
    
    self.currentJobDescription = [NSString stringWithFormat:@"Merging changes..."];
    
    NSError *error = nil;
    if (![moc save:&error]) {
        [NSApp presentError:error];
    }
    
    if ([self.delegate respondsToSelector:@selector(relationshipScannerDidFinish:)]) {
        [self.delegate performSelectorOnMainThread:@selector(relationshipScannerDidFinish:)
                                        withObject:@"manifests"
                                     waitUntilDone:YES];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:moc];
    moc = nil;
    
    
}


- (void)scanPkginfos
{
    // Configure the context
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
    MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
    [moc setPersistentStoreCoordinator:[appDelegate persistentStoreCoordinator]];
    [moc setUndoManager:nil];
    [moc setMergePolicy:NSOverwriteMergePolicy];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:moc];
    NSEntityDescription *catalogEntityDescr = [NSEntityDescription entityForName:@"Catalog" inManagedObjectContext:moc];
    NSEntityDescription *packageEntityDescr = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc];
    NSEntityDescription *applicationEntityDescr = [NSEntityDescription entityForName:@"Application" inManagedObjectContext:moc];
    NSEntityDescription *categoryEntityDescr = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:moc];
    NSEntityDescription *developerEntityDescr = [NSEntityDescription entityForName:@"Developer" inManagedObjectContext:moc];
    
    
    /*
     Get all packages and all catalogs for later use
     */
    NSFetchRequest *getPackages = [[NSFetchRequest alloc] init];
    [getPackages setEntity:packageEntityDescr];
    //[getPackages setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"packageInfos", nil]];
    self.allPackages = [moc executeFetchRequest:getPackages error:nil];
    
    NSFetchRequest *getAllCatalogs = [[NSFetchRequest alloc] init];
    [getAllCatalogs setEntity:catalogEntityDescr];
    //[getPackages setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"packageInfos", @"catalogInfos", @"packages", nil]];
    self.allCatalogs = [moc executeFetchRequest:getAllCatalogs error:nil];
    
    NSFetchRequest *getApplications = [[NSFetchRequest alloc] init];
    [getApplications setEntity:applicationEntityDescr];
    self.allApplications = [moc executeFetchRequest:getApplications error:nil];
    
    /*
     Create a default icon for packages without a custom icon
     */
    IconImageMO *defaultIcon = [[MAMunkiRepositoryManager sharedManager] createIconImageFromURL:nil managedObjectContext:moc];
    
    DDLogDebug(@"Processing %lu packages...", [self.allPackages count]);
    [self.allPackages enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        self.currentJobDescription = [NSString stringWithFormat:@"Processing %lu/%lu", (unsigned long)idx+1, (unsigned long)[self.allPackages count]];
        PackageMO *currentPackage = (PackageMO *)obj;
        NSArray *existingCatalogTitles = [currentPackage.catalogInfos valueForKeyPath:@"catalog.title"];
        NSDictionary *originalPkginfo = (NSDictionary *)currentPackage.originalPkginfo;
        NSArray *catalogsFromPkginfo = [originalPkginfo objectForKey:@"catalogs"];
        
        NSURL *parentDirectoryURL = [currentPackage.packageInfoURL URLByDeletingLastPathComponent];
        currentPackage.packageInfoParentDirectoryURL = parentDirectoryURL;
        
        // Loop through the catalog objects we already know about
        DDLogDebug(@"%@: Looping through catalog objects we already know about...", currentPackage.titleWithVersion);
        for (CatalogMO *aCatalog in self.allCatalogs) {
            if (![existingCatalogTitles containsObject:aCatalog.title]) {
                CatalogInfoMO *newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:moc];
                newCatalogInfo.package = currentPackage;
                newCatalogInfo.catalog.title = aCatalog.title;
                
                [aCatalog addPackagesObject:currentPackage];
                [aCatalog addCatalogInfosObject:newCatalogInfo];
                
                PackageInfoMO *newPackageInfo = [NSEntityDescription insertNewObjectForEntityForName:@"PackageInfo" inManagedObjectContext:moc];
                newPackageInfo.catalog = aCatalog;
                newPackageInfo.title = [currentPackage.munki_display_name stringByAppendingFormat:@" %@", currentPackage.munki_version];
                newPackageInfo.package = currentPackage;
                
                if ([[originalPkginfo objectForKey:@"catalogs"] containsObject:aCatalog.title]) {
                    DDLogDebug(@"%@: Should be enabled for catalog %@", currentPackage.titleWithVersion, aCatalog.title);
                    newCatalogInfo.isEnabledForPackageValue = YES;
                    newCatalogInfo.originalIndex = [NSNumber numberWithUnsignedInteger:[[originalPkginfo objectForKey:@"catalogs"] indexOfObject:aCatalog.title]];
                    newPackageInfo.isEnabledForCatalogValue = YES;
                } else {
                    DDLogDebug(@"%@: Should be disabled for catalog %@", currentPackage.titleWithVersion, aCatalog.title);
                    newCatalogInfo.isEnabledForPackageValue = NO;
                    newCatalogInfo.originalIndexValue = 10000;
                    newPackageInfo.isEnabledForCatalogValue = NO;
                }
            }
        }
        
        
        // Loop through the "catalogs" key in the original pkginfo
        // and create new catalog objects if necessary
        DDLogDebug(@"%@: Looping through catalogs key in the original pkginfo...", currentPackage.titleWithVersion);
        [catalogsFromPkginfo enumerateObjectsUsingBlock:^(id catalogObject, NSUInteger catalogIndex, BOOL *stopCatalogEnum) {
            
            NSFetchRequest *fetchForCatalogs = [[NSFetchRequest alloc] init];
            [fetchForCatalogs setEntity:catalogEntityDescr];
            
            NSPredicate *catalogTitlePredicate = [NSPredicate predicateWithFormat:@"title == %@", catalogObject];
            [fetchForCatalogs setPredicate:catalogTitlePredicate];
            
            NSUInteger numFoundCatalogs = [moc countForFetchRequest:fetchForCatalogs error:nil];
            
            
            // There is an item in catalogs array which does not
            // yet have it's own CatalogMO object.
            // Create it and add dependencies for it
            
            if (numFoundCatalogs == 0) {
                DDLogDebug(@"%@: Should be enabled for new catalog %@", currentPackage.titleWithVersion, catalogObject);
                CatalogMO *aNewCatalog = [NSEntityDescription insertNewObjectForEntityForName:@"Catalog" inManagedObjectContext:moc];
                aNewCatalog.title = catalogObject;
                [aNewCatalog addPackagesObject:currentPackage];
                CatalogInfoMO *newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:moc];
                newCatalogInfo.package = currentPackage;
                newCatalogInfo.catalog.title = aNewCatalog.title;
                newCatalogInfo.isEnabledForPackageValue = YES;
                newCatalogInfo.originalIndex = [NSNumber numberWithUnsignedInteger:[catalogsFromPkginfo indexOfObject:catalogObject]];
                [aNewCatalog addCatalogInfosObject:newCatalogInfo];
                
                PackageInfoMO *newPackageInfo = [NSEntityDescription insertNewObjectForEntityForName:@"PackageInfo" inManagedObjectContext:moc];
                newPackageInfo.catalog = aNewCatalog;
                newPackageInfo.title = [currentPackage.munki_display_name stringByAppendingFormat:@" %@", currentPackage.munki_version];
                newPackageInfo.package = currentPackage;
                newPackageInfo.isEnabledForCatalogValue = YES;
            }
            
            
            // Found one (or more) existing CatalogMO objects with this name.
            // Use the first one and create dependencies if needed
            
            else {
                CatalogMO *foundCatalog = [[moc executeFetchRequest:fetchForCatalogs error:nil] objectAtIndex:0];
                
                if (![[currentPackage.catalogInfos valueForKeyPath:@"catalog.title"] containsObject:catalogObject]) {
                    DDLogDebug(@"%@: Should be enabled for existing catalog %@", currentPackage.titleWithVersion, foundCatalog.title);
                    [foundCatalog addPackagesObject:currentPackage];
                    CatalogInfoMO *newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:moc];
                    newCatalogInfo.package = currentPackage;
                    newCatalogInfo.catalog.title = foundCatalog.title;
                    newCatalogInfo.isEnabledForPackageValue = YES;
                    newCatalogInfo.originalIndex = [NSNumber numberWithUnsignedInteger:[catalogsFromPkginfo indexOfObject:catalogObject]];
                    [foundCatalog addCatalogInfosObject:newCatalogInfo];
                    PackageInfoMO *newPackageInfo = [NSEntityDescription insertNewObjectForEntityForName:@"PackageInfo" inManagedObjectContext:moc];
                    newPackageInfo.catalog = foundCatalog;
                    newPackageInfo.title = [currentPackage.munki_display_name stringByAppendingFormat:@" %@", currentPackage.munki_version];
                    newPackageInfo.package = currentPackage;
                    newPackageInfo.isEnabledForCatalogValue = YES;
                }
            }
        }];
        
        /*
         Deal with the package icon
         
         First check if the pkginfo has a custom icon defined in "icon_name" key.
         If not, check if there's an icon mathing the "name" key. If both of these fail,
         use a default icon (which is the icon for .pkg file type).
         */
        if ((currentPackage.munki_icon_name != nil) && (![currentPackage.munki_icon_name isEqualToString:@""])) {
            NSURL *iconURL = [[appDelegate iconsURL] URLByAppendingPathComponent:currentPackage.munki_icon_name];
            if ([[iconURL pathExtension] isEqualToString:@""]) {
                iconURL = [iconURL URLByAppendingPathExtension:@"png"];
            }
            if ([[NSFileManager defaultManager] fileExistsAtPath:[iconURL path]]) {
                IconImageMO *icon = [[MAMunkiRepositoryManager sharedManager] createIconImageFromURL:iconURL managedObjectContext:moc];
                currentPackage.iconImage = icon;
            } else {
                currentPackage.iconImage = defaultIcon;
            }
        } else {
            NSURL *iconURL = [[appDelegate iconsURL] URLByAppendingPathComponent:currentPackage.munki_name];
            iconURL = [iconURL URLByAppendingPathExtension:@"png"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[iconURL path]]) {
                IconImageMO *icon = [[MAMunkiRepositoryManager sharedManager] createIconImageFromURL:iconURL managedObjectContext:moc];
                currentPackage.iconImage = icon;
            } else {
                currentPackage.iconImage = defaultIcon;
            }
        }
        
        /*
         Deal with the package category
         */
        if ([originalPkginfo objectForKey:@"category"] != nil) {
            NSFetchRequest *fetchForCategory = [[NSFetchRequest alloc] init];
            [fetchForCategory setEntity:categoryEntityDescr];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", [originalPkginfo objectForKey:@"category"]];
            [fetchForCategory setPredicate:predicate];
            
            NSUInteger numFoundCategories = [moc countForFetchRequest:fetchForCategory error:nil];
            CategoryMO *category = nil;
            if (numFoundCategories > 0) {
                category = [[moc executeFetchRequest:fetchForCategory error:nil] objectAtIndex:0];
                [category addPackagesObject:currentPackage];
            } else {
                category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:moc];
                category.title = [originalPkginfo objectForKey:@"category"];
                [category addPackagesObject:currentPackage];
            }
        }
        
        /*
         Deal with the package developer
         */
        if ([originalPkginfo objectForKey:@"developer"] != nil) {
            NSFetchRequest *fetchForDeveloper = [[NSFetchRequest alloc] init];
            [fetchForDeveloper setEntity:developerEntityDescr];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", [originalPkginfo objectForKey:@"developer"]];
            [fetchForDeveloper setPredicate:predicate];
            
            NSUInteger numFoundDevelopers = [moc countForFetchRequest:fetchForDeveloper error:nil];
            DeveloperMO *developer = nil;
            if (numFoundDevelopers > 0) {
                developer = [[moc executeFetchRequest:fetchForDeveloper error:nil] objectAtIndex:0];
                [developer addPackagesObject:currentPackage];
            } else {
                developer = [NSEntityDescription insertNewObjectForEntityForName:@"Developer" inManagedObjectContext:moc];
                developer.title = [originalPkginfo objectForKey:@"developer"];
                [developer addPackagesObject:currentPackage];
            }
        }
    }];
    
    /*
     Run through all the "name-grouped" packages and update the
     reference to the latest package.
     */
    [self.allApplications enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ApplicationMO *currentApplication = (ApplicationMO *)obj;
        [currentApplication updateLatestPackage];
    }];
    
    /*
     Create the source list items for category objects
     */
    [[MACoreDataManager sharedManager] configureSourceListCategoriesSection:moc];
    
    /*
     Create the source list items for developer objects
     */
    [[MACoreDataManager sharedManager] configureSourceListDevelopersSection:moc];
    
    
    self.currentJobDescription = [NSString stringWithFormat:@"Merging changes..."];
    
    NSError *error = nil;
    if (![moc save:&error]) {
        [NSApp presentError:error];
    }
    
    if ([self.delegate respondsToSelector:@selector(relationshipScannerDidFinish:)]) {
        [self.delegate performSelectorOnMainThread:@selector(relationshipScannerDidFinish:)
                                        withObject:@"pkgs"
                                     waitUntilDone:YES];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:moc];
    moc = nil;
}


-(void)main {
	@try {
		@autoreleasepool {
            
            switch (self.operationMode) {
                case 0:
                    [self scanPkginfos];
                    break;
                case 1:
                    [self scanManifests];
                default:
                    break;
            }
            
		}
	}
	@catch(...) {
		// Do not rethrow exceptions.
	}
}

@end
