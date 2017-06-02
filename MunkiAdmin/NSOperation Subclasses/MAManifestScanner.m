//
//  ManifestScanner.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 6.10.2010.
//

#import "MAManifestScanner.h"
#import "MAMunkiAdmin_AppDelegate.h"
#import "MAMunkiRepositoryManager.h"
#import "DataModelHeaders.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

@interface MAManifestScanner ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (strong) NSArray *allManifests;
@property (strong) NSDictionary *allManifestsByTitle;
@property (strong) NSArray *allApplications;
@property (strong) NSArray *allPackages;
@property (strong) NSArray *allCatalogs;
@end

@implementation MAManifestScanner

- (NSUserDefaults *)defaults
{
	return [NSUserDefaults standardUserDefaults];
}


- (id)initWithURL:(NSURL *)src {
	if ((self = [super init])) {
		DDLogVerbose(@"Initializing read operation for manifest %@", [src path]);
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _context.parentContext = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
        _context.undoManager = nil;
		self.sourceURL = src;
		self.fileName = [self.sourceURL lastPathComponent];
		self.currentJobDescription = @"Initializing manifest scan operation";
		
	}
	return self;
}


- (id)matchingObjectForString:(NSString *)aString
{
    NSPredicate *appPred = [NSPredicate predicateWithFormat:@"munki_name == %@", aString];
    NSUInteger foundIndex = [apps indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [appPred evaluateWithObject:obj];
    }];
    
    if (foundIndex != NSNotFound) {
        return [apps objectAtIndex:foundIndex];
    } else {
        NSPredicate *pkgPred = [NSPredicate predicateWithFormat:@"titleWithVersion == %@", aString];
        NSUInteger foundPkgIndex = [packages indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [pkgPred evaluateWithObject:obj];
        }];
        if (foundPkgIndex != NSNotFound) {
            return [packages objectAtIndex:foundPkgIndex];
        } else {
            return nil;
        }
    }
}

