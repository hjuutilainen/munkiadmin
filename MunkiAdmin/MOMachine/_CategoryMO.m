// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CategoryMO.m instead.

#import "_CategoryMO.h"

@implementation CategoryMOID
@end

@implementation _CategoryMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
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

- (NSMutableSet<PackageMO*>*)packagesSet {
	[self willAccessValueForKey:@"packages"];

	NSMutableSet<PackageMO*> *result = (NSMutableSet<PackageMO*>*)[self mutableSetValueForKey:@"packages"];

	[self didAccessValueForKey:@"packages"];
	return result;
}

@end

@implementation CategoryMOAttributes 
+ (NSString *)title {
	return @"title";
}
@end

@implementation CategoryMORelationships 
+ (NSString *)categorySourceListReference {
	return @"categorySourceListReference";
}
+ (NSString *)packages {
	return @"packages";
}
@end

