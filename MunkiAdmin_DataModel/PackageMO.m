#import "PackageMO.h"
#import "CatalogInfoMO.h"
#import "ApplicationMO.h"
#import "PackageInfoMO.h"
#import "ReceiptMO.h"
#import "InstallsItemMO.h"
#import "ItemToCopyMO.h"

@implementation PackageMO


+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	// Define keys that depend on parent application
    /*if ([key isEqualToString:@"munki_name"])
    {
        NSSet *affectingKeys = [NSSet setWithObjects:@"parentApplication.munki_name", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    } 
	
	else if ([key isEqualToString:@"munki_display_name"])
    {
        NSSet *affectingKeys = [NSSet setWithObjects:@"parentApplication.munki_display_name", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }
	
	else if ([key isEqualToString:@"munki_description"])
    {
        NSSet *affectingKeys = [NSSet setWithObjects:@"parentApplication.munki_description", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }*/
	
    return keyPaths;
}

- (NSUserDefaults *)defaults
{
	return [NSUserDefaults standardUserDefaults];
}

- (NSDictionary *)dictValue
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.munki_name, @"title",
			self.munki_version, @"subtitle",
			@"package", @"type",
			nil];
}

- (NSDictionary *)pkgInfoDictionary
{
	NSMutableDictionary *tmpDict = [[[NSMutableDictionary alloc] init] autorelease];
	
	// Define the munki keys we support
	NSMutableDictionary *newPkginfoKeyMappings = [[[NSMutableDictionary alloc] init] autorelease];
	for (NSString *pkginfoKey in [self.defaults arrayForKey:@"pkginfoKeys"]) {
		[newPkginfoKeyMappings setObject:pkginfoKey forKey:[NSString stringWithFormat:@"munki_%@", pkginfoKey]];
	}
	
	// Receipt keys
	NSMutableDictionary *newReceiptKeyMappings = [[[NSMutableDictionary alloc] init] autorelease];
	for (NSString *receiptKey in [self.defaults arrayForKey:@"receiptKeys"]) {
		[newReceiptKeyMappings setObject:receiptKey forKey:[NSString stringWithFormat:@"munki_%@", receiptKey]];
	}
	
	// Installs item keys
	NSMutableDictionary *newInstallsKeyMappings = [[[NSMutableDictionary alloc] init] autorelease];
	for (NSString *installsKey in [self.defaults arrayForKey:@"installsKeys"]) {
		[newInstallsKeyMappings setObject:installsKey forKey:[NSString stringWithFormat:@"munki_%@", installsKey]];
	}
	
	// items_to_copy keys
	NSMutableDictionary *newItemsToCopyKeyMappings = [[[NSMutableDictionary alloc] init] autorelease];
	for (NSString *itemToCopy in [self.defaults arrayForKey:@"itemsToCopyKeys"]) {
		[newItemsToCopyKeyMappings setObject:itemToCopy forKey:[NSString stringWithFormat:@"munki_%@", itemToCopy]];
	}
	
	[newPkginfoKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		id value = [self valueForKey:key];
		if (value != nil) {
			[tmpDict setValue:value forKey:obj];
		} else {

		}
	}];
	
	NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"catalog.title" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortCatalogsByOrigIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
	
	NSMutableArray *catalogs = [NSMutableArray arrayWithCapacity:[self.catalogInfos count]];
	for (CatalogInfoMO *catalogInfo in [self.catalogInfos sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortCatalogsByOrigIndex, sortByTitle, nil]]) {
		if (([catalogInfo isEnabledForPackageValue]) && (![catalogs containsObject:[[catalogInfo catalog] title]])) {
			[catalogs addObject:[[catalogInfo catalog] title]];
		}
	}
	
	for (PackageInfoMO *packageInfo in [self.packageInfos sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByTitle]]) {
		if (([packageInfo isEnabledForCatalogValue]) && (![catalogs containsObject:[packageInfo.catalog title]])) {
			[catalogs addObject:[packageInfo.catalog title]];
		} else if ((![packageInfo isEnabledForCatalogValue]) && ([catalogs containsObject:[packageInfo.catalog title]])) {
			[catalogs removeObject:[packageInfo.catalog title]];
		}
	}
	
	if ([catalogs count] == 0) {
		if ([(NSDictionary *)self.originalPkginfo objectForKey:@"catalogs"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"catalogs"];
		}
	} else {
		[tmpDict setObject:catalogs forKey:@"catalogs"];
	}
	
	
	NSSortDescriptor *sortByPackageID = [NSSortDescriptor sortDescriptorWithKey:@"munki_packageid" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortByFilename = [NSSortDescriptor sortDescriptorWithKey:@"munki_filename" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortByVersion = [NSSortDescriptor sortDescriptorWithKey:@"munki_version" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSArray *receiptSorters = [NSArray arrayWithObjects:sortByPackageID, sortByFilename, sortByVersion, nil];
	
	NSMutableArray *receipts = [NSMutableArray arrayWithCapacity:[self.receipts count]];
	for (ReceiptMO *aReceipt in [self.receipts sortedArrayUsingDescriptors:receiptSorters]) {
		[receipts addObject:[aReceipt dictValueForSave]];
	}
	if ([receipts count] == 0) {
		if ([(NSDictionary *)self.originalPkginfo objectForKey:@"receipts"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"receipts"];
		}
	} else {
		[tmpDict setObject:receipts forKey:@"receipts"];
	}
	
	NSSortDescriptor *sortByCFBundleIdentifier = [NSSortDescriptor sortDescriptorWithKey:@"munki_CFBundleIdentifier" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortByPath = [NSSortDescriptor sortDescriptorWithKey:@"munki_path" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortByCFBundleName = [NSSortDescriptor sortDescriptorWithKey:@"munki_CFBundleName" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortByCFBundleShortVersionString = [NSSortDescriptor sortDescriptorWithKey:@"munki_CFBundleShortVersionString" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSArray *installsSorters = [NSArray arrayWithObjects:sortByCFBundleIdentifier, sortByPath, sortByCFBundleName, sortByCFBundleShortVersionString, nil];
	
	NSMutableArray *installs = [NSMutableArray arrayWithCapacity:[self.installsItems count]];
	for (InstallsItemMO *anInstallsItem in [self.installsItems sortedArrayUsingDescriptors:installsSorters]) {
		[installs addObject:[anInstallsItem dictValueForSave]];
	}
	if ([installs count] == 0) {
		if ([(NSDictionary *)self.originalPkginfo objectForKey:@"installs"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"installs"];
		}
	} else {
		[tmpDict setObject:installs forKey:@"installs"];
	}
	
	NSSortDescriptor *sortByDestPath = [NSSortDescriptor sortDescriptorWithKey:@"munki_destination_path" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortBySourceItem = [NSSortDescriptor sortDescriptorWithKey:@"munki_source_item" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortByUser = [NSSortDescriptor sortDescriptorWithKey:@"munki_user" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortByGroup = [NSSortDescriptor sortDescriptorWithKey:@"munki_group" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSArray *itemsToCopySorters = [NSArray arrayWithObjects:sortByDestPath, sortBySourceItem, sortByUser, sortByGroup, nil];
	
	NSMutableArray *itemsToCopyItems = [NSMutableArray arrayWithCapacity:[self.itemsToCopy count]];
	for (ItemToCopyMO *anItemToCopy in [self.itemsToCopy sortedArrayUsingDescriptors:itemsToCopySorters]) {
		[itemsToCopyItems addObject:[anItemToCopy dictValueForSave]];
	}
	if ([itemsToCopyItems count] == 0) {
		if ([(NSDictionary *)self.originalPkginfo objectForKey:@"items_to_copy"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"items_to_copy"];
		}
	} else {
		[tmpDict setObject:itemsToCopyItems forKey:@"items_to_copy"];
	}
	
	NSDictionary *infoDictInMemory = [NSDictionary dictionaryWithDictionary:tmpDict];
	return infoDictInMemory;
}

- (NSString *)formattedTitle
{
	return [self.munki_display_name stringByAppendingFormat:@" - version %@", self.munki_version];
}

@end
