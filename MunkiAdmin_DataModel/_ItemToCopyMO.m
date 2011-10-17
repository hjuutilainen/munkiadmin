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
	
	if ([key isEqualToString:@"originalIndexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"originalIndex"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic munki_destination_path;






@dynamic munki_group;






@dynamic munki_mode;






@dynamic munki_source_item;






@dynamic munki_user;






@dynamic originalIndex;



- (int)originalIndexValue {
	NSNumber *result = [self originalIndex];
	return [result intValue];
}

- (void)setOriginalIndexValue:(int)value_ {
	[self setOriginalIndex:[NSNumber numberWithInt:value_]];
}

- (int)primitiveOriginalIndexValue {
	NSNumber *result = [self primitiveOriginalIndex];
	return [result intValue];
}

- (void)setPrimitiveOriginalIndexValue:(int)value_ {
	[self setPrimitiveOriginalIndex:[NSNumber numberWithInt:value_]];
}





@dynamic package;

	





@end
