// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CatalogInfoMO.m instead.

#import "_CatalogInfoMO.h"

const struct CatalogInfoMOAttributes CatalogInfoMOAttributes = {
	.indexInManifest = @"indexInManifest",
	.isEnabledForManifest = @"isEnabledForManifest",
	.isEnabledForPackage = @"isEnabledForPackage",
	.originalIndex = @"originalIndex",
};

const struct CatalogInfoMORelationships CatalogInfoMORelationships = {
	.catalog = @"catalog",
	.manifest = @"manifest",
	.package = @"package",
};

const struct CatalogInfoMOFetchedProperties CatalogInfoMOFetchedProperties = {
};

@implementation CatalogInfoMOID
@end

@implementation _CatalogInfoMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CatalogInfo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CatalogInfo" inManagedObjectContext:moc_];
}

- (CatalogInfoMOID*)objectID {
	return (CatalogInfoMOID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"indexInManifestValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"indexInManifest"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"isEnabledForManifestValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isEnabledForManifest"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"isEnabledForPackageValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isEnabledForPackage"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"originalIndexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"originalIndex"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic indexInManifest;



- (int)indexInManifestValue {
	NSNumber *result = [self indexInManifest];
	return [result intValue];
}

- (void)setIndexInManifestValue:(int)value_ {
	[self setIndexInManifest:[NSNumber numberWithInt:value_]];
}

- (int)primitiveIndexInManifestValue {
	NSNumber *result = [self primitiveIndexInManifest];
	return [result intValue];
}

- (void)setPrimitiveIndexInManifestValue:(int)value_ {
	[self setPrimitiveIndexInManifest:[NSNumber numberWithInt:value_]];
}





@dynamic isEnabledForManifest;



- (BOOL)isEnabledForManifestValue {
	NSNumber *result = [self isEnabledForManifest];
	return [result boolValue];
}

- (void)setIsEnabledForManifestValue:(BOOL)value_ {
	[self setIsEnabledForManifest:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsEnabledForManifestValue {
	NSNumber *result = [self primitiveIsEnabledForManifest];
	return [result boolValue];
}

- (void)setPrimitiveIsEnabledForManifestValue:(BOOL)value_ {
	[self setPrimitiveIsEnabledForManifest:[NSNumber numberWithBool:value_]];
}





@dynamic isEnabledForPackage;



- (BOOL)isEnabledForPackageValue {
	NSNumber *result = [self isEnabledForPackage];
	return [result boolValue];
}

- (void)setIsEnabledForPackageValue:(BOOL)value_ {
	[self setIsEnabledForPackage:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsEnabledForPackageValue {
	NSNumber *result = [self primitiveIsEnabledForPackage];
	return [result boolValue];
}

- (void)setPrimitiveIsEnabledForPackageValue:(BOOL)value_ {
	[self setPrimitiveIsEnabledForPackage:[NSNumber numberWithBool:value_]];
}





@dynamic originalIndex;



- (int)originalIndexValue {
	NSNumber *result = [self originalIndex];
	return [result intValue];
}

- (void)setOriginalIndexValue:(int)value_ {
	[self setOriginalIndex:[NSNumber numberWithInt:value_]];
}

- (int)primitiveOriginalIndexValue {
	NSNumber *result = [self primitiveOriginalIndex];
	return [result intValue];
}

- (void)setPrimitiveOriginalIndexValue:(int)value_ {
	[self setPrimitiveOriginalIndex:[NSNumber numberWithInt:value_]];
}





@dynamic catalog;

	

@dynamic manifest;

	

@dynamic package;

	





@end
