//
//  MACoreDataManager.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 16.5.2013.
//
//

#import "MACoreDataManager.h"
#import "MAMunkiAdmin_AppDelegate.h"
#import "MAMunkiRepositoryManager.h"
#import "DataModelHeaders.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

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
    [[[MAMunkiRepositoryManager sharedManager] installsKeyMappings] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id value = [dict objectForKey:obj];
        if (value != nil) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debugLogAllProperties"])
                DDLogDebug(@"Setting installs item key \"%@\" to \"%@\"", obj, value);
            [newInstallsItem setValue:value forKey:key];
        } else {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debugLogAllProperties"]) DDLogDebug(@"Skipped nil value for key %@", key);
        }
    }];
    
    /*
     Loop over the keys we didn't recognize previously and create custom objects out of them
     These can be user defined keys that are usable with the version_comparison_key
     */
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![[defaults arrayForKey:@"installsKeys"] containsObject:key]) {
            if ([defaults boolForKey:@"debugLogAllProperties"])
                DDLogDebug(@"Setting installs item custom key \"%@\" to \"%@\"", key, obj);
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
    NSURL *catalogURL = [[(MAMunkiAdmin_AppDelegate *)[NSApp delegate] catalogsURL] URLByAppendingPathComponent:catalog.title];
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
    NSString *manifestRelativePath = [[MAMunkiRepositoryManager sharedManager] relativePathToChildURL:fileURL parentURL:[(MAMunkiAdmin_AppDelegate *)[NSApp delegate] manifestsURL]];
    
    newManifest.title = manifestRelativePath;
    newManifest.manifestURL = fileURL;
    newManifest.originalManifest = [NSDictionary dictionary];
    
    /*
     Create catalog proxy objects
     */
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    for (CatalogMO *catalog in [self allObjectsForEntity:@"Catalog" sortDescriptors:@[sortByTitle] inManagedObjectContext:moc]) {
        NSString *catalogTitle = [catalog title];
        CatalogInfoMO *newCatalogInfo;
        newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:moc];
        newCatalogInfo.catalog.title = catalogTitle;
        [catalog addManifestsObject:newManifest];
        newCatalogInfo.manifest = newManifest;
        [catalog addCatalogInfosObject:newCatalogInfo];
        newCatalogInfo.isEnabledForManifestValue = NO;
        newCatalogInfo.originalIndexValue = 0;
        newCatalogInfo.indexInManifestValue = 0;
    }
    
    BOOL atomicWrites = [[NSUserDefaults standardUserDefaults] boolForKey:@"atomicWrites"];
    if ([(NSDictionary *)newManifest.originalManifest writeToURL:newManifest.manifestURL atomically:atomicWrites]) {
        /*
        Get file properties
         */
        NSDate *dateCreated;
        [newManifest.manifestURL getResourceValue:&dateCreated forKey:NSURLCreationDateKey error:nil];
        newManifest.manifestDateCreated = dateCreated;
        
        NSDate *dateLastOpened;
        [newManifest.manifestURL getResourceValue:&dateLastOpened forKey:NSURLContentAccessDateKey error:nil];
        newManifest.manifestDateLastOpened = dateLastOpened;
        
        NSDate *dateModified;
        [newManifest.manifestURL getResourceValue:&dateModified forKey:NSURLContentModificationDateKey error:nil];
        newManifest.manifestDateModified = dateModified;
        
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
    newManifest.manifestURL = (NSURL *)[[(MAMunkiAdmin_AppDelegate *)[NSApp delegate] manifestsURL] URLByAppendingPathComponent:title];
    newManifest.originalManifest = [NSDictionary dictionary];
    
    BOOL atomicWrites = [[NSUserDefaults standardUserDefaults] boolForKey:@"atomicWrites"];
    if ([(NSDictionary *)newManifest.originalManifest writeToURL:newManifest.manifestURL atomically:atomicWrites]) {
        return newManifest;
    } else {
        return nil;
    }
}

