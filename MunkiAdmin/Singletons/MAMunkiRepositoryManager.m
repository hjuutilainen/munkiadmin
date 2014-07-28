//
//  MunkiRepositoryManager.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 5.12.2012.
//
//

#import "MAMunkiRepositoryManager.h"
#import "DataModelHeaders.h"
#import "MAMunkiAdmin_AppDelegate.h"
#import "MACoreDataManager.h"
#import "MADiskImageOperation.h"
#import "MAPackageExtractOperation.h"

/*
 * Private interface
 */
@interface MAMunkiRepositoryManager ()

@property (readwrite, strong) NSArray *pkginfoAssimilateKeys;
@property (readwrite, strong) NSArray *pkginfoAssimilateKeysForAuto;

@property (readwrite, strong) NSString *makepkginfoVersion;
@property (readwrite, strong) NSString *makecatalogsVersion;

@property (readwrite, strong) NSDate *saveStartedDate;

- (void)willStartOperations;
- (void)willEndOperations;
- (NSUserDefaults *)defaults;
- (void)setupMappings;

@end


@implementation MAMunkiRepositoryManager

@dynamic makecatalogsInstalled;
@dynamic makepkginfoInstalled;
@dynamic pkginfoAssimilateKeysForAuto;


# pragma mark -
# pragma mark Singleton methods

static MAMunkiRepositoryManager *sharedOperationManager = nil;
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

+ (MAMunkiRepositoryManager *)sharedManager {
    static dispatch_once_t onceQueue;
    
    dispatch_once(&onceQueue, ^{
        sharedOperationManager = [[MAMunkiRepositoryManager alloc] init];
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
            self.diskImageQueue = [NSOperationQueue new];
            self.diskImageQueue.maxConcurrentOperationCount = 1;
        }
    });
    
    self = obj;
    return self;
}

- (void)willStartOperations
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //[[(MAMunkiAdmin_AppDelegate *)[NSApp delegate] progressBar] startAnimation:nil];
    });
}

- (void)willEndOperations
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //[[(MAMunkiAdmin_AppDelegate *)[NSApp delegate] progressBar] stopAnimation:nil];
    });
}

# pragma mark -
# pragma mark Modifying items

- (BOOL)movePackage:(PackageMO *)aPackage toURL:(NSURL *)targetURL moveInstaller:(BOOL)moveInstaller
{
    BOOL returnValue = NO;
    
    //NSManagedObjectContext *moc = [aPackage managedObjectContext];
    
    NSURL *sourceURL = aPackage.packageInfoURL;
    
    /*
     Deal with the pkginfo file first
     */
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *pkginfoMoveError = nil;
    BOOL moveSucceeded = [fm moveItemAtURL:sourceURL toURL:targetURL error:&pkginfoMoveError];
    
    if (moveSucceeded) {
        /*
         File was successfully moved so update the object with a new location
         */
        [aPackage setPackageInfoURL:targetURL];
        [aPackage setPackageInfoParentDirectoryURL:[targetURL URLByDeletingLastPathComponent]];
        returnValue = YES;
    } else {
        /*
         Moving the pkginfo file failed, bail out
         */
        NSLog(@"Failed to move pkginfo with error: %@", pkginfoMoveError);
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
        MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
        NSURL *pkginfoDirectory = [appDelegate pkgsInfoURL];
        NSURL *installerItemsDirectory = [appDelegate pkgsURL];
        
        NSNumber *isDirectory;
        [[targetURL URLByDeletingLastPathComponent] getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        
        if ([isDirectory boolValue]) {
            NSString *relative = [self relativePathToChildURL:[targetURL URLByDeletingLastPathComponent] parentURL:pkginfoDirectory];
            NSURL *pkgsSubURL = [installerItemsDirectory URLByAppendingPathComponent:relative];
            if (![fm fileExistsAtPath:[pkgsSubURL path]]) {
                NSError *createError = nil;
                if (![fm createDirectoryAtURL:pkgsSubURL withIntermediateDirectories:YES attributes:nil error:&createError]) {
                    NSLog(@"%@", createError);
                }
            }
            if ([fm fileExistsAtPath:[pkgsSubURL path]]) {
                /*
                 Try to move the installer item
                 */
                NSURL *installerTargetURL = [pkgsSubURL URLByAppendingPathComponent:[installerSourceURL lastPathComponent]];
                NSError *moveError = nil;
                if (![fm moveItemAtURL:installerSourceURL toURL:installerTargetURL error:&moveError]) {
                    NSLog(@"%@", moveError);
                    returnValue = NO;
                } else {
                    /*
                     Installer item was successfully moved, update the installer_item_location key
                     */
                    NSString *newInstallerItemPath = [self relativePathToChildURL:installerTargetURL parentURL:installerItemsDirectory];
                    aPackage.munki_installer_item_location = newInstallerItemPath;
                    aPackage.packageURL = installerTargetURL;
                    returnValue = YES;
                }
            } else {
                NSLog(@"Failed to move installer item. Directory not found: %@", [pkgsSubURL path]);
                returnValue = NO;
            }
        }
    }
    
    return returnValue;
}

- (void)copyStringObjectsOfType:(NSString *)type from:(PackageMO *)source target:(PackageMO *)target
{
    NSManagedObjectContext *moc = [self appDelegateMoc];
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

- (void)copyCategoryFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc
{
    if (source.category != nil) {
        target.category = source.category;
    }
}

- (void)copyDeveloperFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc
{
    if (source.developer != nil) {
        target.developer = source.developer;
    }
}

- (void)copyIconNameFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc
{
    if (source.munki_icon_name != nil) {
        target.munki_icon_name = source.munki_icon_name;
        [self updateIconForPackage:target];
    }
}

- (void)assimilatePackage:(PackageMO *)targetPackage sourcePackage:(PackageMO *)sourcePackage keys:(NSArray *)munkiKeys
{
    NSManagedObjectContext *mainMoc = [self appDelegateMoc];
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
    NSArray *specialKeys = @[@"category", @"developer", @"icon_name"];
    
    for (NSString *keyName in munkiKeys) {
        if (![arrayKeys containsObject:keyName] && ![specialKeys containsObject:keyName] && [self.pkginfoAssimilateKeys containsObject:keyName]) {
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
            else if ([keyName isEqualToString:@"category"]) {
                [self copyCategoryFrom:sourcePackage target:targetPackage inManagedObjectContext:mainMoc];
            }
            else if ([keyName isEqualToString:@"developer"]) {
                [self copyDeveloperFrom:sourcePackage target:targetPackage inManagedObjectContext:mainMoc];
            }
            else if ([keyName isEqualToString:@"icon_name"]) {
                [self copyIconNameFrom:sourcePackage target:targetPackage inManagedObjectContext:mainMoc];
            }
        }
    }
}

- (void)assimilatePackageWithPreviousVersion:(PackageMO *)targetPackage keys:(NSArray *)munkiKeys
{
    /*
     Helper method to assimilate a package with previous version
     */
    NSManagedObjectContext *moc = [self appDelegateMoc];
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
}



- (void)moveManifest:(ManifestMO *)manifest toURL:(NSURL *)newURL cascade:(BOOL)shouldCascade
{
    NSManagedObjectContext *moc = [self appDelegateMoc];
    NSURL *currentURL = (NSURL *)manifest.manifestURL;
    NSString *oldTitle = manifest.title;
    
    if (![[NSFileManager defaultManager] moveItemAtURL:currentURL toURL:newURL error:nil]) {
        NSLog(@"Failed to rename manifest on disk");
        return;
    }
    
    // Manifest name should be the relative path from manifests subdirectory
    NSArray *manifestComponents = [newURL pathComponents];
    NSArray *manifestDirComponents = [[(MAMunkiAdmin_AppDelegate *)[NSApp delegate] manifestsURL] pathComponents];
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
                    ManifestMO *manifestReference = aReference.manifestReference;
                    aReference.title = manifestRelativePath;
                    manifestReference.hasUnstagedChangesValue = YES;
                    if ([self.defaults boolForKey:@"debug"]) {
                        NSString *aDescr = [NSString stringWithFormat:
                                            @"Renamed included_manifests reference \"%@\" to \"%@\" in manifest %@",
                                            oldTitle,
                                            aReference.title,
                                            manifestReference.title];
                        NSLog(@"%@", aDescr);
                    }
                }
                // This is a conditional nested manifest
                else if (aReference.includedManifestConditionalReference) {
                    ConditionalItemMO *conditional = aReference.includedManifestConditionalReference;
                    ManifestMO *manifestConditional = conditional.manifest;
                    aReference.title = manifestRelativePath;
                    manifestConditional.hasUnstagedChangesValue = YES;
                    if ([self.defaults boolForKey:@"debug"]) {
                        NSString *aDescr = [NSString stringWithFormat:
                                            @"Renamed included_manifests reference \"%@\" to \"%@\" in manifest \"%@\" under condition \"%@\"",
                                            oldTitle,
                                            aReference.title,
                                            manifestConditional.title,
                                            conditional.titleWithParentTitle];
                        NSLog(@"%@", aDescr);
                    }
                }
                
                
            }
        } else {
            if ([self.defaults boolForKey:@"debug"]) NSLog(@"No referencing objects to rename");
        }
    }
}


