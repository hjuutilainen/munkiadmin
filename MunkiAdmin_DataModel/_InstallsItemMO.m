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




@dynamic munki_CFBundleShortVersionString;






@dynamic munki_path;






@dynamic munki_CFBundleIdentifier;






@dynamic munki_md5checksum;






@dynamic munki_CFBundleName;






@dynamic munki_type;






@dynamic packages;

	
- (NSMutableSet*)packagesSet {
	[self willAccessValueForKey:@"packages"];
	NSMutableSet *result = [self mutableSetValueForKey:@"packages"];
	[self didAccessValueForKey:@"packages"];
	return result;
}
	



@end
