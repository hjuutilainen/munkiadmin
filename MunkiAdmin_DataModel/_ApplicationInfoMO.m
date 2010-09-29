// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ApplicationInfoMO.m instead.

#import "_ApplicationInfoMO.h"

@implementation ApplicationInfoMOID
@end

@implementation _ApplicationInfoMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ApplicationInfo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ApplicationInfo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ApplicationInfo" inManagedObjectContext:moc_];
}

- (ApplicationInfoMOID*)objectID {
	return (ApplicationInfoMOID*)[super objectID];
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





@dynamic title;






@dynamic munki_name;






@dynamic manifest;

	

@dynamic application;

	



@end
