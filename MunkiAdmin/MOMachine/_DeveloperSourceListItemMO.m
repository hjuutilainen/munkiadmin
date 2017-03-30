// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DeveloperSourceListItemMO.m instead.

#import "_DeveloperSourceListItemMO.h"

@implementation DeveloperSourceListItemMOID
@end

@implementation _DeveloperSourceListItemMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DeveloperSourceListItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DeveloperSourceListItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DeveloperSourceListItem" inManagedObjectContext:moc_];
}

- (DeveloperSourceListItemMOID*)objectID {
	return (DeveloperSourceListItemMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic developerReference;

@end

@implementation DeveloperSourceListItemMORelationships 
+ (NSString *)developerReference {
	return @"developerReference";
}
@end

