// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CatalogMO.m instead.

#import "_CatalogMO.h"

@implementation CatalogMOID
@end

@implementation _CatalogMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Catalog" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Catalog";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Catalog" inManagedObjectContext:moc_];
}

- (CatalogMOID*)objectID {
	return (CatalogMOID*)[super objectID];
}




@dynamic title;






@dynamic catalogInfos;

	
- (NSMutableSet*)catalogInfosSet {
	[self willAccessValueForKey:@"catalogInfos"];
	NSMutableSet *result = [self mutableSetValueForKey:@"catalogInfos"];
	[self didAccessValueForKey:@"catalogInfos"];
	return result;
}
	

@dynamic packages;

	
- (NSMutableSet*)packagesSet {
	[self willAccessValueForKey:@"packages"];
	NSMutableSet *result = [self mutableSetValueForKey:@"packages"];
	[self didAccessValueForKey:@"packages"];
	return result;
}
	

@dynamic packageInfos;

	
- (NSMutableSet*)packageInfosSet {
	[self willAccessValueForKey:@"packageInfos"];
	NSMutableSet *result = [self mutableSetValueForKey:@"packageInfos"];
	[self didAccessValueForKey:@"packageInfos"];
	return result;
}
	

@dynamic manifests;

	
- (NSMutableSet*)manifestsSet {
	[self willAccessValueForKey:@"manifests"];
	NSMutableSet *result = [self mutableSetValueForKey:@"manifests"];
	[self didAccessValueForKey:@"manifests"];
	return result;
}
	



@end
