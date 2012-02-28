// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CatalogMO.m instead.

#import "_CatalogMO.h"

const struct CatalogMOAttributes CatalogMOAttributes = {
	.title = @"title",
};

const struct CatalogMORelationships CatalogMORelationships = {
	.catalogInfos = @"catalogInfos",
	.manifests = @"manifests",
	.packageInfos = @"packageInfos",
	.packages = @"packages",
};

const struct CatalogMOFetchedProperties CatalogMOFetchedProperties = {
};

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

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic title;






@dynamic catalogInfos;

	
- (NSMutableSet*)catalogInfosSet {
	[self willAccessValueForKey:@"catalogInfos"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"catalogInfos"];
  
	[self didAccessValueForKey:@"catalogInfos"];
	return result;
}
	

@dynamic manifests;

	
- (NSMutableSet*)manifestsSet {
	[self willAccessValueForKey:@"manifests"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"manifests"];
  
	[self didAccessValueForKey:@"manifests"];
	return result;
}
	

@dynamic packageInfos;

	
- (NSMutableSet*)packageInfosSet {
	[self willAccessValueForKey:@"packageInfos"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"packageInfos"];
  
	[self didAccessValueForKey:@"packageInfos"];
	return result;
}
	

@dynamic packages;

	
- (NSMutableSet*)packagesSet {
	[self willAccessValueForKey:@"packages"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"packages"];
  
	[self didAccessValueForKey:@"packages"];
	return result;
}
	






@end
