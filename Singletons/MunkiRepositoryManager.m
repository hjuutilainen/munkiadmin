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
#import "MACoreDataManager.h"

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

- (BOOL)movePackage:(PackageMO *)aPackage toURL:(NSURL *)targetURL moveInstaller:(BOOL)moveInstaller
{
    BOOL returnValue = NO;
    
    NSManagedObjectContext *moc = [aPackage managedObjectContext];
    
    NSURL *sourceURL = aPackage.packageInfoURL;
    DirectoryMO *originalDir = [[MACoreDataManager sharedManager] directoryWithURL:[sourceURL URLByDeletingLastPathComponent] managedObjectContext:moc];
    DirectoryMO *targetDir = [[MACoreDataManager sharedManager] directoryWithURL:[targetURL URLByDeletingLastPathComponent] managedObjectContext:moc];
    
    /*
     Deal with the pkginfo file first
     */
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL moveSucceeded = [fm moveItemAtURL:sourceURL toURL:targetURL error:nil];
    
    if (moveSucceeded) {
        /*
         File was succesfully moved so update the object with a new location
         */
        [aPackage setPackageInfoURL:targetURL];
        [aPackage removeSourceListItemsObject:originalDir];
        [aPackage addSourceListItemsObject:targetDir];
        returnValue = YES;
    } else {
        /*
         Moving the pkginfo file failed, bail out
         */
        return NO;
    }
    
    /*
     Move the installer item too if requested
     */
    NSURL *installerSourceURL = aPackage.packageURL;
    if (moveInstaller && (installerSourceURL != nil)) {
        
        /*
         First check if we have a matching relative subdirectory in ./pkgs
         */
        NSURL *pkginfoDirectory = [[NSApp delegate] pkgsInfoURL];
        NSURL *installerItemsDirectory = [[NSApp delegate] pkgsURL];
        
        NSNumber *isDirectory;
        [[targetURL URLByDeletingLastPathComponent] getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        
        if ([isDirectory boolValue]) {
            NSString *relative = [self relativePathToChildURL:[targetURL URLByDeletingLastPathComponent] parentURL:pkginfoDirectory];
            NSURL *pkgsSubURL = [installerItemsDirectory URLByAppendingPathComponent:relative];
            if ([fm fileExistsAtPath:[pkgsSubURL path]]) {
                /*
                 Try to move the installer item
                 */
                NSURL *installerTargetURL = [pkgsSubURL URLByAppendingPathComponent:[installerSourceURL lastPathComponent]];
                BOOL moveInstallerSucceeded = [fm moveItemAtURL:installerSourceURL toURL:installerTargetURL error:nil];
                if (!moveInstallerSucceeded) {
                    returnValue = NO;
                } else {
                    /*
                     Installer item was succesfully moved, update the installer_item_location key
                     */
                    NSString *newInstallerItemPath = [self relativePathToChildURL:installerTargetURL parentURL:installerItemsDirectory];
                    aPackage.munki_installer_item_location = newInstallerItemPath;
                    aPackage.packageURL = installerTargetURL;
                    returnValue = YES;
                }
            } else {
                returnValue = NO;
            }
        }
    }
    
    return returnValue;
}

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

- (void)copyInstallerEnvironmentVariablesFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc
{
    for (InstallerEnvironmentVariableMO *installerEnvironmentItem in source.installerEnvironmentVariables) {
        InstallerEnvironmentVariableMO *newInstallerEnvironmentItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallerEnvironmentVariable" inManagedObjectContext:moc];
        newInstallerEnvironmentItem.munki_installer_environment_key = installerEnvironmentItem.munki_installer_environment_key;
        newInstallerEnvironmentItem.munki_installer_environment_value = installerEnvironmentItem.munki_installer_environment_value;
        [target addInstallerEnvironmentVariablesObject:newInstallerEnvironmentItem];
    }
}

- (void)copyInstallerChoicesFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc
{
    for (InstallerChoicesItemMO *installerChoicesItem in source.installerChoicesItems) {
        InstallerChoicesItemMO *newInstallerChoicesItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallerChoicesItem" inManagedObjectContext:moc];
        [self.installerChoicesKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id value = [installerChoicesItem valueForKey:key];
            if (value != nil) {
                [newInstallerChoicesItem setValue:value forKey:key];
            }
        }];
        [target addInstallerChoicesItemsObject:newInstallerChoicesItem];
    }
}

