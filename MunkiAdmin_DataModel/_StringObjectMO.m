// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StringObjectMO.m instead.

#import "_StringObjectMO.h"

const struct StringObjectMOAttributes StringObjectMOAttributes = {
	.indexInNestedManifest = @"indexInNestedManifest",
	.originalIndex = @"originalIndex",
	.title = @"title",
	.typeString = @"typeString",
};

const struct StringObjectMORelationships StringObjectMORelationships = {
	.blockingApplicationReference = @"blockingApplicationReference",
	.includedManifestConditionalReference = @"includedManifestConditionalReference",
	.managedInstallConditionalReference = @"managedInstallConditionalReference",
	.managedInstallReference = @"managedInstallReference",
	.managedUninstallConditionalReference = @"managedUninstallConditionalReference",
	.managedUninstallReference = @"managedUninstallReference",
	.managedUpdateConditionalReference = @"managedUpdateConditionalReference",
	.managedUpdateReference = @"managedUpdateReference",
	.manifestReference = @"manifestReference",
	.optionalInstallConditionalReference = @"optionalInstallConditionalReference",
	.optionalInstallReference = @"optionalInstallReference",
	.originalApplication = @"originalApplication",
	.originalPackage = @"originalPackage",
	.requiresReference = @"requiresReference",
	.supportedArchitectureReference = @"supportedArchitectureReference",
	.updateForReference = @"updateForReference",
};

const struct StringObjectMOFetchedProperties StringObjectMOFetchedProperties = {
	.manifestsWithSameTitle = @"manifestsWithSameTitle",
	.packagesWithSameTitle = @"packagesWithSameTitle",
};

@implementation StringObjectMOID
@end

@implementation _StringObjectMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
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
	[self setIndexInNestedManifest:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveIndexInNestedManifestValue {
	NSNumber *result = [self primitiveIndexInNestedManifest];
	return [result intValue];
}

- (void)setPrimitiveIndexInNestedManifestValue:(int32_t)value_ {
	[self setPrimitiveIndexInNestedManifest:[NSNumber numberWithInt:value_]];
}





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





@dynamic title;






@dynamic typeString;






@dynamic blockingApplicationReference;

	

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

	

@dynamic originalPackage;

	

@dynamic requiresReference;

	

@dynamic supportedArchitectureReference;

	

@dynamic updateForReference;

	



@dynamic manifestsWithSameTitle;

@dynamic packagesWithSameTitle;




@end
