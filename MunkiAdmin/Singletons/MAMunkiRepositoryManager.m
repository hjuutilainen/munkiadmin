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
#import "MAManifestScanner.h"
#import "MAScriptRunner.h"
#import "NSImage+PixelSize.h"
#import <NSHash/NSData+NSHash.h>
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

#define kPkginfoPreSaveScriptName @"pkginfo-presave"
#define kPkginfoPostSaveScriptName @"pkginfo-postsave"

#define kManifestPreSaveScriptName @"manifest-presave"
#define kManifestPostSaveScriptName @"manifest-postsave"

#define kRepositoryPreSaveScriptName @"repository-presave"
#define kRepositoryPostSaveScriptName @"repository-postsave"

#define kRepositoryPreOpenScriptName @"repository-preopen"
#define kRepositoryPostOpenScriptName @"repository-postopen"

/*
 * Private interface
 */
@interface MAMunkiRepositoryManager ()

@property (readwrite, strong) NSArray *pkginfoAssimilateKeys;
@property (readwrite, strong) NSArray *pkginfoAssimilateKeysForAuto;

@property (readwrite, strong) NSString *makepkginfoVersion;
@property (readwrite, strong) NSString *makecatalogsVersion;

@property (readwrite, strong) NSDate *saveStartedDate;

@property (readwrite, strong) NSURL *repositoryURL;

@property (readwrite) BOOL repositoryHasPreSaveScript;
@property (readwrite) BOOL repositoryHasPostSaveScript;
@property (readwrite) BOOL repositoryHasPreOpenScript;
@property (readwrite) BOOL repositoryHasPostOpenScript;
@property (readwrite) BOOL repositoryHasPkginfoPreSaveScript;
@property (readwrite) BOOL repositoryHasPkginfoPostSaveScript;
@property (readwrite) BOOL repositoryHasManifestPreSaveScript;
@property (readwrite) BOOL repositoryHasManifestPostSaveScript;

- (void)willStartOperations;
- (void)willEndOperations;
- (NSUserDefaults *)defaults;
- (void)setupMappings;
- (BOOL)runRepositoryPreSaveScript;
- (BOOL)runRepositoryPostSaveScript;

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
            self.lengthForUniqueCatalogTitles = 1;
            self.makecatalogsRunNeeded = NO;
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
        DDLogError(@"Failed to move pkginfo with error: %@", pkginfoMoveError);
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
                    DDLogError(@"%@", createError);
                }
            }
            if ([fm fileExistsAtPath:[pkgsSubURL path]]) {
                /*
                 Try to move the installer item
                 */
                NSURL *installerTargetURL = [pkgsSubURL URLByAppendingPathComponent:[installerSourceURL lastPathComponent]];
                NSError *moveError = nil;
                if (![fm moveItemAtURL:installerSourceURL toURL:installerTargetURL error:&moveError]) {
                    DDLogError(@"%@", moveError);
                    returnValue = NO;
                } else {
                    /*
                     Installer item was successfully moved, update the installer_item_location key
                     */
                    NSString *newInstallerItemPath = [self relativePathToChildURL:installerTargetURL parentURL:installerItemsDirectory];
                    aPackage.munki_installer_item_location = newInstallerItemPath;
                    aPackage.packageURL = installerTargetURL;
                    self.makecatalogsRunNeeded = YES;
                    returnValue = YES;
                }
            } else {
                DDLogError(@"Failed to move installer item. Directory not found: %@", [pkgsSubURL path]);
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
    NSArray *arrayKeys = @[@"blocking_applications",
            @"installer_choices_xml",
            @"installs_items",
            @"requires",
            @"supported_architectures",
            @"update_for",
            @"installer_environment"];
    NSArray *stringKeys = @[@"blocking_applications",
            @"requires",
            @"supported_architectures",
            @"update_for"];
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
        DDLogInfo(@"Assimilator found zero matching Applications for package.");
    } else if (numFoundApplications == 1) {
        ApplicationMO *existingApplication = [moc executeFetchRequest:fetchForApplicationsLoose error:nil][0];
        
        // Get the latest package for comparison
        NSSortDescriptor *sortPkgsByVersion = [NSSortDescriptor sortDescriptorWithKey:@"munki_version" ascending:NO selector:@selector(localizedStandardCompare:)];
        NSArray *results = [[existingApplication packages] sortedArrayUsingDescriptors:@[sortPkgsByVersion]];
        PackageMO *latestPackage = nil;
        if ([results count] > 1) {
            if ([results[0] isEqualTo:targetPackage]) {
                latestPackage = results[1];
            } else {
                latestPackage = results[0];
            }
            DDLogInfo(@"Assimilating package with properties from: %@-%@", latestPackage.munki_name, latestPackage.munki_version);
            if (latestPackage != nil) [self assimilatePackage:targetPackage sourcePackage:latestPackage keys:munkiKeys];
        } else {
            DDLogInfo(@"No previous packages");
        }
    }
}



- (void)moveManifest:(ManifestMO *)manifest toURL:(NSURL *)newURL cascade:(BOOL)shouldCascade
{
    NSManagedObjectContext *moc = [self appDelegateMoc];
    NSURL *currentURL = (NSURL *)manifest.manifestURL;
    NSString *oldTitle = manifest.title;
    
    if (![[NSFileManager defaultManager] moveItemAtURL:currentURL toURL:newURL error:nil]) {
        DDLogError(@"Failed to rename manifest on disk");
        return;
    }
    
    // Manifest name should be the relative path from manifests subdirectory
    NSString *manifestRelativePath = [[MAMunkiRepositoryManager sharedManager] relativePathToChildURL:newURL parentURL:[(MAMunkiAdmin_AppDelegate *)[NSApp delegate] manifestsURL]];
    
    manifest.title = manifestRelativePath;
    manifest.manifestURL = newURL;
    manifest.manifestParentDirectoryURL = [newURL URLByDeletingLastPathComponent];
    DDLogInfo(@"Renamed manifest \"%@\" to \"%@\"", oldTitle, manifest.title);
    
    if (shouldCascade) {
        /*
         Rename other references which include
         - a nested manifest
         - a conditional nested manifest
         */
        NSFetchRequest *getReferencingManifests = [[NSFetchRequest alloc] init];
        [getReferencingManifests setEntity:[NSEntityDescription entityForName:@"StringObject" inManagedObjectContext:moc]];
        NSPredicate *referencingPredicate = [NSPredicate predicateWithFormat:@"title == %@ AND typeString == %@", oldTitle, @"includedManifest"];
        [getReferencingManifests setPredicate:referencingPredicate];
        if ([moc countForFetchRequest:getReferencingManifests error:nil] > 0) {
            NSArray *referencingObjects = [moc executeFetchRequest:getReferencingManifests error:nil];
            for (StringObjectMO *aReference in referencingObjects) {
                
                // This is a nested manifest under included_manifests
                if (aReference.manifestReference) {
                    ManifestMO *manifestReference = aReference.manifestReference;
                    aReference.title = manifestRelativePath;
                    manifestReference.hasUnstagedChangesValue = YES;
                    NSString *includedManifestRenameDescr = [NSString stringWithFormat:
                                        @"Renamed included_manifests reference \"%@\" to \"%@\" in manifest %@",
                                        oldTitle,
                                        aReference.title,
                                        manifestReference.title];
                    DDLogInfo(@"%@", includedManifestRenameDescr);
                }
                // This is a conditional nested manifest
                else if (aReference.includedManifestConditionalReference) {
                    ConditionalItemMO *conditional = aReference.includedManifestConditionalReference;
                    ManifestMO *manifestConditional = conditional.manifest;
                    aReference.title = manifestRelativePath;
                    manifestConditional.hasUnstagedChangesValue = YES;
                    NSString *includedManifestConditionRenameDescr = [NSString stringWithFormat:
                                        @"Renamed included_manifests reference \"%@\" to \"%@\" in manifest \"%@\" under condition \"%@\"",
                                        oldTitle,
                                        aReference.title,
                                        manifestConditional.title,
                                        conditional.titleWithParentTitle];
                    DDLogInfo(@"%@", includedManifestConditionRenameDescr);
                }
                
                
            }
        } else {
            DDLogInfo(@"No referencing objects to rename");
        }
    }
}


