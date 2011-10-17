// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallsItemMO.m instead.

#import "_InstallsItemMO.h"

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

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"originalIndexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"originalIndex"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
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





@dynamic packages;

	
- (NSMutableSet*)packagesSet {
	[self willAccessValueForKey:@"packages"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"packages"];
	[self didAccessValueForKey:@"packages"];
	return result;
}
	





@end