- (CategoryMO *)createCategoryWithTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)moc
{
    if (title == nil) {
        return nil;
    }
    
    if (moc == nil) {
        moc = [self appDelegateMoc];
    }
    
    /*
     Check for existing category with this title
     */
    NSFetchRequest *checkForExisting = [[NSFetchRequest alloc] init];
    [checkForExisting setEntity:[NSEntityDescription entityForName:@"Category" inManagedObjectContext:moc]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", title];
    [checkForExisting setPredicate:predicate];
    NSUInteger foundItems = [moc countForFetchRequest:checkForExisting error:nil];
    if (foundItems > 0) {
        DDLogError(@"Can't create. Found existing category with title: %@", title);
        return nil;
    }
    
    CategoryMO *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:moc];
    newCategory.title = title;
    return newCategory;
}

- (BOOL)renameCategory:(CategoryMO *)category newTitle:(NSString *)newTitle inManagedObjectContext:(NSManagedObjectContext *)moc
{
    /*
     Check if this rename operation makes sense...
     */
    if (category == nil) {
        return NO;
    }
    if ([category.title isEqualToString:newTitle]) {
        return NO;
    }
    
    if (moc == nil) {
        moc = [self appDelegateMoc];
    }
    
    /*
     Check for existing category with this title
     */
    NSFetchRequest *checkForExisting = [[NSFetchRequest alloc] init];
    [checkForExisting setEntity:[NSEntityDescription entityForName:@"Category" inManagedObjectContext:moc]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", newTitle];
    [checkForExisting setPredicate:predicate];
    NSUInteger foundItems = [moc countForFetchRequest:checkForExisting error:nil];
    if (foundItems > 0) {
        DDLogError(@"Can't rename. Found existing category with title: %@", newTitle);
        return NO;
    }
    
    category.title = newTitle;
    category.categorySourceListReference.title = newTitle;
    
    for (PackageMO *aPackage in category.packages) {
        aPackage.hasUnstagedChangesValue = YES;
    }
    
    return YES;
}

- (BOOL)deleteCategory:(CategoryMO *)category inManagedObjectContext:(NSManagedObjectContext *)moc
{
    if (category == nil) {
        return NO;
    }
    
    if (moc == nil) {
        moc = [self appDelegateMoc];
    }
    
    for (PackageMO *aPackage in category.packages) {
        aPackage.hasUnstagedChangesValue = YES;
    }
    
    [moc deleteObject:category.categorySourceListReference];
    [moc deleteObject:category];
    
    return YES;
}

- (BOOL)deleteDeveloper:(DeveloperMO *)developer inManagedObjectContext:(NSManagedObjectContext *)moc
{
    if (developer == nil) {
        return NO;
    }
    
    if (moc == nil) {
        moc = [self appDelegateMoc];
    }
    
    for (PackageMO *aPackage in developer.packages) {
        aPackage.hasUnstagedChangesValue = YES;
    }
    
    [moc deleteObject:developer.developerSourceListReference];
    [moc deleteObject:developer];
    
    return YES;
}

- (DeveloperMO *)createDeveloperWithTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)moc
{
    if (title == nil) {
        return nil;
    }
    
    if (moc == nil) {
        moc = [self appDelegateMoc];
    }
    /*
     Check for existing developer with this title
     */
    NSFetchRequest *checkForExisting = [[NSFetchRequest alloc] init];
    [checkForExisting setEntity:[NSEntityDescription entityForName:@"Developer" inManagedObjectContext:moc]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", title];
    [checkForExisting setPredicate:predicate];
    NSUInteger foundItems = [moc countForFetchRequest:checkForExisting error:nil];
    if (foundItems > 0) {
        DDLogError(@"Can't create. Found existing developer with title: %@", title);
        return nil;
    }
    
    DeveloperMO *newDeveloper = [NSEntityDescription insertNewObjectForEntityForName:@"Developer" inManagedObjectContext:moc];
    newDeveloper.title = title;
    return newDeveloper;
}

- (BOOL)renameDeveloper:(DeveloperMO *)developer newTitle:(NSString *)newTitle inManagedObjectContext:(NSManagedObjectContext *)moc
{
    /*
     Check if this rename operation makes sense...
     */
    if (developer == nil) {
        return NO;
    }
    if ([developer.title isEqualToString:newTitle]) {
        return NO;
    }
    
    if (moc == nil) {
        moc = [self appDelegateMoc];
    }
    
    /*
     Check for existing developer with this title
     */
    NSFetchRequest *checkForExisting = [[NSFetchRequest alloc] init];
    [checkForExisting setEntity:[NSEntityDescription entityForName:@"Developer" inManagedObjectContext:moc]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", newTitle];
    [checkForExisting setPredicate:predicate];
    NSUInteger foundItems = [moc countForFetchRequest:checkForExisting error:nil];
    if (foundItems > 0) {
        DDLogError(@"Can't rename. Found existing developer with title: %@", newTitle);
        return NO;
    }
    
    developer.title = newTitle;
    developer.developerSourceListReference.title = newTitle;
    
    for (PackageMO *aPackage in developer.packages) {
        aPackage.hasUnstagedChangesValue = YES;
    }
    
    return YES;
}

- (NSString *)uppercaseOrCapitalizedHeaderString:(NSString *)headerTitle
{
    if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_9) {
        /* On a 10.9 - 10.9.x system */
        return [headerTitle uppercaseString];
    } else {
        /* 10.10 or later system */
        return [headerTitle capitalizedString];
    }
}

- (id)sourceListItemWithTitle:(NSString *)title entityName:(NSString *)entityName managedObjectContext:(NSManagedObjectContext *)moc
{
    id theItem = nil;
    NSFetchRequest *fetchProducts = [[NSFetchRequest alloc] init];
    [fetchProducts setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
    [fetchProducts setPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    NSUInteger numFoundCatalogs = [moc countForFetchRequest:fetchProducts error:nil];
    if (numFoundCatalogs == 0) {
        theItem = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
        [theItem setTitle:title];
    } else {
        theItem = [[moc executeFetchRequest:fetchProducts error:nil] objectAtIndex:0];
    }
    return theItem;
}

- (void)configureSourceListDevelopersSection:(NSManagedObjectContext *)moc
{
    NSString *developersItemTitle = [self uppercaseOrCapitalizedHeaderString:@"Developers"];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"sidebarDevelopersVisible"]) {
        PackageSourceListItemMO *mainDevelopersItem = [self sourceListItemWithTitle:developersItemTitle entityName:@"PackageSourceListItem" managedObjectContext:moc];
        for (id child in mainDevelopersItem.children) {
            [moc deleteObject:child];
        }
        [moc deleteObject:mainDevelopersItem];
        return;
    }
    
    PackageSourceListItemMO *mainDevelopersItem = [self sourceListItemWithTitle:developersItemTitle entityName:@"PackageSourceListItem" managedObjectContext:moc];
    mainDevelopersItem.originalIndexValue = 3;
    mainDevelopersItem.parent = nil;
    mainDevelopersItem.isGroupItemValue = YES;
    
    NSImage *developerIcon = [NSImage imageNamed:@"developerTemplate"];
    NSImage *developerUnknownIcon = [NSImage imageNamed:@"developerUnknownTemplate"];
    
    DeveloperSourceListItemMO *noDeveloperSmartItem = [self sourceListItemWithTitle:@"Unknown" entityName:@"DeveloperSourceListItem" managedObjectContext:moc];
    noDeveloperSmartItem.itemType = @"smart";
    noDeveloperSmartItem.icon = developerUnknownIcon;
    noDeveloperSmartItem.parent = mainDevelopersItem;
    noDeveloperSmartItem.originalIndexValue = 10;
    noDeveloperSmartItem.filterPredicate = [NSPredicate predicateWithFormat:@"developer == nil"];
    noDeveloperSmartItem.developerReference = nil;
    
    /*
     Fetch all developers and create source list items
     */
    NSEntityDescription *entityDescr = [NSEntityDescription entityForName:@"Developer" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    [fetchRequest setSortDescriptors:@[sortByTitle]];
    [fetchRequest setEntity:entityDescr];
    NSUInteger numFoundDevelopers = [moc countForFetchRequest:fetchRequest error:nil];
    if (numFoundDevelopers != 0) {
        NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
        [results enumerateObjectsUsingBlock:^(DeveloperMO *developer, NSUInteger idx, BOOL *stop) {
            NSArray *devPackageNames = [developer.packages valueForKeyPath:@"@distinctUnionOfObjects.munki_name"];
            NSUInteger requiredCount = (NSUInteger)[[NSUserDefaults standardUserDefaults] integerForKey:@"sidebarDeveloperMinimumNumberOfPackageNames"];
            if ([devPackageNames count] >= requiredCount) {
                DeveloperSourceListItemMO *sourceListItem = [self sourceListItemWithTitle:developer.title entityName:@"DeveloperSourceListItem" managedObjectContext:moc];
                sourceListItem.icon = developerIcon;
                sourceListItem.itemType = @"regular";
                sourceListItem.parent = mainDevelopersItem;
                sourceListItem.originalIndexValue = 20;
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"developer.title == %@", developer.title];
                sourceListItem.filterPredicate = predicate;
                sourceListItem.developerReference = developer;
            } else {
                DeveloperSourceListItemMO *sourceListItem = [self sourceListItemWithTitle:developer.title entityName:@"DeveloperSourceListItem" managedObjectContext:moc];
                [moc deleteObject:sourceListItem];
            }
        }];
    }
}

- (void)configureSourceListCategoriesSection:(NSManagedObjectContext *)moc
{
    NSString *categoriesItemTitle = [self uppercaseOrCapitalizedHeaderString:@"Categories"];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"sidebarCategoriesVisible"]) {
        PackageSourceListItemMO *mainCategoriesItem = [self sourceListItemWithTitle:categoriesItemTitle entityName:@"PackageSourceListItem" managedObjectContext:moc];
        for (id child in mainCategoriesItem.children) {
            [moc deleteObject:child];
        }
        [moc deleteObject:mainCategoriesItem];
        return;
    }
    
    PackageSourceListItemMO *mainCategoriesItem = [self sourceListItemWithTitle:categoriesItemTitle entityName:@"PackageSourceListItem" managedObjectContext:moc];
    mainCategoriesItem.originalIndexValue = 2;
    mainCategoriesItem.parent = nil;
    mainCategoriesItem.isGroupItemValue = YES;
    
    NSImage *categoryMultipleIcon = [NSImage imageNamed:@"tagMultipleTemplate"];
    NSImage *categoryIcon = [NSImage imageNamed:@"tagTemplate"];
    
    CategorySourceListItemMO *noCategoriesSmartItem = [self sourceListItemWithTitle:@"Uncategorized" entityName:@"CategorySourceListItem" managedObjectContext:moc];
    noCategoriesSmartItem.itemType = @"smart";
    noCategoriesSmartItem.icon = categoryMultipleIcon;
    noCategoriesSmartItem.parent = mainCategoriesItem;
    noCategoriesSmartItem.originalIndexValue = 10;
    noCategoriesSmartItem.filterPredicate = [NSPredicate predicateWithFormat:@"category == nil"];
    noCategoriesSmartItem.categoryReference = nil;
    
    /*
     Fetch all categories and create source list items
     */
    NSEntityDescription *categoryEntityDescr = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:moc];
    NSFetchRequest *fetchForCatalogs = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    [fetchForCatalogs setSortDescriptors:@[sortByTitle]];
    [fetchForCatalogs setEntity:categoryEntityDescr];
    NSUInteger numFoundCatalogs = [moc countForFetchRequest:fetchForCatalogs error:nil];
    if (numFoundCatalogs != 0) {
        NSArray *allCatalogs = [moc executeFetchRequest:fetchForCatalogs error:nil];
        [allCatalogs enumerateObjectsUsingBlock:^(CategoryMO *category, NSUInteger idx, BOOL *stop) {
            CategorySourceListItemMO *categorySourceListItem = [self sourceListItemWithTitle:category.title entityName:@"CategorySourceListItem" managedObjectContext:moc];
            categorySourceListItem.itemType = @"regular";
            categorySourceListItem.icon = categoryIcon;
            categorySourceListItem.parent = mainCategoriesItem;
            categorySourceListItem.originalIndexValue = 20;
            NSPredicate *catalogPredicate = [NSPredicate predicateWithFormat:@"category.title == %@", category.title];
            categorySourceListItem.filterPredicate = catalogPredicate;
            categorySourceListItem.categoryReference = category;
            
        }];
    }
}