- (NSArray *)referencingPackageStringObjectsWithTitle:(NSString *)title
{
    NSArray *referencingObjects = nil;
    
    NSManagedObjectContext *moc = [self appDelegateMoc];
    NSArray *stringObjectTypes = @[@"managedInstall",
                                   @"managedUninstall",
                                   @"managedUpdate",
                                   @"optionalInstall",
                                   @"featuredItem",
                                   @"requires",
                                   @"updateFor"];
    
    NSFetchRequest *getReferencesByName = [[NSFetchRequest alloc] init];
    [getReferencesByName setEntity:[NSEntityDescription entityForName:@"StringObject" inManagedObjectContext:moc]];
    NSPredicate *referencingPred = [NSPredicate predicateWithFormat:@"title == %@ AND typeString IN %@", title, stringObjectTypes];
    [getReferencesByName setPredicate:referencingPred];
    if ([moc countForFetchRequest:getReferencesByName error:nil] > 0) {
        referencingObjects = [moc executeFetchRequest:getReferencesByName error:nil];
    } else {
        DDLogVerbose(@"No referencing objects found with title \"%@\"", title);
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
        DDLogVerbose(@"No referencing objects found with title \"%@\"", title);
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
    if (packagesWithSameName) combined[@"packagesWithSameName"] = packagesWithSameName;
    
    // Manifests
    NSMutableArray *managedInstalls = [[NSMutableArray alloc] init];
    NSMutableArray *managedUninstalls = [[NSMutableArray alloc] init];
    NSMutableArray *managedUpdates = [[NSMutableArray alloc] init];
    NSMutableArray *optionalInstalls = [[NSMutableArray alloc] init];
    NSMutableArray *featuredItems = [[NSMutableArray alloc] init];
    
    // Manifest conditional items
    NSMutableArray *conditionalManagedInstalls = [[NSMutableArray alloc] init];
    NSMutableArray *conditionalManagedUninstalls = [[NSMutableArray alloc] init];
    NSMutableArray *conditionalManagedUpdates = [[NSMutableArray alloc] init];
    NSMutableArray *conditionalOptionalInstalls = [[NSMutableArray alloc] init];
    NSMutableArray *conditionalFeaturedItems = [[NSMutableArray alloc] init];
    
    // Pkginfo items
    NSMutableArray *requiresItems = [[NSMutableArray alloc] init];
    NSMutableArray *updateForItems = [[NSMutableArray alloc] init];
    
    /*
     Look for references with the name key. These might include:
     - managed_installs item in a manifest
     - managed_uninstalls item in a manifest
     - managed_updates item in a manifest
     - optional_installs item in a manifest
     - featured_items item in a manifest
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
        } else if (aReference.featuredItemReference) {
            [featuredItems addObject:aReference];
        }
        
        else if (aReference.managedInstallConditionalReference) {
            [conditionalManagedInstalls addObject:aReference];
        } else if (aReference.managedUninstallConditionalReference) {
            [conditionalManagedUninstalls addObject:aReference];
        } else if (aReference.managedUpdateConditionalReference) {
            [conditionalManagedUpdates addObject:aReference];
        } else if (aReference.optionalInstallConditionalReference) {
            [conditionalOptionalInstalls addObject:aReference];
        } else if (aReference.featuredItemConditionalReference) {
            [conditionalFeaturedItems addObject:aReference];
        }
        
        else if (aReference.requiresReference) {
            [requiresItems addObject:aReference];
        } else if (aReference.updateForReference) {
            [updateForItems addObject:aReference];
        }
    }
    
    if (managedInstalls) combined[@"managedInstalls"] = managedInstalls;
    if (managedUninstalls) combined[@"managedUninstalls"] = managedUninstalls;
    if (managedUpdates) combined[@"managedUpdates"] = managedUpdates;
    if (optionalInstalls) combined[@"optionalInstalls"] = optionalInstalls;
    if (featuredItems) combined[@"featuredItems"] = featuredItems;
    
    if (conditionalManagedInstalls) combined[@"conditionalManagedInstalls"] = conditionalManagedInstalls;
    if (conditionalManagedUninstalls) combined[@"conditionalManagedUninstalls"] = conditionalManagedUninstalls;
    if (conditionalManagedUpdates) combined[@"conditionalManagedUpdates"] = conditionalManagedUpdates;
    if (conditionalOptionalInstalls) combined[@"conditionalOptionalInstalls"] = conditionalOptionalInstalls;
    if (conditionalFeaturedItems) combined[@"conditionalFeaturedItems"] = conditionalFeaturedItems;
    
    if (requiresItems) combined[@"requiresItems"] = requiresItems;
    if (updateForItems) combined[@"updateForItems"] = updateForItems;
    
    
    /*
     Look for references with the name and version key. These might include:
     - managed_installs item in a manifest
     - managed_uninstalls item in a manifest
     - managed_updates item in a manifest
     - optional_installs item in a manifest
     - featured_items item in a manifest
     - any of the above within a condition in a manifest
     - requires item in a pkginfo
     - update_for item in a pkginfo
     */
    
    // Manifests
    NSMutableArray *managedInstallsWithVersion = [[NSMutableArray alloc] init];
    NSMutableArray *managedUninstallsWithVersion = [[NSMutableArray alloc] init];
    NSMutableArray *managedUpdatesWithVersion = [[NSMutableArray alloc] init];
    NSMutableArray *optionalInstallsWithVersion = [[NSMutableArray alloc] init];
    NSMutableArray *featuredItemsWithVersion = [[NSMutableArray alloc] init];
    
    // Manifest conditional items
    NSMutableArray *conditionalManagedInstallsWithVersion = [[NSMutableArray alloc] init];
    NSMutableArray *conditionalManagedUninstallsWithVersion = [[NSMutableArray alloc] init];
    NSMutableArray *conditionalManagedUpdatesWithVersion = [[NSMutableArray alloc] init];
    NSMutableArray *conditionalOptionalInstallsWithVersion = [[NSMutableArray alloc] init];
    NSMutableArray *conditionalFeaturedItemsWithVersion = [[NSMutableArray alloc] init];
    
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
        } else if (aReference.featuredItemReference) {
            [featuredItemsWithVersion addObject:aReference];
        }
        
        else if (aReference.managedInstallConditionalReference) {
            [conditionalManagedInstallsWithVersion addObject:aReference];
        } else if (aReference.managedUninstallConditionalReference) {
            [conditionalManagedUninstallsWithVersion addObject:aReference];
        } else if (aReference.managedUpdateConditionalReference) {
            [conditionalManagedUpdatesWithVersion addObject:aReference];
        } else if (aReference.optionalInstallConditionalReference) {
            [conditionalOptionalInstallsWithVersion addObject:aReference];
        } else if (aReference.featuredItemConditionalReference) {
            [conditionalFeaturedItemsWithVersion addObject:aReference];
        }
        
        else if (aReference.requiresReference) {
            [requiresItemsWithVersion addObject:aReference];
        } else if (aReference.updateForReference) {
            [updateForItems addObject:aReference];
        }
    }
    
    if (managedInstallsWithVersion) combined[@"managedInstallsWithVersion"] = managedInstallsWithVersion;
    if (managedUninstallsWithVersion) combined[@"managedUninstallsWithVersion"] = managedUninstallsWithVersion;
    if (managedUpdatesWithVersion) combined[@"managedUpdatesWithVersion"] = managedUpdatesWithVersion;
    if (optionalInstallsWithVersion) combined[@"optionalInstallsWithVersion"] = optionalInstallsWithVersion;
    if (featuredItemsWithVersion) combined[@"featuredItemsWithVersion"] = featuredItemsWithVersion;
    
    if (conditionalManagedInstallsWithVersion) combined[@"conditionalManagedInstallsWithVersion"] = conditionalManagedInstallsWithVersion;
    if (conditionalManagedUninstallsWithVersion) combined[@"conditionalManagedUninstallsWithVersion"] = conditionalManagedUninstallsWithVersion;
    if (conditionalManagedUpdatesWithVersion) combined[@"conditionalManagedUpdatesWithVersion"] = conditionalManagedUpdatesWithVersion;
    if (conditionalOptionalInstallsWithVersion) combined[@"conditionalOptionalInstallsWithVersion"] = conditionalOptionalInstallsWithVersion;
    if (conditionalFeaturedItemsWithVersion) combined[@"conditionalFeaturedItemsWithVersion"] = conditionalFeaturedItemsWithVersion;
    
    if (requiresItemsWithVersion) combined[@"requiresItemsWithVersion"] = requiresItemsWithVersion;
    if (updateForItemsWithVersion) combined[@"updateForItemsWithVersion"] = updateForItemsWithVersion;
    
    
    if (combined) {
        return [NSDictionary dictionaryWithDictionary:combined];
    } else {
        return nil;
    }
}

- (BOOL)copyPropertiesFromManifest:(ManifestMO *)sourceManifest toManifest:(ManifestMO *)targetManifest inManagedObjectContext:(NSManagedObjectContext *)context
{
    BOOL succeeded = NO;
    
    return succeeded;
}

- (BOOL)duplicateManifest:(ManifestMO *)manifest
{
    BOOL succeeded = NO;
    
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    NSString *title = NSLocalizedString(@"Save Manifest", @"");
    savePanel.title = title;
    savePanel.directoryURL = [[manifest manifestURL] URLByDeletingLastPathComponent];
    [savePanel setNameFieldStringValue:[[manifest manifestURL] lastPathComponent]];
    
    if ([savePanel runModal] == NSFileHandlingPanelOKButton)
    {
        NSURL *newURL = [savePanel URL];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *copyError = nil;
        if ([fm copyItemAtURL:manifest.manifestURL toURL:newURL error:&copyError]) {
            /*
             Set date attributes of the new item to current date and time.
             */
            NSDate *now = [NSDate date];
            [newURL setResourceValues:@{NSURLCreationDateKey: now, NSURLContentAccessDateKey: now, NSURLContentModificationDateKey: now} error:nil];
            
            /*
             Scan the new item
             */
            MAManifestScanner *manifestScanner = [[MAManifestScanner alloc] initWithURL:newURL];
            manifestScanner.delegate = [NSApp delegate];
            manifestScanner.performFullScan = YES;
            [manifestScanner start];
            succeeded = YES;
        } else {
            DDLogError(@"Copying failed with error: %@", [copyError description]);
            [NSApp presentError:copyError];
        }
    } else {
        return NO;
    }
    
    
    return succeeded;
}

- (BOOL)duplicateManifest:(ManifestMO *)manifest toURL:(NSURL *)newURL
{
    BOOL succeeded = NO;
    
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
        
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *copyError = nil;
    if ([fm copyItemAtURL:manifest.manifestURL toURL:newURL error:&copyError]) {
        /*
         Set date attributes of the new item to current date and time.
         */
        NSDate *now = [NSDate date];
        [newURL setResourceValues:@{NSURLCreationDateKey: now, NSURLContentAccessDateKey: now, NSURLContentModificationDateKey: now} error:nil];
        
        /*
         Scan the new item
         */
        MAManifestScanner *manifestScanner = [[MAManifestScanner alloc] initWithURL:newURL];
        manifestScanner.delegate = [NSApp delegate];
        manifestScanner.performFullScan = YES;
        [manifestScanner start];
        succeeded = YES;
    } else {
        DDLogError(@"Copying failed with error: %@", [copyError description]);
        [NSApp presentError:copyError];
    }
    
    
    return succeeded;
}

