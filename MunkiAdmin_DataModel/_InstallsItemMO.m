// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallsItemMO.m instead.

#import "_InstallsItemMO.h"

const struct InstallsItemMOAttributes InstallsItemMOAttributes = {
	.munki_CFBundleIdentifier = @"munki_CFBundleIdentifier",
	.munki_CFBundleName = @"munki_CFBundleName",
	.munki_CFBundleShortVersionString = @"munki_CFBundleShortVersionString",
	.munki_md5checksum = @"munki_md5checksum",
	.munki_minosversion = @"munki_minosversion",
	.munki_path = @"munki_path",
	.munki_type = @"munki_type",
	.originalIndex = @"originalIndex",
};

const struct InstallsItemMORelationships InstallsItemMORelationships = {
	.packages = @"packages",
};

const struct InstallsItemMOFetchedProperties InstallsItemMOFetchedProperties = {
};

@implementation InstallsItemMOID
@end

@implementation _InstallsItemMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
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






@dynamic munki_md5checksum;






@dynamic munki_minosversion;






@dynamic munki_path;






@dynamic munki_type;






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
