//
//  MunkiRepositoryManager.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 5.12.2012.
//
//

#import "MunkiRepositoryManager.h"
#import "DataModelHeaders.h"
#import "MunkiAdmin_AppDelegate.h"

/*
 * Private interface
 */
@interface MunkiRepositoryManager ()

@property (readwrite, retain) NSArray *pkginfoAssimilateKeys;
@property (readwrite, retain) NSArray *pkginfoAssimilateKeysForAuto;

@property (readwrite, retain) NSString *makepkginfoVersion;
@property (readwrite, retain) NSString *makecatalogsVersion;

- (void)willStartOperations;
- (void)willEndOperations;
- (NSUserDefaults *)defaults;
- (void)setupMappings;

@end


@implementation MunkiRepositoryManager

@dynamic makecatalogsInstalled;
@dynamic makepkginfoInstalled;
@dynamic pkginfoAssimilateKeysForAuto;

@synthesize pkginfoBasicKeyMappings;
@synthesize pkginfoArrayKeyMappings;
@synthesize pkginfoAssimilateKeys;
@synthesize receiptKeyMappings;
@synthesize installsKeyMappings;
@synthesize itemsToCopyKeyMappings;
@synthesize installerChoicesKeyMappings;
@synthesize makepkginfoVersion;
@synthesize makecatalogsVersion;


# pragma mark -
# pragma mark Singleton methods

static MunkiRepositoryManager *sharedOperationManager = nil;
static dispatch_queue_t serialQueue;

+ (id)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceQueue;
    
    dispatch_once(&onceQueue, ^{
        serialQueue = dispatch_queue_create("MunkiAdmin.RepositoryManager.SerialQueue", NULL);
        if (sharedOperationManager == nil) {
            sharedOperationManager = [super allocWithZone:zone];
        }
    });
    
    return sharedOperationManager;
}

+ (MunkiRepositoryManager *)sharedManager {
    static dispatch_once_t onceQueue;
    
    dispatch_once(&onceQueue, ^{
        sharedOperationManager = [[MunkiRepositoryManager alloc] init];
    });
    
    return sharedOperationManager;
}

- (id)init {
    id __block obj;
    
    dispatch_sync(serialQueue, ^{
        obj = [super init];
        if (obj) {
            [self setupMappings];
            [self updateMunkiVersions];
        }
    });
    
    self = obj;
    return self;
}

- (void)willStartOperations
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //[[[NSApp delegate] progressBar] startAnimation:nil];
    });
}

- (void)willEndOperations
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //[[[NSApp delegate] progressBar] stopAnimation:nil];
    });
}

# pragma mark -
# pragma mark Modifying items

- (void)copyStringObjectsOfType:(NSString *)type from:(PackageMO *)source target:(PackageMO *)target
{
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    if ([type isEqualToString:@"blocking_applications"]) {
        for (StringObjectMO *blockingApp in source.blockingApplications) {
            StringObjectMO *newBlockingApplication = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
            newBlockingApplication.title = blockingApp.title;
            newBlockingApplication.typeString = @"package";
            [target addBlockingApplicationsObject:newBlockingApplication];
        }
    } else if ([type isEqualToString:@"requires"]) {
        for (StringObjectMO *requiresItem in source.requirements) {
            StringObjectMO *newRequiredPkgInfo = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
            newRequiredPkgInfo.title = requiresItem.title;
            newRequiredPkgInfo.typeString = @"package";
            [target addRequirementsObject:newRequiredPkgInfo];
        }
    } else if ([type isEqualToString:@"supported_architectures"]) {
        for (StringObjectMO *supportedArch in source.supportedArchitectures) {
            StringObjectMO *newSupportedArchitecture = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
            newSupportedArchitecture.title = supportedArch.title;
            newSupportedArchitecture.typeString = @"architecture";
            [target addSupportedArchitecturesObject:newSupportedArchitecture];
        }
    } else if ([type isEqualToString:@"update_for"]) {
        for (StringObjectMO *updateForItem in source.updateFor) {
            StringObjectMO *newUpdateForItem = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
            newUpdateForItem.title = updateForItem.title;
            newUpdateForItem.typeString = @"package";
            [target addUpdateForObject:newUpdateForItem];
        }
    }
}

- (void)copyInstallerChoicesFrom:(PackageMO *)source target:(PackageMO *)target
{
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    for (InstallerChoicesItemMO *installerChoicesItem in source.installerChoicesItems) {
        InstallerChoicesItemMO *newInstallerChoicesItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallerChoicesItem" inManagedObjectContext:moc];
        newInstallerChoicesItem.munki_attributeSetting = installerChoicesItem.munki_attributeSetting;
        newInstallerChoicesItem.munki_choiceAttribute = installerChoicesItem.munki_choiceAttribute;
        newInstallerChoicesItem.munki_choiceIdentifier = installerChoicesItem.munki_choiceIdentifier;
        [target addInstallerChoicesItemsObject:newInstallerChoicesItem];
    }
}