- (void)configureSourceListDirectoriesSection:(NSManagedObjectContext *)moc
{
    NSString *directoriesItemTitle = [self uppercaseOrCapitalizedHeaderString:@"Directories"];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"sidebarDirectoriesVisible"]) {
        PackageSourceListItemMO *directoriesGroupItem = [self sourceListItemWithTitle:directoriesItemTitle entityName:@"PackageSourceListItem" managedObjectContext:moc];
        for (id aDirectory in [self allObjectsForEntity:@"Directory" inManagedObjectContext:moc]) {
            [moc deleteObject:aDirectory];
        }
        [moc deleteObject:directoriesGroupItem];
        return;
    }
    
    MACoreDataManager *coreDataManager = [MACoreDataManager sharedManager];
    
    PackageSourceListItemMO *directoriesGroupItem = nil;
    NSFetchRequest *groupItemRequest = [[NSFetchRequest alloc] init];
    [groupItemRequest setEntity:[NSEntityDescription entityForName:@"PackageSourceListItem" inManagedObjectContext:moc]];
    NSPredicate *parentPredicate = [NSPredicate predicateWithFormat:@"title == %@", directoriesItemTitle];
    [groupItemRequest setPredicate:parentPredicate];
    NSUInteger foundItems = [moc countForFetchRequest:groupItemRequest error:nil];
    if (foundItems > 0) {
        directoriesGroupItem = [[moc executeFetchRequest:groupItemRequest error:nil] objectAtIndex:0];
    } else {
        directoriesGroupItem = [NSEntityDescription insertNewObjectForEntityForName:@"PackageSourceListItem" inManagedObjectContext:moc];
        directoriesGroupItem.title = directoriesItemTitle;
        directoriesGroupItem.originalIndexValue = 4;
        directoriesGroupItem.parent = nil;
        directoriesGroupItem.isGroupItemValue = YES;
    }
    
    NSImage *directoryIcon = [NSImage imageNamed:@"folder"];
    [directoryIcon setTemplate:YES];
    
    DirectoryMO *basePkgsInfoDirectory = [coreDataManager directoryWithURL:[(MAMunkiAdmin_AppDelegate *)[NSApp delegate] pkgsInfoURL] managedObjectContext:moc];
    basePkgsInfoDirectory.title = @"pkgsinfo";
    basePkgsInfoDirectory.icon = directoryIcon;
    basePkgsInfoDirectory.itemType = @"regular";
    basePkgsInfoDirectory.parent = directoriesGroupItem;
    basePkgsInfoDirectory.originalIndexValue = 10;
    basePkgsInfoDirectory.filterPredicate = [NSPredicate predicateWithFormat:@"packageInfoParentDirectoryURL == %@", [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] pkgsInfoURL]];
    
    
    NSArray *keysToget = [NSArray arrayWithObjects:NSURLNameKey, NSURLLocalizedNameKey, NSURLIsDirectoryKey, nil];
	NSFileManager *fm = [NSFileManager defaultManager];
    
	NSDirectoryEnumerator *pkgsInfoDirEnum = [fm enumeratorAtURL:[(MAMunkiAdmin_AppDelegate *)[NSApp delegate] pkgsInfoURL] includingPropertiesForKeys:keysToget options:(NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:nil];
	for (NSURL *anURL in pkgsInfoDirEnum)
	{
		NSNumber *isDir;
		[anURL getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
		if ([isDir boolValue]) {
            NSFetchRequest *checkForExistingRequest = [[NSFetchRequest alloc] init];
            [checkForExistingRequest setEntity:[NSEntityDescription entityForName:@"Directory" inManagedObjectContext:moc]];
            [checkForExistingRequest setPredicate:[NSPredicate predicateWithFormat:@"originalURL == %@", anURL]];
            NSUInteger numFoundDirectories = [moc countForFetchRequest:checkForExistingRequest error:nil];
            if (numFoundDirectories == 0) {
                DirectoryMO *newDirectory = [NSEntityDescription insertNewObjectForEntityForName:@"Directory" inManagedObjectContext:moc];
                newDirectory.originalURL = anURL;
                newDirectory.originalIndexValue = 10;
                newDirectory.itemType = @"regular";
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"packageInfoParentDirectoryURL == %@", anURL];
                newDirectory.filterPredicate = predicate;
                NSString *newTitle;
                [anURL getResourceValue:&newTitle forKey:NSURLNameKey error:nil];
                newDirectory.title = newTitle;
                newDirectory.icon = directoryIcon;
                
                NSURL *parentDirectory = [anURL URLByDeletingLastPathComponent];
                if ([parentDirectory isEqual:[(MAMunkiAdmin_AppDelegate *)[NSApp delegate] pkgsInfoURL]]) {
                    newDirectory.parent = basePkgsInfoDirectory;
                } else {
                    NSFetchRequest *parentRequest = [[NSFetchRequest alloc] init];
                    [parentRequest setEntity:[NSEntityDescription entityForName:@"Directory" inManagedObjectContext:moc]];
                    [parentRequest setPredicate:[NSPredicate predicateWithFormat:@"originalURL == %@", parentDirectory]];
                    NSUInteger numFoundParents = [moc countForFetchRequest:parentRequest error:nil];
                    if (numFoundParents > 0) {
                        DirectoryMO *parent = [[moc executeFetchRequest:parentRequest error:nil] objectAtIndex:0];
                        newDirectory.parent = parent;
                    }
                }
            }
        }
	}
}