- (void)removeManifest:(ManifestMO *)aManifest withReferences:(BOOL)removeReferences
{
    NSManagedObjectContext *moc = [self appDelegateMoc];
    NSString *name = aManifest.title;
    
    if (removeReferences) {
        NSArray *referencingObjects = [self referencingManifestStringObjectsWithTitle:name];
        if ([self.defaults boolForKey:@"debug"]) {
            if ((unsigned long)[referencingObjects count] > 0) {
                DDLogInfo(@"Found %li references for manifest \"%@\"", (unsigned long)[referencingObjects count], name);
            } else {
                DDLogInfo(@"No references found for manifest \"%@\"", name);
            }
        }
        for (StringObjectMO *aReference in referencingObjects) {
            /*
             This reference is a regular included_manifest
             */
            if (aReference.manifestReference) {
                ManifestMO *manifest = aReference.manifestReference;
                manifest.hasUnstagedChangesValue = YES;
                DDLogInfo(@"Removed included_manifests reference \"%@\" from manifest \"%@\"", aReference.title, manifest.title);
            }
            /*
             This reference is an included_manifest under a conditional item
             */
            else if (aReference.includedManifestConditionalReference) {
                ConditionalItemMO *cond = aReference.includedManifestConditionalReference;
                ManifestMO *manifest = aReference.includedManifestConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                DDLogInfo(@"Removed included_manifests reference \"%@\" from manifest \"%@\" under condition \"%@\"", aReference.title, manifest.title, cond.titleWithParentTitle);
            }
            
            /*
             Delete the reference object from context
             */
            [moc deleteObject:aReference];
        }
    } else {
        DDLogInfo(@"Not removing references for manifest \"%@\"", name);
    }
    
    /*
     Determine the actual filesystem items to remove
     */
    NSArray *objectsToDelete = nil;
    objectsToDelete = @[aManifest.manifestURL];
    
    for (NSURL *url in objectsToDelete) {
        DDLogInfo(@"Deleting file %@", [url relativePath]);
    }
    
    /*
     Remove items
     */
    NSWorkspace *wp = [NSWorkspace sharedWorkspace];
    [wp recycleURLs:objectsToDelete completionHandler:nil];
    [moc deleteObject:aManifest];
    [moc processPendingChanges];
}

