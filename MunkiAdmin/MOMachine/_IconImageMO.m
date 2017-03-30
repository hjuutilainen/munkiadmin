// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to IconImageMO.m instead.

#import "_IconImageMO.h"

@implementation IconImageMOID
@end

@implementation _IconImageMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"IconImage" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"IconImage";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"IconImage" inManagedObjectContext:moc_];
}

- (IconImageMOID*)objectID {
	return (IconImageMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic imageRepresentation;

@dynamic originalURL;

@dynamic packages;

- (NSMutableSet<PackageMO*>*)packagesSet {
	[self willAccessValueForKey:@"packages"];

	NSMutableSet<PackageMO*> *result = (NSMutableSet<PackageMO*>*)[self mutableSetValueForKey:@"packages"];

	[self didAccessValueForKey:@"packages"];
	return result;
}

@end

@implementation IconImageMOAttributes 
+ (NSString *)imageRepresentation {
	return @"imageRepresentation";
}
+ (NSString *)originalURL {
	return @"originalURL";
}
@end

@implementation IconImageMORelationships 
+ (NSString *)packages {
	return @"packages";
}
@end

