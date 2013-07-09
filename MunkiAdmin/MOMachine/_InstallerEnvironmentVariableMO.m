// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallerEnvironmentVariableMO.m instead.

#import "_InstallerEnvironmentVariableMO.h"

const struct InstallerEnvironmentVariableMOAttributes InstallerEnvironmentVariableMOAttributes = {
	.munki_installer_environment_key = @"munki_installer_environment_key",
	.munki_installer_environment_value = @"munki_installer_environment_value",
	.originalIndex = @"originalIndex",
};

const struct InstallerEnvironmentVariableMORelationships InstallerEnvironmentVariableMORelationships = {
	.packages = @"packages",
};

const struct InstallerEnvironmentVariableMOFetchedProperties InstallerEnvironmentVariableMOFetchedProperties = {
};

@implementation InstallerEnvironmentVariableMOID
@end

@implementation _InstallerEnvironmentVariableMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"InstallerEnvironmentVariable" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"InstallerEnvironmentVariable";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"InstallerEnvironmentVariable" inManagedObjectContext:moc_];
}

- (InstallerEnvironmentVariableMOID*)objectID {
	return (InstallerEnvironmentVariableMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"originalIndexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"originalIndex"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic munki_installer_environment_key;






@dynamic munki_installer_environment_value;






@dynamic originalIndex;



- (int32_t)originalIndexValue {
	NSNumber *result = [self originalIndex];
	return [result intValue];
}

- (void)setOriginalIndexValue:(int32_t)value_ {
	[self setOriginalIndex:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveOriginalIndexValue {
	NSNumber *result = [self primitiveOriginalIndex];
	return [result intValue];
}

- (void)setPrimitiveOriginalIndexValue:(int32_t)value_ {
	[self setPrimitiveOriginalIndex:[NSNumber numberWithInt:value_]];
}





@dynamic packages;

	
- (NSMutableSet*)packagesSet {
	[self willAccessValueForKey:@"packages"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"packages"];
  
	[self didAccessValueForKey:@"packages"];
	return result;
}
	






@end
