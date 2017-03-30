// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ItemToCopyMO.m instead.

#import "_ItemToCopyMO.h"

@implementation ItemToCopyMOID
@end

@implementation _ItemToCopyMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
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

@implementation ItemToCopyMOAttributes 
+ (NSString *)munki_destination_item {
	return @"munki_destination_item";
}
+ (NSString *)munki_destination_path {
	return @"munki_destination_path";
}
+ (NSString *)munki_group {
	return @"munki_group";
}
+ (NSString *)munki_mode {
	return @"munki_mode";
}
+ (NSString *)munki_source_item {
	return @"munki_source_item";
}
+ (NSString *)munki_user {
	return @"munki_user";
}
+ (NSString *)originalIndex {
	return @"originalIndex";
}
@end

@implementation ItemToCopyMORelationships 
+ (NSString *)package {
	return @"package";
}
@end

