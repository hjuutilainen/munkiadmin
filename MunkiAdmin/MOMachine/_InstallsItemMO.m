// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallsItemMO.m instead.

#import "_InstallsItemMO.h"

@implementation InstallsItemMOID
@end

@implementation _InstallsItemMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"InstallsItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"InstallsItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"InstallsItem" inManagedObjectContext:moc_];
}

- (InstallsItemMOID*)objectID {
	return (InstallsItemMOID*)[super objectID];
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

@dynamic munki_CFBundleIdentifier;

@dynamic munki_CFBundleName;

@dynamic munki_CFBundleShortVersionString;

@dynamic munki_CFBundleVersion;

@dynamic munki_md5checksum;

@dynamic munki_minosversion;

@dynamic munki_path;

@dynamic munki_type;

@dynamic munki_version_comparison_key;

@dynamic munki_version_comparison_key_value;

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

@dynamic originalInstallsItem;

@dynamic customKeys;

- (NSMutableSet<InstallsItemCustomKeyMO*>*)customKeysSet {
	[self willAccessValueForKey:@"customKeys"];

	NSMutableSet<InstallsItemCustomKeyMO*> *result = (NSMutableSet<InstallsItemCustomKeyMO*>*)[self mutableSetValueForKey:@"customKeys"];

	[self didAccessValueForKey:@"customKeys"];
	return result;
}

@dynamic packages;

- (NSMutableSet<PackageMO*>*)packagesSet {
	[self willAccessValueForKey:@"packages"];

	NSMutableSet<PackageMO*> *result = (NSMutableSet<PackageMO*>*)[self mutableSetValueForKey:@"packages"];

	[self didAccessValueForKey:@"packages"];
	return result;
}

@end

@implementation InstallsItemMOAttributes 
+ (NSString *)munki_CFBundleIdentifier {
	return @"munki_CFBundleIdentifier";
}
+ (NSString *)munki_CFBundleName {
	return @"munki_CFBundleName";
}
+ (NSString *)munki_CFBundleShortVersionString {
	return @"munki_CFBundleShortVersionString";
}
+ (NSString *)munki_CFBundleVersion {
	return @"munki_CFBundleVersion";
}
+ (NSString *)munki_md5checksum {
	return @"munki_md5checksum";
}
+ (NSString *)munki_minosversion {
	return @"munki_minosversion";
}
+ (NSString *)munki_path {
	return @"munki_path";
}
+ (NSString *)munki_type {
	return @"munki_type";
}
+ (NSString *)munki_version_comparison_key {
	return @"munki_version_comparison_key";
}
+ (NSString *)munki_version_comparison_key_value {
	return @"munki_version_comparison_key_value";
}
+ (NSString *)originalIndex {
	return @"originalIndex";
}
+ (NSString *)originalInstallsItem {
	return @"originalInstallsItem";
}
@end

@implementation InstallsItemMORelationships 
+ (NSString *)customKeys {
	return @"customKeys";
}
+ (NSString *)packages {
	return @"packages";
}
@end