- (void)removePackages:(NSArray *)packages withInstallerItem:(BOOL)removeInstallerItem withReferences:(BOOL)removeReferences
{
    NSManagedObjectContext *moc = [self appDelegateMoc];
    NSWorkspace *wp = [NSWorkspace sharedWorkspace];
    [[moc undoManager] beginUndoGrouping];
    NSMutableArray *objectsToDelete = [[NSMutableArray alloc] init];
    
    for (PackageMO *aPackage in packages) {
        
        NSString *name = aPackage.munki_name;
        NSString *nameWithVersion = aPackage.titleWithVersion;
        
        /*
         Get the packages parent application which represents a group of packageinfos with the same name
         and get the number of other pkginfos with the same name.
         */
        ApplicationMO *packageGroup = aPackage.parentApplication;
        [moc refreshObject:packageGroup mergeChanges:YES];
        NSUInteger numPackagesWithThisName = [packageGroup.packages count];
        
        /*
         This is the last pkginfo with this name and we are allowed to remove references
         */
        if ((numPackagesWithThisName == 1) && removeReferences) {
            DDLogInfo(@"Removing the last pkginfo with this name. Removing references too...");
            
            /*
             Check for and remove references to this package:
             - managed_installs item in a manifest
             - managed_uninstalls item in a manifest
             - managed_updates item in a manifest
             - optional_installs item in a manifest
             - featured_items item in a manifest
             - requires item in a package
             - update_for item in a package
             */
            NSArray *referencingObjects = [self referencingPackageStringObjectsWithTitle:name];
            DDLogInfo(@"Removing %li references with name: \"%@\"", (unsigned long)[referencingObjects count], name);
            for (StringObjectMO *aReference in referencingObjects) {
                [moc deleteObject:aReference];
            }
            
            /*
             Remove versioned references too
             */
            NSArray *referencingObjectsWithVersion = [self referencingPackageStringObjectsWithTitle:nameWithVersion];
            DDLogInfo(@"Removing %li references with name: \"%@\"", (unsigned long)[referencingObjects count], nameWithVersion);
            for (StringObjectMO *aReference in referencingObjectsWithVersion) {
                [moc deleteObject:aReference];
            }
            
            /*
             Remove the icon if it is not used anymore
             */
            IconImageMO *packageIcon = aPackage.iconImage;
            if ([packageIcon.packages count] == 1) {
                if ([[packageIcon.packages anyObject] isEqualTo:aPackage] && packageIcon.originalURL != nil) {
                    DDLogInfo(@"Package icon doesn't have any other references, removing...");
                    [objectsToDelete addObject:packageIcon.originalURL];
                    [moc deleteObject:packageIcon];
                }
            } else if ([packageIcon.packages count] > 1) {
                DDLogInfo(@"Package icon still has other references, leaving...");
                for (PackageMO *package in packageIcon.packages) {
                    if (![package isEqualTo:aPackage]) {
                        DDLogInfo(@"Icon referenced from %@", package.titleWithVersion);
                    }
                }
            }
        }
        
        /*
         This is the last pkginfo with this name but we were told to not touch referencing items
         */
        else if ((numPackagesWithThisName == 1) && !removeReferences) {
            DDLogInfo(@"Removing the last pkginfo with this name but not removing any references...");
        }
        
        /*
         There are other remaining pkginfos with the same name, don't touch any references
         */
        else {
            DDLogInfo(@"This name is used in %li other pkginfo items. Not removing references...", (unsigned long)numPackagesWithThisName - 1);
        }
        
        /*
         Determine the actual filesystem items to remove
         */
        
        if ((aPackage.packageURL != nil) && removeInstallerItem) {
            /*
             Check if there are other pkginfos that reference the installer item
             */
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"packageURL == %@", aPackage.packageURL];
            [fetchRequest setPredicate:predicate];
            if ([moc countForFetchRequest:fetchRequest error:nil] > 1) {
                DDLogInfo(@"The installer item is referenced by other packages. Should only remove the pkginfo file...");
                for (PackageMO *foundPackage in [moc executeFetchRequest:fetchRequest error:nil]) {
                    if (![foundPackage isEqualTo:aPackage]) {
                        DDLogInfo(@"Installer item referenced from %@", foundPackage.titleWithVersion);
                    }
                }
                [objectsToDelete addObject:aPackage.packageInfoURL];
            } else {
                [objectsToDelete addObjectsFromArray:@[aPackage.packageURL, aPackage.packageInfoURL]];
            }
        } else {
            [objectsToDelete addObject:aPackage.packageInfoURL];
        }
        
        if ((aPackage.uninstallerItemURL != nil) && removeInstallerItem) {
            /*
             Check if there are other pkginfos that reference the uninstaller item
             */
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uninstallerItemURL == %@", aPackage.uninstallerItemURL];
            [fetchRequest setPredicate:predicate];
            if ([moc countForFetchRequest:fetchRequest error:nil] > 1) {
                DDLogInfo(@"The uninstaller item is referenced by other packages. Should not remove it...");
                for (PackageMO *foundPackage in [moc executeFetchRequest:fetchRequest error:nil]) {
                    if (![foundPackage isEqualTo:aPackage]) {
                        DDLogInfo(@"Installer item referenced from %@", foundPackage.titleWithVersion);
                    }
                }
            } else {
                [objectsToDelete addObject:aPackage.uninstallerItemURL];
            }
        }
        
        /*
         Check that the files actually exist on disk before trying to remove them
         */
        NSFileManager *fm = [NSFileManager defaultManager];
        NSMutableArray *fileURLsNotFoundOndisk = [NSMutableArray new];
        for (NSURL *fileURL in objectsToDelete) {
            if (![fm fileExistsAtPath:[fileURL path]]) {
                DDLogInfo(@"Not trying to remove non-existent file: %@", [fileURL path]);
                [fileURLsNotFoundOndisk addObject:fileURL];
            }
        }
        if ([fileURLsNotFoundOndisk count] > 0) {
            [objectsToDelete removeObjectsInArray:fileURLsNotFoundOndisk];
        }
        
        [packageGroup removePackagesObject:aPackage];
        [moc deleteObject:aPackage];
    }

    for (NSURL *url in objectsToDelete) {
        DDLogInfo(@"Will delete file %@", [url relativePath]);
    }
    
    /*
     Remove items
     */
    [wp recycleURLs:objectsToDelete completionHandler:^(NSDictionary *newURLs, NSError *error) {
        
        [[moc undoManager] endUndoGrouping];
        
        if (error) {
            /*
             Undo everything we just did
             */
            [[moc undoManager] undo];
            [moc processPendingChanges];
            
            /*
             Check if we moved anything and if so, try to recover
             */
            DDLogVerbose(@"NSWorkspace recycleURLs returned: %@", newURLs);
            [newURLs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSURL *originalURL = key;
                NSURL *recycledURL = obj;
                NSError *moveBackError = nil;
                if (![[NSFileManager defaultManager] moveItemAtURL:recycledURL toURL:originalURL error:&moveBackError]) {
                    DDLogError(@"Failed to restore %@ to %@", recycledURL, originalURL);
                } else {
                    DDLogDebug(@"Restored %@ to %@", recycledURL, originalURL);
                }
            }];
            
            /*
             Display an error
             */
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert runModal];
            });
        } else {
            for (NSURL *url in objectsToDelete) {
                DDLogDebug(@"Successfully deleted %@", [url relativePath]);
            }
        }
    }];
    
    self.makecatalogsRunNeeded = YES;
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
            ApplicationMO *app = apps[0];
            DDLogInfo(@"Found ApplicationMO: %@", app.munki_name);
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
        
        DDLogInfo(@"Changed package name from \"%@\" to \"%@\" in pkginfo file %@", oldName, newName, aPackage.relativePath);
        
        // Get sibling packages
        NSFetchRequest *getSiblings = [[NSFetchRequest alloc] init];
        [getSiblings setEntity:[NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc]];
        NSPredicate *siblingPred = [NSPredicate predicateWithFormat:@"parentApplication == %@", packageGroup];
        [getSiblings setPredicate:siblingPred];
        if ([moc countForFetchRequest:getSiblings error:nil] > 0) {
            NSArray *siblingPackages = [moc executeFetchRequest:getSiblings error:nil];
            for (PackageMO *aSibling in siblingPackages) {
                if (aSibling != aPackage) {
                    DDLogInfo(@"Changed package name from \"%@\" to \"%@\" in pkginfo file %@", aSibling.munki_name, newName, aSibling.relativePath);
                    
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
         - featured_items item in a manifest
         - requires item in a package
         - update_for item in a package
         */
        NSArray *referencingObjects = [self referencingPackageStringObjectsWithTitle:oldName];
        for (StringObjectMO *aReference in referencingObjects) {
            
            // Change the name
            aReference.title = newName;
            NSString *logMessage;
            if (aReference.managedInstallReference) {
                ManifestMO *manifest = aReference.managedInstallReference;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed managed_installs reference \"%@\" to \"%@\" in manifest %@", oldName, aReference.title, manifest.title];
            } else if (aReference.managedUninstallReference) {
                ManifestMO *manifest = aReference.managedUninstallReference;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed managed_uninstalls reference \"%@\" to \"%@\" in manifest %@", oldName, aReference.title, manifest.title];
            } else if (aReference.managedUpdateReference) {
                ManifestMO *manifest = aReference.managedUpdateReference;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed managed_updates reference \"%@\" to \"%@\" in manifest %@", oldName, aReference.title, manifest.title];
            } else if (aReference.optionalInstallReference) {
                ManifestMO *manifest = aReference.optionalInstallReference;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed optional_installs reference \"%@\" to \"%@\" in manifest %@", oldName, aReference.title, manifest.title];
            } else if (aReference.featuredItemReference) {
                ManifestMO *manifest = aReference.featuredItemReference;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed featured_items reference \"%@\" to \"%@\" in manifest %@", oldName, aReference.title, manifest.title];
            }
            
            else if (aReference.managedInstallConditionalReference) {
                ConditionalItemMO *cond = aReference.managedInstallConditionalReference;
                ManifestMO *manifest = aReference.managedInstallConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed managed_installs reference \"%@\" to \"%@\" in manifest %@ under condition \"%@\"", oldName, aReference.title, manifest.title, cond.titleWithParentTitle];
                
            } else if (aReference.managedUninstallConditionalReference) {
                ConditionalItemMO *cond = aReference.managedUninstallConditionalReference;
                ManifestMO *manifest = aReference.managedUninstallConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed managed_uninstalls reference \"%@\" to \"%@\" in manifest %@ under condition \"%@\"", oldName, aReference.title, manifest.title, cond.titleWithParentTitle];
            } else if (aReference.managedUpdateConditionalReference) {
                ConditionalItemMO *cond = aReference.managedUpdateConditionalReference;
                ManifestMO *manifest = aReference.managedUpdateConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed managed_updates reference \"%@\" to \"%@\" in manifest %@ under condition \"%@\"", oldName, aReference.title, manifest.title, cond.titleWithParentTitle];
            } else if (aReference.optionalInstallConditionalReference) {
                ConditionalItemMO *cond = aReference.optionalInstallConditionalReference;
                ManifestMO *manifest = aReference.optionalInstallConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed optional_installs reference \"%@\" to \"%@\" in manifest %@ under condition \"%@\"", oldName, aReference.title, manifest.title, cond.titleWithParentTitle];
            } else if (aReference.featuredItemConditionalReference) {
                ConditionalItemMO *cond = aReference.featuredItemConditionalReference;
                ManifestMO *manifest = aReference.featuredItemConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed featured_items reference \"%@\" to \"%@\" in manifest %@ under condition \"%@\"", oldName, aReference.title, manifest.title, cond.titleWithParentTitle];
            }
            
            else if (aReference.requiresReference) {
                PackageMO *package = aReference.requiresReference;
                package.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed requires reference \"%@\" to \"%@\" in package %@", oldName, aReference.title, package.titleWithVersion];
                
            } else if (aReference.updateForReference) {
                PackageMO *package = aReference.updateForReference;
                package.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed requires reference \"%@\" to \"%@\" in package %@", oldName, aReference.title, package.titleWithVersion];
            }
            DDLogDebug(@"%@", logMessage);
        }
        
        
        NSArray *referencingObjectsWithVersion = [self referencingPackageStringObjectsWithTitle:oldNameWithVersion];
        for (StringObjectMO *aReference in referencingObjectsWithVersion) {
            
            // Change the name
            aReference.title = aPackage.titleWithVersion;
            NSString *logMessage;
            if (aReference.managedInstallReference) {
                ManifestMO *manifest = aReference.managedInstallReference;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed managed_installs reference \"%@\" to \"%@\" in manifest %@", oldNameWithVersion, aReference.title, manifest.title];
            } else if (aReference.managedUninstallReference) {
                ManifestMO *manifest = aReference.managedUninstallReference;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed managed_uninstalls reference \"%@\" to \"%@\" in manifest %@", oldNameWithVersion, aReference.title, manifest.title];
            } else if (aReference.managedUpdateReference) {
                ManifestMO *manifest = aReference.managedUpdateReference;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed managed_updates reference \"%@\" to \"%@\" in manifest %@", oldNameWithVersion, aReference.title, manifest.title];
            } else if (aReference.optionalInstallReference) {
                ManifestMO *manifest = aReference.optionalInstallReference;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed optional_installs reference \"%@\" to \"%@\" in manifest %@", oldNameWithVersion, aReference.title, manifest.title];
            } else if (aReference.featuredItemReference) {
                ManifestMO *manifest = aReference.featuredItemReference;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed featured_items reference \"%@\" to \"%@\" in manifest %@", oldNameWithVersion, aReference.title, manifest.title];
            }
            
            else if (aReference.managedInstallConditionalReference) {
                ConditionalItemMO *cond = aReference.managedInstallConditionalReference;
                ManifestMO *manifest = aReference.managedInstallConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed managed_installs reference \"%@\" to \"%@\" in manifest %@ under condition \"%@\"", oldNameWithVersion, aReference.title, manifest.title, cond.titleWithParentTitle];
            } else if (aReference.managedUninstallConditionalReference) {
                ConditionalItemMO *cond = aReference.managedUninstallConditionalReference;
                ManifestMO *manifest = aReference.managedUninstallConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed managed_uninstalls reference \"%@\" to \"%@\" in manifest %@ under condition \"%@\"", oldNameWithVersion, aReference.title, manifest.title, cond.titleWithParentTitle];
            } else if (aReference.managedUpdateConditionalReference) {
                ConditionalItemMO *cond = aReference.managedUpdateConditionalReference;
                ManifestMO *manifest = aReference.managedUpdateConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed managed_updates reference \"%@\" to \"%@\" in manifest %@ under condition \"%@\"", oldNameWithVersion, aReference.title, manifest.title, cond.titleWithParentTitle];
            } else if (aReference.optionalInstallConditionalReference) {
                ConditionalItemMO *cond = aReference.optionalInstallConditionalReference;
                ManifestMO *manifest = aReference.optionalInstallConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed optional_installs reference \"%@\" to \"%@\" in manifest %@ under condition \"%@\"", oldNameWithVersion, aReference.title, manifest.title, cond.titleWithParentTitle];
            } else if (aReference.featuredItemConditionalReference) {
                ConditionalItemMO *cond = aReference.featuredItemConditionalReference;
                ManifestMO *manifest = aReference.featuredItemConditionalReference.manifest;
                manifest.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed featured_items reference \"%@\" to \"%@\" in manifest %@ under condition \"%@\"", oldNameWithVersion, aReference.title, manifest.title, cond.titleWithParentTitle];
            }
            
            else if (aReference.requiresReference) {
                PackageMO *package = aReference.requiresReference;
                package.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed requires reference \"%@\" to \"%@\" in package %@", oldNameWithVersion, aReference.title, package.titleWithVersion];
                
            } else if (aReference.updateForReference) {
                PackageMO *package = aReference.updateForReference;
                package.hasUnstagedChangesValue = YES;
                logMessage = [NSString stringWithFormat:@"Renamed requires reference \"%@\" to \"%@\" in package %@", oldNameWithVersion, aReference.title, package.titleWithVersion];
            }
            DDLogDebug(@"%@", logMessage);
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
            ApplicationMO *app = apps[0];
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
        
        DDLogDebug(@"Changed package name from \"%@\" to \"%@\" in pkginfo file %@", oldName, newName, aPackage.relativePath);
    }
    
    self.makecatalogsRunNeeded = YES;
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
            DDLogVerbose(@"Creating new icon object from %@", [url path]);
            newIconImage.originalURL = url;
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            NSImage *image = [[NSImage alloc] initWithData:imageData];
            newIconImage.imageRepresentation = image;
        } else {
            DDLogVerbose(@"Creating new icon object for pkg file type");
            newIconImage.originalURL = nil;
            NSImage *pkgicon = [[NSWorkspace sharedWorkspace] iconForFileType:@"pkg"];
            newIconImage.imageRepresentation = pkgicon;
        }
        
        return newIconImage;
    }
    
    // One existing icon found, fetch and reuse it.
    else if (numFound == 1) {
        if (url) {
            DDLogVerbose(@"Reusing existing icon object for %@", [url path]);
        } else {
            DDLogVerbose(@"Reusing existing icon object for pkg file type");
        }
        
        IconImageMO *existingIconImage = [moc executeFetchRequest:fetchRequest error:nil][0];
        return existingIconImage;
    }
    
    // Something went terribly wrong if we got here...
    else {
        DDLogWarn(@"Found multiple existing icon objects for URL. This really shouldn't happen...");
        DDLogWarn(@"%@", [moc executeFetchRequest:fetchRequest error:nil]);
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

- (NSString *)calculateSHA256HashForData:(NSData *)data
{
    NSData *sha256Data = [data SHA256];
    NSUInteger dataLength = [sha256Data length];
    NSMutableString *iconSHA256HashString = [NSMutableString stringWithCapacity:dataLength*2];
    const unsigned char *dataBytes = [sha256Data bytes];
    for (NSUInteger idx = 0; idx < dataLength; ++idx) {
        [iconSHA256HashString appendFormat:@"%02x", dataBytes[idx]];
    }
    return iconSHA256HashString;
}

- (NSString *)calculateSHA256HashForURL:(NSURL *)url
{
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:[url path]]) {
        return nil;
    }
    
    NSData *iconData = [NSData dataWithContentsOfURL:url];
    return [self calculateSHA256HashForData:iconData];
}

