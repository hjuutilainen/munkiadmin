// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CategoryMO.m instead.

#import "_CategoryMO.h"

const struct CategoryMOAttributes CategoryMOAttributes = {
	.title = @"title",
};

const struct CategoryMORelationships CategoryMORelationships = {
	.categorySourceListReference = @"categorySourceListReference",
	.packages = @"packages",
};

@implementation CategoryMOID
@end

@implementation _CategoryMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Category";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Category" inManagedObjectContext:moc_];
}

- (CategoryMOID*)objectID {
	return (CategoryMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic title;

@dynamic categorySourceListReference;

@dynamic packages;

- (NSMutableSet*)packagesSet {
	[self willAccessValueForKey:@"packages"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"packages"];

	[self didAccessValueForKey:@"packages"];
	return result;
}

@end