- (void)copyInstallsItemsFrom:(PackageMO *)source target:(PackageMO *)target
{
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    for (InstallsItemMO *installsItem in source.installsItems) {
        InstallsItemMO *newInstallsItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallsItem" inManagedObjectContext:moc];
        newInstallsItem.munki_CFBundleIdentifier = installsItem.munki_CFBundleIdentifier;
        newInstallsItem.munki_CFBundleName = installsItem.munki_CFBundleName;
        newInstallsItem.munki_CFBundleShortVersionString = installsItem.munki_CFBundleShortVersionString;
        newInstallsItem.munki_md5checksum = installsItem.munki_md5checksum;
        newInstallsItem.munki_minosversion = installsItem.munki_minosversion;
        newInstallsItem.munki_path = installsItem.munki_path;
        newInstallsItem.munki_type = installsItem.munki_type;
        [target addInstallsItemsObject:newInstallsItem];
    }
}

- (void)copyItemsToCopyItemsFrom:(PackageMO *)source target:(PackageMO *)target
{
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    for (ItemToCopyMO *itemsToCopyItem in source.itemsToCopy) {
        ItemToCopyMO *newItemsToCopyItem = [NSEntityDescription insertNewObjectForEntityForName:@"ItemToCopy" inManagedObjectContext:moc];
        newItemsToCopyItem.munki_destination_item = itemsToCopyItem.munki_destination_item;
        newItemsToCopyItem.munki_destination_path = itemsToCopyItem.munki_destination_path;
        newItemsToCopyItem.munki_group = itemsToCopyItem.munki_group;
        newItemsToCopyItem.munki_mode = itemsToCopyItem.munki_mode;
        newItemsToCopyItem.munki_source_item = itemsToCopyItem.munki_source_item;
        newItemsToCopyItem.munki_user = itemsToCopyItem.munki_user;
        [target addItemsToCopyObject:newItemsToCopyItem];
    }
}

- (void)assimilatePackage:(PackageMO *)targetPackage sourcePackage:(PackageMO *)sourcePackage keys:(NSArray *)munkiKeys
{
    NSArray *arrayKeys = [NSArray arrayWithObjects:
                          @"blocking_applications",
                          @"installer_choices_xml",
                          @"installs_items",
                          @"requires",
                          @"supported_architectures",
                          @"update_for",
                          nil];
    NSArray *stringKeys = [NSArray arrayWithObjects:
                           @"blocking_applications",
                           @"requires",
                           @"supported_architectures",
                           @"update_for",
                           nil];
    
    for (NSString *keyName in munkiKeys) {
        if (![arrayKeys containsObject:keyName] && [self.pkginfoAssimilateKeys containsObject:keyName]) {
            NSString *munkiadminKeyName = [NSString stringWithFormat:@"munki_%@", keyName];
            id sourceValue = [sourcePackage valueForKey:munkiadminKeyName];
            [targetPackage setValue:sourceValue forKey:munkiadminKeyName];
        } else {
            if ([stringKeys containsObject:keyName]) {
                [self copyStringObjectsOfType:keyName from:sourcePackage target:targetPackage];
            }
            else if ([keyName isEqualToString:@"installer_choices_xml"]) {
                [self copyInstallerChoicesFrom:sourcePackage target:targetPackage];
            }
            else if ([keyName isEqualToString:@"installs_items"]) {
                [self copyInstallsItemsFrom:sourcePackage target:targetPackage];
            }
        }
    }
}

- (void)assimilatePackageWithPreviousVersion:(PackageMO *)targetPackage keys:(NSArray *)munkiKeys
{
    /*
     Helper method to assimilate a package with previous version
     */
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    NSFetchRequest *fetchForApplicationsLoose = [[NSFetchRequest alloc] init];
    [fetchForApplicationsLoose setEntity:[NSEntityDescription entityForName:@"Application" inManagedObjectContext:moc]];
    NSPredicate *applicationTitlePredicateLoose;
    applicationTitlePredicateLoose = [NSPredicate predicateWithFormat:@"munki_name like[cd] %@", targetPackage.munki_name];
    
    [fetchForApplicationsLoose setPredicate:applicationTitlePredicateLoose];
    
    NSUInteger numFoundApplications = [moc countForFetchRequest:fetchForApplicationsLoose error:nil];
    if (numFoundApplications == 0) {
        // No matching Applications found.
        NSLog(@"Assimilator found zero matching Applications for package.");
    } else if (numFoundApplications == 1) {
        ApplicationMO *existingApplication = [[moc executeFetchRequest:fetchForApplicationsLoose error:nil] objectAtIndex:0];
        
        // Get the latest package for comparison
        NSSortDescriptor *sortPkgsByVersion = [NSSortDescriptor sortDescriptorWithKey:@"munki_version" ascending:NO selector:@selector(localizedStandardCompare:)];
        NSArray *results = [[existingApplication packages] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortPkgsByVersion]];
        PackageMO *latestPackage = nil;
        if ([results count] > 1) {
            if ([[results objectAtIndex:0] isEqualTo:targetPackage]) {
                latestPackage = [results objectAtIndex:1];
            } else {
                latestPackage = [results objectAtIndex:0];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"])
                NSLog(@"Assimilating package with properties from: %@-%@", latestPackage.munki_name, latestPackage.munki_version);
            if (latestPackage != nil) [self assimilatePackage:targetPackage sourcePackage:latestPackage keys:munkiKeys];
        } else {
            NSLog(@"No previous packages");
        }
    }
    [fetchForApplicationsLoose release];
}

