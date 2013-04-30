// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallsItemCustomKeyMO.m instead.

#import "_InstallsItemCustomKeyMO.h"

const struct InstallsItemCustomKeyMOAttributes InstallsItemCustomKeyMOAttributes = {
	.customKeyName = @"customKeyName",
	.customKeyValue = @"customKeyValue",
};

const struct InstallsItemCustomKeyMORelationships InstallsItemCustomKeyMORelationships = {
	.installsItem = @"installsItem",
};

const struct InstallsItemCustomKeyMOFetchedProperties InstallsItemCustomKeyMOFetchedProperties = {
};

@implementation InstallsItemCustomKeyMOID
@end

@implementation _InstallsItemCustomKeyMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"InstallsItemCustomKey" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"InstallsItemCustomKey";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"InstallsItemCustomKey" inManagedObjectContext:moc_];
}

- (InstallsItemCustomKeyMOID*)objectID {
	return (InstallsItemCustomKeyMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic customKeyName;






@dynamic customKeyValue;






@dynamic installsItem;

	






@end
