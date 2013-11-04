#import "ManifestMO.h"
#import "ManifestInfoMO.h"
#import "CatalogMO.h"
#import "CatalogInfoMO.h"
#import "ApplicationMO.h"
#import "ManagedUpdateMO.h"
#import "ManagedInstallMO.h"
#import "ManagedUninstallMO.h"
#import "OptionalInstallMO.h"
#import "StringObjectMO.h"
#import "ConditionalItemMO.h"

@implementation ManifestMO

- (NSString *)fileName
{
    NSString *tempFileName = nil;
    if (![(NSURL *)self.manifestURL getResourceValue:&tempFileName forKey:NSURLNameKey error:nil]) {
        tempFileName = self.title;
    }
    return tempFileName;
}

- (NSArray *)rootConditionalItems
{
    [self willAccessValueForKey:@"conditionalItems"];
    NSSet *tmp = [[self primitiveValueForKey:@"conditionalItems"] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"parent == nil"]];
    NSSortDescriptor *sortByTitleWithParentTitle = [NSSortDescriptor sortDescriptorWithKey:@"titleWithParentTitle" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray *tmpArray = [tmp sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByTitleWithParentTitle]];
    [self didAccessValueForKey:@"conditionalItems"];
    return tmpArray;
}

- (NSArray *)enabledManagedUpdates
{
	NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:@"isEnabled == TRUE"];
	NSArray *tempArray = [[self.managedUpdates allObjects] filteredArrayUsingPredicate:enabledPredicate];
	return tempArray;
}

- (NSArray *)enabledManagedInstalls
{
	NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:@"isEnabled == TRUE"];
	NSArray *tempArray = [[self.managedInstalls allObjects] filteredArrayUsingPredicate:enabledPredicate];
	return tempArray;
}

- (NSArray *)enabledManagedUninstalls
{
	NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:@"isEnabled == TRUE"];
	NSArray *tempArray = [[self.managedUninstalls allObjects] filteredArrayUsingPredicate:enabledPredicate];
	return tempArray;
}

- (NSArray *)enabledOptionalInstalls
{
	NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:@"isEnabled == TRUE"];
	NSArray *tempArray = [[self.optionalInstalls allObjects] filteredArrayUsingPredicate:enabledPredicate];
	return tempArray;
}

- (NSArray *)enabledCatalogs
{
	NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:@"isEnabledForManifest == TRUE"];
	NSArray *tempArray = [[self.catalogInfos allObjects] filteredArrayUsingPredicate:enabledPredicate];
	return tempArray;
}

- (NSArray *)enabledIncludedManifests
{
	NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:@"isEnabledForManifest == TRUE"];
	NSArray *tempArray = [[self.includedManifests allObjects] filteredArrayUsingPredicate:enabledPredicate];
	return tempArray;
}


- (NSDictionary *)dictValue
{
	NSString *subtitle = @"";
    
    int manInCount = 0;
    int manUnCount = 0;
    int manUpCount = 0;
    int optInCount = 0;
    int incManCount = 0;
    
    for (ConditionalItemMO *condition in self.conditionalItems) {
        manInCount += [condition.managedInstalls count];
        manUnCount += [condition.managedUninstalls count];
        manUpCount += [condition.managedUpdates count];
        optInCount += [condition.optionalInstalls count];
        incManCount += [condition.includedManifests count];
    }
    
    manInCount += [self.managedInstallsFaster count];
    manUnCount += [self.managedUninstallsFaster count];
    manUpCount += [self.managedUpdatesFaster count];
    optInCount += [self.optionalInstallsFaster count];
    incManCount += [self.includedManifestsFaster count];
    
    if (manInCount > 0) {
        subtitle = [subtitle stringByAppendingFormat:@"%u installs, ", manInCount];
    }
    if (manUnCount > 0) {
        subtitle = [subtitle stringByAppendingFormat:@"%u uninstalls, ", manUnCount];
    }
    if (optInCount > 0) {
        subtitle = [subtitle stringByAppendingFormat:@"%u optional installs, ", optInCount];
    }
    if (manUpCount > 0) {
        subtitle = [subtitle stringByAppendingFormat:@"%u updates, ", manUpCount];
    }
    if (incManCount > 0) {
        subtitle = [subtitle stringByAppendingFormat:@"%u nested manifests", incManCount];
    }
    
    if ([subtitle isEqualToString:@""]) {
        subtitle = @"Empty";
    }
    subtitle = [subtitle stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
    
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.title, @"title",
			subtitle, @"subtitle",
			@"manifest", @"type",
			nil];
}