- (void)renamePackage:(PackageMO *)aPackage newName:(NSString *)newName cascade:(BOOL)shouldCascade
{
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    if (shouldCascade) {
        // Get the current app
        ApplicationMO *currentApp = aPackage.parentApplication;
        
        // Check for existing ApplicationMO with the same title
        NSFetchRequest *getApplication = [[NSFetchRequest alloc] init];
        [getApplication setEntity:[NSEntityDescription entityForName:@"Application" inManagedObjectContext:moc]];
        NSPredicate *appPred = [NSPredicate predicateWithFormat:@"munki_name == %@", newName];
        [getApplication setPredicate:appPred];
        if ([moc countForFetchRequest:getApplication error:nil] > 0) {
            // Application object exists with the new name so use it
            NSArray *apps = [moc executeFetchRequest:getApplication error:nil];
            ApplicationMO *app = [apps objectAtIndex:0];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Found ApplicationMO: %@", app.munki_name);
            aPackage.munki_name = newName;
            aPackage.hasUnstagedChangesValue = YES;
            aPackage.parentApplication = app;
        } else {
            // No existing application objects with this name so just rename it
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Renaming ApplicationMO %@ to %@", currentApp.munki_name, newName);
            currentApp.munki_name = newName;
            aPackage.munki_name = newName;
            aPackage.hasUnstagedChangesValue = YES;
            aPackage.parentApplication = currentApp; // Shouldn't need this...
        }
        [getApplication release];
        
        // Get sibling packages
        NSFetchRequest *getSiblings = [[NSFetchRequest alloc] init];
        [getSiblings setEntity:[NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc]];
        NSPredicate *siblingPred = [NSPredicate predicateWithFormat:@"parentApplication == %@", currentApp];
        [getSiblings setPredicate:siblingPred];
        if ([moc countForFetchRequest:getSiblings error:nil] > 0) {
            NSArray *siblingPackages = [moc executeFetchRequest:getSiblings error:nil];
            for (PackageMO *aSibling in siblingPackages) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Renaming sibling %@ to %@", aSibling.munki_name, newName);
                aSibling.munki_name = newName;
                aSibling.hasUnstagedChangesValue = YES;
                aSibling.parentApplication = aPackage.parentApplication;
            }
        } else {
            
        }
        [getSiblings release];
        
        for (StringObjectMO *i in [aPackage referencingStringObjects]) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Renaming packageref %@ to: %@", i.title, aPackage.titleWithVersion);
            i.title = aPackage.titleWithVersion;
            [moc refreshObject:i mergeChanges:YES];
            if (i.managedInstallReference) {
                i.managedInstallReference.hasUnstagedChangesValue = YES;
            }
            if (i.managedUninstallReference) {
                i.managedUninstallReference.hasUnstagedChangesValue = YES;
            }
            if (i.managedUpdateReference) {
                i.managedUpdateReference.hasUnstagedChangesValue = YES;
            }
            if (i.optionalInstallReference) {
                i.optionalInstallReference.hasUnstagedChangesValue = YES;
            }
        
        }
        for (StringObjectMO *i in [aPackage.parentApplication referencingStringObjects]) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Renaming appref %@ to: %@", i.title, aPackage.parentApplication.munki_name);
            i.title = aPackage.parentApplication.munki_name;
            [moc refreshObject:i mergeChanges:YES];
            if (i.managedInstallReference) {
                i.managedInstallReference.hasUnstagedChangesValue = YES;
            }
            if (i.managedUninstallReference) {
                i.managedUninstallReference.hasUnstagedChangesValue = YES;
            }
            if (i.managedUpdateReference) {
                i.managedUpdateReference.hasUnstagedChangesValue = YES;
            }
            if (i.optionalInstallReference) {
                i.optionalInstallReference.hasUnstagedChangesValue = YES;
            }
        }
        
    } else {
        aPackage.munki_name = newName;
        for (StringObjectMO *i in [aPackage referencingStringObjects]) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Renaming packageref %@ to: %@", i.title, aPackage.titleWithVersion);
            i.title = aPackage.titleWithVersion;
            [moc refreshObject:i mergeChanges:YES];
            
        }
        for (StringObjectMO *i in [aPackage.parentApplication referencingStringObjects]) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Renaming appref %@ to: %@", i.title, aPackage.parentApplication.munki_name);
            i.title = aPackage.parentApplication.munki_name;
            [moc refreshObject:i mergeChanges:YES];
            
        }
    }
}

# pragma mark -
# pragma mark Creating new items

