#import "ConditionalItemMO.h"
#import "StringObjectMO.h"

unichar kSeparatorCharacter = 0x02192;

@implementation ConditionalItemMO

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
    if ([key isEqualToString:@"parent"]) {
        NSSet *affectingKeys = [NSSet setWithObjects:@"titleWithParentTitle", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }
    
    /*
     Description for the contained items should be updated when conditional items are changed in the GUI
     */
    NSArray *catalogDescriptionKeys = @[@"containedItemsCountDescriptionShort", @"containedItemsCountDescriptionLong"];
    if ([catalogDescriptionKeys containsObject:key]) {
        NSSet *affectingKeys = [NSSet setWithObjects:@"managedInstalls", @"managedUninstalls", @"optionalInstalls", @"managedUpdates", @"includedManifests", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }
	
    return keyPaths;
}

- (NSString *)titleWithParentTitle
{
    if (self.parent) {
        // Return a string representation with conditions separated with an arrow character
        return [NSString stringWithFormat:@"%@ %C %@", self.parent.titleWithParentTitle, kSeparatorCharacter, self.munki_condition];
    } else {
        return self.munki_condition;
    }
}

- (NSString *)containedItemsCountDescriptionLong
{
    /*
     Used in conditional item tooltip
     */
    NSString *longDescription = @"";
    
    NSNumber *numManagedInstalls = [self valueForKeyPath:@"managedInstalls.@count"];
    NSNumber *numManagedUninstalls = [self valueForKeyPath:@"managedUninstalls.@count"];
    NSNumber *numOptionalInstalls = [self valueForKeyPath:@"optionalInstalls.@count"];
    NSNumber *numFeaturedItems = [self valueForKeyPath:@"featuredItems.@count"];
    NSNumber *numManagedUpdates = [self valueForKeyPath:@"managedUpdates.@count"];
    NSNumber *numIncludedManifests = [self valueForKeyPath:@"includedManifests.@count"];
    
    NSInteger sum = (numManagedInstalls.integerValue +
                     numManagedUninstalls.integerValue +
                     numManagedUpdates.integerValue +
                     numOptionalInstalls.integerValue +
                     numFeaturedItems.integerValue +
                     numIncludedManifests.integerValue);
    if (sum == 0) {
        return @"Condition contains no managed installs, uninstalls, updates, optional installs, featured items or included manifests.";
    }
    
    if (numManagedInstalls.integerValue > 0) {
        longDescription = [longDescription stringByAppendingFormat:@"%li managed installs\n", numManagedInstalls.integerValue];
    }
    if (numManagedUninstalls.integerValue > 0) {
        longDescription = [longDescription stringByAppendingFormat:@"%li managed uninstalls\n", numManagedUninstalls.integerValue];
    }
    if (numOptionalInstalls.integerValue > 0) {
        longDescription = [longDescription stringByAppendingFormat:@"%li optional installs\n", numOptionalInstalls.integerValue];
    }
    if (numFeaturedItems.integerValue > 0) {
        longDescription = [longDescription stringByAppendingFormat:@"%li featured items\n", numFeaturedItems.integerValue];
    }
    if (numManagedUpdates.integerValue > 0) {
        longDescription = [longDescription stringByAppendingFormat:@"%li managed updates\n", numManagedUpdates.integerValue];
    }
    if (numIncludedManifests.integerValue > 0) {
        longDescription = [longDescription stringByAppendingFormat:@"%li included manifests\n", numIncludedManifests.integerValue];
    }
    longDescription = [longDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return longDescription;
}

- (NSString *)containedItemsCountDescriptionShort
{
    NSString *shortDescription = nil;
    
    NSNumber *numManagedInstalls = [self valueForKeyPath:@"managedInstalls.@count"];
    NSNumber *numManagedUninstalls = [self valueForKeyPath:@"managedUninstalls.@count"];
    NSNumber *numOptionalInstalls = [self valueForKeyPath:@"optionalInstalls.@count"];
    NSNumber *numFeaturedItems = [self valueForKeyPath:@"featuredItems.@count"];
    NSNumber *numManagedUpdates = [self valueForKeyPath:@"managedUpdates.@count"];
    NSNumber *numIncludedManifests = [self valueForKeyPath:@"includedManifests.@count"];
    
    NSInteger sum = (numManagedInstalls.integerValue +
                     numManagedUninstalls.integerValue +
                     numManagedUpdates.integerValue +
                     numOptionalInstalls.integerValue +
                     numFeaturedItems.integerValue +
                     numIncludedManifests.integerValue);
    
    if (sum == 0) {
        shortDescription = @"No items";
    } else if (sum == 1) {
        shortDescription = [NSString stringWithFormat:@"%li item", sum];
    } else if (sum > 1) {
        shortDescription = [NSString stringWithFormat:@"%li items", sum];
    } else {
        shortDescription = @"";
    }
    
    return shortDescription;
}

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
    
    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
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
    // featured_items
    // =====================
    NSArray *featuredItemsSorters;
    if ([defaults boolForKey:@"sortFeaturedItemsByTitle"]) {
        featuredItemsSorters = [NSArray arrayWithObjects:sortByTitle, sortByIndex, nil];
    } else {
        featuredItemsSorters = [NSArray arrayWithObjects:sortByIndex, sortByTitle, nil];
    }
    if ([conditionalItem.featuredItems count] > 0) {
        NSMutableArray *featuredItems = [NSMutableArray arrayWithCapacity:[conditionalItem.featuredItems count]];
        for (StringObjectMO *featuredItem in [conditionalItem.featuredItems sortedArrayUsingDescriptors:featuredItemsSorters]) {
            [featuredItems addObject:featuredItem.title];
        }
        [tmpDict setObject:featuredItems forKey:@"featured_items"];
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
