// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ApplicationProxyMO.m instead.

#import "_ApplicationProxyMO.h"

const struct ApplicationProxyMOAttributes ApplicationProxyMOAttributes = {
	.isEnabled = @"isEnabled",
};

const struct ApplicationProxyMORelationships ApplicationProxyMORelationships = {
	.parentApplication = @"parentApplication",
};

const struct ApplicationProxyMOFetchedProperties ApplicationProxyMOFetchedProperties = {
};

@implementation ApplicationProxyMOID
@end

@implementation _ApplicationProxyMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ApplicationProxy" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ApplicationProxy";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ApplicationProxy" inManagedObjectContext:moc_];
}

- (ApplicationProxyMOID*)objectID {
	return (ApplicationProxyMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"isEnabledValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isEnabled"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic isEnabled;



- (BOOL)isEnabledValue {
	NSNumber *result = [self isEnabled];
	return [result boolValue];
}

- (void)setIsEnabledValue:(BOOL)value_ {
	[self setIsEnabled:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsEnabledValue {
	NSNumber *result = [self primitiveIsEnabled];
	return [result boolValue];
}

- (void)setPrimitiveIsEnabledValue:(BOOL)value_ {
	[self setPrimitiveIsEnabled:[NSNumber numberWithBool:value_]];
}





@dynamic parentApplication;

	






@end
