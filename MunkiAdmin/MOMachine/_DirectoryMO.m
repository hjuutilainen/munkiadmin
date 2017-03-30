// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DirectoryMO.m instead.

#import "_DirectoryMO.h"

@implementation DirectoryMOID
@end

@implementation _DirectoryMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Directory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Directory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Directory" inManagedObjectContext:moc_];
}

- (DirectoryMOID*)objectID {
	return (DirectoryMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic originalURL;

@dynamic childPackages;

@end

@implementation DirectoryMOAttributes 
+ (NSString *)originalURL {
	return @"originalURL";
}
@end

@implementation DirectoryMOFetchedProperties 
+ (NSString *)childPackages {
	return @"childPackages";
}
@end

