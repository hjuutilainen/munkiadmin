// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CatalogMO.m instead.

#import "_CatalogMO.h"

@implementation CatalogMOID
@end

@implementation _CatalogMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
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

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic title;

@dynamic catalogInfos;

- (NSMutableSet<CatalogInfoMO*>*)catalogInfosSet {
	[self willAccessValueForKey:@"catalogInfos"];

	NSMutableSet<CatalogInfoMO*> *result = (NSMutableSet<CatalogInfoMO*>*)[self mutableSetValueForKey:@"catalogInfos"];

	[self didAccessValueForKey:@"catalogInfos"];
	return result;
}

@dynamic manifests;

- (NSMutableSet<ManifestMO*>*)manifestsSet {
	[self willAccessValueForKey:@"manifests"];

	NSMutableSet<ManifestMO*> *result = (NSMutableSet<ManifestMO*>*)[self mutableSetValueForKey:@"manifests"];

	[self didAccessValueForKey:@"manifests"];
	return result;
}

@dynamic packageInfos;

- (NSMutableSet<PackageInfoMO*>*)packageInfosSet {
	[self willAccessValueForKey:@"packageInfos"];

	NSMutableSet<PackageInfoMO*> *result = (NSMutableSet<PackageInfoMO*>*)[self mutableSetValueForKey:@"packageInfos"];

	[self didAccessValueForKey:@"packageInfos"];
	return result;
}

@dynamic packages;

- (NSMutableSet<PackageMO*>*)packagesSet {
	[self willAccessValueForKey:@"packages"];

	NSMutableSet<PackageMO*> *result = (NSMutableSet<PackageMO*>*)[self mutableSetValueForKey:@"packages"];

	[self didAccessValueForKey:@"packages"];
	return result;
}

@end

@implementation CatalogMOAttributes 
+ (NSString *)title {
	return @"title";
}
@end

@implementation CatalogMORelationships 
+ (NSString *)catalogInfos {
	return @"catalogInfos";
}
+ (NSString *)manifests {
	return @"manifests";
}
+ (NSString *)packageInfos {
	return @"packageInfos";
}
+ (NSString *)packages {
	return @"packages";
}
@end

