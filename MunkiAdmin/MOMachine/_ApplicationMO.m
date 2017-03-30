// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ApplicationMO.m instead.

#import "_ApplicationMO.h"

@implementation ApplicationMOID
@end

@implementation _ApplicationMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Application" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Application";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Application" inManagedObjectContext:moc_];
}

- (ApplicationMOID*)objectID {
	return (ApplicationMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic munki_description;

@dynamic munki_display_name;

@dynamic munki_name;

@dynamic applicationProxies;

- (NSMutableSet<ApplicationProxyMO*>*)applicationProxiesSet {
	[self willAccessValueForKey:@"applicationProxies"];

	NSMutableSet<ApplicationProxyMO*> *result = (NSMutableSet<ApplicationProxyMO*>*)[self mutableSetValueForKey:@"applicationProxies"];

	[self didAccessValueForKey:@"applicationProxies"];
	return result;
}

@dynamic latestPackage;

@dynamic manifests;

- (NSMutableSet<ManifestMO*>*)manifestsSet {
	[self willAccessValueForKey:@"manifests"];

	NSMutableSet<ManifestMO*> *result = (NSMutableSet<ManifestMO*>*)[self mutableSetValueForKey:@"manifests"];

	[self didAccessValueForKey:@"manifests"];
	return result;
}

@dynamic packages;

- (NSMutableSet<PackageMO*>*)packagesSet {
	[self willAccessValueForKey:@"packages"];

	NSMutableSet<PackageMO*> *result = (NSMutableSet<PackageMO*>*)[self mutableSetValueForKey:@"packages"];

	[self didAccessValueForKey:@"packages"];
	return result;
}

@dynamic referencingStringObjects;

- (NSMutableSet<StringObjectMO*>*)referencingStringObjectsSet {
	[self willAccessValueForKey:@"referencingStringObjects"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"referencingStringObjects"];

	[self didAccessValueForKey:@"referencingStringObjects"];
	return result;
}

@end

@implementation ApplicationMOAttributes 
+ (NSString *)munki_description {
	return @"munki_description";
}
+ (NSString *)munki_display_name {
	return @"munki_display_name";
}
+ (NSString *)munki_name {
	return @"munki_name";
}
@end

@implementation ApplicationMORelationships 
+ (NSString *)applicationProxies {
	return @"applicationProxies";
}
+ (NSString *)latestPackage {
	return @"latestPackage";
}
+ (NSString *)manifests {
	return @"manifests";
}
+ (NSString *)packages {
	return @"packages";
}
+ (NSString *)referencingStringObjects {
	return @"referencingStringObjects";
}
@end

