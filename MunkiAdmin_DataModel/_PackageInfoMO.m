// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PackageInfoMO.m instead.

#import "_PackageInfoMO.h"

@implementation PackageInfoMOID
@end

@implementation _PackageInfoMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
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




@dynamic isEnabledForCatalog;



- (BOOL)isEnabledForCatalogValue {
	NSNumber *result = [self isEnabledForCatalog];
	return [result boolValue];
}

- (void)setIsEnabledForCatalogValue:(BOOL)value_ {
	[self setIsEnabledForCatalog:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsEnabledForCatalogValue {
	NSNumber *result = [self primitiveIsEnabledForCatalog];
	return [result boolValue];
}

- (void)setPrimitiveIsEnabledForCatalogValue:(BOOL)value_ {
	[self setPrimitiveIsEnabledForCatalog:[NSNumber numberWithBool:value_]];
}





@dynamic title;






@dynamic package;

	

@dynamic catalog;

	



@end