- (void)deleteIconHashForPackage:(PackageMO *)package
{
    DDLogDebug(@"%@: Removing icon_hash for package...", package.titleWithVersion);
    
    /*
     Setting the value to nil causes the whole key to be deleted
     */
    package.munki_icon_hash = nil;
}

- (void)updateIconHashForPackage:(PackageMO *)package
{
    DDLogDebug(@"%@: Updating icon_hash for package...", package.titleWithVersion);
    
    /*
     Get the current icon_hash
     */
    NSString *originalIconHash = package.munki_icon_hash;
    
    /*
     Get the hash for the icon file on disk. This may be nil if
     the package doesn't have an icon.
     */
    NSString *iconImageFileHash = nil;
    if (package.iconImage.originalURL) {
        iconImageFileHash = [self calculateSHA256HashForURL:package.iconImage.originalURL];
    }
    
    /*
     If we have a hash, update it
     */
    if (iconImageFileHash) {
        package.munki_icon_hash = iconImageFileHash;
    }
    
    if (package.munki_icon_hash && (![originalIconHash isEqualToString:package.munki_icon_hash])) {
        DDLogInfo(@"%@: Updated icon_hash to %@", package.titleWithVersion, package.munki_icon_hash);
    }
    
    package.hasUnstagedChangesValue = YES;
}

- (void)clearCustomIconForPackage:(PackageMO *)package
{
    if (package.munki_icon_name != nil) {
        DDLogDebug(@"Cleared custom icon_name in pkginfo file %@", package.relativePath);
        
        package.iconImage = nil;
        package.munki_icon_name = nil;
        package.hasUnstagedChangesValue = YES;
    } else {
        DDLogDebug(@"Custom icon_name is already empty in pkginfo file %@", package.relativePath);
    }
    [self updateIconForPackage:package];
}

- (void)setIconNameFromURL:(NSURL *)iconURL forPackage:(PackageMO *)package
{
    NSURL *mainIconsURL = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] iconsURL];
    NSString *relativePath = [self relativePathToChildURL:iconURL parentURL:mainIconsURL];
    DDLogInfo(@"Changed icon_name to \"%@\" in pkginfo file %@", relativePath, package.relativePath);
    
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
            DDLogInfo(@"%@: %@", THIS_METHOD, error);
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
    /*
     Extract icon from an .app bundle. It would've been a lot easier (and cleaner) to just use:
     
        [[NSWorkSpace sharedWorkspace] iconForFile:applicationURL]
        or
        [applicationURL getResourceValue:&iconImage forKey:NSURLEffectiveIconKey error:&error]
     
     but neither of those get the actual icon right when just quickly attaching and detaching the image.
     The only solution that works is to find and read the app icon manually from file.
     */
    
    NSBundle *appBundle = [NSBundle bundleWithURL:applicationURL];
    NSString *bundleIconName = [appBundle objectForInfoDictionaryKey:@"CFBundleIconFile"];
    if (!bundleIconName) {
        return nil;
    }
    
    NSURL *iconURL;
    if ([[bundleIconName pathExtension] isEqualToString:@""]) {
        iconURL = [appBundle URLForResource:bundleIconName withExtension:@"icns"];
    } else if ([[bundleIconName pathExtension] isEqualToString:@"icns"]) {
        iconURL = [appBundle URLForResource:bundleIconName withExtension:nil];
    }
    
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:iconURL];
    [image setSize:[image pixelSize]];
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
                        if (image) {
                            NSDictionary *itemDict = @{@"image": image, @"URL": itemURL};
                            [extractedImages addObject:itemDict];
                        }
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
                
                for (NSString *mountpoint in mountpoints) {
                    
                    DDLogInfo(@"Processing mountpoint: %@", mountpoint);
                    
                    /*
                     Determine the package location
                     */
                    NSURL *packageURL = nil;
                    if (munkiPackagePath) {
                        // The pkginfo file had custom package path, extract that
                        packageURL = [[NSURL fileURLWithPath:mountpoint] URLByAppendingPathComponent:munkiPackagePath];
                    } else {
                        // Look for installer packages in the mount point directory
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtURL:[NSURL fileURLWithPath:mountpoint]
                                                                 includingPropertiesForKeys:@[NSURLTypeIdentifierKey]
                                                                                    options:(NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsPackageDescendants)
                                                                               errorHandler:nil];
                        
                        // An array to store the all the enumerated file names in
                        NSMutableArray *packages = [NSMutableArray array];
                        
                        // Enumerate the dirEnumerator results
                        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
                        for (NSURL *theURL in dirEnumerator) {
                            // Skip any subdirectories
                            NSNumber *isDirectory = nil;
                            [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
                            if ([isDirectory boolValue]) {
                                [dirEnumerator skipDescendants];
                            }
                            // Regular file, check the type identifier
                            else {
                                NSString *typeIdentifier;
                                [theURL getResourceValue:&typeIdentifier forKey:NSURLTypeIdentifierKey error:nil];
                                //DDLogInfo(@"%@ %@", typeIdentifier, theURL);
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
                        }
                        if ([packages count] > 0) {
                            DDLogInfo(@"%@", packages);
                            packageURL = [packages sortedArrayUsingSelector:@selector(compare:)][0];
                        }
                    }
                    if (packageURL) {
                        MAPackageExtractOperation *extractOp = [MAPackageExtractOperation extractOperationWithURL:packageURL];
                        [extractOp setProgressCallback:progressHandlerTemp];
                        
                        [extractOp setDidExtractHandler:^(NSURL *extractCache) {
                            NSArray *newImages = [self findAllIcnsFilesAtURL:extractCache];
                            [extractedImages addObjectsFromArray:newImages];
                        }];
                        
                        [weakSelf.diskImageQueue addOperation:extractOp];
                    } else {
                        DDLogInfo(@"Error: Did not find any packages in mountpoint %@", mountpoint);
                    }
                    
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
    } else {
        /*
         Unsupported pkginfo type. Call completion handler with nil results.
         */
        NSBlockOperation *doneOp = [NSBlockOperation blockOperationWithBlock:^{
            if (completionHandler != nil) {
                completionHandler(nil);
            }
        }];
        
        [weakSelf.diskImageQueue addOperation:doneOp];
    }
}

- (NSArray *)findAllIcnsFilesAtURL:(NSURL *)mountpointURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
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
            DDLogInfo(@"Found com.apple.icns file: %@", [fileURL path]);
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:fileURL];
            [image setSize:[image pixelSize]];
            NSDictionary *itemDict = @{@"image": image, @"URL": fileURL};
            [mutableImages addObject:itemDict];
        }
    }
    return [NSArray arrayWithArray:mutableImages];
}

# pragma mark -
# pragma mark Script support

- (NSURL *)repositorySupportDirectory
{
    MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
    NSURL *mainRepoURL;
    if (self.repositoryURL) {
        mainRepoURL = self.repositoryURL;
    } else {
        mainRepoURL = [appDelegate repoURL];
        self.repositoryURL = [appDelegate repoURL];
    }
    NSURL *munkiAdminRepoURL = [mainRepoURL URLByAppendingPathComponent:@"MunkiAdmin"];
    return munkiAdminRepoURL;
}

- (NSURL *)repositoryScriptsDirectory
{
    return [[self repositorySupportDirectory] URLByAppendingPathComponent:@"scripts"];
}

- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"MunkiAdmin"];
}

- (NSURL *)applicationScriptsDirectory
{
    return [[self applicationFilesDirectory] URLByAppendingPathComponent:@"scripts"];
}

- (NSURL *)scriptURLForName:(NSString *)name
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    /*
     Check if we have a script with no extension
     */
    NSURL *defaultURLForName = [[self repositorySupportDirectory] URLByAppendingPathComponent:name];
    if ([fm fileExistsAtPath:[defaultURLForName path]]) {
        DDLogVerbose(@"Found script in default location: %@", [defaultURLForName path]);
        return defaultURLForName;
    }
    
    /*
     Look for item with any extension
     */
    NSArray *propertiesToGet = @[NSURLIsRegularFileKey, NSURLIsExecutableKey, NSURLNameKey];
    
    NSArray *supportDirectories = @[[self repositoryScriptsDirectory], [self applicationScriptsDirectory]];
    for (NSURL *supportDir in supportDirectories) {
        NSArray *dirContents = [fm contentsOfDirectoryAtURL:supportDir
                                 includingPropertiesForKeys:propertiesToGet
                                                    options:NSDirectoryEnumerationSkipsHiddenFiles
                                                      error:nil];
        for (NSURL *item in dirContents) {
            NSNumber *isRegularFile = nil;
            [item getResourceValue:&isRegularFile forKey:NSURLIsRegularFileKey error:nil];
            if (![isRegularFile boolValue]) {
                continue;
            }
            
            
            NSNumber *isExecutable = nil;
            [item getResourceValue:&isExecutable forKey:NSURLIsExecutableKey error:nil];
            
            NSString *fileName = nil;
            [item getResourceValue:&fileName forKey:NSURLNameKey error:nil];
            if ([[fileName stringByDeletingPathExtension] isEqualToString:name]) {
                if ([isExecutable boolValue]) {
                    DDLogVerbose(@"Found script with custom path extension: %@", [item path]);
                    return item;
                } else {
                    DDLogVerbose(@"Found matching file with custom path extension but it is not executable: %@", [item path]);
                }
            }
        }
    }
    DDLogVerbose(@"Did not find script for name: %@", name);
    return nil;
}

- (NSString *)pkginfoPostSaveScriptPath
{
    return [[self scriptURLForName:kPkginfoPostSaveScriptName] path];
}

- (NSString *)pkginfoPreSaveScriptPath
{
    return [[self scriptURLForName:kPkginfoPreSaveScriptName] path];
}