- (NSArray *)referencingPackageStringObjectsWithTitle:(NSString *)title
{
    NSArray *referencingObjects = nil;
    
    NSManagedObjectContext *moc = [self appDelegateMoc];
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
    return referencingObjects;
}


- (NSArray *)referencingManifestStringObjectsWithTitle:(NSString *)title
{
    NSArray *referencingObjects = nil;
    
    NSManagedObjectContext *moc = [self appDelegateMoc];
    NSArray *stringObjectTypes = @[@"includedManifest"];
    
    NSFetchRequest *getReferencesByName = [[NSFetchRequest alloc] init];
    [getReferencesByName setEntity:[NSEntityDescription entityForName:@"StringObject" inManagedObjectContext:moc]];
    NSPredicate *referencingPred = [NSPredicate predicateWithFormat:@"title == %@ AND typeString IN %@", title, stringObjectTypes];
    [getReferencesByName setPredicate:referencingPred];
    if ([moc countForFetchRequest:getReferencesByName error:nil] > 0) {
        referencingObjects = [moc executeFetchRequest:getReferencesByName error:nil];
    } else {
        //if ([self.defaults boolForKey:@"debug"]) NSLog(@"No referencing objects found with title \"%@\"", title);
    }
    return referencingObjects;
}


- (NSDictionary *)referencingItemsForPackage:(PackageMO *)aPackage
{
    NSString *packageName = aPackage.munki_name;
    NSString *packageNameWithVersion = aPackage.titleWithVersion;
    
    NSMutableDictionary *combined = [[NSMutableDictionary alloc] init];
    NSManagedObjectContext *moc = [self appDelegateMoc];
    
    // Get sibling packages
    NSMutableArray *packagesWithSameName = [[NSMutableArray alloc] init];
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
    if (packagesWithSameName) [combined setObject:packagesWithSameName forKey:@"packagesWithSameName"];
    
    // Manifests
    NSMutableArray *managedInstalls = [[NSMutableArray alloc] init];
    NSMutableArray *managedUninstalls = [[NSMutableArray alloc] init];
    NSMutableArray *managedUpdates = [[NSMutableArray alloc] init];
    NSMutableArray *optionalInstalls = [[NSMutableArray alloc] init];
    
    // Manifest conditional items
    NSMutableArray *conditionalManagedInstalls = [[NSMutableArray alloc] init];
    NSMutableArray *conditionalManagedUninstalls = [[NSMutableArray alloc] init];
    NSMutableArray *conditionalManagedUpdates = [[NSMutableArray alloc] init];
    NSMutableArray *conditionalOptionalInstalls = [[NSMutableArray alloc] init];
    
    // Pkginfo items
    NSMutableArray *requiresItems = [[NSMutableArray alloc] init];
    NSMutableArray *updateForItems = [[NSMutableArray alloc] init];
    
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
    NSMutableArray *managedInstallsWithVersion = [[NSMutableArray alloc] init];
    NSMutableArray *managedUninstallsWithVersion = [[NSMutableArray alloc] init];
    NSMutableArray *managedUpdatesWithVersion = [[NSMutableArray alloc] init];
    NSMutableArray *optionalInstallsWithVersion = [[NSMutableArray alloc] init];
    
    // Manifest conditional items
    NSMutableArray *conditionalManagedInstallsWithVersion = [[NSMutableArray alloc] init];
    NSMutableArray *conditionalManagedUninstallsWithVersion = [[NSMutableArray alloc] init];
    NSMutableArray *conditionalManagedUpdatesWithVersion = [[NSMutableArray alloc] init];
    NSMutableArray *conditionalOptionalInstallsWithVersion = [[NSMutableArray alloc] init];
    
    // Pkginfo items
    NSMutableArray *requiresItemsWithVersion = [[NSMutableArray alloc] init];
    NSMutableArray *updateForItemsWithVersion = [[NSMutableArray alloc] init];
    
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

- (void)removeManifest:(ManifestMO *)aManifest withReferences:(BOOL)removeReferences
{
    NSManagedObjectContext *moc = [self appDelegateMoc];
    NSString *name = aManifest.title;
    
    if (removeReferences) {
        NSArray *referencingObjects = [self referencingManifestStringObjectsWithTitle:name];
        if ([self.defaults boolForKey:@"debug"]) {
            if ((unsigned long)[referencingObjects count] > 0) {
                NSLog(@"Found %li references for manifest \"%@\"", (unsigned long)[referencingObjects count], name);
            } else {
                NSLog(@"No references found for manifest \"%@\"", name);
            }
        }
        for (StringObjectMO *aReference in referencingObjects) {
            /*
             This reference is a regular included_manifest
             */
            if (aReference.manifestReference) {
                ManifestMO *manifest = aReference.manifestReference;
                manifest.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Removed included_manifests reference \"%@\" from manifest \"%@\"", aReference.title, manifest.title];
                    NSLog(@"%@", aDescr);
                }
            }
            /*
             This reference is an included_manifest under a conditional item
             */
            else if (aReference.includedManifestConditionalReference) {
                ConditionalItemMO *cond = aReference.includedManifestConditionalReference;
                ManifestMO *manifest = aReference.includedManifestConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                if ([self.defaults boolForKey:@"debug"]) {
                    NSString *aDescr = [NSString stringWithFormat:@"Removed included_manifests reference \"%@\" from manifest \"%@\" under condition \"%@\"", aReference.title, manifest.title, cond.titleWithParentTitle];
                    NSLog(@"%@", aDescr);
                }
            }
            
            /*
             Delete the reference object from context
             */
            [moc deleteObject:aReference];
        }
    } else {
        if ([self.defaults boolForKey:@"debug"]) {
            NSLog(@"Not removing references for manifest \"%@\"", name);
        }
    }
    
    /*
     Determine the actual filesystem items to remove
     */
    NSArray *objectsToDelete = nil;
    objectsToDelete = @[aManifest.manifestURL];
    
    for (NSURL *url in objectsToDelete) {
        if ([self.defaults boolForKey:@"debug"]) {
            NSLog(@"Deleting file %@", [url relativePath]);
        }
    }
    
    /*
     Remove items
     */
    NSWorkspace *wp = [NSWorkspace sharedWorkspace];
    [wp recycleURLs:objectsToDelete completionHandler:nil];
    [moc deleteObject:aManifest];
    [moc processPendingChanges];
}

