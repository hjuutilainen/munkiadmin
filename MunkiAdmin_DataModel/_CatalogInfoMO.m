// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CatalogInfoMO.m instead.

#import "_CatalogInfoMO.h"

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





@dynamic manifest;

	

@dynamic package;

	

@dynamic catalog;

	





@end
