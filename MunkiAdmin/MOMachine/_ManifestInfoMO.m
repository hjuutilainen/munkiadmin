// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManifestInfoMO.m instead.

#import "_ManifestInfoMO.h"

const struct ManifestInfoMOAttributes ManifestInfoMOAttributes = {
	.isAvailableForEditing = @"isAvailableForEditing",
	.isEnabledForManifest = @"isEnabledForManifest",
};

const struct ManifestInfoMORelationships ManifestInfoMORelationships = {
	.manifest = @"manifest",
	.parentManifest = @"parentManifest",
};

const struct ManifestInfoMOFetchedProperties ManifestInfoMOFetchedProperties = {
};

@implementation ManifestInfoMOID
@end

@implementation _ManifestInfoMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ManifestInfo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ManifestInfo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ManifestInfo" inManagedObjectContext:moc_];
}

- (ManifestInfoMOID*)objectID {
	return (ManifestInfoMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"isAvailableForEditingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isAvailableForEditing"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isEnabledForManifestValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isEnabledForManifest"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic isAvailableForEditing;



- (BOOL)isAvailableForEditingValue {
	NSNumber *result = [self isAvailableForEditing];
	return [result boolValue];
}

- (void)setIsAvailableForEditingValue:(BOOL)value_ {
	[self setIsAvailableForEditing:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsAvailableForEditingValue {
	NSNumber *result = [self primitiveIsAvailableForEditing];
	return [result boolValue];
}

- (void)setPrimitiveIsAvailableForEditingValue:(BOOL)value_ {
	[self setPrimitiveIsAvailableForEditing:[NSNumber numberWithBool:value_]];
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





@dynamic manifest;

	

@dynamic parentManifest;

	






@end