- (void)removePackage:(PackageMO *)aPackage withInstallerItem:(BOOL)removeInstallerItem withReferences:(BOOL)removeReferences
{
    NSManagedObjectContext *moc = [self appDelegateMoc];
    NSWorkspace *wp = [NSWorkspace sharedWorkspace];
    
    NSString *name = aPackage.munki_name;
    NSString *nameWithVersion = aPackage.titleWithVersion;
    
    /*
     Get the packages parent application which represents a group of packageinfos with the same name
     and get the number of other pkginfos with the same name.
     */
    ApplicationMO *packageGroup = aPackage.parentApplication;
    NSUInteger numPackagesWithThisName = [packageGroup.packages count];
    
    /*
     This is the last pkginfo with this name and we are allowed to remove references
     */
    if ((numPackagesWithThisName == 1) && removeReferences) {
        NSLog(@"Removing the last pkginfo with this name. Removing references too...");
        
        /*
         Check for and remove references to this package:
         - managed_installs item in a manifest
         - managed_uninstalls item in a manifest
         - managed_updates item in a manifest
         - optional_installs item in a manifest
         - requires item in a package
         - update_for item in a package
         */
        NSArray *referencingObjects = [self referencingPackageStringObjectsWithTitle:name];
        if ([self.defaults boolForKey:@"debug"]) {
            NSLog(@"Removing %li references with name: \"%@\"", (unsigned long)[referencingObjects count], name);
        }
        for (StringObjectMO *aReference in referencingObjects) {
            [moc deleteObject:aReference];
        }
        
        /*
         Remove versioned references too
         */
        NSArray *referencingObjectsWithVersion = [self referencingPackageStringObjectsWithTitle:nameWithVersion];
        if ([self.defaults boolForKey:@"debug"]) {
            NSLog(@"Removing %li references with name: \"%@\"", (unsigned long)[referencingObjects count], nameWithVersion);
        }
        for (StringObjectMO *aReference in referencingObjectsWithVersion) {
            [moc deleteObject:aReference];
        }
        
        /*
         Remove the icon if it is not used anymore
         */
        IconImageMO *packageIcon = aPackage.iconImage;
        if ([packageIcon.packages count] == 1) {
            if ([[packageIcon.packages anyObject] isEqualTo:aPackage] && packageIcon.originalURL != nil) {
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"Package icon doesn't have any other references, removing...");
                [wp recycleURLs:@[packageIcon.originalURL] completionHandler:nil];
                [moc deleteObject:packageIcon];
            }
        } else if ([packageIcon.packages count] > 1) {
            if ([self.defaults boolForKey:@"debug"]) NSLog(@"Package icon still has other references, leaving...");
            for (PackageMO *package in packageIcon.packages) {
                if (![package isEqualTo:aPackage]) {
                    if ([self.defaults boolForKey:@"debug"]) NSLog(@"Icon referenced from %@", package.titleWithVersion);
                }
            }
        }
    }
    
    /*
     This is the last pkginfo with this name but we were told to not touch referencing items
     */
    else if ((numPackagesWithThisName == 1) && !removeReferences) {
        NSLog(@"Removing the last pkginfo with this name but not removing any references...");
    }
    
    /*
     There are other remaining pkginfos with the same name, don't touch any references
     */
    else {
        NSLog(@"This name is used in %li other pkginfo items. Not removing references...", (unsigned long)numPackagesWithThisName - 1);
    }
    
    /*
     Determine the actual filesystem items to remove
     */
    NSArray *objectsToDelete = nil;
    if ((aPackage.packageURL != nil) && removeInstallerItem) {
        objectsToDelete = [NSArray arrayWithObjects:aPackage.packageURL, aPackage.packageInfoURL, nil];
    } else {
        objectsToDelete = [NSArray arrayWithObjects:aPackage.packageInfoURL, nil];
    }
    
    for (NSURL *url in objectsToDelete) {
        if ([self.defaults boolForKey:@"debug"]) {
            NSLog(@"Deleting file %@", [url relativePath]);
        }
    }
    
    /*
     Remove items
     */
    [wp recycleURLs:objectsToDelete completionHandler:nil];
    [moc deleteObject:aPackage];
    [moc processPendingChanges];
}


