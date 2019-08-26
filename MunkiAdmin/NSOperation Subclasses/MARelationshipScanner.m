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

static const int BatchSize = 50;

@interface MARelationshipScanner ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation MARelationshipScanner

- (NSUserDefaults *)defaults
{
	return [NSUserDefaults standardUserDefaults];
}

+ (id)pkginfoScanner
{
    DDLogVerbose(@"Initializing pkginfo relationship operation");
	return [[self alloc] initWithMode:0];
}

+ (id)manifestScanner
{
    DDLogVerbose(@"Initializing manifest relationship operation");
	return [[self alloc] initWithMode:1];
}

- (id)initWithMode:(NSInteger)mode {
	if ((self = [super init])) {
		_operationMode = mode;
		_currentJobDescription = @"Initializing relationship operation";
		
	}
	return self;
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

- (ManifestMO *)matchingManifestForString:(NSString *)title
{
    ManifestMO *manifest = nil;
    /*
     Try to get a managed object ID for this title, this is a broken reference if it doesn't exist!
     */
    ManifestMOID *manifestID = [self.allManifestsByTitle objectForKey:title];
    if (manifestID) {
        
        /*
         Resolve the managed object ID to an actual manifest object
         */
        manifest = (ManifestMO *)[self.context existingObjectWithID:manifestID error:nil];
        if (manifest) {
            DDLogVerbose(@"Found existing manifest with title '%@'", title);
        } else {
            DDLogError(@"Error: Could not find manifest with title '%@'", title);
        }
    } else {
        DDLogError(@"Error: Could not find manifest with title '%@'", title);
    }
    return manifest;
}

- (void)scanManifests
{
    NSManagedObjectContext *privateContext = self.context;
    
    NSEntityDescription *catalogEntityDescr = [NSEntityDescription entityForName:@"Catalog" inManagedObjectContext:privateContext];
    NSEntityDescription *manifestEntityDescr = [NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:privateContext];
    NSEntityDescription *applicationEntityDescr = [NSEntityDescription entityForName:@"Application" inManagedObjectContext:privateContext];
    NSEntityDescription *packageEntityDescr = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:privateContext];
    
    
    // Get some objects for later use
    
    NSFetchRequest *getManifests = [[NSFetchRequest alloc] init];
    [getManifests setEntity:manifestEntityDescr];
    self.allManifests = [privateContext executeFetchRequest:getManifests error:nil];
    
    NSMutableDictionary *manifestsAndTitles = [[NSMutableDictionary alloc] initWithCapacity:[self.allManifests count]];
    for (ManifestMO *manifest in self.allManifests) {
        manifestsAndTitles[manifest.title] = manifest.objectID;
    }
    self.allManifestsByTitle = manifestsAndTitles;
    
    NSFetchRequest *getApplications = [[NSFetchRequest alloc] init];
    [getApplications setEntity:applicationEntityDescr];
    self.allApplications = [privateContext executeFetchRequest:getApplications error:nil];
    
    NSFetchRequest *getAllCatalogs = [[NSFetchRequest alloc] init];
    [getAllCatalogs setEntity:catalogEntityDescr];
    self.allCatalogs = [privateContext executeFetchRequest:getAllCatalogs error:nil];
    
    NSFetchRequest *getPackages = [[NSFetchRequest alloc] init];
    [getPackages setEntity:packageEntityDescr];
    self.allPackages = [privateContext executeFetchRequest:getPackages error:nil];
    
    
    // Loop through all known manifest objects
    // and configure contents for each
    DDLogDebug(@"Processing %lu manifests...", [self.allManifests count]);
    
    
    NSUInteger count = [self.allManifests count];
    NSUInteger progressGranularity;
    if (count < 100) {
        progressGranularity = 1; // Update progress for every package
    } else {
        progressGranularity = count / 100; // Update progress after every ~1% of work
    }
    
    [self.allManifests enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ManifestMO *currentManifest = (ManifestMO *)obj;
        NSDictionary *originalManifestDict = (NSDictionary *)currentManifest.originalManifest;
        
        
        NSArray *existingCatalogTitles = [[currentManifest.catalogInfos valueForKeyPath:@"catalog.title"] allObjects];
        NSArray *newCatalogTitles = [self.allCatalogs valueForKeyPath:@"title"];
        
        // Loop through all known catalog objects and configure
        // them for this manifest
        
        if (![existingCatalogTitles isEqualToArray:newCatalogTitles]) {
            
            // Delete the old catalogs
            for (CatalogInfoMO *aCatInfo in currentManifest.catalogInfos) {
                [privateContext deleteObject:aCatInfo];
            }
            
            NSArray *catalogs = [originalManifestDict objectForKey:@"catalogs"];
            for (CatalogMO *aCatalog in self.allCatalogs) {
                NSString *catalogTitle = [aCatalog title];
                CatalogInfoMO *newCatalogInfo;
                newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:privateContext];
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
        
        
        /*
         StringObjects are created during the initial manifest scan.
         Now loop through them and link them to an existing
         PackageMO or ApplicationMO object
         */
        
        for (StringObjectMO *aManagedInstall in currentManifest.managedInstallsFaster) {
            DDLogVerbose(@"%@: linking managed_install object %@", currentManifest.fileName, aManagedInstall.title);
            id matchingObject = [self matchingAppOrPkgForString:aManagedInstall.title];
            if (!matchingObject) {
                DDLogError(@"%@: Error: Could not link managed_install object %lu --> Name: %@", currentManifest.title, (unsigned long)idx, aManagedInstall.title);
            } else if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
                aManagedInstall.originalApplication = matchingObject;
            } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
                aManagedInstall.originalPackage = matchingObject;
            }
        }
        for (StringObjectMO *aManagedUninstall in currentManifest.managedUninstallsFaster) {
            DDLogVerbose(@"%@: linking managed_uninstall object %@", currentManifest.fileName, aManagedUninstall.title);
            id matchingObject = [self matchingAppOrPkgForString:aManagedUninstall.title];
            if (!matchingObject) {
                DDLogError(@"%@: Error: Could not link managed_uninstall object %lu --> Name: %@", currentManifest.title, (unsigned long)idx, aManagedUninstall.title);
            } else if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
                aManagedUninstall.originalApplication = matchingObject;
            } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
                aManagedUninstall.originalPackage = matchingObject;
            }
        }
        for (StringObjectMO *aManagedUpdate in currentManifest.managedUpdatesFaster) {
            DDLogVerbose(@"%@: linking managed_update object %@", currentManifest.fileName, aManagedUpdate.title);
            id matchingObject = [self matchingAppOrPkgForString:aManagedUpdate.title];
            if (!matchingObject) {
                DDLogError(@"%@: Error: Could not link managed_update object %lu --> Name: %@", currentManifest.title, (unsigned long)idx, aManagedUpdate.title);
            } else if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
                aManagedUpdate.originalApplication = matchingObject;
            } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
                aManagedUpdate.originalPackage = matchingObject;
            }
        }
        for (StringObjectMO *anOptionalInstall in currentManifest.optionalInstallsFaster) {
            DDLogVerbose(@"%@: linking optional_install object %@", currentManifest.fileName, anOptionalInstall.title);
            id matchingObject = [self matchingAppOrPkgForString:anOptionalInstall.title];
            if (!matchingObject) {
                DDLogError(@"%@: Error: Could not link optional_install object %lu --> Name: %@", currentManifest.title, (unsigned long)idx, anOptionalInstall.title);
            } else if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
                anOptionalInstall.originalApplication = matchingObject;
            } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
                anOptionalInstall.originalPackage = matchingObject;
            }
        }
        
        /*
         Link included manifest items
         */
        for (StringObjectMO *stringObject in currentManifest.includedManifestsFaster) {
            DDLogVerbose(@"%@: linking included_manifest object %@", currentManifest.fileName, stringObject.title);
            
            ManifestMO *originalManifest = [self matchingManifestForString:stringObject.title];
            if (originalManifest) {
                DDLogVerbose(@"%@: linking included_manifest object %@ to original manifest %@", currentManifest.fileName, stringObject.title, originalManifest.title);
                stringObject.originalManifest = originalManifest;
            } else {
                DDLogError(@"%@: Error: Could not link included_manifest object %lu --> Name: %@", currentManifest.title, (unsigned long)idx, stringObject.title);
            }
        }
        
        /*
         Link items under conditional items
         */
        for (ConditionalItemMO *conditionalItem in currentManifest.conditionalItems) {
            for (StringObjectMO *managedInstall in conditionalItem.managedInstalls) {
                DDLogVerbose(@"%@: linking conditional managed_install object %@", currentManifest.fileName, managedInstall.title);
                id matchingObject = [self matchingAppOrPkgForString:managedInstall.title];
                if (!matchingObject) {
                    DDLogError(@"%@: Error: Could not link conditional managed_install object %lu --> Name: %@", currentManifest.title, (unsigned long)idx, managedInstall.title);
                } else if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
                    managedInstall.originalApplication = matchingObject;
                } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
                    managedInstall.originalPackage = matchingObject;
                }
            }
            for (StringObjectMO *managedUninstall in conditionalItem.managedUninstalls) {
                DDLogVerbose(@"%@: linking conditional managed_uninstall object %@", currentManifest.fileName, managedUninstall.title);
                id matchingObject = [self matchingAppOrPkgForString:managedUninstall.title];
                if (!matchingObject) {
                    DDLogError(@"%@: Error: Could not link conditional managed_uninstall object %lu --> Name: %@", currentManifest.title, (unsigned long)idx, managedUninstall.title);
                } else if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
                    managedUninstall.originalApplication = matchingObject;
                } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
                    managedUninstall.originalPackage = matchingObject;
                }
            }
            for (StringObjectMO *managedUpdate in conditionalItem.managedUpdates) {
                DDLogVerbose(@"%@: linking conditional managed_update object %@", currentManifest.fileName, managedUpdate.title);
                id matchingObject = [self matchingAppOrPkgForString:managedUpdate.title];
                if (!matchingObject) {
                    DDLogError(@"%@: Error: Could not link conditional managed_update object %lu --> Name: %@", currentManifest.title, (unsigned long)idx, managedUpdate.title);
                } else if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
                    managedUpdate.originalApplication = matchingObject;
                } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
                    managedUpdate.originalPackage = matchingObject;
                }
            }
            for (StringObjectMO *optionalInstall in conditionalItem.optionalInstalls) {
                DDLogVerbose(@"%@: linking conditional optional_install object %@", currentManifest.fileName, optionalInstall.title);
                id matchingObject = [self matchingAppOrPkgForString:optionalInstall.title];
                if (!matchingObject) {
                    DDLogError(@"%@: Error: Could not link conditional optional_install object %lu --> Name: %@", currentManifest.title, (unsigned long)idx, optionalInstall.title);
                } else if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
                    optionalInstall.originalApplication = matchingObject;
                } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
                    optionalInstall.originalPackage = matchingObject;
                }
            }
            
            for (StringObjectMO *includedManifest in conditionalItem.includedManifests) {
                DDLogVerbose(@"%@: linking conditional included_manifest object %@", currentManifest.fileName, includedManifest.title);
                
                ManifestMO *originalManifest = [self matchingManifestForString:includedManifest.title];
                if (originalManifest) {
                    DDLogVerbose(@"%@: linking conditional included_manifest object %@ to original manifest %@", currentManifest.fileName, includedManifest.title, originalManifest.title);
                    includedManifest.originalManifest = originalManifest;
                } else {
                    DDLogError(@"%@: could not link conditional included_manifest object %lu --> Name: %@", currentManifest.title, (unsigned long)idx, includedManifest.title);
                }
            }
        }
         
        
        if (idx % progressGranularity == 0) {
            double percentage = (idx / (float)[self.allManifests count]) * 100.0;
            self.currentJobDescription = [NSString stringWithFormat:@"Processing: (%1.0f%% done)", percentage];
        }
        if (idx % BatchSize == 0) {
            [privateContext save:nil];
        }
    }];
    
    /*
     Update the number of characters we need to display unique catalog titles
     */
    NSUInteger length = 1;
    while (length < 10) {
        NSMutableArray *currentTitles = [NSMutableArray new];
        for (CatalogMO *catalog in self.allCatalogs) {
            NSString *shortenedTitle = [catalog.title substringToIndex:([catalog.title length] > length) ? length : [catalog.title length]];
            [currentTitles addObject:shortenedTitle];
        }
        
        if ([[currentTitles valueForKeyPath:@"@distinctUnionOfObjects.self"] count] == [currentTitles count]) {
            DDLogDebug(@"Short catalog titles are unique when the length is %lu character...", (unsigned long)length);
            [[MAMunkiRepositoryManager sharedManager] setLengthForUniqueCatalogTitles:length];
            break;
        } else {
            DDLogVerbose(@"Not all short titles are unique");
            DDLogVerbose(@"%@", [currentTitles description]);
        }
        
        length++;
    }
    
    
    self.currentJobDescription = [NSString stringWithFormat:@"Merging changes..."];
    
    /*
     Save both private and parent contexts. We need to use
     performBlock since we're in NSPrivateQueueConcurrencyType
     */
    NSError *error = nil;
    if ([privateContext save:&error]) {
        /*
        [privateContext.parentContext performBlock:^{
            NSError *parentError = nil;
            [privateContext.parentContext save:&parentError];
        }];
         */
    } else {
        DDLogError(@"Private context failed to save: %@", error);
    }
    
    if ([self.delegate respondsToSelector:@selector(relationshipScannerDidFinish:)]) {
        [self.delegate performSelectorOnMainThread:@selector(relationshipScannerDidFinish:)
                                        withObject:@"manifests"
                                     waitUntilDone:YES];
    }
}