- (NSString *)manifestPreSaveScriptPath
{
    return [[self scriptURLForName:kManifestPreSaveScriptName] path];
}

- (NSString *)manifestPostSaveScriptPath
{
    return [[self scriptURLForName:kManifestPostSaveScriptName] path];
}

- (NSString *)repositoryPreSaveScriptPath
{
    return [[self scriptURLForName:kRepositoryPreSaveScriptName] path];
}

- (NSString *)repositoryPostSaveScriptPath
{
    return [[self scriptURLForName:kRepositoryPostSaveScriptName] path];
}

- (NSString *)repositoryPreOpenScriptPath
{
    return [[self scriptURLForName:kRepositoryPreOpenScriptName] path];
}

- (NSString *)repositoryPostOpenScriptPath
{
    return [[self scriptURLForName:kRepositoryPostOpenScriptName] path];
}

- (void)updateRepositoryScriptStatus
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    self.repositoryHasPkginfoPreSaveScript = ([fm fileExistsAtPath:[self pkginfoPreSaveScriptPath]]) ? YES : NO;
    self.repositoryHasPkginfoPostSaveScript = ([fm fileExistsAtPath:[self pkginfoPostSaveScriptPath]]) ? YES : NO;
    
    self.repositoryHasManifestPreSaveScript = ([fm fileExistsAtPath:[self manifestPreSaveScriptPath]]) ? YES : NO;
    self.repositoryHasManifestPostSaveScript = ([fm fileExistsAtPath:[self manifestPostSaveScriptPath]]) ? YES : NO;
    
    self.repositoryHasPreSaveScript = ([fm fileExistsAtPath:[self repositoryPreSaveScriptPath]]) ? YES : NO;
    self.repositoryHasPostSaveScript = ([fm fileExistsAtPath:[self repositoryPostSaveScriptPath]]) ? YES : NO;
    
    self.repositoryHasPreOpenScript = ([fm fileExistsAtPath:[self repositoryPreOpenScriptPath]]) ? YES : NO;
    self.repositoryHasPostOpenScript = ([fm fileExistsAtPath:[self repositoryPostOpenScriptPath]]) ? YES : NO;
}

- (MAScriptRunner *)postSaveScriptForPackage:(PackageMO *)aPackage
{
    MAScriptRunner *scriptRunner = [MAScriptRunner scriptWithPath:[self pkginfoPostSaveScriptPath]];
    scriptRunner.currentDirectoryPath = [self.repositoryURL path];
    scriptRunner.arguments = @[[aPackage.packageInfoURL path], [aPackage.packageInfoURL lastPathComponent]];
    return scriptRunner;
}

- (MAScriptRunner *)preSaveScriptForPackage:(PackageMO *)aPackage
{
    MAScriptRunner *scriptRunner = [MAScriptRunner scriptWithPath:[self pkginfoPreSaveScriptPath]];
    scriptRunner.currentDirectoryPath = [self.repositoryURL path];
    scriptRunner.arguments = @[[aPackage.packageInfoURL path], [aPackage.packageInfoURL lastPathComponent]];
    return scriptRunner;
}

- (MAScriptRunner *)preSaveScriptForManifest:(ManifestMO *)aManifest
{
    MAScriptRunner *scriptRunner = [MAScriptRunner scriptWithPath:[self manifestPreSaveScriptPath]];
    scriptRunner.currentDirectoryPath = [self.repositoryURL path];
    scriptRunner.arguments = @[[aManifest.manifestURL path], [aManifest.manifestURL lastPathComponent]];
    return scriptRunner;
}

- (MAScriptRunner *)postSaveScriptForManifest:(ManifestMO *)aManifest
{
    MAScriptRunner *scriptRunner = [MAScriptRunner scriptWithPath:[self manifestPostSaveScriptPath]];
    scriptRunner.currentDirectoryPath = [self.repositoryURL path];
    scriptRunner.arguments = @[[aManifest.manifestURL path], [aManifest.manifestURL lastPathComponent]];
    return scriptRunner;
}

- (MAScriptRunner *)preSaveScriptForRepository
{
    MAScriptRunner *scriptRunner = [MAScriptRunner scriptWithPath:[self repositoryPreSaveScriptPath]];
    scriptRunner.currentDirectoryPath = [self.repositoryURL path];
    scriptRunner.arguments = nil;
    return scriptRunner;
}

- (MAScriptRunner *)postSaveScriptForRepository
{
    MAScriptRunner *scriptRunner = [MAScriptRunner scriptWithPath:[self repositoryPostSaveScriptPath]];
    scriptRunner.currentDirectoryPath = [self.repositoryURL path];
    scriptRunner.arguments = nil;
    return scriptRunner;
}

- (BOOL)runRepositoryPreSaveScript
{
    if (self.repositoryHasPreSaveScript) {
        DDLogDebug(@"Running repository pre-save script...");
        MAScriptRunner *scriptRunner = [self preSaveScriptForRepository];
        [scriptRunner start];
        if (scriptRunner.standardOutput) {
            DDLogVerbose(@"\n%@", scriptRunner.standardOutput);
        }
        if (scriptRunner.terminationStatus != 0) {
            DDLogError(@"Pre-save script exited with code %i", scriptRunner.terminationStatus);
            if (scriptRunner.standardError) {
                DDLogError(@"\n%@", scriptRunner.standardError);
            }
            return NO;
        }
    }
    return YES;
}

- (BOOL)runRepositoryPostSaveScript
{
    if (self.repositoryHasPostSaveScript) {
        DDLogDebug(@"Running repository post-save script...");
        MAScriptRunner *scriptRunner = [self postSaveScriptForRepository];
        [scriptRunner start];
        if (scriptRunner.standardOutput) {
            DDLogVerbose(@"\n%@", scriptRunner.standardOutput);
        }
        if (scriptRunner.terminationStatus != 0) {
            DDLogError(@"Post-save script exited with code %i", scriptRunner.terminationStatus);
            if (scriptRunner.standardError && [scriptRunner.standardError isEqualToString:@""]) {
                DDLogError(@"\n%@", scriptRunner.standardError);
            }
            return NO;
        }
    }
    return YES;
}

# pragma mark -
# pragma mark Writing to the repository

- (void)prepareForSaving
{
    [self updateRepositoryScriptStatus];
}

- (void)writeRepositoryChangesToDisk:(BOOL *)success didWritePkginfos:(BOOL *)pkginfos didWriteManifests:(BOOL *)manifests
{
    [self prepareForSaving];
    
    *success = YES;
    *pkginfos = NO;
    *manifests = NO;
    
    /*
     Run the pre-save script (if any).
     Only continue if the script exited with 0
     */
    if (![self runRepositoryPreSaveScript]) {
        NSAlert *alert = [[NSAlert alloc] init];
        NSString *messageText = NSLocalizedString(@"Pre-save script failed", @"");
        alert.messageText = messageText;
        NSString *informativeText = NSLocalizedString(@"Pre-save script exited with a non-zero code. Save was aborted.", @"");
        alert.informativeText = informativeText;
        [alert runModal];
        *success = NO;
        *pkginfos = NO;
        *manifests = NO;
        return;
    }
    
    /*
     Write the changes
     */
    BOOL didWritePkginfoFiles = NO;
    if ([self.defaults boolForKey:@"UpdatePkginfosOnSave"]) {
        BOOL pkginfoSaveSucceeded = [self writePackagePropertyListsToDisk:&didWritePkginfoFiles];
        *pkginfos = didWritePkginfoFiles;
        if (!pkginfoSaveSucceeded) {
            *success = NO;
            return;
        }
    }
    BOOL didWriteManifestFiles = NO;
    if ([self.defaults boolForKey:@"UpdateManifestsOnSave"]) {
        BOOL manifestSaveSucceeded = [self writeManifestPropertyListsToDisk:&didWriteManifestFiles];
        *manifests = didWriteManifestFiles;
        if (!manifestSaveSucceeded) {
            *success = NO;
            return;
        }
    }
    
    /*
     Run post-save script (if any)
     */
    if (![self runRepositoryPostSaveScript]) {
        DDLogError(@"Repository post-save script failed...");
    }
    
    return;
}

- (NSSet *)modifiedManifestsSinceLastSave
{
    DDLogDebug(@"Getting modified manifests since last save");
    
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
    DDLogDebug(@"Getting modified pkginfos since last save");
    
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
    NSString *filename = [(NSURL *)aManifest.manifestURL lastPathComponent];
    
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
            DDLogError(@"%@: Failed to create backup directory: %@", filename, [dirCreateError description]);
            return NO;
        }
        
        NSError *copyError = nil;
        if (![fm copyItemAtURL:aManifest.manifestURL toURL:backupFileURL error:&copyError]) {
            DDLogInfo(@"Failed to copy: %@", [copyError description]);
            return NO;
        } else {
            itemBackedUp = YES;
        }
    } else {
        DDLogError(@"Error: saveStartedDate is nil");
    }
    
    return itemBackedUp;
}

