// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ReceiptMO.m instead.

#import "_ReceiptMO.h"

const struct ReceiptMOAttributes ReceiptMOAttributes = {
	.munki_filename = @"munki_filename",
	.munki_installed_size = @"munki_installed_size",
	.munki_name = @"munki_name",
	.munki_packageid = @"munki_packageid",
	.munki_version = @"munki_version",
	.originalIndex = @"originalIndex",
};

const struct ReceiptMORelationships ReceiptMORelationships = {
	.package = @"package",
};

const struct ReceiptMOFetchedProperties ReceiptMOFetchedProperties = {
};

@implementation ReceiptMOID
@end

@implementation _ReceiptMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Receipt" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Receipt";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Receipt" inManagedObjectContext:moc_];
}

- (ReceiptMOID*)objectID {
	return (ReceiptMOID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"munki_installed_sizeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_installed_size"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"originalIndexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"originalIndex"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic munki_filename;






@dynamic munki_installed_size;



- (int64_t)munki_installed_sizeValue {
	NSNumber *result = [self munki_installed_size];
	return [result longLongValue];
}

- (void)setMunki_installed_sizeValue:(int64_t)value_ {
	[self setMunki_installed_size:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveMunki_installed_sizeValue {
	NSNumber *result = [self primitiveMunki_installed_size];
	return [result longLongValue];
}

- (void)setPrimitiveMunki_installed_sizeValue:(int64_t)value_ {
	[self setPrimitiveMunki_installed_size:[NSNumber numberWithLongLong:value_]];
}





@dynamic munki_name;






@dynamic munki_packageid;






@dynamic munki_version;






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





@dynamic package;

	






@end
