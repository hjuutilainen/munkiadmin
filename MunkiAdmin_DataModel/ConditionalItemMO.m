#import "ConditionalItemMO.h"
#import "StringObjectMO.h"

@implementation ConditionalItemMO

- (NSDictionary *)dictValue
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.munki_condition, @"title",
			@"", @"subtitle",
			@"installsitem", @"type",
			nil];
}

- (NSDictionary *)singleLevelDictionary:(ConditionalItemMO *)conditionalItem
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *tmpDict = [[[NSMutableDictionary alloc] init] autorelease];
    if (conditionalItem.munki_condition != nil) [tmpDict setObject:conditionalItem.munki_condition forKey:@"condition"];
    
    NSSortDescriptor *sortByIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    
    // =====================
    // managed_installs
    // =====================
    NSArray *managedInstallsSorters;
    if ([defaults boolForKey:@"sortManagedInstallsByTitle"]) {
        managedInstallsSorters = [NSArray arrayWithObjects:sortByTitle, sortByIndex, nil];
    } else {
        managedInstallsSorters = [NSArray arrayWithObjects:sortByIndex, sortByTitle, nil];
    }
    
    if ([conditionalItem.managedInstalls count] > 0) {
        NSMutableArray *managedInstalls = [NSMutableArray arrayWithCapacity:[conditionalItem.managedInstalls count]];
		for (StringObjectMO *managedInstall in [conditionalItem.managedInstalls sortedArrayUsingDescriptors:managedInstallsSorters]) {
            [managedInstalls addObject:managedInstall.title];
		}
        [tmpDict setObject:managedInstalls forKey:@"managed_installs"];
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
    if ([conditionalItem.managedUninstalls count] > 0) {
        NSMutableArray *managedUninstalls = [NSMutableArray arrayWithCapacity:[conditionalItem.managedUninstalls count]];
		for (StringObjectMO *managedUninstall in [conditionalItem.managedUninstalls sortedArrayUsingDescriptors:managedUninstallsSorters]) {
            [managedUninstalls addObject:managedUninstall.title];
		}
        [tmpDict setObject:managedUninstalls forKey:@"managed_uninstalls"];
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
    if ([conditionalItem.managedUpdates count] > 0) {
        NSMutableArray *managedUpdates = [NSMutableArray arrayWithCapacity:[conditionalItem.managedUpdates count]];
		for (StringObjectMO *managedUpdate in [conditionalItem.managedUpdates sortedArrayUsingDescriptors:managedUpdatesSorters]) {
            [managedUpdates addObject:managedUpdate.title];
		}
        [tmpDict setObject:managedUpdates forKey:@"managed_updates"];
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
    if ([conditionalItem.optionalInstalls count] > 0) {
        NSMutableArray *optionalInstalls = [NSMutableArray arrayWithCapacity:[conditionalItem.optionalInstalls count]];
		for (StringObjectMO *optionalInstall in [conditionalItem.optionalInstalls sortedArrayUsingDescriptors:optionalInstallsSorters]) {
            [optionalInstalls addObject:optionalInstall.title];
		}
        [tmpDict setObject:optionalInstalls forKey:@"optional_installs"];
    }
	
    
    // =====================
    // included_manifests
    // =====================
    NSSortDescriptor *sortByIndexInNestedManifest = [NSSortDescriptor sortDescriptorWithKey:@"indexInNestedManifest" ascending:YES selector:@selector(compare:)];
    if ([conditionalItem.includedManifests count] > 0) {
        NSMutableArray *includedManifests = [NSMutableArray arrayWithCapacity:[conditionalItem.includedManifests count]];
		for (StringObjectMO *includedManifest in [conditionalItem.includedManifests sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortByIndexInNestedManifest, sortByTitle, nil]]) {
            [includedManifests addObject:includedManifest.title];
		}
        [tmpDict setObject:includedManifests forKey:@"included_manifests"];
    }
    
    // =====================
    // conditional_items
    // =====================
    if ([conditionalItem.children count] > 0) {
        NSMutableArray *childConditionalItems = [NSMutableArray arrayWithCapacity:[conditionalItem.children count]];
		for (ConditionalItemMO *childConditionalItem in [conditionalItem.children sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByIndex]]) {
            [childConditionalItems addObject:[self singleLevelDictionary:childConditionalItem]];
		}
        [tmpDict setObject:childConditionalItems forKey:@"conditional_items"];
    }
    
    NSDictionary *returnDict = [NSDictionary dictionaryWithDictionary:tmpDict];
	return returnDict;
}

- (NSDictionary *)dictValueForSave
{
	NSDictionary *returnDict = [NSDictionary dictionaryWithDictionary:[self singleLevelDictionary:self]];
	return returnDict;
}


@end
