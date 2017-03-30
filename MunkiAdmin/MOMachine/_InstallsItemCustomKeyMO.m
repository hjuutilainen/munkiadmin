// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallsItemCustomKeyMO.m instead.

#import "_InstallsItemCustomKeyMO.h"

@implementation InstallsItemCustomKeyMOID
@end

@implementation _InstallsItemCustomKeyMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
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

@implementation InstallsItemCustomKeyMOAttributes 
+ (NSString *)customKeyName {
	return @"customKeyName";
}
+ (NSString *)customKeyValue {
	return @"customKeyValue";
}
@end

@implementation InstallsItemCustomKeyMORelationships 
+ (NSString *)installsItem {
	return @"installsItem";
}
@end

