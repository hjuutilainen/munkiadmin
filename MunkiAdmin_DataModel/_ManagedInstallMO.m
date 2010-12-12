// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManagedInstallMO.m instead.

#import "_ManagedInstallMO.h"

@implementation ManagedInstallMOID
@end

@implementation _ManagedInstallMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ManagedInstall" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ManagedInstall";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ManagedInstall" inManagedObjectContext:moc_];
}

- (ManagedInstallMOID*)objectID {
	return (ManagedInstallMOID*)[super objectID];
}




@dynamic manifest;

	





@end
