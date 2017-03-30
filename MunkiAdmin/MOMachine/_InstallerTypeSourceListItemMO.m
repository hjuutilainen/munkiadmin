// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallerTypeSourceListItemMO.m instead.

#import "_InstallerTypeSourceListItemMO.h"

@implementation InstallerTypeSourceListItemMOID
@end

@implementation _InstallerTypeSourceListItemMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"InstallerTypeSourceListItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"InstallerTypeSourceListItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"InstallerTypeSourceListItem" inManagedObjectContext:moc_];
}

- (InstallerTypeSourceListItemMOID*)objectID {
	return (InstallerTypeSourceListItemMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@end

