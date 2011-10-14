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

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic manifestURL;






@dynamic originalManifest;






@dynamic title;






@dynamic applications;

	
- (NSMutableSet*)applicationsSet {
	[self willAccessValueForKey:@"applications"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"applications"];
	[self didAccessValueForKey:@"applications"];
	return result;
}
	

@dynamic catalogInfos;

	
- (NSMutableSet*)catalogInfosSet {
	[self willAccessValueForKey:@"catalogInfos"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"catalogInfos"];
	[self didAccessValueForKey:@"catalogInfos"];
	return result;
}
	

@dynamic catalogs;

	
- (NSMutableSet*)catalogsSet {
	[self willAccessValueForKey:@"catalogs"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"catalogs"];
	[self didAccessValueForKey:@"catalogs"];
	return result;
}
	

@dynamic includedManifests;

	
- (NSMutableSet*)includedManifestsSet {
	[self willAccessValueForKey:@"includedManifests"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"includedManifests"];
	[self didAccessValueForKey:@"includedManifests"];
	return result;
}
	

@dynamic managedInstalls;

	
- (NSMutableSet*)managedInstallsSet {
	[self willAccessValueForKey:@"managedInstalls"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"managedInstalls"];
	[self didAccessValueForKey:@"managedInstalls"];
	return result;
}
	

@dynamic managedUninstalls;

	
- (NSMutableSet*)managedUninstallsSet {
	[self willAccessValueForKey:@"managedUninstalls"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"managedUninstalls"];
	[self didAccessValueForKey:@"managedUninstalls"];
	return result;
}
	

@dynamic managedUpdates;

	
- (NSMutableSet*)managedUpdatesSet {
	[self willAccessValueForKey:@"managedUpdates"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"managedUpdates"];
	[self didAccessValueForKey:@"managedUpdates"];
	return result;
}
	

@dynamic manifestInfos;

	
- (NSMutableSet*)manifestInfosSet {
	[self willAccessValueForKey:@"manifestInfos"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"manifestInfos"];
	[self didAccessValueForKey:@"manifestInfos"];
	return result;
}
	

@dynamic optionalInstalls;

	
- (NSMutableSet*)optionalInstallsSet {
	[self willAccessValueForKey:@"optionalInstalls"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"optionalInstalls"];
	[self didAccessValueForKey:@"optionalInstalls"];
	return result;
}
	





@end