- (BOOL)backupPackage:(PackageMO *)aPackage
{
    BOOL itemBackedUp = NO;
    NSString *filename = [(NSURL *)aPackage.packageInfoURL lastPathComponent];
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
            DDLogError(@"%@: Failed to create backup directory: %@", filename, [dirCreateError description]);
            return NO;
        }
        
        NSError *copyError = nil;
        NSURL *packageInfoURL = [(NSURL *)aPackage.packageInfoURL filePathURL];
        if (![fm copyItemAtURL:packageInfoURL toURL:[backupFileURL filePathURL] error:&copyError]) {
            DDLogInfo(@"Failed to copy: %@", [copyError description]);
            return NO;
        } else {
            DDLogInfo(@"Copied %@", packageInfoURL);
            itemBackedUp = YES;
        }        
    } else {
        DDLogError(@"Error: saveStartedDate is nil");
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

- (BOOL)writePackagePropertyList:(NSDictionary *)plist forPackage:(PackageMO *)aPackage error:(NSError **)error
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *filename = [(NSURL *)aPackage.packageInfoURL lastPathComponent];
    
    /*
     Create a backup
     */
    if ([defaults boolForKey:@"backupPkginfosBeforeWriting"]) {
        DDLogDebug(@"%@: Backing up...", filename);
        [self backupPackage:aPackage];
    }
    
    /*
     Run pre-save script
     */
    if (self.repositoryHasPkginfoPreSaveScript) {
        DDLogDebug(@"%@: Running pre-save script...", filename);
        MAScriptRunner *preSave = [self preSaveScriptForPackage:aPackage];
        [preSave start];
        if (preSave.standardOutput) {
            DDLogVerbose(@"%@", preSave.standardOutput);
        }
        if (preSave.terminationStatus != 0) {
            DDLogError(@"%@: Pre-save script failed...", filename);
            NSString *description = @"Pre-save script failed";
            NSString *recoverySuggestion = [NSString stringWithFormat:@"Pre-save script for pkginfo \"%@\" exited with code %i.", [(NSURL *)aPackage.packageInfoURL path], preSave.terminationStatus];
            if (preSave.standardError) {
                DDLogError(@"%@", preSave.standardError);
                recoverySuggestion = [recoverySuggestion stringByAppendingFormat:@"\n\n%@", preSave.standardError];
            }
            
            
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: description,
                                              NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion,
                                              NSFilePathErrorKey: [(NSURL *)aPackage.packageInfoURL path]};
            if (error != NULL) {
                *error = [[NSError alloc] initWithDomain:@"MunkiAdmin Script Error Domain" code:999 userInfo:errorDictionary];
            }
            return NO;
        }
    }
    
    /*
     Write the file
     */
    DDLogDebug(@"%@: Writing new pkginfo to disk...", filename);
    BOOL atomicWrites = [defaults boolForKey:@"atomicWrites"];
    DDLogDebug(@"%@: Should write atomically: %@", filename, atomicWrites ? @"YES" : @"NO");
    if ([plist writeToURL:(NSURL *)aPackage.packageInfoURL atomically:atomicWrites]) {
        aPackage.originalPkginfo = plist;
        
        /*
         Check if we have custom permissions
         */
        NSString *customPermissions = [defaults stringForKey:@"pkginfoFilePermissions"];
        if (customPermissions) {
            DDLogDebug(@"%@: Setting custom permissions...", filename);
            if (![self setPermissions:customPermissions forURL:aPackage.packageInfoURL]) {
                DDLogError(@"%@: Failed to set permissions", filename);
            }
        }
        
        /*
         Run post-save script
         */
        if (self.repositoryHasPkginfoPostSaveScript) {
            DDLogDebug(@"%@: Running post-save script...", filename);
            MAScriptRunner *postSave = [self postSaveScriptForPackage:aPackage];
            [postSave start];
            if (postSave.standardOutput) {
                DDLogVerbose(@"%@", postSave.standardOutput);
            }
            if (postSave.terminationStatus != 0) {
                DDLogError(@"%@: Post-save script failed...", filename);
                if (postSave.standardError) {
                    DDLogError(@"%@", postSave.standardError);
                }
            }
        }
        
        return YES;
    } else {
        DDLogError(@"%@: Error: Failed to write %@", filename, [(NSURL *)aPackage.packageInfoURL path]);
        return NO;
    }
}

- (BOOL)writeManifestPropertyList:(NSDictionary *)plist forManifest:(ManifestMO *)aManifest error:(NSError **)error
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *filename = [(NSURL *)aManifest.manifestURL lastPathComponent];
    
    /*
     Create a backup
     */
    if ([defaults boolForKey:@"backupManifestsBeforeWriting"]) {
        DDLogDebug(@"%@: Backing up...", filename);
        [self backupManifest:aManifest];
    }
    
    /*
     Run pre-save script
     */
    if (self.repositoryHasManifestPreSaveScript) {
        DDLogDebug(@"%@: Running pre-save script...", filename);
        MAScriptRunner *preSave = [self preSaveScriptForManifest:aManifest];
        [preSave start];
        if (preSave.standardOutput) {
            DDLogVerbose(@"%@", preSave.standardOutput);
        }
        if (preSave.terminationStatus != 0) {
            DDLogError(@"%@", preSave.standardError);
            
            NSString *description = @"Pre-save script failed";
            NSString *recoverySuggestion = [NSString stringWithFormat:@"Pre-save script for manifest \"%@\" exited with code %i.", [(NSURL *)aManifest.manifestURL path], preSave.terminationStatus];
            if (preSave.standardError) {
                recoverySuggestion = [recoverySuggestion stringByAppendingFormat:@"\n\n%@", preSave.standardError];
            }
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: description,
                                              NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion,
                                              NSFilePathErrorKey: [(NSURL *)aManifest.manifestURL path]};
            if (error != NULL) {
                *error = [[NSError alloc] initWithDomain:@"MunkiAdmin Script Error Domain" code:999 userInfo:errorDictionary];
            }
            return NO;
        }
    }
    
    /*
     Write the file
     */
    DDLogDebug(@"%@: Writing new manifest to disk...", filename);
    BOOL atomicWrites = [defaults boolForKey:@"atomicWrites"];
    DDLogDebug(@"%@: Should write atomically: %@", filename, atomicWrites ? @"YES" : @"NO");
    if ([plist writeToURL:(NSURL *)aManifest.manifestURL atomically:atomicWrites]) {
        aManifest.originalManifest = plist;
        
        /*
         Check if we have custom permissions
         */
        NSString *customPermissions = [defaults stringForKey:@"manifestFilePermissions"];
        if (customPermissions) {
            DDLogDebug(@"%@: Setting custom permissions...", filename);
            if (![self setPermissions:customPermissions forURL:(NSURL *)aManifest.manifestURL]) {
                DDLogError(@"%@: Failed to set permissions", filename);
            }
        }
        
        /*
         Run post-save script
         */
        if (self.repositoryHasManifestPostSaveScript) {
            DDLogDebug(@"%@: Running post-save script...", filename);
            MAScriptRunner *postSave = [self postSaveScriptForManifest:aManifest];
            [postSave start];
            if (postSave.standardOutput) {
                DDLogVerbose(@"%@", postSave.standardOutput);
            }
            if (postSave.terminationStatus != 0) {
                DDLogError(@"%@", postSave.standardError);
            }
        }
        
        return YES;
    } else {
        DDLogError(@"%@: Error: Failed to write %@", filename, [(NSURL *)aManifest.manifestURL path]);
        return NO;
    }
}

