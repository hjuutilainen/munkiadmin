// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DeveloperMO.m instead.

#import "_DeveloperMO.h"

const struct DeveloperMOAttributes DeveloperMOAttributes = {
	.title = @"title",
};

const struct DeveloperMORelationships DeveloperMORelationships = {
	.developerSourceListReference = @"developerSourceListReference",
	.packages = @"packages",
};

@implementation DeveloperMOID
@end

@implementation _DeveloperMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Developer" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Developer";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Developer" inManagedObjectContext:moc_];
}

- (DeveloperMOID*)objectID {
	return (DeveloperMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic title;

@dynamic developerSourceListReference;

@dynamic packages;

- (NSMutableSet*)packagesSet {
	[self willAccessValueForKey:@"packages"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"packages"];

	[self didAccessValueForKey:@"packages"];
	return result;
}

@end

