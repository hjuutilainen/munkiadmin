// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallerChoicesItemMO.m instead.

#import "_InstallerChoicesItemMO.h"

const struct InstallerChoicesItemMOAttributes InstallerChoicesItemMOAttributes = {
	.munki_attributeSetting = @"munki_attributeSetting",
	.munki_choiceAttribute = @"munki_choiceAttribute",
	.munki_choiceIdentifier = @"munki_choiceIdentifier",
	.originalIndex = @"originalIndex",
};

const struct InstallerChoicesItemMORelationships InstallerChoicesItemMORelationships = {
	.package = @"package",
};

const struct InstallerChoicesItemMOFetchedProperties InstallerChoicesItemMOFetchedProperties = {
};

@implementation InstallerChoicesItemMOID
@end

@implementation _InstallerChoicesItemMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"InstallerChoicesItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"InstallerChoicesItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"InstallerChoicesItem" inManagedObjectContext:moc_];
}

- (InstallerChoicesItemMOID*)objectID {
	return (InstallerChoicesItemMOID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"munki_attributeSettingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_attributeSetting"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"originalIndexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"originalIndex"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic munki_attributeSetting;



- (BOOL)munki_attributeSettingValue {
	NSNumber *result = [self munki_attributeSetting];
	return [result boolValue];
}

- (void)setMunki_attributeSettingValue:(BOOL)value_ {
	[self setMunki_attributeSetting:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveMunki_attributeSettingValue {
	NSNumber *result = [self primitiveMunki_attributeSetting];
	return [result boolValue];
}

- (void)setPrimitiveMunki_attributeSettingValue:(BOOL)value_ {
	[self setPrimitiveMunki_attributeSetting:[NSNumber numberWithBool:value_]];
}





@dynamic munki_choiceAttribute;






@dynamic munki_choiceIdentifier;






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
