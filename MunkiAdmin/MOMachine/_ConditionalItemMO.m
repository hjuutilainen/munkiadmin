// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConditionalItemMO.m instead.

#import "_ConditionalItemMO.h"

const struct ConditionalItemMOAttributes ConditionalItemMOAttributes = {
	.munki_condition = @"munki_condition",
	.originalIndex = @"originalIndex",
};

const struct ConditionalItemMORelationships ConditionalItemMORelationships = {
	.children = @"children",
	.includedManifests = @"includedManifests",
	.managedInstalls = @"managedInstalls",
	.managedUninstalls = @"managedUninstalls",
	.managedUpdates = @"managedUpdates",
	.manifest = @"manifest",
	.optionalInstalls = @"optionalInstalls",
	.parent = @"parent",
};

@implementation ConditionalItemMOID
@end

@implementation _ConditionalItemMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
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
	[self setOriginalIndex:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveOriginalIndexValue {
	NSNumber *result = [self primitiveOriginalIndex];
	return [result intValue];
}

- (void)setPrimitiveOriginalIndexValue:(int32_t)value_ {
	[self setPrimitiveOriginalIndex:[NSNumber numberWithInt:value_]];
}

@dynamic children;

- (NSMutableSet*)childrenSet {
	[self willAccessValueForKey:@"children"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"children"];

	[self didAccessValueForKey:@"children"];
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

@dynamic manifest;

@dynamic optionalInstalls;

- (NSMutableSet*)optionalInstallsSet {
	[self willAccessValueForKey:@"optionalInstalls"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"optionalInstalls"];

	[self didAccessValueForKey:@"optionalInstalls"];
	return result;
}

@dynamic parent;

@end

