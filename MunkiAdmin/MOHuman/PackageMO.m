#import "PackageMO.h"
#import "CatalogInfoMO.h"
#import "ApplicationMO.h"
#import "PackageInfoMO.h"
#import "ReceiptMO.h"
#import "InstallsItemMO.h"
#import "InstallerChoicesItemMO.h"
#import "InstallerEnvironmentVariableMO.h"
#import "ItemToCopyMO.h"
#import "StringObjectMO.h"
#import "MAMunkiAdmin_AppDelegate.h"

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
    
    
    NSArray *catalogDescriptionKeys = @[@"catalogsDescriptionString", @"catalogStrings", @"catalogShortStrings"];
    
    if ([catalogDescriptionKeys containsObject:key]) {
        NSSet *affectingKeys = [NSSet setWithObjects:@"catalogs", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }
    
    return keyPaths;
}

- (NSImage *)packageInfoIconImage
{
    return [[NSWorkspace sharedWorkspace] iconForFile:[self.packageInfoURL relativePath]];
}

- (NSImage *)packageIconImage
{
    return [[NSWorkspace sharedWorkspace] iconForFile:[self.packageURL relativePath]];
}

- (NSURL *)parentURL
{
    return [self.packageInfoURL URLByDeletingLastPathComponent];
}

- (NSString *)relativePath
{
    NSMutableArray *relativePathComponents = [NSMutableArray arrayWithArray:[self.packageInfoURL pathComponents]];
    
    NSURL *repoURL = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] pkgsInfoURL];
    NSArray *parentPathComponents = [NSArray arrayWithArray:[repoURL pathComponents]];
    NSArray *childPathComponents = [NSArray arrayWithArray:[self.packageInfoURL pathComponents]];
    
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

- (NSString *)catalogsDescriptionString
{
    NSArray *catalogStrings = [self catalogStrings];
    if (catalogStrings) {
        return [catalogStrings componentsJoinedByString:@", "];
    } else {
        return nil;
    }
    
}