- (void)configureSourceListInstallerTypesSection:(NSManagedObjectContext *)moc
{
    NSString *installerTypesItemTitle = [self uppercaseOrCapitalizedHeaderString:@"Installer Types"];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"sidebarInstallerTypesVisible"]) {
        PackageSourceListItemMO *mainTypesItem = [self sourceListItemWithTitle:installerTypesItemTitle entityName:@"PackageSourceListItem" managedObjectContext:moc];
        for (id child in mainTypesItem.children) {
            [moc deleteObject:child];
        }
        [moc deleteObject:mainTypesItem];
        return;
    }
    
    PackageSourceListItemMO *mainTypesItem = [self sourceListItemWithTitle:installerTypesItemTitle entityName:@"PackageSourceListItem" managedObjectContext:moc];
    mainTypesItem.originalIndexValue = 1;
    mainTypesItem.parent = nil;
    mainTypesItem.isGroupItemValue = YES;
    
    NSImage *smartIcon = [NSImage imageNamed:NSImageNameSmartBadgeTemplate];
    
    InstallerTypeSourceListItemMO *copyFromDmgSmartItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallerTypeSourceListItem" inManagedObjectContext:moc];
    copyFromDmgSmartItem.title = @"Copy from Disk Image";
    copyFromDmgSmartItem.icon = smartIcon;
    copyFromDmgSmartItem.itemType = @"smart";
    copyFromDmgSmartItem.parent = mainTypesItem;
    copyFromDmgSmartItem.originalIndexValue = 10;
    copyFromDmgSmartItem.filterPredicate = [NSPredicate predicateWithFormat:@"munki_installer_type == %@", @"copy_from_dmg"];
    
    InstallerTypeSourceListItemMO *packagesSmartItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallerTypeSourceListItem" inManagedObjectContext:moc];
    packagesSmartItem.title = @"Installer Package";
    packagesSmartItem.icon = smartIcon;
    packagesSmartItem.itemType = @"smart";
    packagesSmartItem.parent = mainTypesItem;
    packagesSmartItem.originalIndexValue = 20;
    packagesSmartItem.filterPredicate = [NSPredicate predicateWithFormat:@"munki_installer_type == %@ OR munki_installer_type == nil", @""];
    
    InstallerTypeSourceListItemMO *nopkgSmartItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallerTypeSourceListItem" inManagedObjectContext:moc];
    nopkgSmartItem.title = @"No Package";
    nopkgSmartItem.icon = smartIcon;
    nopkgSmartItem.itemType = @"smart";
    nopkgSmartItem.parent = mainTypesItem;
    nopkgSmartItem.originalIndexValue = 30;
    nopkgSmartItem.filterPredicate = [NSPredicate predicateWithFormat:@"munki_installer_type == %@", @"nopkg"];
    
    InstallerTypeSourceListItemMO *appleUpdatesSmartItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallerTypeSourceListItem" inManagedObjectContext:moc];
    appleUpdatesSmartItem.title = @"Apple Update Metadata";
    appleUpdatesSmartItem.icon = smartIcon;
    appleUpdatesSmartItem.itemType = @"smart";
    appleUpdatesSmartItem.parent = mainTypesItem;
    appleUpdatesSmartItem.originalIndexValue = 40;
    appleUpdatesSmartItem.filterPredicate = [NSPredicate predicateWithFormat:@"munki_installer_type == %@", @"apple_update_metadata"];

    InstallerTypeSourceListItemMO *startosinstallSmartItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallerTypeSourceListItem" inManagedObjectContext:moc];
    startosinstallSmartItem.title = @"startosinstall";
    startosinstallSmartItem.icon = smartIcon;
    startosinstallSmartItem.itemType = @"smart";
    startosinstallSmartItem.parent = mainTypesItem;
    startosinstallSmartItem.originalIndexValue = 45;
    startosinstallSmartItem.filterPredicate = [NSPredicate predicateWithFormat:@"munki_installer_type == %@", @"startosinstall"];

    InstallerTypeSourceListItemMO *configurationProfilesSmartItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallerTypeSourceListItem" inManagedObjectContext:moc];
    configurationProfilesSmartItem.title = @"Configuration Profile";
    configurationProfilesSmartItem.icon = smartIcon;
    configurationProfilesSmartItem.itemType = @"smart";
    configurationProfilesSmartItem.parent = mainTypesItem;
    configurationProfilesSmartItem.originalIndexValue = 50;
    configurationProfilesSmartItem.filterPredicate = [NSPredicate predicateWithFormat:@"munki_installer_type == %@", @"profile"];
    
    InstallerTypeSourceListItemMO *onDemandSmartItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallerTypeSourceListItem" inManagedObjectContext:moc];
    onDemandSmartItem.title = @"On Demand";
    onDemandSmartItem.icon = smartIcon;
    onDemandSmartItem.itemType = @"smart";
    onDemandSmartItem.parent = mainTypesItem;
    onDemandSmartItem.originalIndexValue = 51;
    onDemandSmartItem.filterPredicate = [NSPredicate predicateWithFormat:@"munki_OnDemand == %@", @(YES)];
    
    InstallerTypeSourceListItemMO *adobeSmartItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallerTypeSourceListItem" inManagedObjectContext:moc];
    adobeSmartItem.title = @"Adobe Installer";
    adobeSmartItem.icon = smartIcon;
    adobeSmartItem.itemType = @"smart";
    adobeSmartItem.parent = mainTypesItem;
    adobeSmartItem.originalIndexValue = 60;
    NSArray *adobePredicates = @[[NSPredicate predicateWithFormat:@"munki_installer_type CONTAINS %@", @"AdobeAcrobatUpdater"],
                                 [NSPredicate predicateWithFormat:@"munki_installer_type CONTAINS %@", @"AdobeCCPInstaller"],
                                 [NSPredicate predicateWithFormat:@"munki_installer_type CONTAINS %@", @"AdobeCS5AAMEEPackage"],
                                 [NSPredicate predicateWithFormat:@"munki_installer_type CONTAINS %@", @"AdobeCS5PatchInstaller"],
                                 [NSPredicate predicateWithFormat:@"munki_installer_type CONTAINS %@", @"AdobeSetup"],
                                 [NSPredicate predicateWithFormat:@"munki_installer_type CONTAINS %@", @"AdobeUberInstaller"]];
    NSPredicate *adobePredicatesCombined = [NSCompoundPredicate orPredicateWithSubpredicates:adobePredicates];
    adobeSmartItem.filterPredicate = adobePredicatesCombined;
}

