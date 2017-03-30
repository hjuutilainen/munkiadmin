// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ReceiptMO.m instead.

#import "_ReceiptMO.h"

@implementation ReceiptMOID
@end

@implementation _ReceiptMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
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

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"munki_installed_sizeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_installed_size"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"munki_optionalValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_optional"];
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

@dynamic munki_filename;

@dynamic munki_installed_size;

- (int64_t)munki_installed_sizeValue {
	NSNumber *result = [self munki_installed_size];
	return [result longLongValue];
}

- (void)setMunki_installed_sizeValue:(int64_t)value_ {
	[self setMunki_installed_size:@(value_)];
}

- (int64_t)primitiveMunki_installed_sizeValue {
	NSNumber *result = [self primitiveMunki_installed_size];
	return [result longLongValue];
}

- (void)setPrimitiveMunki_installed_sizeValue:(int64_t)value_ {
	[self setPrimitiveMunki_installed_size:@(value_)];
}

@dynamic munki_name;

@dynamic munki_optional;

- (BOOL)munki_optionalValue {
	NSNumber *result = [self munki_optional];
	return [result boolValue];
}

- (void)setMunki_optionalValue:(BOOL)value_ {
	[self setMunki_optional:@(value_)];
}

- (BOOL)primitiveMunki_optionalValue {
	NSNumber *result = [self primitiveMunki_optional];
	return [result boolValue];
}

- (void)setPrimitiveMunki_optionalValue:(BOOL)value_ {
	[self setPrimitiveMunki_optional:@(value_)];
}

@dynamic munki_packageid;

@dynamic munki_version;

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

@implementation ReceiptMOAttributes 
+ (NSString *)munki_filename {
	return @"munki_filename";
}
+ (NSString *)munki_installed_size {
	return @"munki_installed_size";
}
+ (NSString *)munki_name {
	return @"munki_name";
}
+ (NSString *)munki_optional {
	return @"munki_optional";
}
+ (NSString *)munki_packageid {
	return @"munki_packageid";
}
+ (NSString *)munki_version {
	return @"munki_version";
}
+ (NSString *)originalIndex {
	return @"originalIndex";
}
@end

@implementation ReceiptMORelationships 
+ (NSString *)package {
	return @"package";
}
@end