- (void)renamePackage:(PackageMO *)aPackage newName:(NSString *)newName cascade:(BOOL)shouldCascade
{
    NSManagedObjectContext *moc = [self appDelegateMoc];
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
        
        /*
         Rename the icon file if needed
         */
        if (aPackage.munki_icon_name == nil || [aPackage.munki_icon_name isEqualToString:@""]) {
            /*
             This package is not using a custom icon so it expects to find an icon using the name key
             */
            IconImageMO *iconImage = aPackage.iconImage;
            if (iconImage.originalURL != nil) {
                /*
                 And the package actually has an icon file on disk
                 */
                NSString *originalExtension = [iconImage.originalURL pathExtension];
                NSURL *newIconURL = [[[iconImage.originalURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:newName] URLByAppendingPathExtension:originalExtension];
                if (![newIconURL isEqualTo:iconImage.originalURL]) {
                    NSError *moveError;
                    if ([[NSFileManager defaultManager] moveItemAtURL:iconImage.originalURL toURL:newIconURL error:&moveError]) {
                        iconImage.originalURL = newIconURL;
                    }
                    
                    /*
                     Modify the icon_name in packages which use custom icon.
                     */
                    for (PackageMO *iconPackage in iconImage.packages) {
                        if (iconPackage.munki_icon_name != nil) {
                            [self setIconNameFromURL:newIconURL forPackage:iconPackage];
                        }
                    }
                }
            }
        }
        
        
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
        
        if ([self.defaults boolForKey:@"debug"]) {
            NSString *aDescr = [NSString stringWithFormat:@"Changed package name from \"%@\" to \"%@\" in pkginfo file %@", oldName, newName, aPackage.relativePath];
            NSLog(@"%@", aDescr);
        }
    }
}


- (IconImageMO *)createIconImageFromURL:(NSURL *)url managedObjectContext:(NSManagedObjectContext *)moc
{
    /*
     Search the context for an existing icon for the provided URL. If there's none, create a new icon object.
     Passing nil for the URL returns the default pkginfo icon (icon for .pkg file type).
     */
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"IconImage" inManagedObjectContext:moc]];
    NSPredicate *predicate;
    if (url != nil) {
        predicate = [NSPredicate predicateWithFormat:@"originalURL == %@", url];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"originalURL == %@", [NSNull null]];
    }
    [fetchRequest setPredicate:predicate];
    
    // Check the result count before fetching the actual object(s).
    NSUInteger numFound = [moc countForFetchRequest:fetchRequest error:nil];
    
    // No existing icon found, create a new one
    if (numFound == 0) {
        IconImageMO *newIconImage = [NSEntityDescription insertNewObjectForEntityForName:@"IconImage" inManagedObjectContext:moc];
        if (url != nil) {
            newIconImage.originalURL = url;
            NSImage *image = [[NSImage alloc] initByReferencingURL:url];
            newIconImage.imageRepresentation = image;
        } else {
            newIconImage.originalURL = nil;
            NSImage *pkgicon = [[NSWorkspace sharedWorkspace] iconForFileType:@"pkg"];
            newIconImage.imageRepresentation = pkgicon;
        }
        
        return newIconImage;
    }
    
    // One existing icon found, fetch and reuse it.
    else if (numFound == 1) {
        IconImageMO *existingIconImage = [[moc executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
        return existingIconImage;
    }
    
    // Something went terribly wrong if we got here...
    else {
        NSLog(@"Found multiple existing icon objects for URL. This really shouldn't happen...");
        NSLog(@"%@", [moc executeFetchRequest:fetchRequest error:nil]);
    }
    
    return nil;
}

- (void)updateIconForPackage:(PackageMO *)package
{
    NSManagedObjectContext *moc = [self appDelegateMoc];
    
    /*
     Create a default icon for packages without a custom icon
     */
    IconImageMO *defaultIcon = [self createIconImageFromURL:nil managedObjectContext:moc];
    NSImage *pkgicon = [[NSWorkspace sharedWorkspace] iconForFileType:@"pkg"];
    defaultIcon.imageRepresentation = pkgicon;
    defaultIcon.originalURL = nil;
    
    if ((package.munki_icon_name != nil) && (![package.munki_icon_name isEqualToString:@""])) {
        NSURL *iconURL = [[(MAMunkiAdmin_AppDelegate *)[NSApp delegate] iconsURL] URLByAppendingPathComponent:package.munki_icon_name];
        if ([[iconURL pathExtension] isEqualToString:@""]) {
            iconURL = [iconURL URLByAppendingPathExtension:@"png"];
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:[iconURL path]]) {
            IconImageMO *icon = [self createIconImageFromURL:iconURL managedObjectContext:moc];
            package.iconImage = icon;
        } else {
            package.iconImage = defaultIcon;
        }
    } else {
        NSURL *iconURL = [[(MAMunkiAdmin_AppDelegate *)[NSApp delegate] iconsURL] URLByAppendingPathComponent:package.munki_name];
        iconURL = [iconURL URLByAppendingPathExtension:@"png"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[iconURL path]]) {
            IconImageMO *icon = [self createIconImageFromURL:iconURL managedObjectContext:moc];
            package.iconImage = icon;
        } else {
            package.iconImage = defaultIcon;
        }
    }
}

- (void)clearCustomIconForPackage:(PackageMO *)package
{
    if (package.munki_icon_name != nil) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
            NSString *aDescr = [NSString stringWithFormat:@"Cleared custom icon_name in pkginfo file %@", package.relativePath];
            NSLog(@"%@", aDescr);
        }
        package.iconImage = nil;
        package.munki_icon_name = nil;
        package.hasUnstagedChangesValue = YES;
    } else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
            NSString *aDescr = [NSString stringWithFormat:@"Custom icon_name is already empty in pkginfo file %@", package.relativePath];
            NSLog(@"%@", aDescr);
        }
    }
    [self updateIconForPackage:package];
}

- (void)setIconNameFromURL:(NSURL *)iconURL forPackage:(PackageMO *)package
{
    NSURL *mainIconsURL = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] iconsURL];
    NSString *relativePath = [self relativePathToChildURL:iconURL parentURL:mainIconsURL];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
        NSString *aDescr = [NSString stringWithFormat:@"Changed icon_name to \"%@\" in pkginfo file %@", relativePath, package.relativePath];
        NSLog(@"%@", aDescr);
    }
    package.munki_icon_name = relativePath;
    [self updateIconForPackage:package];
    package.hasUnstagedChangesValue = YES;
}

- (void)scanIconsDirectoryForImages
{
    /*
     Go through every file in <repo>/icons directory and create an IconImage object
     if missing. Most of the files should have it already if used in any pkginfos.
     */
    NSURL *directoryURL = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] iconsURL];
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    
    NSArray *keys = @[NSURLTypeIdentifierKey, NSURLLocalizedNameKey];
    
    NSDirectoryEnumerator *dirEnum;
    NSDirectoryEnumerationOptions options = (NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles);
    dirEnum = [[NSFileManager defaultManager] enumeratorAtURL:directoryURL
                                   includingPropertiesForKeys:keys
                                                      options:options
                                                 errorHandler:^(NSURL *url, NSError *error) {
                                                     return YES;
                                                 }];
    for (NSURL *url in dirEnum) {
        /*
         Get the uniform type identifier (UTI) for the URL
         */
        NSString *typeIdentifier;
        NSError *error;
        if (![url getResourceValue:&typeIdentifier forKey:NSURLTypeIdentifierKey error:&error]) {
            NSLog(@"%@", error);
            continue;
        }
        
        /*
         If this is an image file, create an IconImage object.
         */
        if ([workspace type:typeIdentifier conformsToType:@"public.image"]) {
            [self createIconImageFromURL:url managedObjectContext:[self appDelegateMoc]];
        }
    }
}


