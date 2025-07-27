// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManifestBuiltinSourceListItemMO.m instead.

#import "_ManifestBuiltinSourceListItemMO.h"

@implementation ManifestBuiltinSourceListItemMOID
@end

@implementation _ManifestBuiltinSourceListItemMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ManifestBuiltinSourceListItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ManifestBuiltinSourceListItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ManifestBuiltinSourceListItem" inManagedObjectContext:moc_];
}

- (ManifestBuiltinSourceListItemMOID*)objectID {
	return (ManifestBuiltinSourceListItemMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic identifier;

@end

@implementation ManifestBuiltinSourceListItemMOAttributes 
+ (NSString *)identifier {
	return @"identifier";
}
@end

