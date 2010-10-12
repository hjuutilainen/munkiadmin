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




@dynamic munki_description;






@dynamic munki_display_name;






@dynamic munki_name;






@dynamic manifests;

	
- (NSMutableSet*)manifestsSet {
	[self willAccessValueForKey:@"manifests"];
	NSMutableSet *result = [self mutableSetValueForKey:@"manifests"];
	[self didAccessValueForKey:@"manifests"];
	return result;
}
	

@dynamic packages;

	
- (NSMutableSet*)packagesSet {
	[self willAccessValueForKey:@"packages"];
	NSMutableSet *result = [self mutableSetValueForKey:@"packages"];
	[self didAccessValueForKey:@"packages"];
	return result;
}
	

@dynamic applicationProxies;

	
- (NSMutableSet*)applicationProxiesSet {
	[self willAccessValueForKey:@"applicationProxies"];
	NSMutableSet *result = [self mutableSetValueForKey:@"applicationProxies"];
	[self didAccessValueForKey:@"applicationProxies"];
	return result;
}
	



@end