- (void)conditionalItemsFrom:(NSArray *)items parent:(ConditionalItemMO *)parent manifest:(ManifestMO *)manifest context:(NSManagedObjectContext *)moc
{
    [items enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            NSString *condition = [(NSDictionary *)obj objectForKey:@"condition"];
            ConditionalItemMO *newConditionalItem = [NSEntityDescription insertNewObjectForEntityForName:@"ConditionalItem" inManagedObjectContext:moc];
            newConditionalItem.munki_condition = condition;
            newConditionalItem.manifest = manifest;
            newConditionalItem.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
            if (parent) {
                newConditionalItem.parent = parent;
                //newConditionalItem.joinedCondition = [NSString stringWithFormat:@"%@ - %@", parent.joinedCondition, newConditionalItem.munki_condition];
                DDLogVerbose(@"%@ Nested conditional_item %lu --> Condition: %@", manifest.title, (unsigned long)idx, condition);
            } else {
                //newConditionalItem.joinedCondition = [NSString stringWithFormat:@"%@", newConditionalItem.munki_condition];
                DDLogVerbose(@"%@ conditional_item %lu --> Condition: %@", manifest.title, (unsigned long)idx, condition);
            }
            
            NSArray *managedInstalls = [(NSDictionary *)obj objectForKey:@"managed_installs"];
            [managedInstalls enumerateObjectsWithOptions:0 usingBlock:^(id managedInstallName, NSUInteger managedInstallIndex, BOOL *stopManagedInstallsEnum) {
                DDLogVerbose(@"%@ conditional_item --> managed_installs item %lu --> Name: %@", manifest.title, (unsigned long)managedInstallIndex, managedInstallName);
                StringObjectMO *newManagedInstall = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
                newManagedInstall.title = (NSString *)managedInstallName;
                newManagedInstall.typeString = @"managedInstall";
                newManagedInstall.originalIndex = [NSNumber numberWithUnsignedInteger:managedInstallIndex];
                [newConditionalItem addManagedInstallsObject:newManagedInstall];
            }];
            NSArray *managedUninstalls = [(NSDictionary *)obj objectForKey:@"managed_uninstalls"];
            [managedUninstalls enumerateObjectsWithOptions:0 usingBlock:^(id managedUninstallName, NSUInteger managedUninstallIndex, BOOL *stopManagedUninstallsEnum) {
                DDLogVerbose(@"%@ conditional_item --> managed_uninstalls item %lu --> Name: %@", manifest.title, (unsigned long)managedUninstallIndex, managedUninstallName);
                StringObjectMO *newManagedUninstall = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
                newManagedUninstall.title = (NSString *)managedUninstallName;
                newManagedUninstall.typeString = @"managedUninstall";
                newManagedUninstall.originalIndex = [NSNumber numberWithUnsignedInteger:managedUninstallIndex];
                [newConditionalItem addManagedUninstallsObject:newManagedUninstall];
            }];
            NSArray *managedUpdates = [(NSDictionary *)obj objectForKey:@"managed_updates"];
            [managedUpdates enumerateObjectsWithOptions:0 usingBlock:^(id managedUpdateName, NSUInteger managedUpdateIndex, BOOL *stopManagedUpdatesEnum) {
                DDLogVerbose(@"%@ conditional_item --> managed_updates item %lu --> Name: %@", manifest.title, (unsigned long)managedUpdateIndex, managedUpdateName);
                StringObjectMO *newManagedUpdate = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
                newManagedUpdate.title = (NSString *)managedUpdateName;
                newManagedUpdate.typeString = @"managedUpdate";
                newManagedUpdate.originalIndex = [NSNumber numberWithUnsignedInteger:managedUpdateIndex];
                [newConditionalItem addManagedUpdatesObject:newManagedUpdate];
            }];
            NSArray *optionalInstalls = [(NSDictionary *)obj objectForKey:@"optional_installs"];
            [optionalInstalls enumerateObjectsWithOptions:0 usingBlock:^(id optionalInstallName, NSUInteger optionalInstallIndex, BOOL *stopOptionalInstallsEnum) {
                DDLogVerbose(@"%@ conditional_item --> optional_installs item %lu --> Name: %@", manifest.title, (unsigned long)optionalInstallIndex, optionalInstallName);
                StringObjectMO *newOptionalInstall = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
                newOptionalInstall.title = (NSString *)optionalInstallName;
                newOptionalInstall.typeString = @"optionalInstall";
                newOptionalInstall.originalIndex = [NSNumber numberWithUnsignedInteger:optionalInstallIndex];
                [newConditionalItem addOptionalInstallsObject:newOptionalInstall];
            }];
            NSArray *featuredItems = [(NSDictionary *)obj objectForKey:@"featured_items"];
            [featuredItems enumerateObjectsWithOptions:0 usingBlock:^(id featuredItemName, NSUInteger featuredItemIndex, BOOL *stopFeaturedItemsEnum) {
                DDLogVerbose(@"%@ conditional_item --> featured_items item %lu --> Name: %@", manifest.title, (unsigned long)featuredItemIndex, featuredItemName);
                StringObjectMO *newFeaturedItem = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
                newFeaturedItem.title = (NSString *)featuredItemName;
                newFeaturedItem.typeString = @"featuredItem";
                newFeaturedItem.originalIndex = [NSNumber numberWithUnsignedInteger:featuredItemIndex];
                [newConditionalItem addFeaturedItemsObject:newFeaturedItem];
            }];
            NSArray *includedManifests = [(NSDictionary *)obj objectForKey:@"included_manifests"];
            [includedManifests enumerateObjectsWithOptions:0 usingBlock:^(id includedManifestName, NSUInteger includedManifestIndex, BOOL *stopIncludedManifestsEnum) {
                DDLogVerbose(@"%@ conditional_item --> included_manifests item %lu --> Name: %@", manifest.title, (unsigned long)includedManifestIndex, includedManifestName);
                StringObjectMO *newIncludedManifest = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
                newIncludedManifest.title = (NSString *)includedManifestName;
                newIncludedManifest.typeString = @"includedManifest";
                newIncludedManifest.originalIndex = [NSNumber numberWithUnsignedInteger:includedManifestIndex];
                newIncludedManifest.indexInNestedManifest = [NSNumber numberWithUnsignedInteger:includedManifestIndex];
                [newConditionalItem addIncludedManifestsObject:newIncludedManifest];
                
                /*
                 Determining the referencing manifests is done in RelationshipScanner
                 */
            }];
            
            // If there are nested conditional items, loop through them with this same function
            NSArray *conditionalItems = [(NSDictionary *)obj objectForKey:@"conditional_items"];
            if (conditionalItems) {
                @autoreleasepool {
                    [self conditionalItemsFrom:conditionalItems parent:newConditionalItem manifest:manifest context:moc];
                }
            }
        }
    }];
}


