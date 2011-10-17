#import "PackageMO.h"
#import "CatalogInfoMO.h"
#import "ApplicationMO.h"
#import "PackageInfoMO.h"
#import "ReceiptMO.h"
#import "InstallsItemMO.h"
#import "InstallerChoicesItemMO.h"
#import "ItemToCopyMO.h"
#import "StringObjectMO.h"

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
    
    // installer_choices_xml
    NSMutableDictionary *newInstallerChoicesKeyMappings = [[[NSMutableDictionary alloc] init] autorelease];
	for (NSString *installerChoice in [self.defaults arrayForKey:@"installerChoicesKeys"]) {
		[newInstallerChoicesKeyMappings setObject:installerChoice forKey:[NSString stringWithFormat:@"munki_%@", installerChoice]];
	}
	
    // ==================================================
    // Compose the pkginfo dictionary from current values
    // ==================================================
	[newPkginfoKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id value = [self valueForKey:key];
        if (value != nil) {
            
            // ===========================================================
            // Work around for writing boolean values to property lists
            // We need <false/> or <true/> instead of <integer>1</integer>
            // ===========================================================
            if ([key isEqualToString:@"munki_autoremove"]) {
                if (self.munki_autoremoveValue) {
                    [tmpDict setValue:(id)kCFBooleanTrue forKey:obj];
                } else {
                    [tmpDict setValue:(id)kCFBooleanFalse forKey:obj];
                }
            }
            
            // =====================================
            // forced_install --> unattended_install
            // =====================================
            else if ([key isEqualToString:@"munki_forced_install"]) {
                if (self.munki_forced_installValue) {
                    [tmpDict setValue:(id)kCFBooleanTrue forKey:@"unattended_install"];
                } else {
                    [tmpDict setValue:(id)kCFBooleanFalse forKey:@"unattended_install"];
                }
            }
            // =========================================
            // forced_uninstall --> unattended_uninstall
            // =========================================
            else if ([key isEqualToString:@"munki_forced_uninstall"]) {
                if (self.munki_forced_uninstallValue) {
                    [tmpDict setValue:(id)kCFBooleanTrue forKey:@"unattended_uninstall"];
                } else {
                    [tmpDict setValue:(id)kCFBooleanFalse forKey:@"unattended_uninstall"];
                }
            }
            else if ([key isEqualToString:@"munki_unattended_install"]) {
                if (self.munki_unattended_installValue) {
                    [tmpDict setValue:(id)kCFBooleanTrue forKey:obj];
                } else {
                    [tmpDict setValue:(id)kCFBooleanFalse forKey:obj];
                }
            }
            else if ([key isEqualToString:@"munki_unattended_uninstall"]) {
                if (self.munki_unattended_uninstallValue) {
                    [tmpDict setValue:(id)kCFBooleanTrue forKey:obj];
                } else {
                    [tmpDict setValue:(id)kCFBooleanFalse forKey:obj];
                }
            }
            else if ([key isEqualToString:@"munki_uninstallable"]) {
                if (self.munki_uninstallableValue) {
                    [tmpDict setValue:(id)kCFBooleanTrue forKey:obj];
                } else {
                    [tmpDict setValue:(id)kCFBooleanFalse forKey:obj];
                }
            }
            // =====================================================
            // For everything else just write the values as they are
            // =====================================================
            else {
                [tmpDict setValue:value forKey:obj];
            }
        }
        else {
            //NSLog(@"Got nil value for key: %@", [obj description]);
        }
	}];
	
	
	// ==========
	// catalogs
	// ==========
	NSSortDescriptor *sortByCatalogTitle = [NSSortDescriptor sortDescriptorWithKey:@"catalog.title" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortCatalogsByOrigIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
	
	NSMutableArray *catalogs = [NSMutableArray arrayWithCapacity:[self.catalogInfos count]];
	for (CatalogInfoMO *catalogInfo in [self.catalogInfos sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortCatalogsByOrigIndex, sortByCatalogTitle, nil]]) {
		if (([catalogInfo isEnabledForPackageValue]) && (![catalogs containsObject:[[catalogInfo catalog] title]])) {
			[catalogs addObject:[[catalogInfo catalog] title]];
		}
	}
	
	for (PackageInfoMO *packageInfo in [self.packageInfos sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByCatalogTitle]]) {
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
	
	
	// ==========
	// update_for
	// ==========
	NSSortDescriptor *sortUpdateForItemsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortUpdateForItemsByOrigIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
	NSMutableArray *updateForItems = [NSMutableArray arrayWithCapacity:[self.updateFor count]];
	for (StringObjectMO *updateForItem in [self.updateFor sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortUpdateForItemsByOrigIndex, sortUpdateForItemsByTitle, nil]]) {
		if (![updateForItems containsObject:[updateForItem title]]) {
			[updateForItems addObject:[updateForItem title]];
		}
	}
	if ([updateForItems count] == 0) {
		if ([(NSDictionary *)self.originalPkginfo objectForKey:@"update_for"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"update_for"];
		}
	} else {
		[tmpDict setObject:updateForItems forKey:@"update_for"];
	}
	
	
	// ==========
	// requires
	// ==========
	NSSortDescriptor *sortRequiresItemsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortRequiresByOrigIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
	NSMutableArray *requiresItems = [NSMutableArray arrayWithCapacity:[self.requirements count]];
	for (StringObjectMO *requiresItem in [self.requirements sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortRequiresByOrigIndex, sortRequiresItemsByTitle, nil]]) {
		if (![requiresItems containsObject:[requiresItem title]]) {
			[requiresItems addObject:[requiresItem title]];
		}
	}
	if ([requiresItems count] == 0) {
		if ([(NSDictionary *)self.originalPkginfo objectForKey:@"requires"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"requires"];
		}
	} else {
		[tmpDict setObject:requiresItems forKey:@"requires"];
	}
    
    
    // ==========
	// blocking_applications
	// ==========
	NSSortDescriptor *sortBlockingItemsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortBlockingByOrigIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
	NSMutableArray *blockingApplicationsItems = [NSMutableArray arrayWithCapacity:[self.blockingApplications count]];
	for (StringObjectMO *blockingItem in [self.blockingApplications sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortBlockingItemsByTitle, sortBlockingByOrigIndex, nil]]) {
		if (![blockingApplicationsItems containsObject:[blockingItem title]]) {
			[blockingApplicationsItems addObject:[blockingItem title]];
		}
	}
	if ([blockingApplicationsItems count] == 0) {
		if ([(NSDictionary *)self.originalPkginfo objectForKey:@"blocking_applications"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"blocking_applications"];
		}
	} else {
		[tmpDict setObject:blockingApplicationsItems forKey:@"blocking_applications"];
	}
	
	// ==========
	// receipts
	// ==========
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
	
	
	// ==========
	// installs
	// ==========
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
	
	
	// =============
	// items_to_copy
	// =============
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
	
    
    // ======================
	// installer_choices_xml
	// ======================
	NSSortDescriptor *sortByChoiceIdentifier = [NSSortDescriptor sortDescriptorWithKey:@"munki_choiceIdentifier" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortByChoiceAttribute = [NSSortDescriptor sortDescriptorWithKey:@"munki_choiceAttribute" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSArray *installerChoicesSorters = [NSArray arrayWithObjects:sortByChoiceIdentifier, sortByChoiceAttribute, nil];
	
	NSMutableArray *installerItems = [NSMutableArray arrayWithCapacity:[self.installerChoicesItems count]];
    for (InstallerChoicesItemMO *aChoice in [self.installerChoicesItems sortedArrayUsingDescriptors:installerChoicesSorters]) {
        [installerItems addObject:[aChoice dictValueForSave]];
    }
	if ([installerItems count] == 0) {
		if ([(NSDictionary *)self.originalPkginfo objectForKey:@"installer_choices_xml"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"installer_choices_xml"];
		}
	} else {
		[tmpDict setObject:installerItems forKey:@"installer_choices_xml"];
	}
    
    
	NSDictionary *infoDictInMemory = [NSDictionary dictionaryWithDictionary:tmpDict];
	return infoDictInMemory;
}

- (NSString *)formattedTitle
{
	return [self.munki_display_name stringByAppendingFormat:@" - version %@", self.munki_version];
}

@end