# pragma mark -
# pragma mark Icon extraction

- (NSImage *)iconForApplicationAtURL:(NSURL *)applicationURL
{
    NSURL *appInfoPlistURL = [applicationURL URLByAppendingPathComponent:@"Contents/Info.plist"];
    NSDictionary *appInfoPlist = [NSDictionary dictionaryWithContentsOfURL:appInfoPlistURL];
    NSString *bundleIconName;
    if (appInfoPlist[@"CFBundleIconFile"]) {
        bundleIconName = appInfoPlist[@"CFBundleIconFile"];
    } else {
        bundleIconName = [[applicationURL lastPathComponent] stringByDeletingPathExtension];
    }
    NSURL *iconURL = [applicationURL URLByAppendingPathComponent:@"Contents/Resources"];
    iconURL = [iconURL URLByAppendingPathComponent:bundleIconName];
    if ([[iconURL pathExtension] isEqualToString:@""]) {
        iconURL = [iconURL URLByAppendingPathExtension:@"icns"];
    }
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:iconURL];
    NSImageRep *bestRepresentation = [image bestRepresentationForRect:NSMakeRect(0, 0, 1024.0, 1024.0) context:nil hints:nil];
    [image setSize:[bestRepresentation size]];
    return image;
}


/*
 TODO: This needs to be refactored to smaller pieces
 */
