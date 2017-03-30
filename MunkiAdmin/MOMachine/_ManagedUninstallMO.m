// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManagedUninstallMO.m instead.

#import "_ManagedUninstallMO.h"

@implementation ManagedUninstallMOID
@end

@implementation _ManagedUninstallMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ManagedUninstall" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ManagedUninstall";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ManagedUninstall" inManagedObjectContext:moc_];
}

- (ManagedUninstallMOID*)objectID {
	return (ManagedUninstallMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic manifest;

@end

@implementation ManagedUninstallMORelationships 
+ (NSString *)manifest {
	return @"manifest";
}
@end