- (ManifestMO *)matchingManifestForString:(NSString *)title inMoc:(NSManagedObjectContext *)moc
{
    // Get all application objects for later use
    NSFetchRequest *getManifests = [[NSFetchRequest alloc] init];
    [getManifests setEntity:[NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:moc]];
    [getManifests setReturnsObjectsAsFaults:NO];
    [getManifests setIncludesSubentities:NO];
    NSArray *manifests = [moc executeFetchRequest:getManifests error:nil];
    
    NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title == %@", title];
    NSUInteger foundIndex = [manifests indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [titlePredicate evaluateWithObject:obj];
    }];
    
    if (foundIndex != NSNotFound) {
        return [manifests objectAtIndex:foundIndex];
    } else {
        return nil;
    }
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

- (void)resolveAllReferencesForManifest:(ManifestMO *)manifest
{
    NSEntityDescription *catalogEntityDescr = [NSEntityDescription entityForName:@"Catalog" inManagedObjectContext:self.context];
    NSEntityDescription *manifestEntityDescr = [NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:self.context];
    NSEntityDescription *applicationEntityDescr = [NSEntityDescription entityForName:@"Application" inManagedObjectContext:self.context];
    NSEntityDescription *packageEntityDescr = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:self.context];
    
    
    // Get some objects for later use
    
    NSFetchRequest *getManifests = [[NSFetchRequest alloc] init];
    [getManifests setEntity:manifestEntityDescr];
    self.allManifests = [self.context executeFetchRequest:getManifests error:nil];
    
    NSMutableDictionary *manifestsAndTitles = [[NSMutableDictionary alloc] initWithCapacity:[self.allManifests count]];
    for (ManifestMO *existingManifest in self.allManifests) {
        manifestsAndTitles[existingManifest.title] = existingManifest.objectID;
    }
    self.allManifestsByTitle = manifestsAndTitles;
    
    NSFetchRequest *getApplications = [[NSFetchRequest alloc] init];
    [getApplications setEntity:applicationEntityDescr];
    self.allApplications = [self.context executeFetchRequest:getApplications error:nil];
    
    NSFetchRequest *getAllCatalogs = [[NSFetchRequest alloc] init];
    [getAllCatalogs setEntity:catalogEntityDescr];
    self.allCatalogs = [self.context executeFetchRequest:getAllCatalogs error:nil];
    
    NSFetchRequest *getPackages = [[NSFetchRequest alloc] init];
    [getPackages setEntity:packageEntityDescr];
    self.allPackages = [self.context executeFetchRequest:getPackages error:nil];
    
    ManifestMO *currentManifest = manifest;
    NSDictionary *originalManifestDict = (NSDictionary *)currentManifest.originalManifest;
    
    
    NSArray *existingCatalogTitles = [[currentManifest.catalogInfos valueForKeyPath:@"catalog.title"] allObjects];
    NSArray *newCatalogTitles = [self.allCatalogs valueForKeyPath:@"title"];
    
    // Loop through all known catalog objects and configure
    // them for this manifest
    
    if (![existingCatalogTitles isEqualToArray:newCatalogTitles]) {
        
        // Delete the old catalogs
        for (CatalogInfoMO *aCatInfo in currentManifest.catalogInfos) {
            [self.context deleteObject:aCatInfo];
        }
        
        NSArray *catalogs = [originalManifestDict objectForKey:@"catalogs"];
        for (CatalogMO *aCatalog in self.allCatalogs) {
            NSString *catalogTitle = [aCatalog title];
            CatalogInfoMO *newCatalogInfo;
            newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:self.context];
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
            DDLogError(@"%@: Error: Could not link managed_install object %@", currentManifest.title, aManagedInstall.title);
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
            DDLogError(@"%@: Error: Could not link managed_uninstall object: %@", currentManifest.title, aManagedUninstall.title);
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
            DDLogError(@"%@: Error: Could not link managed_update object: %@", currentManifest.title, aManagedUpdate.title);
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
            DDLogError(@"%@: Error: Could not link optional_install object: %@", currentManifest.title, anOptionalInstall.title);
        } else if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
            anOptionalInstall.originalApplication = matchingObject;
        } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
            anOptionalInstall.originalPackage = matchingObject;
        }
    }
    for (StringObjectMO *featuredItem in currentManifest.featuredItems) {
        DDLogVerbose(@"%@: linking featured_item object %@", currentManifest.fileName, featuredItem.title);
        id matchingObject = [self matchingAppOrPkgForString:featuredItem.title];
        if (!matchingObject) {
            DDLogError(@"%@: Error: Could not link featured_item object: %@", currentManifest.title, featuredItem.title);
        } else if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
            featuredItem.originalApplication = matchingObject;
        } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
            featuredItem.originalPackage = matchingObject;
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
            DDLogError(@"%@: Error: Could not link included_manifest object: %@", currentManifest.title, stringObject.title);
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
                DDLogError(@"%@: Error: Could not link conditional managed_install object: %@", currentManifest.title, managedInstall.title);
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
                DDLogError(@"%@: Error: Could not link conditional managed_uninstall object: %@", currentManifest.title, managedUninstall.title);
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
                DDLogError(@"%@: Error: Could not link conditional managed_update object: %@", currentManifest.title, managedUpdate.title);
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
                DDLogError(@"%@: Error: Could not link conditional optional_install object: %@", currentManifest.title, optionalInstall.title);
            } else if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
                optionalInstall.originalApplication = matchingObject;
            } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
                optionalInstall.originalPackage = matchingObject;
            }
        }
        for (StringObjectMO *featuredItem in conditionalItem.featuredItems) {
            DDLogVerbose(@"%@: linking conditional featured_item object %@", currentManifest.fileName, featuredItem.title);
            id matchingObject = [self matchingAppOrPkgForString:featuredItem.title];
            if (!matchingObject) {
                DDLogError(@"%@: Error: Could not link conditional featured_item object: %@", currentManifest.title, featuredItem.title);
            } else if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
                featuredItem.originalApplication = matchingObject;
            } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
                featuredItem.originalPackage = matchingObject;
            }
        }
        
        for (StringObjectMO *includedManifest in conditionalItem.includedManifests) {
            DDLogVerbose(@"%@: linking conditional included_manifest object %@", currentManifest.fileName, includedManifest.title);
            
            ManifestMO *originalManifest = [self matchingManifestForString:includedManifest.title];
            if (originalManifest) {
                DDLogVerbose(@"%@: linking conditional included_manifest object %@ to original manifest %@", currentManifest.fileName, includedManifest.title, originalManifest.title);
                includedManifest.originalManifest = originalManifest;
            } else {
                DDLogError(@"%@: could not link conditional included_manifest object: %@", currentManifest.title, includedManifest.title);
            }
        }
    }
}

