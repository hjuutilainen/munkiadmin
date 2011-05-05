// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ItemToCopyMO.m instead.

#import "_ItemToCopyMO.h"

@implementation ItemToCopyMOID
@end

@implementation _ItemToCopyMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ItemToCopy" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ItemToCopy";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ItemToCopy" inManagedObjectContext:moc_];
}

- (ItemToCopyMOID*)objectID {
	return (ItemToCopyMOID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic munki_group;






@dynamic munki_destination_path;






@dynamic munki_mode;






@dynamic munki_user;






@dynamic munki_source_item;






@dynamic package;

	





@end
