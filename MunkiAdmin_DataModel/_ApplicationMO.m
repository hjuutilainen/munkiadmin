// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ApplicationMO.m instead.

#import "_ApplicationMO.h"

@implementation ApplicationMOID
@end

@implementation _ApplicationMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
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

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic munki_description;






@dynamic munki_display_name;






@dynamic munki_name;






@dynamic applicationProxies;

	
- (NSMutableSet*)applicationProxiesSet {
	[self willAccessValueForKey:@"applicationProxies"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"applicationProxies"];
	[self didAccessValueForKey:@"applicationProxies"];
	return result;
}
	

@dynamic manifests;

	
- (NSMutableSet*)manifestsSet {
	[self willAccessValueForKey:@"manifests"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"manifests"];
	[self didAccessValueForKey:@"manifests"];
	return result;
}
	

@dynamic packages;

	
- (NSMutableSet*)packagesSet {
	[self willAccessValueForKey:@"packages"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"packages"];
	[self didAccessValueForKey:@"packages"];
	return result;
}
	

@dynamic referencingStringObjects;

	
- (NSMutableSet*)referencingStringObjectsSet {
	[self willAccessValueForKey:@"referencingStringObjects"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"referencingStringObjects"];
	[self didAccessValueForKey:@"referencingStringObjects"];
	return result;
}
	





@end
