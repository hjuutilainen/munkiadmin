// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DeveloperSourceListItemMO.m instead.

#import "_DeveloperSourceListItemMO.h"

const struct DeveloperSourceListItemMOAttributes DeveloperSourceListItemMOAttributes = {
};

const struct DeveloperSourceListItemMORelationships DeveloperSourceListItemMORelationships = {
	.developerReference = @"developerReference",
};

const struct DeveloperSourceListItemMOFetchedProperties DeveloperSourceListItemMOFetchedProperties = {
};

@implementation DeveloperSourceListItemMOID
@end

@implementation _DeveloperSourceListItemMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DeveloperSourceListItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DeveloperSourceListItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DeveloperSourceListItem" inManagedObjectContext:moc_];
}

- (DeveloperSourceListItemMOID*)objectID {
	return (DeveloperSourceListItemMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic developerReference;

	






@end
