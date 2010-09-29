// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManifestMO.m instead.

#import "_ManifestMO.h"

@implementation ManifestMOID
@end

@implementation _ManifestMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Manifest" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Manifest";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:moc_];
}

- (ManifestMOID*)objectID {
	return (ManifestMOID*)[super objectID];
}




@dynamic title;






@dynamic manifestURL;






@dynamic catalogInfos;

	
- (NSMutableSet*)catalogInfosSet {
	[self willAccessValueForKey:@"catalogInfos"];
	NSMutableSet *result = [self mutableSetValueForKey:@"catalogInfos"];
	[self didAccessValueForKey:@"catalogInfos"];
	return result;
}
	

@dynamic catalogs;

	
- (NSMutableSet*)catalogsSet {
	[self willAccessValueForKey:@"catalogs"];
	NSMutableSet *result = [self mutableSetValueForKey:@"catalogs"];
	[self didAccessValueForKey:@"catalogs"];
	return result;
}
	

@dynamic applications;

	
- (NSMutableSet*)applicationsSet {
	[self willAccessValueForKey:@"applications"];
	NSMutableSet *result = [self mutableSetValueForKey:@"applications"];
	[self didAccessValueForKey:@"applications"];
	return result;
}
	

@dynamic manifestInfos;

	
- (NSMutableSet*)manifestInfosSet {
	[self willAccessValueForKey:@"manifestInfos"];
	NSMutableSet *result = [self mutableSetValueForKey:@"manifestInfos"];
	[self didAccessValueForKey:@"manifestInfos"];
	return result;
}
	

@dynamic applicationInfos;

	
- (NSMutableSet*)applicationInfosSet {
	[self willAccessValueForKey:@"applicationInfos"];
	NSMutableSet *result = [self mutableSetValueForKey:@"applicationInfos"];
	[self didAccessValueForKey:@"applicationInfos"];
	return result;
}
	

@dynamic includedManifests;

	
- (NSMutableSet*)includedManifestsSet {
	[self willAccessValueForKey:@"includedManifests"];
	NSMutableSet *result = [self mutableSetValueForKey:@"includedManifests"];
	[self didAccessValueForKey:@"includedManifests"];
	return result;
}
	



@end