- (NSDictionary *)manifestInfoDictionary
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
	
    // =====================
    // catalogs
    // =====================
	if ([[self enabledCatalogs] count] > 0) {
        NSSortDescriptor *sortCatalogsByIndexInManifest = [NSSortDescriptor sortDescriptorWithKey:@"indexInManifest" ascending:YES selector:@selector(compare:)];
		NSSortDescriptor *sortCatalogsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"catalog.title" ascending:YES selector:@selector(localizedStandardCompare:)];
		NSMutableArray *catalogs = [NSMutableArray arrayWithCapacity:[self.catalogInfos count]];
		for (CatalogInfoMO *catalogInfo in [self.catalogInfos sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortCatalogsByIndexInManifest, sortCatalogsByTitle,nil]]) {
			if (([catalogInfo isEnabledForManifestValue]) && (![catalogs containsObject:[[catalogInfo catalog] title]])) {
				[catalogs addObject:[[catalogInfo catalog] title]];
			}
		}
		[tmpDict setObject:catalogs forKey:@"catalogs"];
	} else {
		if ([(NSDictionary *)self.originalManifest objectForKey:@"catalogs"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"catalogs"];
		}
	}
	
	//NSSortDescriptor *sortApplicationsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"parentApplication.munki_name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
    
    
    // =====================
    // managed_installs
    // =====================
    NSArray *managedInstallsSorters;
    if ([defaults boolForKey:@"sortManagedInstallsByTitle"]) {
        managedInstallsSorters = [NSArray arrayWithObjects:sortByTitle, sortByIndex, nil];
    } else {
        managedInstallsSorters = [NSArray arrayWithObjects:sortByIndex, sortByTitle, nil];
    }
    
    if ([self.managedInstallsFaster count] > 0) {
        NSMutableArray *managedInstalls = [NSMutableArray arrayWithCapacity:[self.managedInstallsFaster count]];
		for (StringObjectMO *managedInstall in [self.managedInstallsFaster sortedArrayUsingDescriptors:managedInstallsSorters]) {
            [managedInstalls addObject:managedInstall.title];
		}
        [tmpDict setObject:managedInstalls forKey:@"managed_installs"];
    } else {
		if ([(NSDictionary *)self.originalManifest objectForKey:@"managed_installs"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"managed_installs"];
		}
	}
    
	
    // =====================
    // managed_uninstalls
    // =====================
    NSArray *managedUninstallsSorters;
    if ([defaults boolForKey:@"sortManagedUninstallsByTitle"]) {
        managedUninstallsSorters = [NSArray arrayWithObjects:sortByTitle, sortByIndex, nil];
    } else {
        managedUninstallsSorters = [NSArray arrayWithObjects:sortByIndex, sortByTitle, nil];
    }
    if ([self.managedUninstallsFaster count] > 0) {
        NSMutableArray *managedUninstalls = [NSMutableArray arrayWithCapacity:[self.managedUninstallsFaster count]];
		for (StringObjectMO *managedUninstall in [self.managedUninstallsFaster sortedArrayUsingDescriptors:managedUninstallsSorters]) {
            [managedUninstalls addObject:managedUninstall.title];
		}
        [tmpDict setObject:managedUninstalls forKey:@"managed_uninstalls"];
    } else {
		if ([(NSDictionary *)self.originalManifest objectForKey:@"managed_uninstalls"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"managed_uninstalls"];
		}
	}
    
	
    // =====================
    // managed_updates
    // =====================
    NSArray *managedUpdatesSorters;
    if ([defaults boolForKey:@"sortManagedUpdatesByTitle"]) {
        managedUpdatesSorters = [NSArray arrayWithObjects:sortByTitle, sortByIndex, nil];
    } else {
        managedUpdatesSorters = [NSArray arrayWithObjects:sortByIndex, sortByTitle, nil];
    }
    if ([self.managedUpdatesFaster count] > 0) {
        NSMutableArray *managedUpdates = [NSMutableArray arrayWithCapacity:[self.managedUpdatesFaster count]];
		for (StringObjectMO *managedUpdate in [self.managedUpdatesFaster sortedArrayUsingDescriptors:managedUpdatesSorters]) {
            [managedUpdates addObject:managedUpdate.title];
		}
        [tmpDict setObject:managedUpdates forKey:@"managed_updates"];
    } else {
		if ([(NSDictionary *)self.originalManifest objectForKey:@"managed_updates"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"managed_updates"];
		}
	}
	
    
    // =====================
    // optional_installs
    // =====================
    NSArray *optionalInstallsSorters;
    if ([defaults boolForKey:@"sortOptionalInstallsByTitle"]) {
        optionalInstallsSorters = [NSArray arrayWithObjects:sortByTitle, sortByIndex, nil];
    } else {
        optionalInstallsSorters = [NSArray arrayWithObjects:sortByIndex, sortByTitle, nil];
    }
    if ([self.optionalInstallsFaster count] > 0) {
        NSMutableArray *optionalInstalls = [NSMutableArray arrayWithCapacity:[self.optionalInstallsFaster count]];
		for (StringObjectMO *optionalInstall in [self.optionalInstallsFaster sortedArrayUsingDescriptors:optionalInstallsSorters]) {
            [optionalInstalls addObject:optionalInstall.title];
		}
        [tmpDict setObject:optionalInstalls forKey:@"optional_installs"];
    } else {
		if ([(NSDictionary *)self.originalManifest objectForKey:@"optional_installs"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"optional_installs"];
		}
	}
	
    
    // =====================
    // included_manifests
    // =====================
    NSSortDescriptor *sortByIndexInNestedManifest = [NSSortDescriptor sortDescriptorWithKey:@"indexInNestedManifest" ascending:YES selector:@selector(compare:)];
    if ([self.includedManifestsFaster count] > 0) {
        NSMutableArray *includedManifests = [NSMutableArray arrayWithCapacity:[self.includedManifestsFaster count]];
		for (StringObjectMO *includedManifest in [self.includedManifestsFaster sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortByIndexInNestedManifest, sortByTitle, nil]]) {
            [includedManifests addObject:includedManifest.title];
		}
        [tmpDict setObject:includedManifests forKey:@"included_manifests"];
    } else {
		if ([(NSDictionary *)self.originalManifest objectForKey:@"included_manifests"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"included_manifests"];
		}
	}
    
    
	// =====================
    // conditional_items
    // =====================
    if ([self.conditionalItems count] > 0) {
        NSMutableArray *conditionalItems = [NSMutableArray arrayWithCapacity:[self.conditionalItems count]];
		for (ConditionalItemMO *conditionalItem in [self.conditionalItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByIndex]]) {
            if (conditionalItem.parent == nil) {
                [conditionalItems addObject:[conditionalItem dictValueForSave]];
            }
		}
        [tmpDict setObject:conditionalItems forKey:@"conditional_items"];
    } else {
		if ([(NSDictionary *)self.originalManifest objectForKey:@"conditional_items"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"conditional_items"];
		}
	}
    
	NSDictionary *infoDictInMemory = [NSDictionary dictionaryWithDictionary:tmpDict];
	
	return infoDictInMemory;
}


@end
