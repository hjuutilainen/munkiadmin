#import "PackageMO.h"
#import "CatalogInfoMO.h"
#import "ApplicationMO.h"
#import "PackageInfoMO.h"
#import "ReceiptMO.h"
#import "InstallsItemMO.h"

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
	NSSortDescriptor *sortByTitle = [[[NSSortDescriptor alloc] initWithKey:@"catalog.title" ascending:YES selector:@selector(localizedStandardCompare:)] autorelease];
	NSMutableArray *catalogs = [NSMutableArray arrayWithCapacity:[self.catalogInfos count]];
	for (CatalogInfoMO *catalogInfo in [self.catalogInfos sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByTitle]]) {
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
	
	NSSortDescriptor *sortByPackageID = [[[NSSortDescriptor alloc] initWithKey:@"munki_packageid" ascending:YES selector:@selector(localizedStandardCompare:)] autorelease];
	NSMutableArray *receipts = [NSMutableArray arrayWithCapacity:[self.receipts count]];
	for (ReceiptMO *aReceipt in [self.receipts sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByPackageID]]) {
		[receipts addObject:[aReceipt dictValueForSave]];
	}
	
	NSSortDescriptor *sortByCFBundleIdentifier = [[[NSSortDescriptor alloc] initWithKey:@"munki_CFBundleIdentifier" ascending:YES selector:@selector(localizedStandardCompare:)] autorelease];
	NSSortDescriptor *sortByPath = [[[NSSortDescriptor alloc] initWithKey:@"munki_path" ascending:YES selector:@selector(localizedStandardCompare:)] autorelease];
	NSMutableArray *installs = [NSMutableArray arrayWithCapacity:[self.installsItems count]];
	for (InstallsItemMO *anInstallsItem in [self.installsItems sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortByCFBundleIdentifier, sortByPath, nil]]) {
		[installs addObject:[anInstallsItem dictValueForSave]];
	}
	
	/*
	// Trying to combine the ApplicationMO and PackageMO descriptions
	NSString *combinedDescription;
	BOOL descrAreEqual = [self.munki_description isEqualToString:self.parentApplication.munki_description];
	BOOL parentDescIsEmpty = [self.parentApplication.munki_description isEqualToString:@""];
	BOOL pkgDescIsEmpty = [self.munki_description isEqualToString:@""];
	
	if (descrAreEqual) {
		combinedDescription = self.munki_description;
	} else if (pkgDescIsEmpty && !parentDescIsEmpty) {
		combinedDescription = self.parentApplication.munki_description;
	} else if (!pkgDescIsEmpty && parentDescIsEmpty) {
		combinedDescription = self.munki_description;
	} else if (!pkgDescIsEmpty && !parentDescIsEmpty && !descrAreEqual) {
		combinedDescription = self.munki_description;
	}*/
	
	NSDictionary *infoDictInMemory = [NSDictionary dictionaryWithObjectsAndKeys:
									  self.munki_autoremove, @"autoremove",
									  catalogs, @"catalogs",
									  self.munki_description, @"description",
									  self.munki_display_name, @"display_name",
									  self.munki_installed_size, @"installed_size",
									  self.munki_installer_item_hash, @"installer_item_hash",
									  self.munki_installer_item_location, @"installer_item_location",
									  self.munki_installer_item_size, @"installer_item_size",
									  self.munki_installer_type, @"installer_type",
									  installs, @"installs",
									  self.munki_minimum_os_version, @"minimum_os_version",
									  self.munki_name, @"name",
									  receipts, @"receipts",
									  self.munki_uninstall_method, @"uninstall_method",
									  self.munki_uninstallable, @"uninstallable",
									  self.munki_version, @"version",
									  nil];
		
	return infoDictInMemory;
}

- (NSString *)formattedTitle
{
	return [self.munki_display_name stringByAppendingFormat:@" - version %@", self.munki_version];
}

@end
