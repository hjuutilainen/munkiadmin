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

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    NSArray *catalogDescriptionKeys = @[@"catalogsDescriptionString", @"catalogStrings"];
    NSArray *managedInstallsKeys = @[@"managedInstallsStrings",
                                     @"managedInstallsCount",
                                     @"managedInstallsCountDescription",
                                     @"managedInstallsCountShortDescription"];
    NSArray *managedUninstallsKeys = @[@"managedUninstallsStrings",
                                       @"managedUninstallsCount",
                                       @"managedUninstallsCountDescription",
                                       @"managedUninstallsCountShortDescription"];
    NSArray *managedUpdatesKeys = @[@"managedUpdatesStrings",
                                    @"managedUpdatesCount",
                                    @"managedUpdatesCountDescription",
                                    @"managedUpdatesCountShortDescription"];
    NSArray *optionalInstallsKeys = @[@"optionalInstallsStrings",
                                      @"optionalInstallsCount",
                                      @"optionalInstallsCountDescription",
                                      @"optionalInstallsCountShortDescription"];
    NSArray *featuredItemsKeys = @[@"featuredItemsStrings",
                                   @"featuredItemsCount",
                                   @"featuredItemsCountDescription",
                                   @"featuredItemsCountShortDescription"];
    NSArray *conditionalsKeys = @[@"conditionalItemsStrings",
                                  @"conditionsCount",
                                  @"conditionsCountDescription",
                                  @"conditionsCountShortDescription",
                                  @"rootConditionalItems"];
    NSArray *includedManifestsKeys = @[@"includedManifestsStrings",
                                       @"includedManifestsCount",
                                       @"includedManifestsCountDescription",
                                       @"includedManifestsCountShortDescription"];
    NSArray *referencingManifestsKeys = @[@"referencingManifestsStrings",
                                          @"referencingManifestsCount",
                                          @"referencingManifestsCountDescription",
                                          @"referencingManifestsCountShortDescription"];
    
    if ([catalogDescriptionKeys containsObject:key]) {
        NSSet *affectingKeys = [NSSet setWithObjects:@"catalogs", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    } else if ([managedInstallsKeys containsObject:key]) {
        NSSet *affectingKeys = [NSSet setWithObjects:@"managedInstallsFaster", @"conditionalItems", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    } else if ([managedUninstallsKeys containsObject:key]) {
        NSSet *affectingKeys = [NSSet setWithObjects:@"managedUninstallsFaster", @"conditionalItems", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    } else if ([managedUpdatesKeys containsObject:key]) {
        NSSet *affectingKeys = [NSSet setWithObjects:@"managedUpdatesFaster", @"conditionalItems", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    } else if ([optionalInstallsKeys containsObject:key]) {
        NSSet *affectingKeys = [NSSet setWithObjects:@"optionalInstallsFaster", @"conditionalItems", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    } else if ([featuredItemsKeys containsObject:key]) {
        NSSet *affectingKeys = [NSSet setWithObjects:@"featuredItems", @"conditionalItems", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    } else if ([conditionalsKeys containsObject:key]) {
        NSSet *affectingKeys = [NSSet setWithObjects:@"conditionalItems", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    } else if ([includedManifestsKeys containsObject:key]) {
        NSSet *affectingKeys = [NSSet setWithObjects:@"includedManifestsFaster", @"conditionalItems", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    } else if ([referencingManifestsKeys containsObject:key]) {
        NSSet *affectingKeys = [NSSet setWithObjects:@"referencingManifests", @"conditionalItems", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    } else if ([key isEqualToString:@"titleOrDisplayName"]) {
        NSSet *affectingKeys = [NSSet setWithObjects:@"title", @"manifestDisplayName", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }
    
    return keyPaths;
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

- (NSArray *)allPackageStrings
{
    NSMutableArray *items = [NSMutableArray new];
    
    for (StringObjectMO *item in self.managedInstallsFaster) {
        if (![items containsObject:[item title]]) {
            [items addObject:[item title]];
        }
    }
    
    for (ConditionalItemMO *condition in self.conditionalItems) {
        for (StringObjectMO *item in condition.managedInstalls) {
            if (![items containsObject:[item title]]) {
                [items addObject:[item title]];
            }
        }
    }
    
    for (StringObjectMO *item in self.managedUpdatesFaster) {
        if (![items containsObject:[item title]]) {
            [items addObject:[item title]];
        }
    }
    
    for (ConditionalItemMO *condition in self.conditionalItems) {
        for (StringObjectMO *item in condition.managedUpdates) {
            if (![items containsObject:[item title]]) {
                [items addObject:[item title]];
            }
        }
    }
    
    for (StringObjectMO *item in self.optionalInstallsFaster) {
        if (![items containsObject:[item title]]) {
            [items addObject:[item title]];
        }
    }
    
    for (StringObjectMO *item in self.featuredItems) {
        if (![items containsObject:[item title]]) {
            [items addObject:[item title]];
        }
    }
    
    for (ConditionalItemMO *condition in self.conditionalItems) {
        for (StringObjectMO *item in condition.optionalInstalls) {
            if (![items containsObject:[item title]]) {
                [items addObject:[item title]];
            }
        }
    }
    
    for (StringObjectMO *item in self.managedUninstallsFaster) {
        if (![items containsObject:[item title]]) {
            [items addObject:[item title]];
        }
    }
    
    for (ConditionalItemMO *condition in self.conditionalItems) {
        for (StringObjectMO *item in condition.managedUninstalls) {
            if (![items containsObject:[item title]]) {
                [items addObject:[item title]];
            }
        }
    }
    
    if ([items count] == 0) {
        return nil;
    } else {
        return [items sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    }
}

- (NSArray *)managedInstallsStrings
{
    NSMutableArray *items = [NSMutableArray new];
    for (StringObjectMO *item in self.managedInstallsFaster) {
        if (![items containsObject:[item title]]) {
            [items addObject:[item title]];
        }
    }
    
    for (ConditionalItemMO *condition in self.conditionalItems) {
        for (StringObjectMO *item in condition.managedInstalls) {
            if (![items containsObject:[item title]]) {
                [items addObject:[item title]];
            }
        }
    }
    
    if ([items count] == 0) {
        return nil;
    } else {
        return [items sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    }
}

- (NSArray *)managedUpdatesStrings
{
    NSMutableArray *items = [NSMutableArray new];
    for (StringObjectMO *item in self.managedUpdatesFaster) {
        if (![items containsObject:[item title]]) {
            [items addObject:[item title]];
        }
    }
    
    for (ConditionalItemMO *condition in self.conditionalItems) {
        for (StringObjectMO *item in condition.managedUpdates) {
            if (![items containsObject:[item title]]) {
                [items addObject:[item title]];
            }
        }
    }
    
    if ([items count] == 0) {
        return nil;
    } else {
        return [items sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    }
}

- (NSArray *)optionalInstallsStrings
{
    NSMutableArray *items = [NSMutableArray new];
    for (StringObjectMO *item in self.optionalInstallsFaster) {
        if (![items containsObject:[item title]]) {
            [items addObject:[item title]];
        }
    }
    
    for (ConditionalItemMO *condition in self.conditionalItems) {
        for (StringObjectMO *item in condition.optionalInstalls) {
            if (![items containsObject:[item title]]) {
                [items addObject:[item title]];
            }
        }
    }
    
    if ([items count] == 0) {
        return nil;
    } else {
        return [items sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    }
}

- (NSArray *)featuredItemsStrings
{
    NSMutableArray *items = [NSMutableArray new];
    for (StringObjectMO *item in self.featuredItems) {
        if (![items containsObject:[item title]]) {
            [items addObject:[item title]];
        }
    }
    
    for (ConditionalItemMO *condition in self.conditionalItems) {
        for (StringObjectMO *item in condition.featuredItems) {
            if (![items containsObject:[item title]]) {
                [items addObject:[item title]];
            }
        }
    }
    
    if ([items count] == 0) {
        return nil;
    } else {
        return [items sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    }
}

- (NSArray *)managedUninstallsStrings
{
    NSMutableArray *items = [NSMutableArray new];
    for (StringObjectMO *item in self.managedUninstallsFaster) {
        if (![items containsObject:[item title]]) {
            [items addObject:[item title]];
        }
    }
    
    for (ConditionalItemMO *condition in self.conditionalItems) {
        for (StringObjectMO *item in condition.managedUninstalls) {
            if (![items containsObject:[item title]]) {
                [items addObject:[item title]];
            }
        }
    }
    
    if ([items count] == 0) {
        return nil;
    } else {
        return [items sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    }
}

- (NSArray *)includedManifestsStrings
{
    NSMutableArray *items = [NSMutableArray new];
    for (StringObjectMO *item in self.allIncludedManifests) {
        if (![items containsObject:[item title]]) {
            [items addObject:[item title]];
        }
    }
    
    if ([items count] == 0) {
        return nil;
    } else {
        return [items sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    }
}

- (NSArray *)referencingManifestsStrings
{
    NSMutableArray *items = [NSMutableArray new];
    for (StringObjectMO *referencingManifest in self.allReferencingManifests) {
        if (referencingManifest.manifestReference) {
            if (![items containsObject:referencingManifest.manifestReference.title]) {
                [items addObject:referencingManifest.manifestReference.title];
            }
        } else {
            if (![items containsObject:referencingManifest.includedManifestConditionalReference.manifest.title]) {
                [items addObject:referencingManifest.includedManifestConditionalReference.manifest.title];
            }
        }
    }
    
    if ([items count] == 0) {
        return nil;
    } else {
        return [items sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    }
}

- (NSArray *)conditionalItemsStrings
{
    NSMutableArray *items = [NSMutableArray new];
    
    for (ConditionalItemMO *condition in self.conditionalItems) {
        if (![items containsObject:[condition munki_condition]]) {
            [items addObject:[condition munki_condition]];
        }
    }
    
    if ([items count] == 0) {
        return nil;
    } else {
        return [items sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    }
}

- (NSNumber *)managedInstallsCount
{
    NSSet *allConditionalItems = [self valueForKeyPath:@"conditionalItems.@distinctUnionOfSets.managedInstalls"];
    NSNumber *numManagedInstalls = [self valueForKeyPath:@"managedInstallsFaster.@count"];
    NSUInteger all = [allConditionalItems count] + [numManagedInstalls unsignedIntegerValue];
    return [NSNumber numberWithUnsignedInteger:all];
}

- (NSString *)managedInstallsCountShortDescription
{
    NSUInteger all = [self.managedInstallsCount unsignedIntegerValue];
    if (all == 0) {
        return nil;
    } else {
        return [self.managedInstallsCount stringValue];
    }
}

- (NSString *)managedInstallsCountDescription
{
    NSUInteger all = [self.managedInstallsCount unsignedIntegerValue];
    if (all == 0) {
        return @"No managed installs";
    } else if (all == 1) {
        return @"1 managed install";
    } else if (all > 1) {
        return [NSString stringWithFormat:@"%lu managed installs", (unsigned long)all];
    } else {
        return [NSString stringWithFormat:@""];
    }
}

- (NSNumber *)managedUninstallsCount
{
    NSSet *allConditionalItems = [self valueForKeyPath:@"conditionalItems.@distinctUnionOfSets.managedUninstalls"];
    NSNumber *numManagedInstalls = [self valueForKeyPath:@"managedUninstallsFaster.@count"];
    NSUInteger all = [allConditionalItems count] + [numManagedInstalls unsignedIntegerValue];
    return [NSNumber numberWithUnsignedInteger:all];
}

- (NSString *)managedUninstallsCountShortDescription
{
    NSUInteger all = [self.managedUninstallsCount unsignedIntegerValue];
    if (all == 0) {
        return nil;
    } else {
        return [self.managedUninstallsCount stringValue];
    }
}

- (NSString *)managedUninstallsCountDescription
{
    NSUInteger all = [self.managedUninstallsCount unsignedIntegerValue];
    if (all == 0) {
        return @"No managed uninstalls";
    } else if (all == 1) {
        return @"1 managed uninstall";
    } else if (all > 1) {
        return [NSString stringWithFormat:@"%lu managed uninstalls", (unsigned long)all];
    } else {
        return [NSString stringWithFormat:@""];
    }
}

- (NSNumber *)managedUpdatesCount
{
    NSSet *allConditionalItems = [self valueForKeyPath:@"conditionalItems.@distinctUnionOfSets.managedUpdates"];
    NSNumber *numManagedInstalls = [self valueForKeyPath:@"managedUpdatesFaster.@count"];
    NSUInteger all = [allConditionalItems count] + [numManagedInstalls unsignedIntegerValue];
    return [NSNumber numberWithUnsignedInteger:all];
}

- (NSString *)managedUpdatesCountShortDescription
{
    NSUInteger all = [self.managedUpdatesCount unsignedIntegerValue];
    if (all == 0) {
        return nil;
    } else {
        return [self.managedUpdatesCount stringValue];
    }
}

- (NSString *)managedUpdatesCountDescription
{
    NSUInteger all = [self.managedUpdatesCount unsignedIntegerValue];
    if (all == 0) {
        return @"No managed updates";
    } else if (all == 1) {
        return @"1 managed update";
    } else if (all > 1) {
        return [NSString stringWithFormat:@"%lu managed updates", (unsigned long)all];
    } else {
        return [NSString stringWithFormat:@""];
    }
}

- (NSNumber *)optionalInstallsCount
{
    NSSet *allConditionalItems = [self valueForKeyPath:@"conditionalItems.@distinctUnionOfSets.optionalInstalls"];
    NSNumber *numManagedInstalls = [self valueForKeyPath:@"optionalInstallsFaster.@count"];
    NSUInteger all = [allConditionalItems count] + [numManagedInstalls unsignedIntegerValue];
    return [NSNumber numberWithUnsignedInteger:all];
}

- (NSString *)optionalInstallsCountShortDescription
{
    NSUInteger all = [self.optionalInstallsCount unsignedIntegerValue];
    if (all == 0) {
        return nil;
    } else {
        return [self.optionalInstallsCount stringValue];
    }
}

- (NSString *)optionalInstallsCountDescription
{
    NSUInteger all = [self.optionalInstallsCount unsignedIntegerValue];
    if (all == 0) {
        return @"No optional installs";
    } else if (all == 1) {
        return @"1 optional install";
    } else if (all > 1) {
        return [NSString stringWithFormat:@"%lu optional installs", (unsigned long)all];
    } else {
        return [NSString stringWithFormat:@""];
    }
}

- (NSNumber *)featuredItemsCount
{
    NSSet *allFeaturedItems = [self valueForKeyPath:@"conditionalItems.@distinctUnionOfSets.featuredItems"];
    NSNumber *numFeaturedItems = [self valueForKeyPath:@"featuredItems.@count"];
    NSUInteger all = [allFeaturedItems count] + [numFeaturedItems unsignedIntegerValue];
    return [NSNumber numberWithUnsignedInteger:all];
}

- (NSString *)featuredItemsCountShortDescription
{
    NSUInteger all = [self.featuredItemsCount unsignedIntegerValue];
    if (all == 0) {
        return nil;
    } else {
        return [self.featuredItemsCount stringValue];
    }
}

- (NSString *)featuredItemsCountDescription
{
    NSUInteger all = [self.featuredItemsCount unsignedIntegerValue];
    if (all == 0) {
        return @"No featured items";
    } else if (all == 1) {
        return @"1 featured item";
    } else if (all > 1) {
        return [NSString stringWithFormat:@"%lu featured items", (unsigned long)all];
    } else {
        return [NSString stringWithFormat:@""];
    }
}

- (NSNumber *)includedManifestsCount
{
    NSSet *allConditionalItems = [self valueForKeyPath:@"conditionalItems.@distinctUnionOfSets.includedManifests"];
    NSNumber *numManagedInstalls = [self valueForKeyPath:@"includedManifestsFaster.@count"];
    NSUInteger all = [allConditionalItems count] + [numManagedInstalls unsignedIntegerValue];
    return [NSNumber numberWithUnsignedInteger:all];
}

- (NSString *)includedManifestsCountShortDescription
{
    NSUInteger all = [self.includedManifestsCount unsignedIntegerValue];
    if (all == 0) {
        return nil;
    } else {
        return [self.includedManifestsCount stringValue];
    }
}

- (NSString *)includedManifestsCountDescription
{
    NSUInteger all = [self.includedManifestsCount unsignedIntegerValue];
    if (all == 0) {
        return @"No included manifests";
    } else if (all == 1) {
        return @"1 included manifest";
    } else if (all > 1) {
        return [NSString stringWithFormat:@"%lu included manifests", (unsigned long)all];
    } else {
        return [NSString stringWithFormat:@""];
    }
}

- (NSNumber *)referencingManifestsCount
{
    NSSet *manifestStringObjects = [self.referencingManifests filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"typeString == %@", @"includedManifest"]];
    NSUInteger all = [manifestStringObjects count];
    return [NSNumber numberWithUnsignedInteger:all];
}

- (NSString *)referencingManifestsCountShortDescription
{
    NSUInteger all = [self.referencingManifestsCount unsignedIntegerValue];
    if (all == 0) {
        return nil;
    } else {
        return [self.referencingManifestsCount stringValue];
    }
}

- (NSString *)referencingManifestsCountDescription
{
    NSUInteger all = [self.referencingManifestsCount unsignedIntegerValue];
    if (all == 0) {
        return @"No referencing manifests";
    } else if (all == 1) {
        return @"1 referencing manifest";
    } else if (all > 1) {
        return [NSString stringWithFormat:@"%lu referencing manifests", (unsigned long)all];
    } else {
        return [NSString stringWithFormat:@""];
    }
}

- (NSNumber *)conditionsCount
{
    NSUInteger all = [self.conditionalItems count];
    return [NSNumber numberWithUnsignedInteger:all];
}

- (NSString *)conditionsCountShortDescription
{
    NSUInteger all = [self.conditionsCount unsignedIntegerValue];
    if (all == 0) {
        return nil;
    } else {
        return [self.conditionsCount stringValue];
    }
}

- (NSString *)conditionsCountDescription
{
    NSUInteger count = [self.conditionsCount unsignedIntegerValue];
    if (count == 0) {
        return @"No conditions";
    } else if (count == 1) {
        return @"1 condition";
    } else if (count > 1) {
        return [NSString stringWithFormat:@"%lu conditions", (unsigned long)[self.conditionalItems count]];
    } else {
        return @"";
    }
}

- (NSArray *)catalogStrings
{
    NSMutableArray *catalogs = [NSMutableArray new];
    NSSortDescriptor *byIndex = [NSSortDescriptor sortDescriptorWithKey:@"indexInManifest" ascending:YES selector:@selector(compare:)];
    NSSortDescriptor *byTitle = [NSSortDescriptor sortDescriptorWithKey:@"catalog.title" ascending:YES selector:@selector(localizedStandardCompare:)];
    for (CatalogInfoMO *catalogInfo in [self.catalogInfos sortedArrayUsingDescriptors:@[byIndex, byTitle]]) {
        if (([catalogInfo isEnabledForManifestValue]) && (![catalogs containsObject:[[catalogInfo catalog] title]])) {
            [catalogs addObject:[[catalogInfo catalog] title]];
        }
    }
    
    if ([catalogs count] == 0) {
        return nil;
    } else {
        return catalogs;
    }
}

- (NSString *)catalogsDescriptionString
{
    NSArray *catalogStrings = [self catalogStrings];
    if (catalogStrings) {
        return [[self catalogStrings] componentsJoinedByString:@", "];
    } else {
        return nil;
    }
    
}

- (NSString *)catalogsCountDescriptionString
{
    NSArray *catalogStrings = [self catalogStrings];
    if (catalogStrings) {
        NSUInteger catalogsCount = [catalogStrings count];
        if (catalogsCount == 1) {
            return @"1 catalog";
        } else if (catalogsCount > 1) {
            return [NSString stringWithFormat:@"%lu catalogs", (unsigned long)[catalogStrings count]];
        } else {
            return @"";
        }
    } else {
        return @"No catalogs";
    }
}

- (NSString *)titleOrDisplayName
{
    if (self.manifestDisplayName) {
        return self.manifestDisplayName;
    } else {
        return self.title;
    }
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

- (NSImage *)image
{
    return [NSImage imageNamed:@"manifestIcon_32x32"];
}

- (NSString *)manifestContentsDescription
{
    NSString *descriptionString = @"";
    
    NSUInteger manInCount = 0;
    NSUInteger manUnCount = 0;
    NSUInteger manUpCount = 0;
    NSUInteger optInCount = 0;
    NSUInteger featCount = 0;
    NSUInteger incManCount = 0;
    
    for (ConditionalItemMO *condition in self.conditionalItems) {
        manInCount += [condition.managedInstalls count];
        manUnCount += [condition.managedUninstalls count];
        manUpCount += [condition.managedUpdates count];
        optInCount += [condition.optionalInstalls count];
        featCount += [condition.featuredItems count];
        incManCount += [condition.includedManifests count];
    }
    
    manInCount += [self.managedInstallsFaster count];
    manUnCount += [self.managedUninstallsFaster count];
    manUpCount += [self.managedUpdatesFaster count];
    optInCount += [self.optionalInstallsFaster count];
    featCount += [self.featuredItems count];
    incManCount += [self.includedManifestsFaster count];
    
    if (manInCount > 0) {
        descriptionString = [descriptionString stringByAppendingFormat:@"%lu installs, ", (unsigned long)manInCount];
    }
    if (manUnCount > 0) {
        descriptionString = [descriptionString stringByAppendingFormat:@"%lu uninstalls, ", (unsigned long)manUnCount];
    }
    if (optInCount > 0) {
        descriptionString = [descriptionString stringByAppendingFormat:@"%lu optional installs, ", (unsigned long)optInCount];
    }
    if (featCount > 0) {
        descriptionString = [descriptionString stringByAppendingFormat:@"%lu featured items, ", (unsigned long)featCount];
    }
    if (manUpCount > 0) {
        descriptionString = [descriptionString stringByAppendingFormat:@"%lu updates, ", (unsigned long)manUpCount];
    }
    if (incManCount > 0) {
        descriptionString = [descriptionString stringByAppendingFormat:@"%lu nested manifests", (unsigned long)incManCount];
    }
    
    if ([descriptionString isEqualToString:@""]) {
        descriptionString = @"Empty";
    }
    descriptionString = [descriptionString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
    return descriptionString;
}


- (NSDictionary *)dictValue
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.title, @"title",
			self.manifestContentsDescription, @"subtitle",
			@"manifest", @"type",
			nil];
}

- (NSDictionary *)manifestInfoDictionary
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
    
    /*
     Manifest custom metadata keys
     */
    if (self.manifestUserName && ![self.manifestUserName isEqualToString:@""]) {
        [tmpDict setObject:self.manifestUserName forKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"manifestUserNameKey"]];
    }
    if (self.manifestDisplayName && ![self.manifestDisplayName isEqualToString:@""]) {
        [tmpDict setObject:self.manifestDisplayName forKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"manifestDisplayNameKey"]];
    }
    if (self.manifestAdminNotes && ![self.manifestAdminNotes isEqualToString:@""]) {
        [tmpDict setObject:self.manifestAdminNotes forKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"manifestAdminNotesKey"]];
    }
	
    /*
     catalogs
     */
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
    
    
    /*
     managed_installs
     */
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
    
	
    /*
     managed_uninstalls
     */
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
    
	
    /*
     managed_updates
     */
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
	
    
    /*
     optional_installs
     */
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
    
    /*
     featured_items
     */
    NSArray *featuredItemsSorters;
    if ([defaults boolForKey:@"sortFeaturedItemsByTitle"]) {
        featuredItemsSorters = [NSArray arrayWithObjects:sortByTitle, sortByIndex, nil];
    } else {
        featuredItemsSorters = [NSArray arrayWithObjects:sortByIndex, sortByTitle, nil];
    }
    if ([self.featuredItems count] > 0) {
        NSMutableArray *featuredItems = [NSMutableArray arrayWithCapacity:[self.featuredItems count]];
        for (StringObjectMO *featuredItem in [self.featuredItems sortedArrayUsingDescriptors:featuredItemsSorters]) {
            [featuredItems addObject:featuredItem.title];
        }
        [tmpDict setObject:featuredItems forKey:@"featured_items"];
    } else {
        if ([(NSDictionary *)self.originalManifest objectForKey:@"featured_items"] != nil) {
            [tmpDict setObject:[NSArray array] forKey:@"featured_items"];
        }
    }
	
    
    /*
     included_manifests
     */
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
    
    
	/*
     conditional_items
     */
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
