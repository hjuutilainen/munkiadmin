// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CatalogInfoMO.m instead.

#import "_CatalogInfoMO.h"

@implementation CatalogInfoMOID
@end

@implementation _CatalogInfoMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
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

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"indexInManifestValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"indexInManifest"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isEnabledForManifestValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isEnabledForManifest"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isEnabledForPackageValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isEnabledForPackage"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"originalIndexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"originalIndex"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic indexInManifest;

- (int32_t)indexInManifestValue {
	NSNumber *result = [self indexInManifest];
	return [result intValue];
}

- (void)setIndexInManifestValue:(int32_t)value_ {
	[self setIndexInManifest:@(value_)];
}

- (int32_t)primitiveIndexInManifestValue {
	NSNumber *result = [self primitiveIndexInManifest];
	return [result intValue];
}

- (void)setPrimitiveIndexInManifestValue:(int32_t)value_ {
	[self setPrimitiveIndexInManifest:@(value_)];
}

@dynamic isEnabledForManifest;

- (BOOL)isEnabledForManifestValue {
	NSNumber *result = [self isEnabledForManifest];
	return [result boolValue];
}

- (void)setIsEnabledForManifestValue:(BOOL)value_ {
	[self setIsEnabledForManifest:@(value_)];
}

- (BOOL)primitiveIsEnabledForManifestValue {
	NSNumber *result = [self primitiveIsEnabledForManifest];
	return [result boolValue];
}

- (void)setPrimitiveIsEnabledForManifestValue:(BOOL)value_ {
	[self setPrimitiveIsEnabledForManifest:@(value_)];
}

@dynamic isEnabledForPackage;

- (BOOL)isEnabledForPackageValue {
	NSNumber *result = [self isEnabledForPackage];
	return [result boolValue];
}

- (void)setIsEnabledForPackageValue:(BOOL)value_ {
	[self setIsEnabledForPackage:@(value_)];
}

- (BOOL)primitiveIsEnabledForPackageValue {
	NSNumber *result = [self primitiveIsEnabledForPackage];
	return [result boolValue];
}

- (void)setPrimitiveIsEnabledForPackageValue:(BOOL)value_ {
	[self setPrimitiveIsEnabledForPackage:@(value_)];
}

@dynamic originalIndex;

- (int32_t)originalIndexValue {
	NSNumber *result = [self originalIndex];
	return [result intValue];
}

- (void)setOriginalIndexValue:(int32_t)value_ {
	[self setOriginalIndex:@(value_)];
}

- (int32_t)primitiveOriginalIndexValue {
	NSNumber *result = [self primitiveOriginalIndex];
	return [result intValue];
}

- (void)setPrimitiveOriginalIndexValue:(int32_t)value_ {
	[self setPrimitiveOriginalIndex:@(value_)];
}

@dynamic catalog;

@dynamic manifest;

@dynamic package;

@end

@implementation CatalogInfoMOAttributes 
+ (NSString *)indexInManifest {
	return @"indexInManifest";
}
+ (NSString *)isEnabledForManifest {
	return @"isEnabledForManifest";
}
+ (NSString *)isEnabledForPackage {
	return @"isEnabledForPackage";
}
+ (NSString *)originalIndex {
	return @"originalIndex";
}
@end

@implementation CatalogInfoMORelationships 
+ (NSString *)catalog {
	return @"catalog";
}
+ (NSString *)manifest {
	return @"manifest";
}
+ (NSString *)package {
	return @"package";
}
@end