- (void)copyInstallsItemsFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc
{
    for (InstallsItemMO *installsItem in source.installsItems) {
        InstallsItemMO *newInstallsItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallsItem" inManagedObjectContext:moc];
        [self.installsKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id value = [installsItem valueForKey:key];
            if (value != nil) {
                [newInstallsItem setValue:value forKey:key];
            }
        }];
        
        [target addInstallsItemsObject:newInstallsItem];
        
        [installsItem.customKeys enumerateObjectsWithOptions:0 usingBlock:^(InstallsItemCustomKeyMO *obj, BOOL *stop) {
            InstallsItemCustomKeyMO *newCustomKey = [NSEntityDescription insertNewObjectForEntityForName:@"InstallsItemCustomKey" inManagedObjectContext:moc];
            newCustomKey.customKeyName = obj.customKeyName;
            newCustomKey.customKeyValue = obj.customKeyValue;
            newCustomKey.installsItem = newInstallsItem;
        }];
        
        /*
         Save the original installs item dictionary so that we can compare to it later
         */
        newInstallsItem.originalInstallsItem = installsItem.originalInstallsItem;
    }
}

- (void)copyItemsToCopyItemsFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc
{
    for (ItemToCopyMO *itemsToCopyItem in source.itemsToCopy) {
        ItemToCopyMO *newItemsToCopyItem = [NSEntityDescription insertNewObjectForEntityForName:@"ItemToCopy" inManagedObjectContext:moc];
        [self.itemsToCopyKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id value = [itemsToCopyItem valueForKey:key];
            if (value != nil) {
                [newItemsToCopyItem setValue:value forKey:key];
            }
        }];
        [target addItemsToCopyObject:newItemsToCopyItem];
    }
}

