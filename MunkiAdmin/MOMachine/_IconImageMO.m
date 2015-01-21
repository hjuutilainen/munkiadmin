// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to IconImageMO.m instead.

#import "_IconImageMO.h"

const struct IconImageMOAttributes IconImageMOAttributes = {
	.fileSHA256Checksum = @"fileSHA256Checksum",
	.imageRepresentation = @"imageRepresentation",
	.originalURL = @"originalURL",
};

const struct IconImageMORelationships IconImageMORelationships = {
	.packages = @"packages",
};

@implementation IconImageMOID
@end

@implementation _IconImageMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"IconImage" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"IconImage";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"IconImage" inManagedObjectContext:moc_];
}

- (IconImageMOID*)objectID {
	return (IconImageMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic fileSHA256Checksum;

@dynamic imageRepresentation;

@dynamic originalURL;

@dynamic packages;

- (NSMutableSet*)packagesSet {
	[self willAccessValueForKey:@"packages"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"packages"];

	[self didAccessValueForKey:@"packages"];
	return result;
}

@end

