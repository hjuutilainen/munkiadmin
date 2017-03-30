// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DeveloperMO.m instead.

#import "_DeveloperMO.h"

@implementation DeveloperMOID
@end

@implementation _DeveloperMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
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

- (NSMutableSet<PackageMO*>*)packagesSet {
	[self willAccessValueForKey:@"packages"];

	NSMutableSet<PackageMO*> *result = (NSMutableSet<PackageMO*>*)[self mutableSetValueForKey:@"packages"];

	[self didAccessValueForKey:@"packages"];
	return result;
}

@end

@implementation DeveloperMOAttributes 
+ (NSString *)title {
	return @"title";
}
@end

@implementation DeveloperMORelationships 
+ (NSString *)developerSourceListReference {
	return @"developerSourceListReference";
}
+ (NSString *)packages {
	return @"packages";
}
@end

