// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManagedUpdateMO.m instead.

#import "_ManagedUpdateMO.h"

@implementation ManagedUpdateMOID
@end

@implementation _ManagedUpdateMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ManagedUpdate" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ManagedUpdate";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ManagedUpdate" inManagedObjectContext:moc_];
}

- (ManagedUpdateMOID*)objectID {
	return (ManagedUpdateMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic manifest;

@end

@implementation ManagedUpdateMORelationships 
+ (NSString *)manifest {
	return @"manifest";
}
@end