- (void)iconSuggestionsForPackage:(PackageMO *)package
                completionHandler:(void (^)(NSArray *images))completionHandler
                  progressHandler:(void (^)(double progress, NSString *description))progressHandler
{
    /*
     Get some package properties that we're going to need later
     */
    NSURL *installerItemURL = package.packageURL;
    NSString *installerType = package.munki_installer_type;
    MAMunkiRepositoryManager * __weak weakSelf = self;
    
    __block NSMutableArray *extractedImages = [NSMutableArray new];
    __block NSMutableArray *mountpointsScanned = [NSMutableArray new];
    
    void (^progressHandlerTemp)(double progress, NSString *description);
    progressHandlerTemp = ^(double progress, NSString *description){
        if (progressHandler != nil) {
            progressHandler(progress, description);
        }
    };
    
    /*
     Currently we support extraction for copy_from_dmg and installer package types
     and they obviously need to be handled very differently.
     */
    if ([installerType isEqualToString:@"copy_from_dmg"]) {
        
        /*
         Go through the items_to_copy array to see if it contains any
         application bundles. This would be the most simple extraction.
         */
        NSMutableArray *sourceItemPaths = [NSMutableArray new];
        for (ItemToCopyMO *itemToCopy in package.itemsToCopy) {
            if ([itemToCopy.munki_source_item hasSuffix:@".app"]) {
                [sourceItemPaths addObject:itemToCopy.munki_source_item];
            }
        }
        __block NSArray *blockSourceItemPaths = [NSArray arrayWithArray:sourceItemPaths];
        
        MADiskImageOperation *attachOperation = [MADiskImageOperation attachOperationWithURL:installerItemURL];
        [attachOperation setProgressCallback:progressHandlerTemp];
        
        /*
         Add a handler to be called when the image mounts.
         */
        [attachOperation setDidMountHandler:^(NSArray *mountpoints, BOOL alreadyMounted) {
            if ([blockSourceItemPaths count] > 0) {
                /*
                 This is a copy_from_dmg item with at least one
                 application bundle in the items_to_copy array. The best guess
                 at this point is to just get icons for them.
                 */
                for (NSString *mountpoint in mountpoints) {
                    for (NSString *sourceItem in blockSourceItemPaths) {
                        NSURL *mountpointURL = [NSURL fileURLWithPath:mountpoint];
                        NSURL *itemURL = [mountpointURL URLByAppendingPathComponent:sourceItem];
                        NSImage *image = [weakSelf iconForApplicationAtURL:itemURL];
                        NSDictionary *itemDict = @{@"image": image, @"URL": itemURL};
                        [extractedImages addObject:itemDict];
                    }
                    
                    if (!alreadyMounted) {
                        [mountpointsScanned addObject:mountpoint];
                    }
                }
            } else {
                /*
                 This is a copy_from_dmg item but it didn't have any application
                 bundles in its items_to_copy items. We need to scan the whole mountpoint
                 for icon (.icns) files.
                 */
                for (NSString *mountpoint in mountpoints) {
                    NSURL *mountpointURL = [NSURL fileURLWithPath:mountpoint];
                    NSArray *newImages = [weakSelf findAllIcnsFilesAtURL:mountpointURL];
                    [extractedImages addObjectsFromArray:newImages];
                    
                    if (!alreadyMounted) {
                        [mountpointsScanned addObject:mountpoint];
                    }
                }
            }
        }];
        
        /*
         Add a handler to be called when the mount operation is complete.
         This gives the extracted images to the caller for further processing.
         */
        [attachOperation setDidFinishCallback:^{
            /*
             Create detach operations for any mountpoints we created
             */
            NSMutableArray *operationsToAdd = [NSMutableArray new];
            for (NSString *mountpoint in mountpointsScanned) {
                MADiskImageOperation *detach = [MADiskImageOperation detachOperationWithMountpoints:@[mountpoint]];
                [detach setProgressCallback:progressHandlerTemp];
                [operationsToAdd addObject:detach];
            }
            
            /*
             Create block operation to call completion handler after we're all done.
             */
            NSBlockOperation *doneOp = [NSBlockOperation blockOperationWithBlock:^{
                if (completionHandler != nil) {
                    completionHandler([NSArray arrayWithArray:extractedImages]);
                }
            }];
            
            /*
             Completion handler should be called after all detach operations are
             done so create dependencies for them.
             */
            for (id operation in operationsToAdd) {
                [doneOp addDependency:operation];
            }
            [operationsToAdd addObject:doneOp];
            [weakSelf.diskImageQueue addOperations:operationsToAdd waitUntilFinished:NO];
        }];
        
        /*
         And finally run the attach operation to actually do all of the above
         */
        [weakSelf.diskImageQueue addOperation:attachOperation];
        
    }
    
    else if (installerType == nil) {
        /*
         This is an installer package type
         */
        
        NSArray *packageExtensions = @[@"pkg", @"mpkg"];
        NSArray *diskImageExtensions = @[@"dmg", @"iso"];
        
        /*
         Check if this is a package or a package wrapped in a disk image
         */
        if ([packageExtensions containsObject:[installerItemURL pathExtension]]) {
            /*
             Package (and assume it is a flat package for now)
             */
            MAPackageExtractOperation *extractOp = [MAPackageExtractOperation extractOperationWithURL:installerItemURL];
            [extractOp setProgressCallback:progressHandlerTemp];
            
            [extractOp setDidExtractHandler:^(NSURL *extractCache) {
                NSArray *newImages = [weakSelf findAllIcnsFilesAtURL:extractCache];
                [extractedImages addObjectsFromArray:newImages];
            }];
            
            [extractOp setDidFinishCallback:^{
                /*
                 Create block operation to call completion handler after we're all done.
                 */
                NSBlockOperation *doneOp = [NSBlockOperation blockOperationWithBlock:^{
                    if (completionHandler != nil) {
                        completionHandler([NSArray arrayWithArray:extractedImages]);
                    }
                }];
                [weakSelf.diskImageQueue addOperation:doneOp];
            }];
            
            /*
             And finally run the attach operation to actually do all of the above
             */
            [weakSelf.diskImageQueue addOperation:extractOp];
        }
        
        else if ([diskImageExtensions containsObject:[installerItemURL pathExtension]]) {
            /*
             This is an installer package wrapped in a disk image.
             We need to mount it first so create a mount operation and create
             an extract operation in the didMountHandler.
             */
            __block NSString *munkiPackagePath;
            if (package.munki_package_path) {
                munkiPackagePath = [NSString stringWithString:package.munki_package_path];
            }
            
            MADiskImageOperation *attachOperation = [MADiskImageOperation attachOperationWithURL:installerItemURL];
            [attachOperation setProgressCallback:progressHandlerTemp];
            
            /*
             Add a handler to be called when the image mounts.
             */
            [attachOperation setDidMountHandler:^(NSArray *mountpoints, BOOL alreadyMounted) {
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                for (NSString *mountpoint in mountpoints) {
                    
                    if ([defaults boolForKey:@"debug"]) {
                        NSLog(@"Processing mountpoint: %@", mountpoint);
                    }
                    
                    /*
                     Determine the package location
                     */
                    NSURL *packageURL = nil;
                    if (munkiPackagePath) {
                        packageURL = [[NSURL fileURLWithPath:mountpoint] URLByAppendingPathComponent:munkiPackagePath];
                    } else {
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtURL:[NSURL fileURLWithPath:mountpoint]
                                                                 includingPropertiesForKeys:@[NSURLTypeIdentifierKey]
                                                                                    options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                               errorHandler:nil];
                        
                        // An array to store the all the enumerated file names in
                        NSMutableArray *packages = [NSMutableArray array];
                        
                        // Enumerate the dirEnumerator results, each value is stored in allURLs
                        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
                        for (NSURL *theURL in dirEnumerator) {
                            NSString *typeIdentifier;
                            [theURL getResourceValue:&typeIdentifier forKey:NSURLTypeIdentifierKey error:nil];
                            //NSLog(@"%@ %@", typeIdentifier, theURL);
                            if ([workspace type:typeIdentifier conformsToType:@"com.apple.installer-package-archive"]) {
                                // Flat package
                                [packages addObject:theURL];
                            } else if ([workspace type:typeIdentifier conformsToType:@"com.apple.installer-package"]) {
                                // Bundle package (.pkg)
                                [packages addObject:theURL];
                            } else if ([workspace type:typeIdentifier conformsToType:@"com.apple.installer-meta-package"]) {
                                // Bundle package (.mpkg)
                                [packages addObject:theURL];
                            }
                        }
                        if (packages) {
                            //NSLog(@"%@", packages);
                            packageURL = packages[0];
                        }
                    }
                    
                    MAPackageExtractOperation *extractOp = [MAPackageExtractOperation extractOperationWithURL:packageURL];
                    [extractOp setProgressCallback:progressHandlerTemp];
                    
                    [extractOp setDidExtractHandler:^(NSURL *extractCache) {
                        NSArray *newImages = [self findAllIcnsFilesAtURL:extractCache];
                        [extractedImages addObjectsFromArray:newImages];
                    }];
                    
                    //[extractOp setDidFinishCallback:^{}];
                    [weakSelf.diskImageQueue addOperation:extractOp];
                    
                    if (!alreadyMounted) {
                        [mountpointsScanned addObject:mountpoint];
                    }
                }
            }];
            
            /*
             Add a handler to be called when the mount operation is complete.
             This gives the extracted images to the caller for further processing.
             */
            [attachOperation setDidFinishCallback:^{
                /*
                 Create detach operations for any mountpoints we created
                 */
                NSMutableArray *operationsToAdd = [NSMutableArray new];
                for (NSString *mountpoint in mountpointsScanned) {
                    MADiskImageOperation *detach = [MADiskImageOperation detachOperationWithMountpoints:@[mountpoint]];
                    [detach setProgressCallback:progressHandlerTemp];
                    [operationsToAdd addObject:detach];
                }
                
                /*
                 Create block operation to call completion handler after we're all done.
                 */
                NSBlockOperation *doneOp = [NSBlockOperation blockOperationWithBlock:^{
                    if (completionHandler != nil) {
                        completionHandler([NSArray arrayWithArray:extractedImages]);
                    }
                }];
                
                /*
                 Completion handler should be called after all detach operations are
                 done so create dependencies for them.
                 */
                for (id operation in operationsToAdd) {
                    [doneOp addDependency:operation];
                }
                [operationsToAdd addObject:doneOp];
                [weakSelf.diskImageQueue addOperations:operationsToAdd waitUntilFinished:NO];
            }];
            
            /*
             And finally run the attach operation to actually do all of the above
             */
            [weakSelf.diskImageQueue addOperation:attachOperation];
            
        }
    }
}

- (NSArray *)findAllIcnsFilesAtURL:(NSURL *)mountpointURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:mountpointURL
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey, NSURLTypeIdentifierKey]
                                                             options:0
                                                        errorHandler:nil];
    NSMutableArray *mutableImages = [NSMutableArray array];
    for (NSURL *fileURL in enumerator) {
        NSString *filename;
        [fileURL getResourceValue:&filename
                           forKey:NSURLNameKey
                            error:nil];
        NSNumber *isDirectory;
        [fileURL getResourceValue:&isDirectory
                           forKey:NSURLIsDirectoryKey
                            error:nil];
        NSString *typeIdentifier;
        [fileURL getResourceValue:&typeIdentifier
                           forKey:NSURLTypeIdentifierKey
                            error:nil];
        if ([workspace type:typeIdentifier conformsToType:@"com.apple.icns"]) {
            if ([defaults boolForKey:@"debug"]) {
                NSLog(@"Found com.apple.icns file: %@", [fileURL path]);
            }
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:fileURL];
            NSImageRep *bestRepresentation = [image bestRepresentationForRect:NSMakeRect(0, 0, 1024.0, 1024.0) context:nil hints:nil];
            [image setSize:[bestRepresentation size]];
            NSDictionary *itemDict = @{@"image": image, @"URL": fileURL};
            [mutableImages addObject:itemDict];
        }
    }
    return [NSArray arrayWithArray:mutableImages];
}


