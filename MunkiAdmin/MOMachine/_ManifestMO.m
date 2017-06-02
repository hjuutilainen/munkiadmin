// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManifestMO.m instead.

#import "_ManifestMO.h"

@implementation ManifestMOID
@end

@implementation _ManifestMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
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
	[self setHasUnstagedChanges:@(value_)];
}

- (BOOL)primitiveHasUnstagedChangesValue {
	NSNumber *result = [self primitiveHasUnstagedChanges];
	return [result boolValue];
}

- (void)setPrimitiveHasUnstagedChangesValue:(BOOL)value_ {
	[self setPrimitiveHasUnstagedChanges:@(value_)];
}

@dynamic manifestAdminNotes;

@dynamic manifestDateCreated;

@dynamic manifestDateLastOpened;

@dynamic manifestDateModified;

@dynamic manifestDisplayName;

@dynamic manifestParentDirectoryURL;

@dynamic manifestURL;

@dynamic manifestUserName;

@dynamic originalManifest;

@dynamic title;

@dynamic applications;

- (NSMutableSet<ApplicationMO*>*)applicationsSet {
	[self willAccessValueForKey:@"applications"];

	NSMutableSet<ApplicationMO*> *result = (NSMutableSet<ApplicationMO*>*)[self mutableSetValueForKey:@"applications"];

	[self didAccessValueForKey:@"applications"];
	return result;
}

@dynamic catalogInfos;

- (NSMutableSet<CatalogInfoMO*>*)catalogInfosSet {
	[self willAccessValueForKey:@"catalogInfos"];

	NSMutableSet<CatalogInfoMO*> *result = (NSMutableSet<CatalogInfoMO*>*)[self mutableSetValueForKey:@"catalogInfos"];

	[self didAccessValueForKey:@"catalogInfos"];
	return result;
}

@dynamic catalogs;

- (NSMutableSet<CatalogMO*>*)catalogsSet {
	[self willAccessValueForKey:@"catalogs"];

	NSMutableSet<CatalogMO*> *result = (NSMutableSet<CatalogMO*>*)[self mutableSetValueForKey:@"catalogs"];

	[self didAccessValueForKey:@"catalogs"];
	return result;
}

@dynamic conditionalItems;