- (CatalogMO *)newCatalogWithTitle:(NSString *)title
{
    if (title == nil) {
        return nil;
    }
    
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    CatalogMO *catalog;
    catalog = [NSEntityDescription insertNewObjectForEntityForName:@"Catalog" inManagedObjectContext:moc];
    catalog.title = title;
    NSURL *catalogURL = [[[NSApp delegate] catalogsURL] URLByAppendingPathComponent:catalog.title];
    [[NSFileManager defaultManager] createFileAtPath:[catalogURL relativePath] contents:nil attributes:nil];
    
    // Loop through Package managed objects
    for (PackageMO *aPackage in [sharedOperationManager allObjectsForEntity:@"Package"]) {
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
    
    return catalog;
}

- (ManifestMO *)newManifestWithTitle:(NSString *)title
{
    if (title == nil) {
        return nil;
    }
    
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    ManifestMO *newManifest = [NSEntityDescription insertNewObjectForEntityForName:@"Manifest" inManagedObjectContext:moc];
    newManifest.title = title;
    newManifest.manifestURL = (NSURL *)[[[NSApp delegate] manifestsURL] URLByAppendingPathComponent:title];
    newManifest.originalManifest = [NSDictionary dictionary];
    
    if ([(NSDictionary *)newManifest.originalManifest writeToURL:newManifest.manifestURL atomically:YES]) {
        return newManifest;
    } else {
        return nil;
    }
}


# pragma mark -
# pragma mark Writing to the repository

- (NSSet *)modifiedManifestsSinceLastSave
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debugLogAllProperties"]) {
		NSLog(@"Getting modified manifests since last save");
	}
    
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    NSMutableArray *tempModifiedManifests = [[NSMutableArray alloc] init];
    
    /*
     Check the updated objects for manifest related changes
     */
    for (id anUpdatedObject in [moc updatedObjects]) {
        /*
         The modified object is a manifest
         */
        if ([anUpdatedObject isKindOfClass:[ManifestMO class]]) {
            [tempModifiedManifests addObject:anUpdatedObject];
        }
        /*
         The modified object is a sub-item of a manifest
         */
        else if ([anUpdatedObject respondsToSelector:@selector(manifest)]) {
            if ([anUpdatedObject manifest] != nil) {
                [tempModifiedManifests addObject:[anUpdatedObject manifest]];
            }
        }
    }
    
    /*
     Check if the inserted (new) objects contain any manifests
     */
    for (id anInsertedObject in [moc insertedObjects]) {
        if ([anInsertedObject isKindOfClass:[ManifestMO class]]) {
            [tempModifiedManifests addObject:anInsertedObject];
        }
        else if ([anInsertedObject respondsToSelector:@selector(manifest)]) {
            if ([anInsertedObject manifest] != nil) {
                [tempModifiedManifests addObject:[anInsertedObject manifest]];
            }
        }
    }
    
    /*
     * Finally fetch manifests that have been saved but not yet written to disk
     */
    NSEntityDescription *entityDescr = [NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
    NSPredicate *unstagedChangesPredicate = [NSPredicate predicateWithFormat:@"hasUnstagedChanges == YES"];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescr];
    [fetchRequest setPredicate:unstagedChangesPredicate];
	NSArray *fetchResults = [[[NSApp delegate] managedObjectContext] executeFetchRequest:fetchRequest error:nil];
    if ([fetchResults count] != 0) {
        [tempModifiedManifests addObjectsFromArray:fetchResults];
    }
    [fetchRequest release];
    
    NSSet *allModifiedManifests = [NSSet setWithArray:tempModifiedManifests];
    [tempModifiedManifests release];
    return allModifiedManifests;
}


- (NSSet *)modifiedPackagesSinceLastSave
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debugLogAllProperties"]) {
		NSLog(@"Getting modified pkginfos since last save");
	}
    
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    NSMutableArray *tempModifiedPackages = [[NSMutableArray alloc] init];
    
    /*
     Check the updated objects for package related changes
     */
    for (id anUpdatedObject in [moc updatedObjects]) {
        /*
         The modified object is a package
         */
        if ([anUpdatedObject isKindOfClass:[PackageMO class]]) {
            [tempModifiedPackages addObject:anUpdatedObject];
        }
        /*
         The modified object is a sub-item of a package
         */
        else if ([anUpdatedObject respondsToSelector:@selector(package)]) {
            if ([anUpdatedObject package] != nil) {
                [tempModifiedPackages addObject:[anUpdatedObject package]];
            }
        }
    }
    
    /*
     Check if the inserted (new) objects contain any packages
     */
    for (id anInsertedObject in [moc insertedObjects]) {
        if ([anInsertedObject isKindOfClass:[PackageMO class]]) {
            [tempModifiedPackages addObject:anInsertedObject];
        }
        else if ([anInsertedObject respondsToSelector:@selector(package)]) {
            if ([anInsertedObject package] != nil) {
                [tempModifiedPackages addObject:[anInsertedObject package]];
            }
        }
    }
    
    /*
     * Finally fetch packages that have been saved but not yet written to disk
     */
    NSEntityDescription *entityDescr = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
    NSPredicate *unstagedChangesPredicate = [NSPredicate predicateWithFormat:@"hasUnstagedChanges == YES"];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescr];
    [fetchRequest setPredicate:unstagedChangesPredicate];
	NSArray *fetchResults = [[[NSApp delegate] managedObjectContext] executeFetchRequest:fetchRequest error:nil];
    if ([fetchResults count] != 0) {
        [tempModifiedPackages addObjectsFromArray:fetchResults];
    }
    [fetchRequest release];
    
    NSSet *allModifiedPackages = [NSSet setWithArray:tempModifiedPackages];
    [tempModifiedPackages release];
    return allModifiedPackages;
}

