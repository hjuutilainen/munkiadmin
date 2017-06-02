// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConditionalItemMO.m instead.

#import "_ConditionalItemMO.h"

@implementation ConditionalItemMOID
@end

@implementation _ConditionalItemMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ConditionalItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ConditionalItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ConditionalItem" inManagedObjectContext:moc_];
}

- (ConditionalItemMOID*)objectID {
	return (ConditionalItemMOID*)[super objectID];
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

@dynamic munki_condition;

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

@dynamic children;

- (NSMutableSet<ConditionalItemMO*>*)childrenSet {
	[self willAccessValueForKey:@"children"];

	NSMutableSet<ConditionalItemMO*> *result = (NSMutableSet<ConditionalItemMO*>*)[self mutableSetValueForKey:@"children"];

	[self didAccessValueForKey:@"children"];
	return result;
}

@dynamic featuredItems;

- (NSMutableSet<StringObjectMO*>*)featuredItemsSet {
	[self willAccessValueForKey:@"featuredItems"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"featuredItems"];

	[self didAccessValueForKey:@"featuredItems"];
	return result;
}

@dynamic includedManifests;

- (NSMutableSet<StringObjectMO*>*)includedManifestsSet {
	[self willAccessValueForKey:@"includedManifests"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"includedManifests"];

	[self didAccessValueForKey:@"includedManifests"];
	return result;
}

@dynamic managedInstalls;

- (NSMutableSet<StringObjectMO*>*)managedInstallsSet {
	[self willAccessValueForKey:@"managedInstalls"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"managedInstalls"];

	[self didAccessValueForKey:@"managedInstalls"];
	return result;
}

@dynamic managedUninstalls;

- (NSMutableSet<StringObjectMO*>*)managedUninstallsSet {
	[self willAccessValueForKey:@"managedUninstalls"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"managedUninstalls"];

	[self didAccessValueForKey:@"managedUninstalls"];
	return result;
}

@dynamic managedUpdates;

- (NSMutableSet<StringObjectMO*>*)managedUpdatesSet {
	[self willAccessValueForKey:@"managedUpdates"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"managedUpdates"];

	[self didAccessValueForKey:@"managedUpdates"];
	return result;
}

@dynamic manifest;

@dynamic optionalInstalls;

- (NSMutableSet<StringObjectMO*>*)optionalInstallsSet {
	[self willAccessValueForKey:@"optionalInstalls"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"optionalInstalls"];

	[self didAccessValueForKey:@"optionalInstalls"];
	return result;
}

@dynamic parent;

@dynamic referencingManifests;

- (NSMutableSet<StringObjectMO*>*)referencingManifestsSet {
	[self willAccessValueForKey:@"referencingManifests"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"referencingManifests"];

	[self didAccessValueForKey:@"referencingManifests"];
	return result;
}

@end

@implementation ConditionalItemMOAttributes 
+ (NSString *)munki_condition {
	return @"munki_condition";
}
+ (NSString *)originalIndex {
	return @"originalIndex";
}
@end

@implementation ConditionalItemMORelationships 
+ (NSString *)children {
	return @"children";
}
+ (NSString *)featuredItems {
	return @"featuredItems";
}
+ (NSString *)includedManifests {
	return @"includedManifests";
}
+ (NSString *)managedInstalls {
	return @"managedInstalls";
}
+ (NSString *)managedUninstalls {
	return @"managedUninstalls";
}
+ (NSString *)managedUpdates {
	return @"managedUpdates";
}
+ (NSString *)manifest {
	return @"manifest";
}
+ (NSString *)optionalInstalls {
	return @"optionalInstalls";
}
+ (NSString *)parent {
	return @"parent";
}
+ (NSString *)referencingManifests {
	return @"referencingManifests";
}
@end