- (NSMutableSet<ConditionalItemMO*>*)conditionalItemsSet {
	[self willAccessValueForKey:@"conditionalItems"];

	NSMutableSet<ConditionalItemMO*> *result = (NSMutableSet<ConditionalItemMO*>*)[self mutableSetValueForKey:@"conditionalItems"];

	[self didAccessValueForKey:@"conditionalItems"];
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

- (NSMutableSet<ManifestInfoMO*>*)includedManifestsSet {
	[self willAccessValueForKey:@"includedManifests"];

	NSMutableSet<ManifestInfoMO*> *result = (NSMutableSet<ManifestInfoMO*>*)[self mutableSetValueForKey:@"includedManifests"];

	[self didAccessValueForKey:@"includedManifests"];
	return result;
}

@dynamic includedManifestsFaster;

- (NSMutableSet<StringObjectMO*>*)includedManifestsFasterSet {
	[self willAccessValueForKey:@"includedManifestsFaster"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"includedManifestsFaster"];

	[self didAccessValueForKey:@"includedManifestsFaster"];
	return result;
}

@dynamic managedInstalls;

- (NSMutableSet<ManagedInstallMO*>*)managedInstallsSet {
	[self willAccessValueForKey:@"managedInstalls"];

	NSMutableSet<ManagedInstallMO*> *result = (NSMutableSet<ManagedInstallMO*>*)[self mutableSetValueForKey:@"managedInstalls"];

	[self didAccessValueForKey:@"managedInstalls"];
	return result;
}

@dynamic managedInstallsFaster;

- (NSMutableSet<StringObjectMO*>*)managedInstallsFasterSet {
	[self willAccessValueForKey:@"managedInstallsFaster"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"managedInstallsFaster"];

	[self didAccessValueForKey:@"managedInstallsFaster"];
	return result;
}

@dynamic managedUninstalls;

- (NSMutableSet<ManagedUninstallMO*>*)managedUninstallsSet {
	[self willAccessValueForKey:@"managedUninstalls"];

	NSMutableSet<ManagedUninstallMO*> *result = (NSMutableSet<ManagedUninstallMO*>*)[self mutableSetValueForKey:@"managedUninstalls"];

	[self didAccessValueForKey:@"managedUninstalls"];
	return result;
}

@dynamic managedUninstallsFaster;

- (NSMutableSet<StringObjectMO*>*)managedUninstallsFasterSet {
	[self willAccessValueForKey:@"managedUninstallsFaster"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"managedUninstallsFaster"];

	[self didAccessValueForKey:@"managedUninstallsFaster"];
	return result;
}

@dynamic managedUpdates;

- (NSMutableSet<ManagedUpdateMO*>*)managedUpdatesSet {
	[self willAccessValueForKey:@"managedUpdates"];

	NSMutableSet<ManagedUpdateMO*> *result = (NSMutableSet<ManagedUpdateMO*>*)[self mutableSetValueForKey:@"managedUpdates"];

	[self didAccessValueForKey:@"managedUpdates"];
	return result;
}

@dynamic managedUpdatesFaster;

- (NSMutableSet<StringObjectMO*>*)managedUpdatesFasterSet {
	[self willAccessValueForKey:@"managedUpdatesFaster"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"managedUpdatesFaster"];

	[self didAccessValueForKey:@"managedUpdatesFaster"];
	return result;
}

@dynamic manifestInfos;

- (NSMutableSet<ManifestInfoMO*>*)manifestInfosSet {
	[self willAccessValueForKey:@"manifestInfos"];

	NSMutableSet<ManifestInfoMO*> *result = (NSMutableSet<ManifestInfoMO*>*)[self mutableSetValueForKey:@"manifestInfos"];

	[self didAccessValueForKey:@"manifestInfos"];
	return result;
}

@dynamic optionalInstalls;

- (NSMutableSet<OptionalInstallMO*>*)optionalInstallsSet {
	[self willAccessValueForKey:@"optionalInstalls"];

	NSMutableSet<OptionalInstallMO*> *result = (NSMutableSet<OptionalInstallMO*>*)[self mutableSetValueForKey:@"optionalInstalls"];

	[self didAccessValueForKey:@"optionalInstalls"];
	return result;
}

@dynamic optionalInstallsFaster;

- (NSMutableSet<StringObjectMO*>*)optionalInstallsFasterSet {
	[self willAccessValueForKey:@"optionalInstallsFaster"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"optionalInstallsFaster"];

	[self didAccessValueForKey:@"optionalInstallsFaster"];
	return result;
}

@dynamic referencingManifests;

- (NSMutableSet<StringObjectMO*>*)referencingManifestsSet {
	[self willAccessValueForKey:@"referencingManifests"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"referencingManifests"];

	[self didAccessValueForKey:@"referencingManifests"];
	return result;
}

@dynamic allFeaturedItems;

@dynamic allIncludedManifests;

@dynamic allManagedInstalls;

@dynamic allManagedUninstalls;

@dynamic allManagedUpdates;

@dynamic allOptionalInstalls;

@dynamic allReferencingManifests;

@end

@implementation ManifestMOAttributes 
+ (NSString *)hasUnstagedChanges {
	return @"hasUnstagedChanges";
}
+ (NSString *)manifestAdminNotes {
	return @"manifestAdminNotes";
}
+ (NSString *)manifestDateCreated {
	return @"manifestDateCreated";
}
+ (NSString *)manifestDateLastOpened {
	return @"manifestDateLastOpened";
}
+ (NSString *)manifestDateModified {
	return @"manifestDateModified";
}
+ (NSString *)manifestDisplayName {
	return @"manifestDisplayName";
}
+ (NSString *)manifestParentDirectoryURL {
	return @"manifestParentDirectoryURL";
}
+ (NSString *)manifestURL {
	return @"manifestURL";
}
+ (NSString *)manifestUserName {
	return @"manifestUserName";
}
+ (NSString *)originalManifest {
	return @"originalManifest";
}
+ (NSString *)title {
	return @"title";
}
@end

@implementation ManifestMORelationships 
+ (NSString *)applications {
	return @"applications";
}
+ (NSString *)catalogInfos {
	return @"catalogInfos";
}
+ (NSString *)catalogs {
	return @"catalogs";
}
+ (NSString *)conditionalItems {
	return @"conditionalItems";
}
+ (NSString *)featuredItems {
	return @"featuredItems";
}
+ (NSString *)includedManifests {
	return @"includedManifests";
}
+ (NSString *)includedManifestsFaster {
	return @"includedManifestsFaster";
}
+ (NSString *)managedInstalls {
	return @"managedInstalls";
}
+ (NSString *)managedInstallsFaster {
	return @"managedInstallsFaster";
}
+ (NSString *)managedUninstalls {
	return @"managedUninstalls";
}
+ (NSString *)managedUninstallsFaster {
	return @"managedUninstallsFaster";
}
+ (NSString *)managedUpdates {
	return @"managedUpdates";
}
+ (NSString *)managedUpdatesFaster {
	return @"managedUpdatesFaster";
}
+ (NSString *)manifestInfos {
	return @"manifestInfos";
}
+ (NSString *)optionalInstalls {
	return @"optionalInstalls";
}
+ (NSString *)optionalInstallsFaster {
	return @"optionalInstallsFaster";
}
+ (NSString *)referencingManifests {
	return @"referencingManifests";
}
@end

@implementation ManifestMOFetchedProperties 
+ (NSString *)allFeaturedItems {
	return @"allFeaturedItems";
}
+ (NSString *)allIncludedManifests {
	return @"allIncludedManifests";
}
+ (NSString *)allManagedInstalls {
	return @"allManagedInstalls";
}
+ (NSString *)allManagedUninstalls {
	return @"allManagedUninstalls";
}
+ (NSString *)allManagedUpdates {
	return @"allManagedUpdates";
}
+ (NSString *)allOptionalInstalls {
	return @"allOptionalInstalls";
}
+ (NSString *)allReferencingManifests {
	return @"allReferencingManifests";
}
@end