# pragma mark -
# pragma mark Writing to the repository

- (NSSet *)modifiedManifestsSinceLastSave
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debugLogAllProperties"]) {
		NSLog(@"Getting modified manifests since last save");
	}
    
    NSManagedObjectContext *moc = [self appDelegateMoc];
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
    NSEntityDescription *entityDescr = [NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:[self appDelegateMoc]];
    NSPredicate *unstagedChangesPredicate = [NSPredicate predicateWithFormat:@"hasUnstagedChanges == YES"];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescr];
    [fetchRequest setPredicate:unstagedChangesPredicate];
	NSArray *fetchResults = [[self appDelegateMoc] executeFetchRequest:fetchRequest error:nil];
    if ([fetchResults count] != 0) {
        [tempModifiedManifests addObjectsFromArray:fetchResults];
    }
    
    NSSet *allModifiedManifests = [NSSet setWithArray:tempModifiedManifests];
    return allModifiedManifests;
}


- (NSSet *)modifiedPackagesSinceLastSave
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debugLogAllProperties"]) {
		NSLog(@"Getting modified pkginfos since last save");
	}
    
    NSManagedObjectContext *moc = [self appDelegateMoc];
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
    NSEntityDescription *entityDescr = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:[self appDelegateMoc]];
    NSPredicate *unstagedChangesPredicate = [NSPredicate predicateWithFormat:@"hasUnstagedChanges == YES"];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescr];
    [fetchRequest setPredicate:unstagedChangesPredicate];
	NSArray *fetchResults = [[self appDelegateMoc] executeFetchRequest:fetchRequest error:nil];
    if ([fetchResults count] != 0) {
        [tempModifiedPackages addObjectsFromArray:fetchResults];
    }
    
    NSSet *allModifiedPackages = [NSSet setWithArray:tempModifiedPackages];
    return allModifiedPackages;
}

- (BOOL)repositoryHasUnstagedChanges
{
    NSUInteger numModifiedManifests = [[self modifiedManifestsSinceLastSave] count];
    NSUInteger numModifiedPackages = [[self modifiedPackagesSinceLastSave] count];
    
    if ((numModifiedPackages > 0) || (numModifiedManifests > 0)) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)backupManifest:(ManifestMO *)aManifest
{
    BOOL itemBackedUp = NO;
    
    if (self.saveStartedDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd-HHmmss"];
        NSString *formattedDateString = [dateFormatter stringFromDate:self.saveStartedDate];
        NSURL *backupDirForCurrentSave = [[self manifestBackupDirectory] URLByAppendingPathComponent:formattedDateString];
        NSURL *manifestsURL = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] manifestsURL];
        NSString *relativeManifestPath = [self relativePathToChildURL:aManifest.manifestURL parentURL:manifestsURL];
        
        NSURL *backupFileURL = [backupDirForCurrentSave URLByAppendingPathComponent:relativeManifestPath];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *dirCreateError = nil;
        if (![fm createDirectoryAtURL:[backupFileURL URLByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&dirCreateError]) {
            NSLog(@"Failed to create backup directory: %@", [dirCreateError description]);
            return NO;
        }
        
        NSError *copyError = nil;
        if (![fm copyItemAtURL:aManifest.manifestURL toURL:backupFileURL error:&copyError]) {
            NSLog(@"Failed to copy: %@", [copyError description]);
            return NO;
        } else {
            itemBackedUp = YES;
        }
    } else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"])
            NSLog(@"Error: saveStartedDate is nil");
    }
    
    return itemBackedUp;
}

- (BOOL)backupPackage:(PackageMO *)aPackage
{
    BOOL itemBackedUp = NO;
    
    NSURL *backupDirForCurrentSave = nil;
    
    if (self.saveStartedDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd-HHmmss"];
        NSString *formattedDateString = [dateFormatter stringFromDate:self.saveStartedDate];
        backupDirForCurrentSave = [[self pkginfoBackupDirectory] URLByAppendingPathComponent:formattedDateString];
        NSURL *pkgsinfoURL = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] pkgsInfoURL];
        NSString *relativePkginfoPath = [self relativePathToChildURL:aPackage.packageInfoURL parentURL:pkgsinfoURL];
        
        NSURL *backupFileURL = [backupDirForCurrentSave URLByAppendingPathComponent:relativePkginfoPath];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *dirCreateError = nil;
        if (![fm createDirectoryAtURL:[backupFileURL URLByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&dirCreateError]) {
            NSLog(@"Failed to create backup directory: %@", [dirCreateError description]);
            return NO;
        }
        
        NSError *copyError = nil;
        if (![fm copyItemAtURL:aPackage.packageInfoURL toURL:backupFileURL error:&copyError]) {
            NSLog(@"Failed to copy: %@", [copyError description]);
            return NO;
        } else {
            itemBackedUp = YES;
        }
    } else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"])
            NSLog(@"Error: saveStartedDate is nil");
    }
    
    return itemBackedUp;
}

- (NSURL *)applicationSupportDirectory
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *appSupportURL = [fm URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask][0];
    NSURL *appDirectory = [appSupportURL URLByAppendingPathComponent:@"MunkiAdmin"];
    return appDirectory;
}

- (NSURL *)backupDirectory
{
    return [[self applicationSupportDirectory] URLByAppendingPathComponent:@"Backups"];
}

- (NSURL *)pkginfoBackupDirectory
{
    return [[self applicationSupportDirectory] URLByAppendingPathComponent:@"pkgsinfo backups"];
}

- (NSURL *)manifestBackupDirectory
{
    return [[self applicationSupportDirectory] URLByAppendingPathComponent:@"manifests backups"];
}

- (BOOL)writePackagePropertyList:(NSDictionary *)plist forPackage:(PackageMO *)aPackage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"debug"]) {
        NSLog(@"Backing up pkginfo: %@", [(NSURL *)aPackage.packageInfoURL relativePath]);
    }
    
    if ([defaults boolForKey:@"backupPkginfosBeforeWriting"]) {
        [self backupPackage:aPackage];
    }
    
    if ([defaults boolForKey:@"debug"]) {
        NSLog(@"Writing new pkginfo: %@", [(NSURL *)aPackage.packageInfoURL relativePath]);
    }
    
    if ([plist writeToURL:(NSURL *)aPackage.packageInfoURL atomically:YES]) {
        aPackage.originalPkginfo = plist;
        return YES;
    } else {
        NSLog(@"Error: Failed to write %@", [(NSURL *)aPackage.packageInfoURL relativePath]);
        return NO;
    }
}

