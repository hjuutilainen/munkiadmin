// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StringObjectMO.m instead.

#import "_StringObjectMO.h"

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

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"indexInNestedManifestValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"indexInNestedManifest"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"originalIndexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"originalIndex"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic indexInNestedManifest;



- (int)indexInNestedManifestValue {
	NSNumber *result = [self indexInNestedManifest];
	return [result intValue];
}

- (void)setIndexInNestedManifestValue:(int)value_ {
	[self setIndexInNestedManifest:[NSNumber numberWithInt:value_]];
}

- (int)primitiveIndexInNestedManifestValue {
	NSNumber *result = [self primitiveIndexInNestedManifest];
	return [result intValue];
}

- (void)setPrimitiveIndexInNestedManifestValue:(int)value_ {
	[self setPrimitiveIndexInNestedManifest:[NSNumber numberWithInt:value_]];
}





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





@dynamic title;






@dynamic typeString;






@dynamic blockingApplicationReference;

	

@dynamic managedInstallReference;

	

@dynamic managedUninstallReference;

	

@dynamic managedUpdateReference;

	

@dynamic manifestReference;

	

@dynamic optionalInstallReference;

	

@dynamic requiresReference;

	

@dynamic updateForReference;

	



@dynamic manifestsWithSameTitle;

@dynamic packagesWithSameTitle;



@end