- (BOOL)writePackagePropertyListsToDisk:(BOOL *)wroteToDisk
{
    DDLogDebug(@"Was asked to write package property lists to disk");
    
    *wroteToDisk = NO;
    
    [self updateRepositoryScriptStatus];
    
    self.saveStartedDate = [NSDate date];
    BOOL successfullySaved = YES;
    /*
     * =============================================
	 * Get all packages that have been modified
     * since last save and check them for changes
     * =============================================
     */
	
	for (PackageMO *aPackage in [self modifiedPackagesSinceLastSave]) {
        
        NSString *filename = [(NSURL *)aPackage.packageInfoURL lastPathComponent];
        DDLogDebug(@"%@: Checking pkginfo for changes...", filename);
        
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
        NSArray *keysToDelete = @[@"allow_untrusted",
                                  @"blocking_applications",
                                  @"category",
                                  @"description",
                                  @"developer",
                                  @"display_name",
                                  @"force_install_after_date",
                                  @"icon_hash",
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
                                  @"installs",
                                  @"maximum_os_version",
                                  @"minimum_munki_version",
                                  @"minimum_os_version",
                                  @"notes",
                                  @"OnDemand",
                                  @"package_path",
                                  @"precache",
                                  @"preinstall_alert",
                                  @"preinstall_script",
                                  @"preuninstall_alert",
                                  @"preuninstall_script",
                                  @"postinstall_script",
                                  @"postuninstall_script",
                                  @"RestartAction",
                                  @"supported_architectures",
                                  @"uninstall_method",
                                  @"uninstallcheck_script",
                                  @"uninstaller_item_location",
                                  @"uninstall_script",
                                  @"version"];
        
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
        
        for (NSString *aKey in [removedItems allObjects]) {
            if (![keysToDelete containsObject:aKey]) {
                DDLogDebug(@"%@: Key change: \"%@\" found in original pkginfo. Keeping it.", filename, aKey);
            } else {
                DDLogDebug(@"%@: Key change: \"%@\" deleted by MunkiAdmin", filename, aKey);
            }
            
        }
        for (NSString *aKey in [addedItems allObjects]) {
            DDLogDebug(@"%@: Key change: \"%@\" added by MunkiAdmin", filename, aKey);
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
            if (([infoDictFromPackage valueForKey:aKey] == nil) && ([infoDictOnDisk valueForKey:aKey] != nil)) {
                [mergedInfoDict removeObjectForKey:aKey];
            }
        }
        
        /*
         Key arrays already differ.
         User has added new information
         */
        NSArray *sortedMergedKeys = [[mergedInfoDict allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
        NSError *writeError = nil;
		if (![sortedOriginalKeys isEqualToArray:sortedMergedKeys]) {
            if (![self writePackagePropertyList:mergedInfoDict forPackage:aPackage error:&writeError]) {
                DDLogError(@"%@: Failed to write pkginfo...", filename);
                [[NSApplication sharedApplication] presentError:writeError];
                successfullySaved = NO;
                break;
            } else {
                *wroteToDisk = YES;
            }
		}
        
        /*
         Check for value changes
         */
        else {
			DDLogDebug(@"%@: No changes in key array. Checking for value changes...", filename);
            if (![mergedInfoDict isEqualToDictionary:infoDictOnDisk]) {
				DDLogDebug(@"%@: Values differ. Should write new pkginfo...", filename);
                if (![self writePackagePropertyList:mergedInfoDict forPackage:aPackage error:&writeError]) {
                    DDLogError(@"%@: Failed to write pkginfo...", filename);
                    [[NSApplication sharedApplication] presentError:writeError];
                    successfullySaved = NO;
                    break;
                } else {
                    *wroteToDisk = YES;
                }
			} else {
				DDLogDebug(@"%@: No changes detected", filename);
			}
		}
        
        /*
         Clear the internal trigger
         */
        aPackage.hasUnstagedChangesValue = NO;
	}
    
    self.saveStartedDate = nil;
    return successfullySaved;
}


- (BOOL)writeManifestPropertyListsToDisk:(BOOL *)wroteToDisk
{
	DDLogDebug(@"Was asked to write manifest property lists to disk");
    
    *wroteToDisk = NO;
    
    [self updateRepositoryScriptStatus];
    
    self.saveStartedDate = [NSDate date];
    BOOL successfullySaved = YES;
    
    /*
     * =============================================
	 * Get all manifests that have been modified
     * since last save and check them for changes
     * =============================================
     */
	
	for (ManifestMO *aManifest in [self modifiedManifestsSinceLastSave]) {
        
        NSString *filename = [(NSURL *)aManifest.manifestURL lastPathComponent];
        DDLogDebug(@"%@: Checking manifest file for changes...", filename);
        
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
        NSArray *keysToDelete = @[@"catalogs",
                                  @"conditional_items",
                                  @"included_manifests",
                                  @"managed_installs",
                                  @"managed_uninstalls",
                                  @"managed_updates",
                                  @"optional_installs",
                                  @"featured_items",
                                  [[NSUserDefaults standardUserDefaults] stringForKey:@"manifestUserNameKey"],
                                  [[NSUserDefaults standardUserDefaults] stringForKey:@"manifestDisplayNameKey"],
                                  [[NSUserDefaults standardUserDefaults] stringForKey:@"manifestAdminNotesKey"]];
        
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
        
        for (NSString *aKey in [removedItems allObjects]) {
            if (![keysToDelete containsObject:aKey]) {
                DDLogDebug(@"%@: Key change: \"%@\" found in original manifest. Keeping it.", filename, aKey);
            } else {
                DDLogDebug(@"%@: Key change: \"%@\" deleted by MunkiAdmin", filename, aKey);
            }
            
        }
        for (NSString *aKey in [addedItems allObjects]) {
            DDLogDebug(@"%@: Key change: \"%@\" added by MunkiAdmin", filename, aKey);
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
        NSError *writeError = nil;
		if (![sortedOriginalKeys isEqualToArray:sortedMergedKeys]) {
			DDLogDebug(@"%@: Keys differ. Should write new manifest...", filename);
            if (![self writeManifestPropertyList:mergedManifestDict forManifest:aManifest error:&writeError]) {
                DDLogDebug(@"%@: Failed to write manifest to disk...", filename);
                [[NSApplication sharedApplication] presentError:writeError];
                successfullySaved = NO;
                break;
            } else {
                *wroteToDisk = YES;
            }
		}
        
        /*
         Finally write the manifest to disk if
         mergedManifestDict is not equal to infoDictOnDisk
         
         This will be triggered if any value is changed.
         */
        else {
            DDLogDebug(@"%@: No changes in key array. Checking for value changes...", filename);
            if (![mergedManifestDict isEqualToDictionary:infoDictOnDisk]) {
				DDLogDebug(@"%@: Values differ. Should write new manifest...", filename);
                if (![self writeManifestPropertyList:mergedManifestDict forManifest:aManifest error:&writeError]) {
                    DDLogDebug(@"%@: Failed to write manifest to disk...", filename);
                    [[NSApplication sharedApplication] presentError:writeError];
                    successfullySaved = NO;
                    break;
                } else {
                    *wroteToDisk = YES;
                }
			} else {
				DDLogDebug(@"%@: No changes detected", filename);
			}
        }
        
        /*
         Clear the internal trigger
         */
        aManifest.hasUnstagedChangesValue = NO;
	}
    
    self.saveStartedDate = nil;
    return successfullySaved;
}

# pragma mark -
# pragma mark Helper methods

- (NSManagedObjectContext *)appDelegateMoc
{
    return [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
}

- (NSArray *)allObjectsForEntity:(NSString *)entityName
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
	NSEntityDescription *entityDescr = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self appDelegateMoc]];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescr];
	NSArray *fetchResults = [[self appDelegateMoc] executeFetchRequest:fetchRequest error:nil];
	return fetchResults;
}

- (void)updateUniqueCatalogStringLength
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    NSArray *allCatalogs = [self allObjectsForEntity:@"Catalog"];
    
    NSUInteger length = 1;
    
    while (length < 10) {
        NSMutableArray *currentTitles = [NSMutableArray new];
        for (CatalogMO *catalog in allCatalogs) {
            NSString *shortenedTitle = [catalog.title substringToIndex:([catalog.title length] > length) ? length : [catalog.title length]];
            [currentTitles addObject:shortenedTitle];
        }
        
        if ([[currentTitles valueForKeyPath:@"@distinctUnionOfObjects.self"] count] == [currentTitles count]) {
            DDLogDebug(@"Short catalog titles are unique when the length is %lu character...", (unsigned long)length);
            self.lengthForUniqueCatalogTitles = length;
            return;
        } else {
            DDLogVerbose(@"Not all short titles are unique");
            DDLogVerbose(@"%@", [currentTitles description]);
        }
        
        length++;
    }
    
}

- (BOOL)setPermissions:(NSString *)octalAsString forURL:(NSURL *)url
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    if (octalAsString) {
        /*
         Based on <http://stackoverflow.com/a/1181715>
         
         For example, turn a @"0644" string to 420
         */
        unsigned long permsUnsignedLong = strtoul([octalAsString UTF8String], NULL, 0);
        
        NSDictionary *attributes = @{NSFilePosixPermissions: @(permsUnsignedLong)};
        NSString *filepath = [url path];
        NSError *permissionError = nil;
        if (![[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:filepath error:&permissionError]) {
            DDLogError(@"%@", permissionError);
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}


- (NSString *)relativePathToChildURL:(NSURL *)childURL parentURL:(NSURL *)parentURL
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    NSMutableArray *relativePathComponents = [NSMutableArray arrayWithArray:[childURL pathComponents]];
    
    NSArray *parentPathComponents = [NSArray arrayWithArray:[parentURL pathComponents]];
    NSArray *childPathComponents = [NSArray arrayWithArray:[childURL pathComponents]];
    
    // Child URL must have more components than the parent
    if ([childPathComponents count] < [parentPathComponents count]) {
        return nil;
    }
    
    [parentPathComponents enumerateObjectsUsingBlock:^(NSString *parentPathComponent, NSUInteger idx, BOOL *stop) {
        if (idx < [childPathComponents count]) {
            NSString *childPathComponent = childPathComponents[idx];
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
                                       includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
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
        [task setArguments:@[@"--version"]];
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
        [task setArguments:@[@"--version"]];
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
    NSArray *keys = @[NSURLIsPackageKey, NSURLIsDirectoryKey, NSURLIsRegularFileKey];
    NSDictionary *properties = [fileURL resourceValuesForKeys:keys error:nil];
    
    NSNumber *isPackage = properties[NSURLIsPackageKey];
    NSNumber *isRegularFile = properties[NSURLIsRegularFileKey];
    
    /*
     Do a very simple check and fail if the item isn't a regular file
     */
    if (![isRegularFile boolValue]) {
        if (error != NULL) {
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
            
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : description,
                    NSLocalizedRecoverySuggestionErrorKey : recoverySuggestion};
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
        NSString *keyName = [NSString stringWithFormat:@"munki_%@", pkginfoBasicKey];
        newPkginfoBasicKeyMappings[keyName] = pkginfoBasicKey;
	}
	self.pkginfoBasicKeyMappings = [NSDictionary dictionaryWithDictionary:newPkginfoBasicKeyMappings];
    
    // Array keys
    NSMutableDictionary *newPkginfoArrayKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *pkginfoArrayKey in [self.defaults arrayForKey:@"pkginfoArrayKeys"]) {
        NSString *keyName = [NSString stringWithFormat:@"munki_%@", pkginfoArrayKey];
        newPkginfoArrayKeyMappings[keyName] = pkginfoArrayKey;
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
    [newPkginfoAssimilateKeys removeObject:@"PayloadIdentifier"];
    
    [newPkginfoAssimilateKeys addObject:@"category"];
    [newPkginfoAssimilateKeys addObject:@"developer"];
    [newPkginfoAssimilateKeys addObject:@"icon_name"];
    
	self.pkginfoAssimilateKeys = [NSArray arrayWithArray:newPkginfoAssimilateKeys];
	
	// Receipt keys
	NSMutableDictionary *newReceiptKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *receiptKey in [self.defaults arrayForKey:@"receiptKeys"]) {
        NSString *keyName = [NSString stringWithFormat:@"munki_%@", receiptKey];
        newReceiptKeyMappings[keyName] = receiptKey;
	}
	self.receiptKeyMappings = [NSDictionary dictionaryWithDictionary:newReceiptKeyMappings];
	
	// Installs item keys
	NSMutableDictionary *newInstallsKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *installsKey in [self.defaults arrayForKey:@"installsKeys"]) {
        NSString *keyName = [NSString stringWithFormat:@"munki_%@", installsKey];
        newInstallsKeyMappings[keyName] = installsKey;
	}
	self.installsKeyMappings = [NSDictionary dictionaryWithDictionary:newInstallsKeyMappings];
	
	// items_to_copy keys
	NSMutableDictionary *newItemsToCopyKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *itemToCopy in [self.defaults arrayForKey:@"itemsToCopyKeys"]) {
        NSString *keyName = [NSString stringWithFormat:@"munki_%@", itemToCopy];
        newItemsToCopyKeyMappings[keyName] = itemToCopy;
	}
	self.itemsToCopyKeyMappings = [NSDictionary dictionaryWithDictionary:newItemsToCopyKeyMappings];
    
    // installer_choices_xml
    NSMutableDictionary *newInstallerChoicesKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *installerChoice in [self.defaults arrayForKey:@"installerChoicesKeys"]) {
        NSString *keyName = [NSString stringWithFormat:@"munki_%@", installerChoice];
        newInstallerChoicesKeyMappings[keyName] = installerChoice;
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
