// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StringObjectMO.m instead.

#import "_StringObjectMO.h"

@implementation StringObjectMOID
@end

@implementation _StringObjectMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"StringObject";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"StringObject" inManagedObjectContext:moc_];
}

- (StringObjectMOID*)objectID {
	return (StringObjectMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"indexInNestedManifestValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"indexInNestedManifest"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"originalIndexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"originalIndex"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic indexInNestedManifest;

- (int32_t)indexInNestedManifestValue {
	NSNumber *result = [self indexInNestedManifest];
	return [result intValue];
}

- (void)setIndexInNestedManifestValue:(int32_t)value_ {
	[self setIndexInNestedManifest:@(value_)];
}

- (int32_t)primitiveIndexInNestedManifestValue {
	NSNumber *result = [self primitiveIndexInNestedManifest];
	return [result intValue];
}

- (void)setPrimitiveIndexInNestedManifestValue:(int32_t)value_ {
	[self setPrimitiveIndexInNestedManifest:@(value_)];
}

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

@dynamic title;

@dynamic typeString;

@dynamic blockingApplicationReference;

@dynamic featuredItemConditionalReference;

@dynamic featuredItemReference;

@dynamic includedManifestConditionalReference;

@dynamic managedInstallConditionalReference;

@dynamic managedInstallReference;

@dynamic managedUninstallConditionalReference;

@dynamic managedUninstallReference;

@dynamic managedUpdateConditionalReference;

@dynamic managedUpdateReference;

@dynamic manifestReference;

@dynamic optionalInstallConditionalReference;

@dynamic optionalInstallReference;

@dynamic originalApplication;

@dynamic originalManifest;

@dynamic originalManifestConditionalReference;

@dynamic originalPackage;

@dynamic requiresReference;

@dynamic supportedArchitectureReference;

@dynamic updateForReference;

@dynamic manifestsWithSameTitle;

@dynamic packagesWithSameTitle;

@end

@implementation StringObjectMOAttributes 
+ (NSString *)indexInNestedManifest {
	return @"indexInNestedManifest";
}
+ (NSString *)originalIndex {
	return @"originalIndex";
}
+ (NSString *)title {
	return @"title";
}
+ (NSString *)typeString {
	return @"typeString";
}
@end

@implementation StringObjectMORelationships 
+ (NSString *)blockingApplicationReference {
	return @"blockingApplicationReference";
}
+ (NSString *)featuredItemConditionalReference {
	return @"featuredItemConditionalReference";
}
+ (NSString *)featuredItemReference {
	return @"featuredItemReference";
}
+ (NSString *)includedManifestConditionalReference {
	return @"includedManifestConditionalReference";
}
+ (NSString *)managedInstallConditionalReference {
	return @"managedInstallConditionalReference";
}
+ (NSString *)managedInstallReference {
	return @"managedInstallReference";
}
+ (NSString *)managedUninstallConditionalReference {
	return @"managedUninstallConditionalReference";
}
+ (NSString *)managedUninstallReference {
	return @"managedUninstallReference";
}
+ (NSString *)managedUpdateConditionalReference {
	return @"managedUpdateConditionalReference";
}
+ (NSString *)managedUpdateReference {
	return @"managedUpdateReference";
}
+ (NSString *)manifestReference {
	return @"manifestReference";
}
+ (NSString *)optionalInstallConditionalReference {
	return @"optionalInstallConditionalReference";
}
+ (NSString *)optionalInstallReference {
	return @"optionalInstallReference";
}
+ (NSString *)originalApplication {
	return @"originalApplication";
}
+ (NSString *)originalManifest {
	return @"originalManifest";
}
+ (NSString *)originalManifestConditionalReference {
	return @"originalManifestConditionalReference";
}
+ (NSString *)originalPackage {
	return @"originalPackage";
}
+ (NSString *)requiresReference {
	return @"requiresReference";
}
+ (NSString *)supportedArchitectureReference {
	return @"supportedArchitectureReference";
}
+ (NSString *)updateForReference {
	return @"updateForReference";
}
@end

@implementation StringObjectMOFetchedProperties 
+ (NSString *)manifestsWithSameTitle {
	return @"manifestsWithSameTitle";
}
+ (NSString *)packagesWithSameTitle {
	return @"packagesWithSameTitle";
}
@end