- (void)assimilatePackage:(PackageMO *)targetPackage sourcePackage:(PackageMO *)sourcePackage keys:(NSArray *)munkiKeys
{
    NSManagedObjectContext *mainMoc = [[NSApp delegate] managedObjectContext];
    NSArray *arrayKeys = [NSArray arrayWithObjects:
                          @"blocking_applications",
                          @"installer_choices_xml",
                          @"installs_items",
                          @"requires",
                          @"supported_architectures",
                          @"update_for",
                          @"installer_environment",
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
                [self copyInstallerChoicesFrom:sourcePackage target:targetPackage inManagedObjectContext:mainMoc];
            }
            else if ([keyName isEqualToString:@"installs_items"]) {
                [self copyInstallsItemsFrom:sourcePackage target:targetPackage inManagedObjectContext:mainMoc];
            }
            else if ([keyName isEqualToString:@"installer_environment"]) {
                [self copyInstallerEnvironmentVariablesFrom:sourcePackage target:targetPackage inManagedObjectContext:mainMoc];
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



- (void)moveManifest:(ManifestMO *)manifest toURL:(NSURL *)newURL cascade:(BOOL)shouldCascade
{
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    NSURL *currentURL = (NSURL *)manifest.manifestURL;
    NSString *oldTitle = manifest.title;
    
    if (![[NSFileManager defaultManager] moveItemAtURL:currentURL toURL:newURL error:nil]) {
        NSLog(@"Failed to rename manifest on disk");
        return;
    }
    
    // Manifest name should be the relative path from manifests subdirectory
    NSArray *manifestComponents = [newURL pathComponents];
    NSArray *manifestDirComponents = [[[NSApp delegate] manifestsURL] pathComponents];
    NSMutableArray *relativePathComponents = [NSMutableArray arrayWithArray:manifestComponents];
    [relativePathComponents removeObjectsInArray:manifestDirComponents];
    NSString *manifestRelativePath = [relativePathComponents componentsJoinedByString:@"/"];
    
    manifest.title = manifestRelativePath;
    manifest.manifestURL = newURL;
    if ([self.defaults boolForKey:@"debug"]) {
        NSString *aDescr = [NSString stringWithFormat:@"Renamed manifest \"%@\" to \"%@\"", oldTitle, manifest.title];
        NSLog(@"%@", aDescr);
    }
    
    if (shouldCascade) {
        /*
         Rename other references which include
         - a nested manifest
         - a conditional nested manifest
         */
        NSFetchRequest *getReferencingManifests = [[NSFetchRequest alloc] init];
        [getReferencingManifests setEntity:[NSEntityDescription entityForName:@"StringObject" inManagedObjectContext:moc]];
        NSPredicate *referencingPred = [NSPredicate predicateWithFormat:@"title == %@ AND typeString == %@", oldTitle, @"includedManifest"];
        [getReferencingManifests setPredicate:referencingPred];
        if ([moc countForFetchRequest:getReferencingManifests error:nil] > 0) {
            NSArray *referencingObjects = [moc executeFetchRequest:getReferencingManifests error:nil];
            for (StringObjectMO *aReference in referencingObjects) {
                
                // This is a nested manifest under included_manifests
                if (aReference.manifestReference) {
                    ManifestMO *manifest = aReference.manifestReference;
                    aReference.title = manifestRelativePath;
                    manifest.hasUnstagedChangesValue = YES;
                    if ([self.defaults boolForKey:@"debug"]) {
                        NSString *aDescr = [NSString stringWithFormat:
                                            @"Renamed included_manifests reference \"%@\" to \"%@\" in manifest %@",
                                            oldTitle,
                                            aReference.title,
                                            manifest.title];
                        NSLog(@"%@", aDescr);
                    }
                }
                // This is a conditional nested manifest
                else if (aReference.includedManifestConditionalReference) {
                    ConditionalItemMO *conditional = aReference.includedManifestConditionalReference;
                    ManifestMO *manifest = conditional.manifest;
                    aReference.title = manifestRelativePath;
                    manifest.hasUnstagedChangesValue = YES;
                    if ([self.defaults boolForKey:@"debug"]) {
                        NSString *aDescr = [NSString stringWithFormat:
                                            @"Renamed included_manifests reference \"%@\" to \"%@\" in manifest \"%@\" under condition \"%@\"",
                                            oldTitle,
                                            aReference.title,
                                            manifest.title,
                                            conditional.titleWithParentTitle];
                        NSLog(@"%@", aDescr);
                    }
                }
                
                
            }
        } else {
            if ([self.defaults boolForKey:@"debug"]) NSLog(@"No referencing objects to rename");
        }
        [getReferencingManifests release];
    }
}


- (NSArray *)referencingPackageStringObjectsWithTitle:(NSString *)title
{
    NSArray *referencingObjects = nil;
    
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    NSArray *stringObjectTypes = [NSArray arrayWithObjects:
                                  @"managedInstall",
                                  @"managedUninstall",
                                  @"managedUpdate",
                                  @"optionalInstall",
                                  @"requires",
                                  @"updateFor",
                                  nil];
    
    NSFetchRequest *getReferencesByName = [[NSFetchRequest alloc] init];
    [getReferencesByName setEntity:[NSEntityDescription entityForName:@"StringObject" inManagedObjectContext:moc]];
    NSPredicate *referencingPred = [NSPredicate predicateWithFormat:@"title == %@ AND typeString IN %@", title, stringObjectTypes];
    [getReferencesByName setPredicate:referencingPred];
    if ([moc countForFetchRequest:getReferencesByName error:nil] > 0) {
        referencingObjects = [moc executeFetchRequest:getReferencesByName error:nil];
    } else {
        //if ([self.defaults boolForKey:@"debug"]) NSLog(@"No referencing objects found with title \"%@\"", title);
    }
    [getReferencesByName release];
    return referencingObjects;
}

- (NSDictionary *)referencingItemsForPackage:(PackageMO *)aPackage
{    
    NSString *packageName = aPackage.munki_name;
    NSString *packageNameWithVersion = aPackage.titleWithVersion;
    
    NSMutableDictionary *combined = [[[NSMutableDictionary alloc] init] autorelease];
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    
    // Get sibling packages
    NSMutableArray *packagesWithSameName = [[[NSMutableArray alloc] init] autorelease];
    NSFetchRequest *getSiblings = [[NSFetchRequest alloc] init];
    [getSiblings setEntity:[NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc]];
    NSPredicate *siblingPred = [NSPredicate predicateWithFormat:@"parentApplication == %@", aPackage.parentApplication];
    [getSiblings setPredicate:siblingPred];
    if ([moc countForFetchRequest:getSiblings error:nil] > 0) {
        NSArray *siblingPackages = [moc executeFetchRequest:getSiblings error:nil];
        for (PackageMO *aSibling in siblingPackages) {
            [packagesWithSameName addObject:aSibling];
        }
    }
    [getSiblings release];
    if (packagesWithSameName) [combined setObject:packagesWithSameName forKey:@"packagesWithSameName"];
    
    // Manifests
    NSMutableArray *managedInstalls = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *managedUninstalls = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *managedUpdates = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *optionalInstalls = [[[NSMutableArray alloc] init] autorelease];
    
    // Manifest conditional items
    NSMutableArray *conditionalManagedInstalls = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *conditionalManagedUninstalls = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *conditionalManagedUpdates = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *conditionalOptionalInstalls = [[[NSMutableArray alloc] init] autorelease];
    
    // Pkginfo items
    NSMutableArray *requiresItems = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *updateForItems = [[[NSMutableArray alloc] init] autorelease];
    
    /*
     Look for references with the name key. These might include:
     - managed_installs item in a manifest
     - managed_uninstalls item in a manifest
     - managed_updates item in a manifest
     - optional_installs item in a manifest
     - any of the above within a condition in a manifest
     - requires item in a pkginfo
     - update_for item in a pkginfo
     */
    
    NSArray *referencingObjects = [self referencingPackageStringObjectsWithTitle:packageName];
    for (StringObjectMO *aReference in referencingObjects) {
        
        if (aReference.managedInstallReference) {
            [managedInstalls addObject:aReference];
        } else if (aReference.managedUninstallReference) {
            [managedUninstalls addObject:aReference];
        } else if (aReference.managedUpdateReference) {
            [managedUpdates addObject:aReference];
        } else if (aReference.optionalInstallReference) {
            [optionalInstalls addObject:aReference];
        }
        
        else if (aReference.managedInstallConditionalReference) {
            [conditionalManagedInstalls addObject:aReference];
        } else if (aReference.managedUninstallConditionalReference) {
            [conditionalManagedUninstalls addObject:aReference];
        } else if (aReference.managedUpdateConditionalReference) {
            [conditionalManagedUpdates addObject:aReference];
        } else if (aReference.optionalInstallConditionalReference) {
            [conditionalOptionalInstalls addObject:aReference];
        }
        
        else if (aReference.requiresReference) {
            [requiresItems addObject:aReference];
        } else if (aReference.updateForReference) {
            [updateForItems addObject:aReference];
        }
    }
    
    if (managedInstalls) [combined setObject:managedInstalls forKey:@"managedInstalls"];
    if (managedUninstalls) [combined setObject:managedUninstalls forKey:@"managedUninstalls"];
    if (managedUpdates) [combined setObject:managedUpdates forKey:@"managedUpdates"];
    if (optionalInstalls) [combined setObject:optionalInstalls forKey:@"optionalInstalls"];
    
    if (conditionalManagedInstalls) [combined setObject:conditionalManagedInstalls forKey:@"conditionalManagedInstalls"];
    if (conditionalManagedUninstalls) [combined setObject:conditionalManagedUninstalls forKey:@"conditionalManagedUninstalls"];
    if (conditionalManagedUpdates) [combined setObject:conditionalManagedUpdates forKey:@"conditionalManagedUpdates"];
    if (conditionalOptionalInstalls) [combined setObject:conditionalOptionalInstalls forKey:@"conditionalOptionalInstalls"];
    
    if (requiresItems) [combined setObject:requiresItems forKey:@"requiresItems"];
    if (updateForItems) [combined setObject:updateForItems forKey:@"updateForItems"];
    
    
    /*
     Look for references with the name and version key. These might include:
     - managed_installs item in a manifest
     - managed_uninstalls item in a manifest
     - managed_updates item in a manifest
     - optional_installs item in a manifest
     - any of the above within a condition in a manifest
     - requires item in a pkginfo
     - update_for item in a pkginfo
     */
    
    // Manifests
    NSMutableArray *managedInstallsWithVersion = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *managedUninstallsWithVersion = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *managedUpdatesWithVersion = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *optionalInstallsWithVersion = [[[NSMutableArray alloc] init] autorelease];
    
    // Manifest conditional items
    NSMutableArray *conditionalManagedInstallsWithVersion = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *conditionalManagedUninstallsWithVersion = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *conditionalManagedUpdatesWithVersion = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *conditionalOptionalInstallsWithVersion = [[[NSMutableArray alloc] init] autorelease];
    
    // Pkginfo items
    NSMutableArray *requiresItemsWithVersion = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *updateForItemsWithVersion = [[[NSMutableArray alloc] init] autorelease];
    
    NSArray *referencingObjectsWithVersion = [self referencingPackageStringObjectsWithTitle:packageNameWithVersion];
    for (StringObjectMO *aReference in referencingObjectsWithVersion) {
        
        if (aReference.managedInstallReference) {
            [managedInstallsWithVersion addObject:aReference];
        } else if (aReference.managedUninstallReference) {
            [managedUninstallsWithVersion addObject:aReference];
        } else if (aReference.managedUpdateReference) {
            [managedUpdatesWithVersion addObject:aReference];
        } else if (aReference.optionalInstallReference) {
            [optionalInstallsWithVersion addObject:aReference];
        }
        
        else if (aReference.managedInstallConditionalReference) {
            [conditionalManagedInstallsWithVersion addObject:aReference];
        } else if (aReference.managedUninstallConditionalReference) {
            [conditionalManagedUninstallsWithVersion addObject:aReference];
        } else if (aReference.managedUpdateConditionalReference) {
            [conditionalManagedUpdatesWithVersion addObject:aReference];
        } else if (aReference.optionalInstallConditionalReference) {
            [conditionalOptionalInstallsWithVersion addObject:aReference];
        }
        
        else if (aReference.requiresReference) {
            [requiresItemsWithVersion addObject:aReference];
        } else if (aReference.updateForReference) {
            [updateForItems addObject:aReference];
        }
    }
    
    if (managedInstallsWithVersion) [combined setObject:managedInstallsWithVersion forKey:@"managedInstallsWithVersion"];
    if (managedUninstallsWithVersion) [combined setObject:managedUninstallsWithVersion forKey:@"managedUninstallsWithVersion"];
    if (managedUpdatesWithVersion) [combined setObject:managedUpdatesWithVersion forKey:@"managedUpdatesWithVersion"];
    if (optionalInstallsWithVersion) [combined setObject:optionalInstallsWithVersion forKey:@"optionalInstallsWithVersion"];
    
    if (conditionalManagedInstallsWithVersion) [combined setObject:conditionalManagedInstallsWithVersion forKey:@"conditionalManagedInstallsWithVersion"];
    if (conditionalManagedUninstallsWithVersion) [combined setObject:conditionalManagedUninstallsWithVersion forKey:@"conditionalManagedUninstallsWithVersion"];
    if (conditionalManagedUpdatesWithVersion) [combined setObject:conditionalManagedUpdatesWithVersion forKey:@"conditionalManagedUpdatesWithVersion"];
    if (conditionalOptionalInstallsWithVersion) [combined setObject:conditionalOptionalInstallsWithVersion forKey:@"conditionalOptionalInstallsWithVersion"];
    
    if (requiresItemsWithVersion) [combined setObject:requiresItemsWithVersion forKey:@"requiresItemsWithVersion"];
    if (updateForItemsWithVersion) [combined setObject:updateForItemsWithVersion forKey:@"updateForItemsWithVersion"];
    
    
    if (combined) {
        return [NSDictionary dictionaryWithDictionary:combined];
    } else {
        return nil;
    }
}

- (void)renamePackage:(PackageMO *)aPackage newName:(NSString *)newName cascade:(BOOL)shouldCascade
{
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    NSString *oldName = aPackage.munki_name;
    NSString *oldNameWithVersion = aPackage.titleWithVersion;
    
    // Get the packages parent application which represents a group of
    // packageinfos with the same name
    ApplicationMO *packageGroup = aPackage.parentApplication;
        
    if (shouldCascade) {
        
        // Check for existing ApplicationMO with the new name
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
            packageGroup.munki_name = newName;
            aPackage.munki_name = newName;
            aPackage.hasUnstagedChangesValue = YES;
            aPackage.parentApplication = packageGroup; // Shouldn't need this...
        }
        [getApplication release];
        
        if ([self.defaults boolForKey:@"debug"]) {
            NSString *aDescr = [NSString stringWithFormat:@"Changed package name from \"%@\" to \"%@\" in pkginfo file %@", oldName, newName, aPackage.relativePath];
            NSLog(@"%@", aDescr);
        }
        
        // Get sibling packages
        NSFetchRequest *getSiblings = [[NSFetchRequest alloc] init];
        [getSiblings setEntity:[NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc]];
        NSPredicate *siblingPred = [NSPredicate predicateWithFormat:@"parentApplication == %@", packageGroup];
        [getSiblings setPredicate:siblingPred];
        if ([moc countForFetchRequest:getSiblings error:nil] > 0) {
            NSArray *siblingPackages = [moc executeFetchRequest:getSiblings error:nil];
            for (PackageMO *aSibling in siblingPackages) {
                if (aSibling != aPackage) {
                    if ([self.defaults boolForKey:@"debug"]) {
                        NSString *aDescr = [NSString stringWithFormat:@"Changed package name from \"%@\" to \"%@\" in pkginfo file %@", aSibling.munki_name, newName, aSibling.relativePath];
                        NSLog(@"%@", aDescr);
                    }
                    aSibling.munki_name = newName;
                    aSibling.hasUnstagedChangesValue = YES;
                    aSibling.parentApplication = aPackage.parentApplication;
                }
            }
        } else {
            
        }
        [getSiblings release];
        
        
        /*
         Rename references with the old name. These might include:
         - managed_installs item in a manifest
         - managed_uninstalls item in a manifest
         - managed_updates item in a manifest
         - optional_installs item in a manifest
         - requires item in a package
         - update_for item in a package
         */
        NSArray *referencingObjects = [self referencingPackageStringObjectsWithTitle:oldName];
        for (StringObjectMO *aReference in referencingObjects) {
            
            // Change the name
            aReference.title = newName;
            
            if (aReference.managedInstallReference) {
                ManifestMO *manifest = aReference.managedInstallReference;
                manifest.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed managed_installs reference \"%@\" to \"%@\" in manifest %@", oldName, aReference.title, manifest.title];
                    NSLog(@"%@", aDescr);
                }
            } else if (aReference.managedUninstallReference) {
                ManifestMO *manifest = aReference.managedUninstallReference;
                manifest.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed managed_uninstalls reference \"%@\" to \"%@\" in manifest %@", oldName, aReference.title, manifest.title];
                    NSLog(@"%@", aDescr);
                }
            } else if (aReference.managedUpdateReference) {
                ManifestMO *manifest = aReference.managedUpdateReference;
                manifest.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed managed_updates reference \"%@\" to \"%@\" in manifest %@", oldName, aReference.title, manifest.title];
                    NSLog(@"%@", aDescr);
                }
            } else if (aReference.optionalInstallReference) {
                ManifestMO *manifest = aReference.optionalInstallReference;
                manifest.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed optional_installs reference \"%@\" to \"%@\" in manifest %@", oldName, aReference.title, manifest.title];
                    NSLog(@"%@", aDescr);
                }
            }
            
            else if (aReference.managedInstallConditionalReference) {
                ConditionalItemMO *cond = aReference.managedInstallConditionalReference;
                ManifestMO *manifest = aReference.managedInstallConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed managed_installs reference \"%@\" to \"%@\" in manifest %@ under condition \"%@\"", oldName, aReference.title, manifest.title, cond.titleWithParentTitle];
                    NSLog(@"%@", aDescr);
                }
                
            } else if (aReference.managedUninstallConditionalReference) {
                ConditionalItemMO *cond = aReference.managedUninstallConditionalReference;
                ManifestMO *manifest = aReference.managedInstallConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed managed_uninstalls reference \"%@\" to \"%@\" in manifest %@ under condition \"%@\"", oldName, aReference.title, manifest.title, cond.titleWithParentTitle];
                    NSLog(@"%@", aDescr);
                }
            } else if (aReference.managedUpdateConditionalReference) {
                ConditionalItemMO *cond = aReference.managedUpdateConditionalReference;
                ManifestMO *manifest = aReference.managedInstallConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed managed_updates reference \"%@\" to \"%@\" in manifest %@ under condition \"%@\"", oldName, aReference.title, manifest.title, cond.titleWithParentTitle];
                    NSLog(@"%@", aDescr);
                }
            } else if (aReference.optionalInstallConditionalReference) {
                ConditionalItemMO *cond = aReference.optionalInstallConditionalReference;
                ManifestMO *manifest = aReference.managedInstallConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed optional_installs reference \"%@\" to \"%@\" in manifest %@ under condition \"%@\"", oldName, aReference.title, manifest.title, cond.titleWithParentTitle];
                    NSLog(@"%@", aDescr);
                }
            }
            
            else if (aReference.requiresReference) {
                PackageMO *package = aReference.requiresReference;
                package.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed requires reference \"%@\" to \"%@\" in package %@", oldName, aReference.title, package.titleWithVersion];
                    NSLog(@"%@", aDescr);
                }
                
            } else if (aReference.updateForReference) {
                PackageMO *package = aReference.updateForReference;
                package.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed requires reference \"%@\" to \"%@\" in package %@", oldName, aReference.title, package.titleWithVersion];
                    NSLog(@"%@", aDescr);
                }
            }
            
        }
        
        
        NSArray *referencingObjectsWithVersion = [self referencingPackageStringObjectsWithTitle:oldNameWithVersion];
        for (StringObjectMO *aReference in referencingObjectsWithVersion) {
            
            // Change the name
            aReference.title = aPackage.titleWithVersion;
            
            if (aReference.managedInstallReference) {
                ManifestMO *manifest = aReference.managedInstallReference;
                manifest.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed managed_installs reference \"%@\" to \"%@\" in manifest %@", oldNameWithVersion, aReference.title, manifest.title];
                    NSLog(@"%@", aDescr);
                }
            } else if (aReference.managedUninstallReference) {
                ManifestMO *manifest = aReference.managedUninstallReference;
                manifest.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed managed_uninstalls reference \"%@\" to \"%@\" in manifest %@", oldNameWithVersion, aReference.title, manifest.title];
                    NSLog(@"%@", aDescr);
                }
            } else if (aReference.managedUpdateReference) {
                ManifestMO *manifest = aReference.managedUpdateReference;
                manifest.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed managed_updates reference \"%@\" to \"%@\" in manifest %@", oldNameWithVersion, aReference.title, manifest.title];
                    NSLog(@"%@", aDescr);
                }
            } else if (aReference.optionalInstallReference) {
                ManifestMO *manifest = aReference.optionalInstallReference;
                manifest.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed optional_installs reference \"%@\" to \"%@\" in manifest %@", oldNameWithVersion, aReference.title, manifest.title];
                    NSLog(@"%@", aDescr);
                }
            }
            
            else if (aReference.managedInstallConditionalReference) {
                ConditionalItemMO *cond = aReference.managedInstallConditionalReference;
                ManifestMO *manifest = aReference.managedInstallConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed managed_installs reference \"%@\" to \"%@\" in manifest %@ under condition \"%@\"", oldNameWithVersion, aReference.title, manifest.title, cond.titleWithParentTitle];
                    NSLog(@"%@", aDescr);
                }
            } else if (aReference.managedUninstallConditionalReference) {
                ConditionalItemMO *cond = aReference.managedUninstallConditionalReference;
                ManifestMO *manifest = aReference.managedInstallConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed managed_uninstalls reference \"%@\" to \"%@\" in manifest %@ under condition \"%@\"", oldNameWithVersion, aReference.title, manifest.title, cond.titleWithParentTitle];
                    NSLog(@"%@", aDescr);
                }
            } else if (aReference.managedUpdateConditionalReference) {
                ConditionalItemMO *cond = aReference.managedUpdateConditionalReference;
                ManifestMO *manifest = aReference.managedInstallConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed managed_updates reference \"%@\" to \"%@\" in manifest %@ under condition \"%@\"", oldNameWithVersion, aReference.title, manifest.title, cond.titleWithParentTitle];
                    NSLog(@"%@", aDescr);
                }
            } else if (aReference.optionalInstallConditionalReference) {
                ConditionalItemMO *cond = aReference.optionalInstallConditionalReference;
                ManifestMO *manifest = aReference.managedInstallConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed optional_installs reference \"%@\" to \"%@\" in manifest %@ under condition \"%@\"", oldNameWithVersion, aReference.title, manifest.title, cond.titleWithParentTitle];
                    NSLog(@"%@", aDescr);
                }
            }
            
            else if (aReference.requiresReference) {
                PackageMO *package = aReference.requiresReference;
                package.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed requires reference \"%@\" to \"%@\" in package %@", oldNameWithVersion, aReference.title, package.titleWithVersion];
                    NSLog(@"%@", aDescr);
                }
                
            } else if (aReference.updateForReference) {
                PackageMO *package = aReference.updateForReference;
                package.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Renamed requires reference \"%@\" to \"%@\" in package %@", oldNameWithVersion, aReference.title, package.titleWithVersion];
                    NSLog(@"%@", aDescr);
                }
            }
            
        }
    }
    
    
    else {
        
        // Check for existing ApplicationMO with the new name
        NSFetchRequest *getApplication = [[NSFetchRequest alloc] init];
        [getApplication setEntity:[NSEntityDescription entityForName:@"Application" inManagedObjectContext:moc]];
        NSPredicate *appPred = [NSPredicate predicateWithFormat:@"munki_name == %@", newName];
        [getApplication setPredicate:appPred];
        if ([moc countForFetchRequest:getApplication error:nil] > 0) {
            // Application object exists with the new name so use it
            NSArray *apps = [moc executeFetchRequest:getApplication error:nil];
            ApplicationMO *app = [apps objectAtIndex:0];
            aPackage.munki_name = newName;
            aPackage.hasUnstagedChangesValue = YES;
            aPackage.parentApplication = app;
        } else {
            // No existing application objects with this name so just create a new instance
            ApplicationMO *aNewApplication = [NSEntityDescription insertNewObjectForEntityForName:@"Application" inManagedObjectContext:moc];
            aNewApplication.munki_name = newName;
            aPackage.munki_name = newName;
            aPackage.hasUnstagedChangesValue = YES;
            aPackage.parentApplication = aNewApplication; // Shouldn't need this...
        }
        [getApplication release];
        
        if ([self.defaults boolForKey:@"debug"]) {
            NSString *aDescr = [NSString stringWithFormat:@"Changed package name from \"%@\" to \"%@\" in pkginfo file %@", oldName, newName, aPackage.relativePath];
            NSLog(@"%@", aDescr);
        }
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
                                 @"installer_environment",
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
                *stop = YES;
            }
        } else {
            *stop = YES;
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
            NSURL *pkgsSubURL = [installerItemsDirectory URLByAppendingPathComponent:relative];
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


- (BOOL)canImportURL:(NSURL *)fileURL error:(NSError **)error
{
    /*
     Get some file properties
     */
    NSArray *keys = [NSArray arrayWithObjects:NSURLIsPackageKey, NSURLIsDirectoryKey, NSURLIsRegularFileKey, nil];
    NSDictionary *properties = [fileURL resourceValuesForKeys:keys error:nil];
    
    NSNumber *isPackage = [properties objectForKey:NSURLIsPackageKey];
    NSNumber *isRegularFile = [properties objectForKey:NSURLIsRegularFileKey];
    
    /*
     Do a very simple check and fail if the item isn't a regular file
     */
    if (![isRegularFile boolValue]) {
        if (error) {
            NSUInteger errorCode = 1;
            NSString *description;
            NSString *recoverySuggestion;
            if ([isPackage boolValue]) {
                description = NSLocalizedString(@"File type not supported", @"");
                recoverySuggestion = NSLocalizedString(@"Bundle file packages are not supported. MunkiAdmin only supports regular files.", @"");
            } else {
                description = NSLocalizedString(@"File type not supported", @"");
                recoverySuggestion = NSLocalizedString(@"MunkiAdmin only supports regular files.", @"");
            }
            
            NSDictionary *errorDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                             description, NSLocalizedDescriptionKey,
                                             recoverySuggestion, NSLocalizedRecoverySuggestionErrorKey,
                                             nil];
            *error = [[[NSError alloc] initWithDomain:@"MunkiAdmin Import Error Domain"
                                                 code:errorCode
                                             userInfo:errorDictionary] autorelease];
        }
        return NO;
    }
    return YES;
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
