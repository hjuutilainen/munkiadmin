//
//  MACoreDataManager.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 16.5.2013.
//
//

#import "MACoreDataManager.h"
#import "MunkiAdmin_AppDelegate.h"
#import "MunkiRepositoryManager.h"
#import "DataModelHeaders.h"

/*
 * Private interface
 */
@interface MACoreDataManager ()


@end

@implementation MACoreDataManager

# pragma mark -
# pragma mark Creating new objects

- (InstallsItemMO *)createInstallsItemFromDictionary:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)moc
{
    if ((dict == nil) || (moc == nil)) {
        return nil;
    }
    
    /*
     Create the initial item
     */
    InstallsItemMO *newInstallsItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallsItem" inManagedObjectContext:moc];
    
    /*
     Get the supported keys from NSUserDefaults and set object properties
     */
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[[MunkiRepositoryManager sharedManager] installsKeyMappings] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id value = [dict objectForKey:obj];
        if (value != nil) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debugLogAllProperties"])
                NSLog(@"Setting installs item key \"%@\" to \"%@\"", obj, value);
            [newInstallsItem setValue:value forKey:key];
        } else {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debugLogAllProperties"]) NSLog(@"Skipped nil value for key %@", key);
        }
    }];
    
    /*
     Loop over the keys we didn't recognize previously and create custom objects out of them
     These can be user defined keys that are usable with the version_comparison_key
     */
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![[defaults arrayForKey:@"installsKeys"] containsObject:key]) {
            if ([defaults boolForKey:@"debugLogAllProperties"])
                NSLog(@"Setting installs item custom key \"%@\" to \"%@\"", key, obj);
            if (key && obj) {
                InstallsItemCustomKeyMO *customKey = [NSEntityDescription insertNewObjectForEntityForName:@"InstallsItemCustomKey" inManagedObjectContext:moc];
                customKey.customKeyName = key;
                customKey.customKeyValue = obj;
                customKey.installsItem = newInstallsItem;
            }
        }
    }];
    
    /*
     Save the original installs item dictionary so that we can compare to it later
     */
    newInstallsItem.originalInstallsItem = (NSDictionary *)dict;
    
    return newInstallsItem;
}


- (DirectoryMO *)directoryWithURL:(NSURL *)anURL managedObjectContext:(NSManagedObjectContext *)moc
{
    // We need the URL and the context
    if (!anURL || !moc) {
        return nil;
    }
    
    DirectoryMO *directory = nil;
    NSFetchRequest *checkForExisting = [[NSFetchRequest alloc] init];
    [checkForExisting setEntity:[NSEntityDescription entityForName:@"Directory" inManagedObjectContext:moc]];
    NSPredicate *parentPredicate = [NSPredicate predicateWithFormat:@"originalURL == %@", anURL];
    [checkForExisting setPredicate:parentPredicate];
    NSUInteger foundItems = [moc countForFetchRequest:checkForExisting error:nil];
    if (foundItems == 0) {
        // Did not find existing object, create a new one.
        directory = [NSEntityDescription insertNewObjectForEntityForName:@"Directory" inManagedObjectContext:moc];
        directory.originalURL = anURL;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"packageInfoParentDirectoryURL == %@", anURL];
        directory.filterPredicate = predicate;
    } else {
        // Existing directory found.
        directory = [[moc executeFetchRequest:checkForExisting error:nil] objectAtIndex:0];
    }
    return directory;
}


- (CatalogMO *)createCatalogWithTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)moc
{
    if ((title == nil) || (moc == nil)) {
        return nil;
    }
    
    CatalogMO *catalog;
    catalog = [NSEntityDescription insertNewObjectForEntityForName:@"Catalog" inManagedObjectContext:moc];
    catalog.title = title;
    NSURL *catalogURL = [[[NSApp delegate] catalogsURL] URLByAppendingPathComponent:catalog.title];
    [[NSFileManager defaultManager] createFileAtPath:[catalogURL relativePath] contents:nil attributes:nil];
    
    // Loop through Package managed objects
    for (PackageMO *aPackage in [sharedOperationManager allObjectsForEntity:@"Package" inManagedObjectContext:moc]) {
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

- (ManifestMO *)createManifestWithURL:(NSURL *)fileURL inManagedObjectContext:(NSManagedObjectContext *)moc
{
    if ((fileURL == nil) || (moc == nil)) {
        return nil;
    }
    
    ManifestMO *newManifest = [NSEntityDescription insertNewObjectForEntityForName:@"Manifest" inManagedObjectContext:moc];
    
    // Manifest name should be the relative path from manifests subdirectory
    NSArray *manifestComponents = [fileURL pathComponents];
    NSArray *manifestDirComponents = [[[NSApp delegate] manifestsURL] pathComponents];
    NSMutableArray *relativePathComponents = [NSMutableArray arrayWithArray:manifestComponents];
    [relativePathComponents removeObjectsInArray:manifestDirComponents];
    NSString *manifestRelativePath = [relativePathComponents componentsJoinedByString:@"/"];
    
    newManifest.title = manifestRelativePath;
    newManifest.manifestURL = fileURL;
    newManifest.originalManifest = [NSDictionary dictionary];
    
    if ([(NSDictionary *)newManifest.originalManifest writeToURL:newManifest.manifestURL atomically:YES]) {
        return newManifest;
    } else {
        return nil;
    }
}

- (ManifestMO *)createManifestWithTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)moc
{
    if ((title == nil) || (moc == nil)) {
        return nil;
    }
    
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
# pragma mark Helpers

- (NSArray *)allObjectsForEntity:(NSString *)entityName inManagedObjectContext:(NSManagedObjectContext *)moc
{
	NSEntityDescription *entityDescr = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescr];
	NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:nil];
	return fetchResults;
}


# pragma mark -
# pragma mark Singleton methods

static MACoreDataManager *sharedOperationManager = nil;
static dispatch_queue_t serialQueue;

+ (id)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceQueue;
    
    dispatch_once(&onceQueue, ^{
        serialQueue = dispatch_queue_create("MunkiAdmin.CoreDataManager.SerialQueue", NULL);
        if (sharedOperationManager == nil) {
            sharedOperationManager = [super allocWithZone:zone];
        }
    });
    
    return sharedOperationManager;
}

+ (MACoreDataManager *)sharedManager {
    static dispatch_once_t onceQueue;
    
    dispatch_once(&onceQueue, ^{
        sharedOperationManager = [[MACoreDataManager alloc] init];
    });
    
    return sharedOperationManager;
}

- (id)init {
    id __block obj;
    
    dispatch_sync(serialQueue, ^{
        obj = [super init];
        if (obj) {
            
        }
    });
    
    self = obj;
    return self;
}


@end
