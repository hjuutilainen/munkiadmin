// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CategorySourceListItemMO.m instead.

#import "_CategorySourceListItemMO.h"

const struct CategorySourceListItemMOAttributes CategorySourceListItemMOAttributes = {
};

const struct CategorySourceListItemMORelationships CategorySourceListItemMORelationships = {
	.categoryReference = @"categoryReference",
};

const struct CategorySourceListItemMOFetchedProperties CategorySourceListItemMOFetchedProperties = {
};

@implementation CategorySourceListItemMOID
@end

@implementation _CategorySourceListItemMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CategorySourceListItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CategorySourceListItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CategorySourceListItem" inManagedObjectContext:moc_];
}

- (CategorySourceListItemMOID*)objectID {
	return (CategorySourceListItemMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic categoryReference;

	






@end
