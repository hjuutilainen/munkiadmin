// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallerEnvironmentVariableMO.m instead.

#import "_InstallerEnvironmentVariableMO.h"

@implementation InstallerEnvironmentVariableMOID
@end

@implementation _InstallerEnvironmentVariableMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
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
	[self setOriginalIndex:@(value_)];
}

- (int32_t)primitiveOriginalIndexValue {
	NSNumber *result = [self primitiveOriginalIndex];
	return [result intValue];
}

- (void)setPrimitiveOriginalIndexValue:(int32_t)value_ {
	[self setPrimitiveOriginalIndex:@(value_)];
}

@dynamic packages;

- (NSMutableSet<PackageMO*>*)packagesSet {
	[self willAccessValueForKey:@"packages"];

	NSMutableSet<PackageMO*> *result = (NSMutableSet<PackageMO*>*)[self mutableSetValueForKey:@"packages"];

	[self didAccessValueForKey:@"packages"];
	return result;
}

@end

@implementation InstallerEnvironmentVariableMOAttributes 
+ (NSString *)munki_installer_environment_key {
	return @"munki_installer_environment_key";
}
+ (NSString *)munki_installer_environment_value {
	return @"munki_installer_environment_value";
}
+ (NSString *)originalIndex {
	return @"originalIndex";
}
@end

@implementation InstallerEnvironmentVariableMORelationships 
+ (NSString *)packages {
	return @"packages";
}
@end