- (void)scanPkginfos
{
    MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)self.delegate;
    NSManagedObjectContext *privateContext = self.context;
    
    NSEntityDescription *catalogEntityDescr = [NSEntityDescription entityForName:@"Catalog" inManagedObjectContext:privateContext];
    NSEntityDescription *packageEntityDescr = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:privateContext];
    NSEntityDescription *applicationEntityDescr = [NSEntityDescription entityForName:@"Application" inManagedObjectContext:privateContext];
    NSEntityDescription *categoryEntityDescr = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:privateContext];
    NSEntityDescription *developerEntityDescr = [NSEntityDescription entityForName:@"Developer" inManagedObjectContext:privateContext];
    
    
    /*
     Get all packages and all catalogs for later use
     */
    NSFetchRequest *getPackages = [[NSFetchRequest alloc] init];
    [getPackages setEntity:packageEntityDescr];
    //[getPackages setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"packageInfos", nil]];
    self.allPackages = [privateContext executeFetchRequest:getPackages error:nil];
    
    NSFetchRequest *getAllCatalogs = [[NSFetchRequest alloc] init];
    [getAllCatalogs setEntity:catalogEntityDescr];
    //[getPackages setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"packageInfos", @"catalogInfos", @"packages", nil]];
    self.allCatalogs = [privateContext executeFetchRequest:getAllCatalogs error:nil];
    
    NSFetchRequest *getApplications = [[NSFetchRequest alloc] init];
    [getApplications setEntity:applicationEntityDescr];
    self.allApplications = [privateContext executeFetchRequest:getApplications error:nil];
    
    /*
     Create a default icon for packages without a custom icon
     */
    IconImageMO *defaultIcon = [[MAMunkiRepositoryManager sharedManager] createIconImageFromURL:nil managedObjectContext:privateContext];
    
    DDLogDebug(@"Processing %lu packages...", [self.allPackages count]);
    
    NSUInteger count = [self.allPackages count];
    NSUInteger progressGranularity;
    if (count < 100) {
        progressGranularity = 1; // Update progress for every package
    } else {
        progressGranularity = count / 100; // Update progress after every ~1% of work
    }
    
    [self.allPackages enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PackageMO *currentPackage = (PackageMO *)obj;
        NSArray *existingCatalogTitles = [currentPackage.catalogInfos valueForKeyPath:@"catalog.title"];
        NSDictionary *originalPkginfo = (NSDictionary *)currentPackage.originalPkginfo;
        NSArray *catalogsFromPkginfo = [originalPkginfo objectForKey:@"catalogs"];
        
        NSURL *parentDirectoryURL = [currentPackage.packageInfoURL URLByDeletingLastPathComponent];
        currentPackage.packageInfoParentDirectoryURL = parentDirectoryURL;
        
        // Loop through the catalog objects we already know about
        DDLogVerbose(@"%@: Looping through catalog objects we already know about...", currentPackage.titleWithVersion);
        for (CatalogMO *aCatalog in self.allCatalogs) {
            if (![existingCatalogTitles containsObject:aCatalog.title]) {
                CatalogInfoMO *newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:privateContext];
                newCatalogInfo.package = currentPackage;
                newCatalogInfo.catalog.title = aCatalog.title;
                
                [aCatalog addPackagesObject:currentPackage];
                [aCatalog addCatalogInfosObject:newCatalogInfo];
                
                PackageInfoMO *newPackageInfo = [NSEntityDescription insertNewObjectForEntityForName:@"PackageInfo" inManagedObjectContext:privateContext];
                newPackageInfo.catalog = aCatalog;
                newPackageInfo.title = [currentPackage.munki_display_name stringByAppendingFormat:@" %@", currentPackage.munki_version];
                newPackageInfo.package = currentPackage;
                
                if ([[originalPkginfo objectForKey:@"catalogs"] containsObject:aCatalog.title]) {
                    DDLogVerbose(@"%@: Should be enabled for catalog %@", currentPackage.titleWithVersion, aCatalog.title);
                    newCatalogInfo.isEnabledForPackageValue = YES;
                    newCatalogInfo.originalIndex = [NSNumber numberWithUnsignedInteger:[[originalPkginfo objectForKey:@"catalogs"] indexOfObject:aCatalog.title]];
                    newPackageInfo.isEnabledForCatalogValue = YES;
                } else {
                    DDLogVerbose(@"%@: Should be disabled for catalog %@", currentPackage.titleWithVersion, aCatalog.title);
                    newCatalogInfo.isEnabledForPackageValue = NO;
                    newCatalogInfo.originalIndexValue = 10000;
                    newPackageInfo.isEnabledForCatalogValue = NO;
                }
            }
        }
        
        
        // Loop through the "catalogs" key in the original pkginfo
        // and create new catalog objects if necessary
        DDLogVerbose(@"%@: Looping through catalogs key in the original pkginfo...", currentPackage.titleWithVersion);
        [catalogsFromPkginfo enumerateObjectsUsingBlock:^(id catalogObject, NSUInteger catalogIndex, BOOL *stopCatalogEnum) {
            
            NSFetchRequest *fetchForCatalogs = [[NSFetchRequest alloc] init];
            [fetchForCatalogs setEntity:catalogEntityDescr];
            
            NSPredicate *catalogTitlePredicate = [NSPredicate predicateWithFormat:@"title == %@", catalogObject];
            [fetchForCatalogs setPredicate:catalogTitlePredicate];
            
            NSUInteger numFoundCatalogs = [privateContext countForFetchRequest:fetchForCatalogs error:nil];
            
            
            // There is an item in catalogs array which does not
            // yet have it's own CatalogMO object.
            // Create it and add dependencies for it
            
            if (numFoundCatalogs == 0) {
                DDLogVerbose(@"%@: Should be enabled for new catalog %@", currentPackage.titleWithVersion, catalogObject);
                CatalogMO *aNewCatalog = [NSEntityDescription insertNewObjectForEntityForName:@"Catalog" inManagedObjectContext:privateContext];
                aNewCatalog.title = catalogObject;
                [aNewCatalog addPackagesObject:currentPackage];
                CatalogInfoMO *newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:privateContext];
                newCatalogInfo.package = currentPackage;
                newCatalogInfo.catalog.title = aNewCatalog.title;
                newCatalogInfo.isEnabledForPackageValue = YES;
                newCatalogInfo.originalIndex = [NSNumber numberWithUnsignedInteger:[catalogsFromPkginfo indexOfObject:catalogObject]];
                [aNewCatalog addCatalogInfosObject:newCatalogInfo];
                
                PackageInfoMO *newPackageInfo = [NSEntityDescription insertNewObjectForEntityForName:@"PackageInfo" inManagedObjectContext:privateContext];
                newPackageInfo.catalog = aNewCatalog;
                newPackageInfo.title = [currentPackage.munki_display_name stringByAppendingFormat:@" %@", currentPackage.munki_version];
                newPackageInfo.package = currentPackage;
                newPackageInfo.isEnabledForCatalogValue = YES;
            }
            
            
            // Found one (or more) existing CatalogMO objects with this name.
            // Use the first one and create dependencies if needed
            
            else {
                CatalogMO *foundCatalog = [[privateContext executeFetchRequest:fetchForCatalogs error:nil] objectAtIndex:0];
                
                if (![[currentPackage.catalogInfos valueForKeyPath:@"catalog.title"] containsObject:catalogObject]) {
                    DDLogVerbose(@"%@: Should be enabled for existing catalog %@", currentPackage.titleWithVersion, foundCatalog.title);
                    [foundCatalog addPackagesObject:currentPackage];
                    CatalogInfoMO *newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:privateContext];
                    newCatalogInfo.package = currentPackage;
                    newCatalogInfo.catalog.title = foundCatalog.title;
                    newCatalogInfo.isEnabledForPackageValue = YES;
                    newCatalogInfo.originalIndex = [NSNumber numberWithUnsignedInteger:[catalogsFromPkginfo indexOfObject:catalogObject]];
                    [foundCatalog addCatalogInfosObject:newCatalogInfo];
                    PackageInfoMO *newPackageInfo = [NSEntityDescription insertNewObjectForEntityForName:@"PackageInfo" inManagedObjectContext:privateContext];
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
                IconImageMO *icon = [[MAMunkiRepositoryManager sharedManager] createIconImageFromURL:iconURL managedObjectContext:privateContext];
                currentPackage.iconImage = icon;
            } else {
                currentPackage.iconImage = defaultIcon;
            }
        } else {
            NSURL *iconURL = [[appDelegate iconsURL] URLByAppendingPathComponent:currentPackage.munki_name];
            iconURL = [iconURL URLByAppendingPathExtension:@"png"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[iconURL path]]) {
                IconImageMO *icon = [[MAMunkiRepositoryManager sharedManager] createIconImageFromURL:iconURL managedObjectContext:privateContext];
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
            
            NSUInteger numFoundCategories = [privateContext countForFetchRequest:fetchForCategory error:nil];
            CategoryMO *category = nil;
            if (numFoundCategories > 0) {
                category = [[privateContext executeFetchRequest:fetchForCategory error:nil] objectAtIndex:0];
                [category addPackagesObject:currentPackage];
            } else {
                category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:privateContext];
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
            
            NSUInteger numFoundDevelopers = [privateContext countForFetchRequest:fetchForDeveloper error:nil];
            DeveloperMO *developer = nil;
            if (numFoundDevelopers > 0) {
                developer = [[privateContext executeFetchRequest:fetchForDeveloper error:nil] objectAtIndex:0];
                [developer addPackagesObject:currentPackage];
            } else {
                developer = [NSEntityDescription insertNewObjectForEntityForName:@"Developer" inManagedObjectContext:privateContext];
                developer.title = [originalPkginfo objectForKey:@"developer"];
                [developer addPackagesObject:currentPackage];
            }
        }
        
        if (idx % progressGranularity == 0) {
            double percentage = (idx / (float)[self.allPackages count]) * 100.0;
            self.currentJobDescription = [NSString stringWithFormat:@"Processing: (%1.0f%% done)", percentage];
        }
        if (idx % BatchSize == 0) {
            [privateContext save:nil];
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
    [[MACoreDataManager sharedManager] configureSourceListCategoriesSection:privateContext];
    
    /*
     Create the source list items for developer objects
     */
    [[MACoreDataManager sharedManager] configureSourceListDevelopersSection:privateContext];
    
    
    self.currentJobDescription = [NSString stringWithFormat:@"Merging changes..."];
    
    /*
     Save both private and parent contexts. We need to use
     performBlock since we're in NSPrivateQueueConcurrencyType
     */
    NSError *error = nil;
    if ([privateContext save:&error]) {
        /*
        [privateContext.parentContext performBlock:^{
            NSError *parentError = nil;
            [privateContext.parentContext save:&parentError];
        }];
         */
    } else {
        DDLogError(@"Private context failed to save: %@", error);
    }
    
    if ([self.delegate respondsToSelector:@selector(relationshipScannerDidFinish:)]) {
        [self.delegate performSelectorOnMainThread:@selector(relationshipScannerDidFinish:)
                                        withObject:@"pkgs"
                                     waitUntilDone:YES];
    }
}


- (void)main {
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.context.parentContext = [(MAMunkiAdmin_AppDelegate *)self.delegate managedObjectContext];
    self.context.undoManager = nil;
    [self.context performBlockAndWait:^{
        @try {
            @autoreleasepool {
                switch (self.operationMode) {
                    case 0:
                        [self scanPkginfos];
                        break;
                    case 1:
                        [self scanManifests];
                        break;
                    default:
                        break;
                }
            }
        }
        @catch(...) {
            // Do not rethrow exceptions.
        }
    }];
}

@end