- (BOOL)writePackagePropertyList:(NSDictionary *)plist forPackage:(PackageMO *)aPackage
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"])
        NSLog(@"Writing new pkginfo: %@", [(NSURL *)aPackage.packageInfoURL relativePath]);
    
    if ([plist writeToURL:(NSURL *)aPackage.packageInfoURL atomically:YES]) {
        aPackage.originalPkginfo = plist;
        return YES;
    } else {
        NSLog(@"Error: Failed to write %@", [(NSURL *)aPackage.packageInfoURL relativePath]);
        return NO;
    }
}

- (void)writePackagePropertyListsToDisk
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"Was asked to write package property lists to disk");
	}
    
    /*
     * =============================================
	 * Get all packages that have been modified
     * since last save and check them for changes
     * =============================================
     */
	
	for (PackageMO *aPackage in [self modifiedPackagesSinceLastSave]) {
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debugLogAllProperties"]) {
            NSLog(@"Checking pkginfo %@", [(NSURL *)aPackage.packageInfoURL lastPathComponent]);
        }
        
        /*
         * ===============================================
         * Note!
         *
         * Pkginfo files might contain custom keys added
         * by the user or not yet supported by MunkiAdmin.
         * We need to be extra careful not to touch those.
         * ===============================================
         */
        
        /*
         Read the current pkginfo from disk
         */
		NSDictionary *infoDictOnDisk = [NSDictionary dictionaryWithContentsOfURL:(NSURL *)aPackage.packageInfoURL];
		NSArray *sortedOriginalKeys = [[infoDictOnDisk allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
        
        /*
         Get the PackageMO as a dictionary
         */
        NSDictionary *infoDictFromPackage = [aPackage pkgInfoDictionary];
		NSArray *sortedPackageKeys = [[infoDictFromPackage allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
		
        /*
         Check for differences in key arrays and log them
         */
        NSSet *originalKeysSet = [NSSet setWithArray:sortedOriginalKeys];
        NSSet *newKeysSet = [NSSet setWithArray:sortedPackageKeys];
        NSArray *keysToDelete = [NSArray arrayWithObjects:
                                 @"blocking_applications",
                                 @"description",
                                 @"display_name",
                                 @"force_install_after_date",
                                 @"installable_condition",
                                 @"installcheck_script",
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
                                 @"uninstallcheck_script",
                                 @"uninstaller_item_location",
                                 @"uninstall_script",
                                 @"version",
                                 nil];
        
        /*
         Determine which keys were removed
         */
        NSMutableSet *removedItems = [NSMutableSet setWithSet:originalKeysSet];
        [removedItems minusSet:newKeysSet];
        
        /*
         Determine which keys were added
         */
        NSMutableSet *addedItems = [NSMutableSet setWithSet:newKeysSet];
        [addedItems minusSet:originalKeysSet];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
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
        
        /*
         Create a new dictionary by merging
         the original and the new one.
         
         This will be written to disk
         */
		NSMutableDictionary *mergedInfoDict = [NSMutableDictionary dictionaryWithDictionary:infoDictOnDisk];
		[mergedInfoDict addEntriesFromDictionary:[aPackage pkgInfoDictionary]];
        
        /*
         Remove keys that were deleted by user
         */
        for (NSString *aKey in keysToDelete) {
            if (([infoDictFromPackage valueForKey:aKey] == nil) &&
                ([infoDictOnDisk valueForKey:aKey] != nil)) {
                [mergedInfoDict removeObjectForKey:aKey];
            }
        }
        
        /*
         Key arrays already differ.
         User has added new information
         */
        NSArray *sortedMergedKeys = [[mergedInfoDict allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
		if (![sortedOriginalKeys isEqualToArray:sortedMergedKeys]) {
			[self writePackagePropertyList:mergedInfoDict forPackage:aPackage];
		}
        
        /*
         Check for value changes
         */
        else {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debugLogAllProperties"]) {
                NSLog(@"%@ No changes in key array. Checking for value changes.", [(NSURL *)aPackage.packageInfoURL lastPathComponent]);
            }
            if (![mergedInfoDict isEqualToDictionary:infoDictOnDisk]) {
				if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
                    NSLog(@"Values differ. Writing new pkginfo: %@", [(NSURL *)aPackage.packageInfoURL relativePath]);
                }
				[self writePackagePropertyList:mergedInfoDict forPackage:aPackage];
			} else {
				if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debugLogAllProperties"]) {
                    NSLog(@"No changes detected");
                }
			}
		}
        
        /*
         Clear the internal trigger
         */
        aPackage.hasUnstagedChangesValue = NO;
	}
}


- (void)writeManifestPropertyListsToDisk
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"Was asked to write manifest property lists to disk");
	}
    
    /*
     * =============================================
	 * Get all manifests that have been modified
     * since last save and check them for changes
     * =============================================
     */
	
	for (ManifestMO *aManifest in [self modifiedManifestsSinceLastSave]) {
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debugLogAllProperties"]) {
            NSLog(@"Checking manifest %@", [(NSURL *)aManifest.manifestURL lastPathComponent]);
        }
        
        /*
         * ================================================
         * Note!
         *
         * Manifest files might contain custom keys added
         * by the user or not yet supported by MunkiAdmin.
         * We need to be extra careful not to touch those.
         * ================================================
         */
        
        /*
         Read the current manifest file from disk
         */
        NSDictionary *infoDictOnDisk = [NSDictionary dictionaryWithContentsOfURL:(NSURL *)aManifest.manifestURL];
		NSArray *sortedOriginalKeys = [[infoDictOnDisk allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
        
        /*
         Get the ManifestMO object as a dictionary
         */
        NSDictionary *infoDictFromManifest = [aManifest manifestInfoDictionary];
		NSArray *sortedManifestKeys = [[infoDictFromManifest allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
		
        /*
         Check for differences in key arrays and log them
         */
        NSSet *originalKeysSet = [NSSet setWithArray:sortedOriginalKeys];
        NSSet *newKeysSet = [NSSet setWithArray:sortedManifestKeys];
        NSArray *keysToDelete = [NSArray arrayWithObjects:
                                 @"catalogs",
                                 @"conditional_items",
                                 @"included_manifests",
                                 @"managed_installs",
                                 @"managed_uninstalls",
                                 @"managed_updates",
                                 @"optional_installs",
                                 nil];
        
        /*
         Determine which keys were removed
         */
        NSMutableSet *removedItems = [NSMutableSet setWithSet:originalKeysSet];
        [removedItems minusSet:newKeysSet];
        
        /*
         Determine which keys were added
         */
        NSMutableSet *addedItems = [NSMutableSet setWithSet:newKeysSet];
        [addedItems minusSet:originalKeysSet];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
            for (NSString *aKey in [removedItems allObjects]) {
                if (![keysToDelete containsObject:aKey]) {
                    NSLog(@"Key change: \"%@\" found in original manifest. Keeping it.", aKey);
                } else {
                    NSLog(@"Key change: \"%@\" deleted by MunkiAdmin", aKey);
                }
                
            }
            for (NSString *aKey in [addedItems allObjects]) {
                NSLog(@"Key change: \"%@\" added by MunkiAdmin", aKey);
            }
        }
        
        /*
         Create a new dictionary by merging
         the original from disk with the new one.
         
         This will be written to disk
         */
		NSMutableDictionary *mergedManifestDict = [NSMutableDictionary dictionaryWithDictionary:infoDictOnDisk];
		[mergedManifestDict addEntriesFromDictionary:[aManifest manifestInfoDictionary]];
        
        /*
         Remove keys that were deleted by user
         */
        for (NSString *aKey in keysToDelete) {
            if (([infoDictFromManifest valueForKey:aKey] == nil) &&
                ([infoDictOnDisk valueForKey:aKey] != nil)) {
                [mergedManifestDict removeObjectForKey:aKey];
            }
        }
        
        /*
         Key arrays already differ.
         User has added new information
         */
        NSArray *sortedMergedKeys = [[mergedManifestDict allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
		if (![sortedOriginalKeys isEqualToArray:sortedMergedKeys]) {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Keys differ. Writing new manifest: %@", [(NSURL *)aManifest.manifestURL relativePath]);
			[mergedManifestDict writeToURL:(NSURL *)aManifest.manifestURL atomically:YES];
		}
        
        /*
         Finally write the manifest to disk if
         mergedManifestDict is not equal to infoDictOnDisk
         
         This will be triggered if any value is changed.
         */
        else {
            if (![mergedManifestDict isEqualToDictionary:infoDictOnDisk]) {
				if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
                    NSLog(@"Values differ. Writing new manifest: %@", [(NSURL *)aManifest.manifestURL relativePath]);
                }
				[mergedManifestDict writeToURL:(NSURL *)aManifest.manifestURL atomically:YES];
			} else {
				if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debugLogAllProperties"]) {
                    NSLog(@"No changes detected");
                }
			}
        }
        
        /*
         Clear the internal trigger
         */
        aManifest.hasUnstagedChangesValue = NO;
	}
}

# pragma mark -
# pragma mark Helper methods

- (NSArray *)allObjectsForEntity:(NSString *)entityName
{
	NSEntityDescription *entityDescr = [NSEntityDescription entityForName:entityName inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescr];
	NSArray *fetchResults = [[[NSApp delegate] managedObjectContext] executeFetchRequest:fetchRequest error:nil];
	[fetchRequest release];
	return fetchResults;
}


- (NSString *)relativePathToChildURL:(NSURL *)childURL parentURL:(NSURL *)parentURL
{
    NSMutableArray *relativePathComponents = [NSMutableArray arrayWithArray:[childURL pathComponents]];
    
    NSArray *parentPathComponents = [NSArray arrayWithArray:[parentURL pathComponents]];
    NSArray *childPathComponents = [NSArray arrayWithArray:[childURL pathComponents]];
    
    // Child URL must have more components than the parent
    if ([childPathComponents count] < [parentPathComponents count]) {
        return nil;
    }
    
    [parentPathComponents enumerateObjectsUsingBlock:^(NSString *parentPathComponent, NSUInteger idx, BOOL *stop) {
        if (idx < [childPathComponents count]) {
            NSString *childPathComponent = [childPathComponents objectAtIndex:idx];
            if ([childPathComponent isEqualToString:parentPathComponent]) {
                [relativePathComponents removeObjectAtIndex:0];
            } else {
                stop = YES;
            }
        } else {
            stop = YES;
        }
    }];
    
    NSString *childPath = [relativePathComponents componentsJoinedByString:@"/"];
    return childPath;
}


- (BOOL)pkgsAndPkgsinfoDirectoriesAreIdentical
{
    BOOL identical = NO;
    
    NSURL *pkginfoDirectory = [[NSApp delegate] pkgsInfoURL];
    NSURL *installerItemsDirectory = [[NSApp delegate] pkgsURL];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtURL:pkginfoDirectory
                                       includingPropertiesForKeys:[NSArray arrayWithObjects:
                                                                   NSURLNameKey,
                                                                   NSURLIsDirectoryKey,nil]
                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                     errorHandler:nil];
    for (NSURL *theURL in dirEnum) {
        
        NSString *fileName;
        [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
        
        NSNumber *isDirectory;
        [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        
        if ([isDirectory boolValue]) {
            // Check if a relative item exists in pkgs directory
            NSString *relative = [self relativePathToChildURL:theURL parentURL:pkginfoDirectory];
            NSURL *pkgsSubURL = [installerItemsDirectory URLByAppendingPathComponent:relative isDirectory:YES];
            if ([fileManager fileExistsAtPath:[pkgsSubURL path]]) {
                identical = YES;
            } else {
                identical = NO;
            }
            
        }
    }
    
    return identical;
}


- (void)updateMakepkginfoVersionAsync
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSTask *task = [[[NSTask alloc] init] autorelease];
        NSPipe *pipe = [NSPipe pipe];
        NSFileHandle *filehandle = [pipe fileHandleForReading];
        NSString *launchPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"makepkginfoPath"];
        [task setLaunchPath:launchPath];
        [task setArguments:[NSArray arrayWithObject:@"--version"]];
        [task setStandardOutput:pipe];
        [task launch];
        NSData *outputData = [filehandle readDataToEndOfFile];
        NSString *results;
        results = [[[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];
        self.makepkginfoVersion = results;
    });
}