- (void)configureSourceListRepositorySection:(NSManagedObjectContext *)moc
{
    PackageSourceListItemMO *newSourceListItem2 = [NSEntityDescription insertNewObjectForEntityForName:@"PackageSourceListItem" inManagedObjectContext:moc];
    newSourceListItem2.title = [self uppercaseOrCapitalizedHeaderString:@"Repository"];
    newSourceListItem2.originalIndexValue = 0;
    newSourceListItem2.parent = nil;
    newSourceListItem2.isGroupItemValue = YES;
    
    NSImage *allPackagesIcon = [NSImage imageNamed:@"inbox"];
    [allPackagesIcon setTemplate:YES];
    NSImage *newPackagesIcon = [NSImage imageNamed:@"calendar_ok"];
    [newPackagesIcon setTemplate:YES];
    
    PackageSourceListItemMO *allPackagesSmartItem = [NSEntityDescription insertNewObjectForEntityForName:@"PackageSourceListItem" inManagedObjectContext:moc];
    allPackagesSmartItem.title = @"All Packages";
    allPackagesSmartItem.icon = allPackagesIcon;
    allPackagesSmartItem.itemType = @"smart";
    allPackagesSmartItem.parent = newSourceListItem2;
    allPackagesSmartItem.originalIndexValue = 10;
    allPackagesSmartItem.filterPredicate = [NSPredicate predicateWithValue:TRUE];
    
    PackageSourceListItemMO *newPackagesSmartItem = [NSEntityDescription insertNewObjectForEntityForName:@"PackageSourceListItem" inManagedObjectContext:moc];
    newPackagesSmartItem.title = @"Recently Modified";
    newPackagesSmartItem.icon = newPackagesIcon;
    newPackagesSmartItem.itemType = @"smart";
    newPackagesSmartItem.parent = newSourceListItem2;
    newPackagesSmartItem.originalIndexValue = 20;
    NSDate *now = [NSDate date];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = -30;
    NSDate *thirtyDaysAgo = [[NSCalendar currentCalendar] dateByAddingComponents:dayComponent toDate:now options:0];
    NSPredicate *thirtyDaysAgoPredicate = [NSPredicate predicateWithFormat:@"packageInfoDateCreated >= %@", thirtyDaysAgo];
    newPackagesSmartItem.filterPredicate = thirtyDaysAgoPredicate;
    NSSortDescriptor *sortByDateModified = [NSSortDescriptor sortDescriptorWithKey:@"packageInfoDateModified" ascending:NO];
    NSSortDescriptor *sortByMunkiName = [NSSortDescriptor sortDescriptorWithKey:@"munki_name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByMunkiDisplayName = [NSSortDescriptor sortDescriptorWithKey:@"munki_display_name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByMunkiVersion = [NSSortDescriptor sortDescriptorWithKey:@"munki_version" ascending:YES selector:@selector(localizedStandardCompare:)];
    newPackagesSmartItem.sortDescriptors = @[sortByDateModified, sortByMunkiName, sortByMunkiVersion, sortByMunkiDisplayName];
}


- (void)configureSourcelistItems:(NSManagedObjectContext *)moc
{
    [self configureSourceListCategoriesSection:moc];
    [self configureSourceListDevelopersSection:moc];
    [self configureSourceListDirectoriesSection:moc];
}

# pragma mark -
# pragma mark Helpers

- (NSManagedObjectContext *)appDelegateMoc
{
    return [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
}

- (NSArray *)allObjectsForEntity:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors inManagedObjectContext:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entityDescr = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescr];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:nil];
    return fetchResults;
}

- (NSArray *)allObjectsForEntity:(NSString *)entityName inManagedObjectContext:(NSManagedObjectContext *)moc
{
    NSArray *fetchResults = [self allObjectsForEntity:entityName sortDescriptors:nil inManagedObjectContext:moc];
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
