// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ItemToCopyMO.m instead.

#import "_ItemToCopyMO.h"

const struct ItemToCopyMOAttributes ItemToCopyMOAttributes = {
	.munki_destination_item = @"munki_destination_item",
	.munki_destination_path = @"munki_destination_path",
	.munki_group = @"munki_group",
	.munki_mode = @"munki_mode",
	.munki_source_item = @"munki_source_item",
	.munki_user = @"munki_user",
	.originalIndex = @"originalIndex",
};

const struct ItemToCopyMORelationships ItemToCopyMORelationships = {
	.package = @"package",
};

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

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"originalIndexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"originalIndex"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic munki_destination_item;

@dynamic munki_destination_path;

@dynamic munki_group;

@dynamic munki_mode;

@dynamic munki_source_item;

@dynamic munki_user;

@dynamic originalIndex;

- (int32_t)originalIndexValue {
	NSNumber *result = [self originalIndex];
	return [result intValue];
}

- (void)setOriginalIndexValue:(int32_t)value_ {
	[self setOriginalIndex:@(value_)];
}

- (int32_t)primitiveOriginalIndexValue {
	NSNumber *result = [self primitiveOriginalIndex];
	return [result intValue];
}

- (void)setPrimitiveOriginalIndexValue:(int32_t)value_ {
	[self setPrimitiveOriginalIndex:@(value_)];
}

@dynamic package;

@end

