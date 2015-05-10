// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManifestMO.m instead.

#import "_ManifestMO.h"

const struct ManifestMOAttributes ManifestMOAttributes = {
	.hasUnstagedChanges = @"hasUnstagedChanges",
	.manifestDateCreated = @"manifestDateCreated",
	.manifestDateLastOpened = @"manifestDateLastOpened",
	.manifestDateModified = @"manifestDateModified",
	.manifestParentDirectoryURL = @"manifestParentDirectoryURL",
	.manifestURL = @"manifestURL",
	.originalManifest = @"originalManifest",
	.title = @"title",
};

const struct ManifestMORelationships ManifestMORelationships = {
	.applications = @"applications",
	.catalogInfos = @"catalogInfos",
	.catalogs = @"catalogs",
	.conditionalItems = @"conditionalItems",
	.includedManifests = @"includedManifests",
	.includedManifestsFaster = @"includedManifestsFaster",
	.managedInstalls = @"managedInstalls",
	.managedInstallsFaster = @"managedInstallsFaster",
	.managedUninstalls = @"managedUninstalls",
	.managedUninstallsFaster = @"managedUninstallsFaster",
	.managedUpdates = @"managedUpdates",
	.managedUpdatesFaster = @"managedUpdatesFaster",
	.manifestInfos = @"manifestInfos",
	.optionalInstalls = @"optionalInstalls",
	.optionalInstallsFaster = @"optionalInstallsFaster",
	.referencingManifests = @"referencingManifests",
};

const struct ManifestMOFetchedProperties ManifestMOFetchedProperties = {
	.allIncludedManifests = @"allIncludedManifests",
	.allManagedInstalls = @"allManagedInstalls",
	.allManagedUninstalls = @"allManagedUninstalls",
	.allManagedUpdates = @"allManagedUpdates",
	.allOptionalInstalls = @"allOptionalInstalls",
	.allReferencingManifests = @"allReferencingManifests",
};

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

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"hasUnstagedChangesValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hasUnstagedChanges"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic hasUnstagedChanges;

- (BOOL)hasUnstagedChangesValue {
	NSNumber *result = [self hasUnstagedChanges];
	return [result boolValue];
}

- (void)setHasUnstagedChangesValue:(BOOL)value_ {
	[self setHasUnstagedChanges:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveHasUnstagedChangesValue {
	NSNumber *result = [self primitiveHasUnstagedChanges];
	return [result boolValue];
}

- (void)setPrimitiveHasUnstagedChangesValue:(BOOL)value_ {
	[self setPrimitiveHasUnstagedChanges:[NSNumber numberWithBool:value_]];
}

@dynamic manifestDateCreated;

@dynamic manifestDateLastOpened;

@dynamic manifestDateModified;

@dynamic manifestParentDirectoryURL;

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

@dynamic conditionalItems;

- (NSMutableSet*)conditionalItemsSet {
	[self willAccessValueForKey:@"conditionalItems"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"conditionalItems"];

	[self didAccessValueForKey:@"conditionalItems"];
	return result;
}

@dynamic includedManifests;

- (NSMutableSet*)includedManifestsSet {
	[self willAccessValueForKey:@"includedManifests"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"includedManifests"];

	[self didAccessValueForKey:@"includedManifests"];
	return result;
}

@dynamic includedManifestsFaster;

- (NSMutableSet*)includedManifestsFasterSet {
	[self willAccessValueForKey:@"includedManifestsFaster"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"includedManifestsFaster"];

	[self didAccessValueForKey:@"includedManifestsFaster"];
	return result;
}

@dynamic managedInstalls;

- (NSMutableSet*)managedInstallsSet {
	[self willAccessValueForKey:@"managedInstalls"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"managedInstalls"];

	[self didAccessValueForKey:@"managedInstalls"];
	return result;
}

@dynamic managedInstallsFaster;

- (NSMutableSet*)managedInstallsFasterSet {
	[self willAccessValueForKey:@"managedInstallsFaster"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"managedInstallsFaster"];

	[self didAccessValueForKey:@"managedInstallsFaster"];
	return result;
}

@dynamic managedUninstalls;

- (NSMutableSet*)managedUninstallsSet {
	[self willAccessValueForKey:@"managedUninstalls"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"managedUninstalls"];

	[self didAccessValueForKey:@"managedUninstalls"];
	return result;
}

@dynamic managedUninstallsFaster;

- (NSMutableSet*)managedUninstallsFasterSet {
	[self willAccessValueForKey:@"managedUninstallsFaster"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"managedUninstallsFaster"];

	[self didAccessValueForKey:@"managedUninstallsFaster"];
	return result;
}

@dynamic managedUpdates;

- (NSMutableSet*)managedUpdatesSet {
	[self willAccessValueForKey:@"managedUpdates"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"managedUpdates"];

	[self didAccessValueForKey:@"managedUpdates"];
	return result;
}

@dynamic managedUpdatesFaster;

- (NSMutableSet*)managedUpdatesFasterSet {
	[self willAccessValueForKey:@"managedUpdatesFaster"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"managedUpdatesFaster"];

	[self didAccessValueForKey:@"managedUpdatesFaster"];
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

@dynamic optionalInstallsFaster;

- (NSMutableSet*)optionalInstallsFasterSet {
	[self willAccessValueForKey:@"optionalInstallsFaster"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"optionalInstallsFaster"];

	[self didAccessValueForKey:@"optionalInstallsFaster"];
	return result;
}

@dynamic referencingManifests;

- (NSMutableSet*)referencingManifestsSet {
	[self willAccessValueForKey:@"referencingManifests"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"referencingManifests"];

	[self didAccessValueForKey:@"referencingManifests"];
	return result;
}

@dynamic allIncludedManifests;

@dynamic allManagedInstalls;

@dynamic allManagedUninstalls;

@dynamic allManagedUpdates;

@dynamic allOptionalInstalls;

@dynamic allReferencingManifests;

@end