- (void)updateMakecatalogsVersionAsync
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSTask *task = [[[NSTask alloc] init] autorelease];
        NSPipe *pipe = [NSPipe pipe];
        NSFileHandle *filehandle = [pipe fileHandleForReading];
        NSString *launchPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"makecatalogsPath"];
        [task setLaunchPath:launchPath];
        [task setArguments:[NSArray arrayWithObject:@"--version"]];
        [task setStandardOutput:pipe];
        [task launch];
        NSData *outputData = [filehandle readDataToEndOfFile];
        NSString *results;
        results = [[[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];
        self.makecatalogsVersion = results;
    });
}

- (void)updateMunkiVersions
{
    /*
     * Update versions for installed munki tools
     */
    if (self.makepkginfoInstalled) [self updateMakepkginfoVersionAsync];
    else self.makepkginfoVersion = nil;
    
    if (self.makecatalogsInstalled) [self updateMakecatalogsVersionAsync];
    else self.makecatalogsVersion = nil;
}


- (BOOL)makepkginfoInstalled
{
	// Check if /usr/local/munki/makepkginfo exists
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *makepkginfoPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"makepkginfoPath"];
	if ([fm fileExistsAtPath:makepkginfoPath]) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)makecatalogsInstalled
{
	// Check if /usr/local/munki/makecatalogs exists
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *makecatalogsPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"makecatalogsPath"];
	if ([fm fileExistsAtPath:makecatalogsPath]) {
		return YES;
	} else {
		return NO;
	}
}