- (void)scan {
	@try {
		@autoreleasepool {
            
            MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
			NSManagedObjectContext *privateContext = self.context;
			self.currentJobDescription = [NSString stringWithFormat:@"Reading manifest %@", self.fileName];
			
            NSEntityDescription *manifestEntityDescr = [NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:privateContext];
            
            // Get manifests for later use
            NSFetchRequest *getManifests = [[NSFetchRequest alloc] init];
            [getManifests setEntity:manifestEntityDescr];
            
            /*
             * Read the manifest dictionary from disk
             */
            DDLogVerbose(@"%@: Reading file from disk", self.fileName);
			NSDictionary *manifestInfoDict = [NSDictionary dictionaryWithContentsOfURL:self.sourceURL];
			if (manifestInfoDict != nil) {
                
                /*
                 * Manifest name should be the relative path from manifests subdirectory
                 */
                NSString *manifestRelativePath = [[MAMunkiRepositoryManager sharedManager] relativePathToChildURL:self.sourceURL parentURL:[appDelegate manifestsURL]];
                
                /*
                 * Check if we already have a manifest with this name
                 */
                ManifestMO *manifest;
                if (self.manifestID) {
                    manifest = (ManifestMO *)[privateContext objectWithID:self.manifestID];
                    DDLogVerbose(@"%@: Reusing existing manifest object from memory", self.fileName);
                } else {
                    manifest = [NSEntityDescription insertNewObjectForEntityForName:@"Manifest" inManagedObjectContext:privateContext];
                    manifest.title = manifestRelativePath;
                    manifest.manifestURL = self.sourceURL;
                    manifest.manifestParentDirectoryURL = [self.sourceURL URLByDeletingLastPathComponent];
                }
				
                
				manifest.originalManifest = manifestInfoDict;
                
                
                /*
                 * Get file properties
                 */
                NSDate *dateCreated;
                [manifest.manifestURL getResourceValue:&dateCreated forKey:NSURLCreationDateKey error:nil];
                manifest.manifestDateCreated = dateCreated;
            
                NSDate *dateLastOpened;
                [manifest.manifestURL getResourceValue:&dateLastOpened forKey:NSURLContentAccessDateKey error:nil];
                manifest.manifestDateLastOpened = dateLastOpened;
                
                NSDate *dateModified;
                [manifest.manifestURL getResourceValue:&dateModified forKey:NSURLContentModificationDateKey error:nil];
                manifest.manifestDateModified = dateModified;
                
                /*
                 * Get the user if it exists
                 */
                NSString *user = [manifestInfoDict objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"manifestUserNameKey"]];
                if (user) {
                    manifest.manifestUserName = user;
                }
                
                /*
                 * Get the display name if it exists
                 */
                NSString *manifestDisplayName = [manifestInfoDict objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"manifestDisplayNameKey"]];
                if (manifestDisplayName) {
                    manifest.manifestDisplayName = manifestDisplayName;
                }
                
                /*
                 * Get the admin notes if it exists
                 */
                NSString *manifestAdminNotes = [manifestInfoDict objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"manifestAdminNotesKey"]];
                if (manifestAdminNotes) {
                    manifest.manifestAdminNotes = manifestAdminNotes;
                }
				
                
                // =================================
				// Get "catalogs" items
                // =================================
				/*
                 Left here as a reminder: Catalogs are processed with RelationshipScanner
                 */
                
                
                // =================================
				// Get "managed_installs" items
				// =================================
                NSDate *startTime = [NSDate date];
                NSArray *managedInstalls = [manifestInfoDict objectForKey:@"managed_installs"];
                if ([managedInstalls count] > 0) {
                    DDLogVerbose(@"%@: Found %lu managed_installs items", self.fileName, (unsigned long)[managedInstalls count]);
                }
                [managedInstalls enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    @autoreleasepool {
                        DDLogVerbose(@"%@: managed_installs item %lu --> Name: %@", manifest.title, (unsigned long)idx, obj);
                        StringObjectMO *newManagedInstall = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:privateContext];
                        newManagedInstall.title = (NSString *)obj;
                        newManagedInstall.typeString = @"managedInstall";
                        newManagedInstall.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
                        [manifest addManagedInstallsFasterObject:newManagedInstall];
                        
                    }
                }];
                NSDate *now = [NSDate date];
                DDLogVerbose(@"Scanning managed_installs took %lf (ms)", [now timeIntervalSinceDate:startTime] * 1000.0);
                
                
                // =================================
				// Get "managed_uninstalls" items
				// =================================
                startTime = [NSDate date];
                NSArray *managedUninstalls = [manifestInfoDict objectForKey:@"managed_uninstalls"];
                if ([managedUninstalls count] > 0) {
                    DDLogVerbose(@"%@: Found %lu managed_uninstalls items", self.fileName, (unsigned long)[managedUninstalls count]);
                }
                [managedUninstalls enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    @autoreleasepool {
                        DDLogVerbose(@"%@ managed_uninstalls item %lu --> Name: %@", manifest.title, (unsigned long)idx, obj);
                        StringObjectMO *newManagedUninstall = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:privateContext];
                        newManagedUninstall.title = (NSString *)obj;
                        newManagedUninstall.typeString = @"managedUninstall";
                        newManagedUninstall.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
                        [manifest addManagedUninstallsFasterObject:newManagedUninstall];
                        
                    }
                }];
                now = [NSDate date];
                DDLogVerbose(@"Scanning managed_uninstalls took %lf (ms)", [now timeIntervalSinceDate:startTime] * 1000.0);
                
                
                // =================================
				// Get "managed_updates" items
				// =================================
                startTime = [NSDate date];
                NSArray *managedUpdates = [manifestInfoDict objectForKey:@"managed_updates"];
                if ([managedUpdates count] > 0) {
                    DDLogVerbose(@"%@: Found %lu managed_updates items", self.fileName, (unsigned long)[managedUpdates count]);
                }
                [managedUpdates enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    @autoreleasepool {
                        DDLogVerbose(@"%@ managed_updates item %lu --> Name: %@", manifest.title, (unsigned long)idx, obj);
                        StringObjectMO *newManagedUpdate = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:privateContext];
                        newManagedUpdate.title = (NSString *)obj;
                        newManagedUpdate.typeString = @"managedUpdate";
                        newManagedUpdate.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
                        [manifest addManagedUpdatesFasterObject:newManagedUpdate];
                        
                    }
                }];
				now = [NSDate date];
                DDLogVerbose(@"Scanning managed_updates took %lf (ms)", [now timeIntervalSinceDate:startTime] * 1000.0);
                
                
                // =================================
				// Get "optional_installs" items
				// =================================
                startTime = [NSDate date];
                NSArray *optionalInstalls = [manifestInfoDict objectForKey:@"optional_installs"];
                if ([optionalInstalls count] > 0) {
                    DDLogVerbose(@"%@: Found %lu optional_installs items", self.fileName, (unsigned long)[optionalInstalls count]);
                }
				[optionalInstalls enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    @autoreleasepool {
                        DDLogVerbose(@"%@ optional_installs item %lu --> Name: %@", manifest.title, (unsigned long)idx, obj);
                        StringObjectMO *newOptionalInstall = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:privateContext];
                        newOptionalInstall.title = (NSString *)obj;
                        newOptionalInstall.typeString = @"optionalInstall";
                        newOptionalInstall.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
                        [manifest addOptionalInstallsFasterObject:newOptionalInstall];
                        
                    }
                }];
                now = [NSDate date];
                DDLogVerbose(@"Scanning optional_installs took %lf (ms)", [now timeIntervalSinceDate:startTime] * 1000.0);
                
                // =================================
                // Get "featured_items" items
                // =================================
                startTime = [NSDate date];
                NSArray *featuredItems = [manifestInfoDict objectForKey:@"featured_items"];
                if ([featuredItems count] > 0) {
                    DDLogVerbose(@"%@: Found %lu featured_items items", self.fileName, (unsigned long)[featuredItems count]);
                }
                [featuredItems enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    @autoreleasepool {
                        DDLogVerbose(@"%@ featured_items item %lu --> Name: %@", manifest.title, (unsigned long)idx, obj);
                        StringObjectMO *newFeaturedItem = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:privateContext];
                        newFeaturedItem.title = (NSString *)obj;
                        newFeaturedItem.typeString = @"featuredItem";
                        newFeaturedItem.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
                        [manifest addFeaturedItemsObject:newFeaturedItem];
                        
                    }
                }];
                now = [NSDate date];
                DDLogVerbose(@"Scanning optional_installs took %lf (ms)", [now timeIntervalSinceDate:startTime] * 1000.0);
                
                
                // =================================
				// Get "included_manifests" items
				// =================================
                startTime = [NSDate date];
				NSArray *includedManifests = [manifestInfoDict objectForKey:@"included_manifests"];
                if ([includedManifests count] > 0) {
                    DDLogVerbose(@"%@: Found %lu included_manifests items", self.fileName, (unsigned long)[includedManifests count]);
                }
                [includedManifests enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    @autoreleasepool {
                        DDLogVerbose(@"%@ included_manifests item %lu --> Name: %@", manifest.title, (unsigned long)idx, obj);
                        StringObjectMO *newIncludedManifest = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:privateContext];
                        newIncludedManifest.title = (NSString *)obj;
                        newIncludedManifest.typeString = @"includedManifest";
                        newIncludedManifest.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
                        newIncludedManifest.indexInNestedManifest = [NSNumber numberWithUnsignedInteger:idx];
                        [manifest addIncludedManifestsFasterObject:newIncludedManifest];
                        
                        /*
                         Determining the referencing manifests is done in RelationshipScanner
                         */
                    }
                    
                }];
                now = [NSDate date];
                DDLogVerbose(@"Scanning included_manifests took %lf (ms)", [now timeIntervalSinceDate:startTime] * 1000.0);
                
                
                // =================================
				// Get "conditional_items"
				// =================================
                startTime = [NSDate date];
				NSArray *conditionalItems = [manifestInfoDict objectForKey:@"conditional_items"];
                [self conditionalItemsFrom:conditionalItems parent:nil manifest:manifest context:privateContext];
                now = [NSDate date];
                DDLogVerbose(@"Scanning conditional_items took %lf (ms)", [now timeIntervalSinceDate:startTime] * 1000.0);
                
                if (self.performFullScan) {
                    /*
                     This is a manifest scan which is not followed by a full relationship scanner
                     */
                    [self resolveAllReferencesForManifest:manifest];
                }
				
			} else {
				DDLogError(@"Can't read manifest file %@", [self.sourceURL relativePath]);
			}
			
			// Save the context
            NSError *error = nil;
            if ([privateContext save:&error]) {
                /*
                 We could save the parent context here but it would just slow us down
                 if done after every file read. Parent context is saved after both pkginfos
                 and manifests are fully read.
                 */
                /*
                [privateContext.parentContext performBlock:^{
                    NSError *parentError = nil;
                    [privateContext.parentContext save:&parentError];
                }];
                 */
            } else {
                DDLogError(@"Private context failed to save: %@", error);
            }
		}
	}
	@catch(...) {
		DDLogError(@"Error: Caught exception while reading manifest %@", self.fileName);
	}
}

- (void)main
{
    [self.context performBlockAndWait:^{
        [self scan];
    }];
}


@end
