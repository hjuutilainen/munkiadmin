// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PackageInfoMO.m instead.

#import "_PackageInfoMO.h"

@implementation PackageInfoMOID
@end

@implementation _PackageInfoMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"PackageInfo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"PackageInfo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"PackageInfo" inManagedObjectContext:moc_];
}

- (PackageInfoMOID*)objectID {
	return (PackageInfoMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"isEnabledForCatalogValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isEnabledForCatalog"];
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

@dynamic isEnabledForCatalog;

- (BOOL)isEnabledForCatalogValue {
	NSNumber *result = [self isEnabledForCatalog];
	return [result boolValue];
}

- (void)setIsEnabledForCatalogValue:(BOOL)value_ {
	[self setIsEnabledForCatalog:@(value_)];
}

- (BOOL)primitiveIsEnabledForCatalogValue {
	NSNumber *result = [self primitiveIsEnabledForCatalog];
	return [result boolValue];
}

- (void)setPrimitiveIsEnabledForCatalogValue:(BOOL)value_ {
	[self setPrimitiveIsEnabledForCatalog:@(value_)];
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

@dynamic title;

@dynamic catalog;

@dynamic package;

@end

@implementation PackageInfoMOAttributes 
+ (NSString *)isEnabledForCatalog {
	return @"isEnabledForCatalog";
}
+ (NSString *)originalIndex {
	return @"originalIndex";
}
+ (NSString *)title {
	return @"title";
}
@end

@implementation PackageInfoMORelationships 
+ (NSString *)catalog {
	return @"catalog";
}
+ (NSString *)package {
	return @"package";
}
@end