- (void)setupMappings
{
	/*
     * =========================================
     * Define the munki keys we support
     *
     * These are read from NSUserDefaults
     * (which gets initialized from UserDefaults.plist)
     * =========================================
     */
    
    // Basic keys
	NSMutableDictionary *newPkginfoBasicKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *pkginfoBasicKey in [self.defaults arrayForKey:@"pkginfoBasicKeys"]) {
		[newPkginfoBasicKeyMappings setObject:pkginfoBasicKey forKey:[NSString stringWithFormat:@"munki_%@", pkginfoBasicKey]];
	}
	self.pkginfoBasicKeyMappings = [NSDictionary dictionaryWithDictionary:newPkginfoBasicKeyMappings];
	[newPkginfoBasicKeyMappings release];
    
    // Array keys
    NSMutableDictionary *newPkginfoArrayKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *pkginfoArrayKey in [self.defaults arrayForKey:@"pkginfoArrayKeys"]) {
		[newPkginfoArrayKeyMappings setObject:pkginfoArrayKey forKey:[NSString stringWithFormat:@"munki_%@", pkginfoArrayKey]];
	}
	self.pkginfoArrayKeyMappings = [NSDictionary dictionaryWithDictionary:newPkginfoArrayKeyMappings];
	[newPkginfoArrayKeyMappings release];
    
    // Keys that might be assimilated
    NSMutableArray *newPkginfoAssimilateKeys = [[NSMutableArray alloc] init];
	for (NSString *pkginfoArrayKey in [self.defaults arrayForKey:@"pkginfoArrayKeys"]) {
		[newPkginfoAssimilateKeys addObject:pkginfoArrayKey];
	}
    for (NSString *pkginfoBasicKey in [self.defaults arrayForKey:@"pkginfoBasicKeys"]) {
		[newPkginfoAssimilateKeys addObject:pkginfoBasicKey];
	}
    
    [newPkginfoAssimilateKeys removeObject:@"catalogs"];
    [newPkginfoAssimilateKeys removeObject:@"receipts"];
    [newPkginfoAssimilateKeys removeObject:@"installs"];
    [newPkginfoAssimilateKeys removeObject:@"items_to_copy"];
    
    [newPkginfoAssimilateKeys removeObject:@"name"];
    [newPkginfoAssimilateKeys removeObject:@"version"];
    [newPkginfoAssimilateKeys removeObject:@"force_install_after_date"];
    [newPkginfoAssimilateKeys removeObject:@"installed_size"];
    [newPkginfoAssimilateKeys removeObject:@"installer_item_hash"];
    [newPkginfoAssimilateKeys removeObject:@"installer_item_location"];
    [newPkginfoAssimilateKeys removeObject:@"installer_item_size"];
    [newPkginfoAssimilateKeys removeObject:@"package_path"];
    
	self.pkginfoAssimilateKeys = [NSArray arrayWithArray:newPkginfoAssimilateKeys];
	[newPkginfoAssimilateKeys release];
	
	// Receipt keys
	NSMutableDictionary *newReceiptKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *receiptKey in [self.defaults arrayForKey:@"receiptKeys"]) {
		[newReceiptKeyMappings setObject:receiptKey forKey:[NSString stringWithFormat:@"munki_%@", receiptKey]];
	}
	self.receiptKeyMappings = [NSDictionary dictionaryWithDictionary:newReceiptKeyMappings];
	[newReceiptKeyMappings release];
	
	// Installs item keys
	NSMutableDictionary *newInstallsKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *installsKey in [self.defaults arrayForKey:@"installsKeys"]) {
		[newInstallsKeyMappings setObject:installsKey forKey:[NSString stringWithFormat:@"munki_%@", installsKey]];
	}
	self.installsKeyMappings = [NSDictionary dictionaryWithDictionary:newInstallsKeyMappings];
	[newInstallsKeyMappings release];
	
	// items_to_copy keys
	NSMutableDictionary *newItemsToCopyKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *itemToCopy in [self.defaults arrayForKey:@"itemsToCopyKeys"]) {
		[newItemsToCopyKeyMappings setObject:itemToCopy forKey:[NSString stringWithFormat:@"munki_%@", itemToCopy]];
	}
	self.itemsToCopyKeyMappings = [NSDictionary dictionaryWithDictionary:newItemsToCopyKeyMappings];
	[newItemsToCopyKeyMappings release];
    
    // installer_choices_xml
    NSMutableDictionary *newInstallerChoicesKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *installerChoice in [self.defaults arrayForKey:@"installerChoicesKeys"]) {
		[newInstallerChoicesKeyMappings setObject:installerChoice forKey:[NSString stringWithFormat:@"munki_%@", installerChoice]];
	}
	self.installerChoicesKeyMappings = [NSDictionary dictionaryWithDictionary:newInstallerChoicesKeyMappings];
	[newInstallerChoicesKeyMappings release];
}

- (NSArray *)pkginfoAssimilateKeysForAuto
{
    // Setup the default selection
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *keysForAutomaticAssimilation = [[[NSMutableArray alloc] init] autorelease];
    for (NSString *keyName in self.pkginfoAssimilateKeys) {
        NSString *assimilateKeyName = [NSString stringWithFormat:@"assimilate_%@", keyName];
        BOOL sourceValue = [defaults boolForKey:assimilateKeyName];
        if (sourceValue) {
            [keysForAutomaticAssimilation addObject:keyName];
        }
    }
    return [NSArray arrayWithArray:keysForAutomaticAssimilation];
}

- (NSUserDefaults *)defaults
{
	return [NSUserDefaults standardUserDefaults];
}

@end
