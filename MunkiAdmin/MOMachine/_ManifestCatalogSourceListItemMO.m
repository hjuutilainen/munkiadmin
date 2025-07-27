// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManifestCatalogSourceListItemMO.m instead.

#import "_ManifestCatalogSourceListItemMO.h"

@implementation ManifestCatalogSourceListItemMOID
@end

@implementation _ManifestCatalogSourceListItemMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ManifestCatalogSourceListItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ManifestCatalogSourceListItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ManifestCatalogSourceListItem" inManagedObjectContext:moc_];
}

- (ManifestCatalogSourceListItemMOID*)objectID {
	return (ManifestCatalogSourceListItemMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic catalogReference;

@end

@implementation ManifestCatalogSourceListItemMORelationships 
+ (NSString *)catalogReference {
	return @"catalogReference";
}
@end