- (BOOL)writeManifestPropertyList:(NSDictionary *)plist forManifest:(ManifestMO *)aManifest
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"debug"]) {
        NSLog(@"Backing up manifest: %@", [(NSURL *)aManifest.manifestURL path]);
    }
    
    if ([defaults boolForKey:@"backupManifestsBeforeWriting"]) {
        [self backupManifest:aManifest];
    }
    
    if ([defaults boolForKey:@"debug"]) {
        NSLog(@"Writing new manifest: %@", [(NSURL *)aManifest.manifestURL path]);
    }
    
    if ([plist writeToURL:(NSURL *)aManifest.manifestURL atomically:YES]) {
        aManifest.originalManifest = plist;
        return YES;
    } else {
        NSLog(@"Error: Failed to write %@", [(NSURL *)aManifest.manifestURL path]);
        return NO;
    }
}

- (void)writePackagePropertyListsToDisk
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"Was asked to write package property lists to disk");
	}
    
    self.saveStartedDate = [NSDate date];
    
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
                                 @"category",
                                 @"description",
                                 @"developer",
                                 @"display_name",
                                 @"force_install_after_date",
                                 @"icon_name",
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
    
    self.saveStartedDate = nil;
}


- (void)writeManifestPropertyListsToDisk
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"Was asked to write manifest property lists to disk");
	}
    
    self.saveStartedDate = [NSDate date];
    
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
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debugLogAllProperties"]) {
                NSLog(@"%@ No changes in key array. Checking for value changes.", [(NSURL *)aManifest.manifestURL lastPathComponent]);
            }
            if (![mergedManifestDict isEqualToDictionary:infoDictOnDisk]) {
				if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
                    NSLog(@"Values differ. Writing new manifest: %@", [(NSURL *)aManifest.manifestURL relativePath]);
                }
                [self writeManifestPropertyList:mergedManifestDict forManifest:aManifest];
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
    
    self.saveStartedDate = nil;
}

# pragma mark -
# pragma mark Helper methods

- (NSManagedObjectContext *)appDelegateMoc
{
    return [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
}

- (NSArray *)allObjectsForEntity:(NSString *)entityName
{
	NSEntityDescription *entityDescr = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self appDelegateMoc]];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescr];
	NSArray *fetchResults = [[self appDelegateMoc] executeFetchRequest:fetchRequest error:nil];
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
    
    NSURL *pkginfoDirectory = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] pkgsInfoURL];
    NSURL *installerItemsDirectory = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] pkgsURL];
    
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
        NSTask *task = [[NSTask alloc] init];
        NSPipe *pipe = [NSPipe pipe];
        NSFileHandle *filehandle = [pipe fileHandleForReading];
        NSString *launchPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"makepkginfoPath"];
        [task setLaunchPath:launchPath];
        [task setArguments:[NSArray arrayWithObject:@"--version"]];
        [task setStandardOutput:pipe];
        [task launch];
        NSData *outputData = [filehandle readDataToEndOfFile];
        NSString *results;
        results = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        self.makepkginfoVersion = results;
    });
}

- (void)updateMakecatalogsVersionAsync
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSTask *task = [[NSTask alloc] init];
        NSPipe *pipe = [NSPipe pipe];
        NSFileHandle *filehandle = [pipe fileHandleForReading];
        NSString *launchPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"makecatalogsPath"];
        [task setLaunchPath:launchPath];
        [task setArguments:[NSArray arrayWithObject:@"--version"]];
        [task setStandardOutput:pipe];
        [task launch];
        NSData *outputData = [filehandle readDataToEndOfFile];
        NSString *results;
        results = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
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
            NSInteger errorCode = 1;
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
            *error = [[NSError alloc] initWithDomain:@"MunkiAdmin Import Error Domain"
                                                code:errorCode
                                            userInfo:errorDictionary];
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
    
    // Array keys
    NSMutableDictionary *newPkginfoArrayKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *pkginfoArrayKey in [self.defaults arrayForKey:@"pkginfoArrayKeys"]) {
		[newPkginfoArrayKeyMappings setObject:pkginfoArrayKey forKey:[NSString stringWithFormat:@"munki_%@", pkginfoArrayKey]];
	}
	self.pkginfoArrayKeyMappings = [NSDictionary dictionaryWithDictionary:newPkginfoArrayKeyMappings];
    
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
    
    [newPkginfoAssimilateKeys addObject:@"category"];
    [newPkginfoAssimilateKeys addObject:@"developer"];
    [newPkginfoAssimilateKeys addObject:@"icon_name"];
    
	self.pkginfoAssimilateKeys = [NSArray arrayWithArray:newPkginfoAssimilateKeys];
	
	// Receipt keys
	NSMutableDictionary *newReceiptKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *receiptKey in [self.defaults arrayForKey:@"receiptKeys"]) {
		[newReceiptKeyMappings setObject:receiptKey forKey:[NSString stringWithFormat:@"munki_%@", receiptKey]];
	}
	self.receiptKeyMappings = [NSDictionary dictionaryWithDictionary:newReceiptKeyMappings];
	
	// Installs item keys
	NSMutableDictionary *newInstallsKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *installsKey in [self.defaults arrayForKey:@"installsKeys"]) {
		[newInstallsKeyMappings setObject:installsKey forKey:[NSString stringWithFormat:@"munki_%@", installsKey]];
	}
	self.installsKeyMappings = [NSDictionary dictionaryWithDictionary:newInstallsKeyMappings];
	
	// items_to_copy keys
	NSMutableDictionary *newItemsToCopyKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *itemToCopy in [self.defaults arrayForKey:@"itemsToCopyKeys"]) {
		[newItemsToCopyKeyMappings setObject:itemToCopy forKey:[NSString stringWithFormat:@"munki_%@", itemToCopy]];
	}
	self.itemsToCopyKeyMappings = [NSDictionary dictionaryWithDictionary:newItemsToCopyKeyMappings];
    
    // installer_choices_xml
    NSMutableDictionary *newInstallerChoicesKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *installerChoice in [self.defaults arrayForKey:@"installerChoicesKeys"]) {
		[newInstallerChoicesKeyMappings setObject:installerChoice forKey:[NSString stringWithFormat:@"munki_%@", installerChoice]];
	}
	self.installerChoicesKeyMappings = [NSDictionary dictionaryWithDictionary:newInstallerChoicesKeyMappings];
}

- (NSArray *)pkginfoAssimilateKeysForAuto
{
    // Setup the default selection
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *keysForAutomaticAssimilation = [[NSMutableArray alloc] init];
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
