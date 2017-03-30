// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OptionalInstallMO.m instead.

#import "_OptionalInstallMO.h"

@implementation OptionalInstallMOID
@end

@implementation _OptionalInstallMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OptionalInstall" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OptionalInstall";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OptionalInstall" inManagedObjectContext:moc_];
}

- (OptionalInstallMOID*)objectID {
	return (OptionalInstallMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic manifest;

@end

@implementation OptionalInstallMORelationships 
+ (NSString *)manifest {
	return @"manifest";
}
@end