- (NSArray *)catalogShortStrings
{
    NSMutableArray *catalogs = [NSMutableArray new];
    for (CatalogInfoMO *catalogInfo in self.catalogInfos) {
        if (([catalogInfo isEnabledForPackageValue]) && (![catalogs containsObject:[[catalogInfo catalog] shortTitle]])) {
            [catalogs addObject:[[catalogInfo catalog] shortTitle]];
        }
    }
    
    for (PackageInfoMO *packageInfo in self.packageInfos) {
        if (([packageInfo isEnabledForCatalogValue]) && (![catalogs containsObject:[packageInfo.catalog shortTitle]])) {
            [catalogs addObject:[packageInfo.catalog shortTitle]];
        } else if ((![packageInfo isEnabledForCatalogValue]) && ([catalogs containsObject:[packageInfo.catalog shortTitle]])) {
            [catalogs removeObject:[packageInfo.catalog shortTitle]];
        }
    }
    
    if ([catalogs count] == 0) {
        return nil;
    } else {
        return [catalogs sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    }
}

- (NSArray *)catalogStrings
{
    NSMutableArray *catalogs = [NSMutableArray new];
    for (CatalogInfoMO *catalogInfo in self.catalogInfos) {
        if (([catalogInfo isEnabledForPackageValue]) && (![catalogs containsObject:[[catalogInfo catalog] title]])) {
            [catalogs addObject:[[catalogInfo catalog] title]];
        }
    }
    
    for (PackageInfoMO *packageInfo in self.packageInfos) {
        if (([packageInfo isEnabledForCatalogValue]) && (![catalogs containsObject:[packageInfo.catalog title]])) {
            [catalogs addObject:[packageInfo.catalog title]];
        } else if ((![packageInfo isEnabledForCatalogValue]) && ([catalogs containsObject:[packageInfo.catalog title]])) {
            [catalogs removeObject:[packageInfo.catalog title]];
        }
    }
    
    if ([catalogs count] == 0) {
        return nil;
    } else {
        return [catalogs sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    }
}

- (NSNumber *)numberOfKeys
{
    return [NSNumber numberWithUnsignedInteger:[self.pkgInfoDictionary count]];
}

- (NSDictionary *)pkgInfoDictionary
{
	NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
	
	// Define the munki keys we support
	NSMutableDictionary *newPkginfoKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *pkginfoKey in [self.defaults arrayForKey:@"pkginfoBasicKeys"]) {
		[newPkginfoKeyMappings setObject:pkginfoKey forKey:[NSString stringWithFormat:@"munki_%@", pkginfoKey]];
	}
	
	// Receipt keys
	NSMutableDictionary *newReceiptKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *receiptKey in [self.defaults arrayForKey:@"receiptKeys"]) {
		[newReceiptKeyMappings setObject:receiptKey forKey:[NSString stringWithFormat:@"munki_%@", receiptKey]];
	}
	
	// Installs item keys
	NSMutableDictionary *newInstallsKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *installsKey in [self.defaults arrayForKey:@"installsKeys"]) {
		[newInstallsKeyMappings setObject:installsKey forKey:[NSString stringWithFormat:@"munki_%@", installsKey]];
	}
	
	// items_to_copy keys
	NSMutableDictionary *newItemsToCopyKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *itemToCopy in [self.defaults arrayForKey:@"itemsToCopyKeys"]) {
		[newItemsToCopyKeyMappings setObject:itemToCopy forKey:[NSString stringWithFormat:@"munki_%@", itemToCopy]];
	}
    
    // installer_choices_xml
    NSMutableDictionary *newInstallerChoicesKeyMappings = [[NSMutableDictionary alloc] init];
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
                if (self.munki_unattended_installValue) {
                    [tmpDict setValue:(id)kCFBooleanTrue forKey:obj];
                } else {
                    [tmpDict setValue:(id)kCFBooleanFalse forKey:obj];
                }
            }
            // =========================================
            // forced_uninstall --> unattended_uninstall
            // =========================================
            else if ([key isEqualToString:@"munki_forced_uninstall"]) {
                if (self.munki_unattended_uninstallValue) {
                    [tmpDict setValue:(id)kCFBooleanTrue forKey:obj];
                } else {
                    [tmpDict setValue:(id)kCFBooleanFalse forKey:obj];
                }
            }
            
            // =========================================
            // Other boolean values
            // =========================================
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
            else if ([key isEqualToString:@"munki_suppress_bundle_relocation"]) {
                if (self.munki_suppress_bundle_relocationValue) {
                    [tmpDict setValue:(id)kCFBooleanTrue forKey:obj];
                } else {
                    [tmpDict setValue:(id)kCFBooleanFalse forKey:obj];
                }
            }
            else if ([key isEqualToString:@"munki_OnDemand"]) {
                if (self.munki_OnDemandValue) {
                    [tmpDict setValue:(id)kCFBooleanTrue forKey:obj];
                } else {
                    [tmpDict setValue:(id)kCFBooleanFalse forKey:obj];
                }
            }
            else if ([key isEqualToString:@"munki_apple_item"]) {
                if (self.munki_apple_itemValue) {
                    [tmpDict setValue:(id)kCFBooleanTrue forKey:obj];
                } else {
                    [tmpDict setValue:(id)kCFBooleanFalse forKey:obj];
                }
            }
            else if ([key isEqualToString:@"munki_allow_untrusted"]) {
                if (self.munki_allow_untrustedValue) {
                    [tmpDict setValue:(id)kCFBooleanTrue forKey:obj];
                } else {
                    [tmpDict setValue:(id)kCFBooleanFalse forKey:obj];
                }
            }
            else if ([key isEqualToString:@"munki_precache"]) {
                if (self.munki_precacheValue) {
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
    
    /*
     Category
     */
    if (self.category != nil) {
        [tmpDict setValue:self.category.title forKey:@"category"];
    }
    
    /*
     Developer
     */
    if (self.developer != nil) {
        [tmpDict setValue:self.developer.title forKey:@"developer"];
    }
    
    /*
     Preinstall alert
     */
    if (self.munki_preinstall_alert_enabledValue) {
        NSMutableDictionary *preinstallAlert = [NSMutableDictionary new];
        if (self.munki_preinstall_alert_alert_title && ![self.munki_preinstall_alert_alert_title isEqualToString:@""]) {
            preinstallAlert[@"alert_title"] = self.munki_preinstall_alert_alert_title;
        }
        if (self.munki_preinstall_alert_alert_detail && ![self.munki_preinstall_alert_alert_detail isEqualToString:@""]) {
            preinstallAlert[@"alert_detail"] = self.munki_preinstall_alert_alert_detail;
        }
        if (self.munki_preinstall_alert_ok_label && ![self.munki_preinstall_alert_ok_label isEqualToString:@""]) {
            preinstallAlert[@"ok_label"] = self.munki_preinstall_alert_ok_label;
        }
        if (self.munki_preinstall_alert_cancel_label && ![self.munki_preinstall_alert_cancel_label isEqualToString:@""]) {
            preinstallAlert[@"cancel_label"] = self.munki_preinstall_alert_cancel_label;
        }
        [tmpDict setValue:preinstallAlert forKey:@"preinstall_alert"];
    }
    
    /*
     Preuninstall alert
     */
    if (self.munki_preuninstall_alert_enabledValue) {
        NSMutableDictionary *preuninstallAlert = [NSMutableDictionary new];
        if (self.munki_preuninstall_alert_alert_title && ![self.munki_preuninstall_alert_alert_title isEqualToString:@""]) {
            preuninstallAlert[@"alert_title"] = self.munki_preuninstall_alert_alert_title;
        }
        if (self.munki_preuninstall_alert_alert_detail && ![self.munki_preuninstall_alert_alert_detail isEqualToString:@""]) {
            preuninstallAlert[@"alert_detail"] = self.munki_preuninstall_alert_alert_detail;
        }
        if (self.munki_preuninstall_alert_ok_label && ![self.munki_preuninstall_alert_ok_label isEqualToString:@""]) {
            preuninstallAlert[@"ok_label"] = self.munki_preuninstall_alert_ok_label;
        }
        if (self.munki_preuninstall_alert_cancel_label && ![self.munki_preuninstall_alert_cancel_label isEqualToString:@""]) {
            preuninstallAlert[@"cancel_label"] = self.munki_preuninstall_alert_cancel_label;
        }
        [tmpDict setValue:preuninstallAlert forKey:@"preuninstall_alert"];
    }
	
	
	// ==========
	// catalogs
	// ==========
    NSArray *sortDescriptors;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sortPkginfoCatalogsByTitle"]) {
        sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"catalog.title" ascending:YES selector:@selector(localizedStandardCompare:)]];
    } else {
        sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)],
                            [NSSortDescriptor sortDescriptorWithKey:@"catalog.title" ascending:YES selector:@selector(localizedStandardCompare:)]];
    }
	
	NSMutableArray *catalogs = [NSMutableArray arrayWithCapacity:[self.catalogInfos count]];
    NSArray *sortedCatalogInfos = [self.catalogInfos sortedArrayUsingDescriptors:sortDescriptors];
	for (CatalogInfoMO *catalogInfo in sortedCatalogInfos) {
		if (([catalogInfo isEnabledForPackageValue]) && (![catalogs containsObject:[[catalogInfo catalog] title]])) {
			[catalogs addObject:[[catalogInfo catalog] title]];
		}
	}
	
	for (PackageInfoMO *packageInfo in [self.packageInfos sortedArrayUsingDescriptors:sortDescriptors]) {
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
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sortPkginfoCatalogsByTitle"]) {
            [catalogs sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES selector:@selector(localizedStandardCompare:)]]];
        }
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
    
    
    // =====================
	// blocking_applications
    // =====================
	NSSortDescriptor *sortBlockingItemsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortBlockingByOrigIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
	NSMutableArray *blockingApplicationsItems = [NSMutableArray arrayWithCapacity:[self.blockingApplications count]];
	for (StringObjectMO *blockingItem in [self.blockingApplications sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortBlockingItemsByTitle, sortBlockingByOrigIndex, nil]]) {
		if (![blockingApplicationsItems containsObject:[blockingItem title]]) {
			[blockingApplicationsItems addObject:[blockingItem title]];
		}
	}
    if (self.hasEmptyBlockingApplicationsValue) {
        [tmpDict setObject:[NSArray array] forKey:@"blocking_applications"];
	}
	else if ([blockingApplicationsItems count] > 0) {
		[tmpDict setObject:blockingApplicationsItems forKey:@"blocking_applications"];
	}
    
    
    // =======================
	// supported_architectures
	// =======================
	NSSortDescriptor *sortArchItemsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortArchByOrigIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
	NSMutableArray *supportedArchitecturesItems = [NSMutableArray arrayWithCapacity:[self.supportedArchitectures count]];
	for (StringObjectMO *supportedArch in [self.supportedArchitectures sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortArchItemsByTitle, sortArchByOrigIndex, nil]]) {
		if (![supportedArchitecturesItems containsObject:[supportedArch title]]) {
			[supportedArchitecturesItems addObject:[supportedArch title]];
		}
	}
	if ([supportedArchitecturesItems count] > 0) {
		[tmpDict setObject:supportedArchitecturesItems forKey:@"supported_architectures"];
	}
    
	
    // ========
	// receipts
    // ========
	NSSortDescriptor *sortByPackageID = [NSSortDescriptor sortDescriptorWithKey:@"munki_packageid" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortByFilename = [NSSortDescriptor sortDescriptorWithKey:@"munki_filename" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortByVersion = [NSSortDescriptor sortDescriptorWithKey:@"munki_version" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortReceiptsByOrigIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
	NSArray *receiptSorters = [NSArray arrayWithObjects:sortReceiptsByOrigIndex, sortByPackageID, sortByFilename, sortByVersion, nil];
	
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
    NSSortDescriptor *sortInstallsByOrigIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
	NSArray *installsSorters = [NSArray arrayWithObjects:sortInstallsByOrigIndex, sortByCFBundleIdentifier, sortByPath, sortByCFBundleName, sortByCFBundleShortVersionString, nil];
	
	NSMutableArray *installs = [NSMutableArray arrayWithCapacity:[self.installsItems count]];
	for (InstallsItemMO *anInstallsItem in [self.installsItems sortedArrayUsingDescriptors:installsSorters]) {
		[installs addObject:[anInstallsItem dictValueForSave]];
	}
	if ([installs count] > 0) {
		[tmpDict setObject:installs forKey:@"installs"];
	}
	
	
	// =============
	// items_to_copy
	// =============
	NSSortDescriptor *sortByDestPath = [NSSortDescriptor sortDescriptorWithKey:@"munki_destination_path" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortBySourceItem = [NSSortDescriptor sortDescriptorWithKey:@"munki_source_item" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortByUser = [NSSortDescriptor sortDescriptorWithKey:@"munki_user" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortByGroup = [NSSortDescriptor sortDescriptorWithKey:@"munki_group" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortItemsToCopyByOrigIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
	NSArray *itemsToCopySorters = [NSArray arrayWithObjects:sortItemsToCopyByOrigIndex, sortByDestPath, sortBySourceItem, sortByUser, sortByGroup, nil];
	
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
    NSSortDescriptor *sortChoicesByOrigIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
	NSArray *installerChoicesSorters = [NSArray arrayWithObjects:sortChoicesByOrigIndex, sortByChoiceIdentifier, sortByChoiceAttribute, nil];
	
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
    
    // ======================
	// installer_environment
	// ======================
    NSSortDescriptor *sortByVariableKey = [NSSortDescriptor sortDescriptorWithKey:@"munki_installer_environment_key" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray *installerEnvironmentSorters = [NSArray arrayWithObjects:sortByVariableKey, nil];
    NSMutableDictionary *installerEnvironmentVariables = [NSMutableDictionary dictionaryWithCapacity:[self.installerEnvironmentVariables count]];
    for (InstallerEnvironmentVariableMO *variable in [self.installerEnvironmentVariables sortedArrayUsingDescriptors:installerEnvironmentSorters]) {
        [installerEnvironmentVariables setValuesForKeysWithDictionary:[variable dictValueForSave]];
    }
    if ([installerEnvironmentVariables count] > 0) {
        [tmpDict setObject:installerEnvironmentVariables forKey:@"installer_environment"];
    }
    
    
	NSDictionary *infoDictInMemory = [NSDictionary dictionaryWithDictionary:tmpDict];
	return infoDictInMemory;
}

- (NSString *)formattedTitle
{
    return [NSString stringWithFormat:@"%@ - version %@", self.munki_name, self.munki_version];
}

- (NSString *)titleWithVersion
{
    return [NSString stringWithFormat:@"%@-%@", self.munki_name, self.munki_version];
}

@end
