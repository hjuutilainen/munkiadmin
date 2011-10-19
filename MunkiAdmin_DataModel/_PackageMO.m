// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PackageMO.m instead.

#import "_PackageMO.h"

@implementation PackageMOID
@end

@implementation _PackageMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Package" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Package";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc_];
}

- (PackageMOID*)objectID {
	return (PackageMOID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"munki_autoremoveValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_autoremove"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"munki_forced_installValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_forced_install"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"munki_forced_uninstallValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_forced_uninstall"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"munki_installed_sizeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_installed_size"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"munki_installer_item_sizeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_installer_item_size"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"munki_unattended_installValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_unattended_install"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"munki_unattended_uninstallValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_unattended_uninstall"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"munki_uninstallableValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_uninstallable"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic munki_autoremove;



- (BOOL)munki_autoremoveValue {
	NSNumber *result = [self munki_autoremove];
	return [result boolValue];
}

- (void)setMunki_autoremoveValue:(BOOL)value_ {
	[self setMunki_autoremove:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveMunki_autoremoveValue {
	NSNumber *result = [self primitiveMunki_autoremove];
	return [result boolValue];
}

- (void)setPrimitiveMunki_autoremoveValue:(BOOL)value_ {
	[self setPrimitiveMunki_autoremove:[NSNumber numberWithBool:value_]];
}





@dynamic munki_description;






@dynamic munki_display_name;






@dynamic munki_forced_install;



- (BOOL)munki_forced_installValue {
	NSNumber *result = [self munki_forced_install];
	return [result boolValue];
}

- (void)setMunki_forced_installValue:(BOOL)value_ {
	[self setMunki_forced_install:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveMunki_forced_installValue {
	NSNumber *result = [self primitiveMunki_forced_install];
	return [result boolValue];
}

- (void)setPrimitiveMunki_forced_installValue:(BOOL)value_ {
	[self setPrimitiveMunki_forced_install:[NSNumber numberWithBool:value_]];
}





@dynamic munki_forced_uninstall;



- (BOOL)munki_forced_uninstallValue {
	NSNumber *result = [self munki_forced_uninstall];
	return [result boolValue];
}

- (void)setMunki_forced_uninstallValue:(BOOL)value_ {
	[self setMunki_forced_uninstall:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveMunki_forced_uninstallValue {
	NSNumber *result = [self primitiveMunki_forced_uninstall];
	return [result boolValue];
}

- (void)setPrimitiveMunki_forced_uninstallValue:(BOOL)value_ {
	[self setPrimitiveMunki_forced_uninstall:[NSNumber numberWithBool:value_]];
}





@dynamic munki_installed_size;



- (long long)munki_installed_sizeValue {
	NSNumber *result = [self munki_installed_size];
	return [result longLongValue];
}

- (void)setMunki_installed_sizeValue:(long long)value_ {
	[self setMunki_installed_size:[NSNumber numberWithLongLong:value_]];
}

- (long long)primitiveMunki_installed_sizeValue {
	NSNumber *result = [self primitiveMunki_installed_size];
	return [result longLongValue];
}

- (void)setPrimitiveMunki_installed_sizeValue:(long long)value_ {
	[self setPrimitiveMunki_installed_size:[NSNumber numberWithLongLong:value_]];
}





@dynamic munki_installer_item_hash;






@dynamic munki_installer_item_location;






@dynamic munki_installer_item_size;



- (long long)munki_installer_item_sizeValue {
	NSNumber *result = [self munki_installer_item_size];
	return [result longLongValue];
}

- (void)setMunki_installer_item_sizeValue:(long long)value_ {
	[self setMunki_installer_item_size:[NSNumber numberWithLongLong:value_]];
}

- (long long)primitiveMunki_installer_item_sizeValue {
	NSNumber *result = [self primitiveMunki_installer_item_size];
	return [result longLongValue];
}

- (void)setPrimitiveMunki_installer_item_sizeValue:(long long)value_ {
	[self setPrimitiveMunki_installer_item_size:[NSNumber numberWithLongLong:value_]];
}





@dynamic munki_installer_type;






@dynamic munki_maximum_os_version;






@dynamic munki_minimum_os_version;






@dynamic munki_name;






@dynamic munki_package_path;






@dynamic munki_postinstall_script;






@dynamic munki_postuninstall_script;






@dynamic munki_preinstall_script;






@dynamic munki_preuninstall_script;






@dynamic munki_receipts;






@dynamic munki_unattended_install;



- (BOOL)munki_unattended_installValue {
	NSNumber *result = [self munki_unattended_install];
	return [result boolValue];
}

- (void)setMunki_unattended_installValue:(BOOL)value_ {
	[self setMunki_unattended_install:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveMunki_unattended_installValue {
	NSNumber *result = [self primitiveMunki_unattended_install];
	return [result boolValue];
}

- (void)setPrimitiveMunki_unattended_installValue:(BOOL)value_ {
	[self setPrimitiveMunki_unattended_install:[NSNumber numberWithBool:value_]];
}





@dynamic munki_unattended_uninstall;



- (BOOL)munki_unattended_uninstallValue {
	NSNumber *result = [self munki_unattended_uninstall];
	return [result boolValue];
}

- (void)setMunki_unattended_uninstallValue:(BOOL)value_ {
	[self setMunki_unattended_uninstall:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveMunki_unattended_uninstallValue {
	NSNumber *result = [self primitiveMunki_unattended_uninstall];
	return [result boolValue];
}

- (void)setPrimitiveMunki_unattended_uninstallValue:(BOOL)value_ {
	[self setPrimitiveMunki_unattended_uninstall:[NSNumber numberWithBool:value_]];
}





@dynamic munki_uninstall_method;






@dynamic munki_uninstall_script;






@dynamic munki_uninstallable;



- (BOOL)munki_uninstallableValue {
	NSNumber *result = [self munki_uninstallable];
	return [result boolValue];
}

- (void)setMunki_uninstallableValue:(BOOL)value_ {
	[self setMunki_uninstallable:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveMunki_uninstallableValue {
	NSNumber *result = [self primitiveMunki_uninstallable];
	return [result boolValue];
}

- (void)setPrimitiveMunki_uninstallableValue:(BOOL)value_ {
	[self setPrimitiveMunki_uninstallable:[NSNumber numberWithBool:value_]];
}





@dynamic munki_uninstaller_item_location;






@dynamic munki_version;






@dynamic originalPkginfo;






@dynamic packageInfoURL;






@dynamic packageURL;






@dynamic titleWithVersion;






@dynamic blockingApplications;

	
- (NSMutableSet*)blockingApplicationsSet {
	[self willAccessValueForKey:@"blockingApplications"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"blockingApplications"];
	[self didAccessValueForKey:@"blockingApplications"];
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
	

@dynamic installerChoicesItems;

	
- (NSMutableSet*)installerChoicesItemsSet {
	[self willAccessValueForKey:@"installerChoicesItems"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"installerChoicesItems"];
	[self didAccessValueForKey:@"installerChoicesItems"];
	return result;
}
	

@dynamic installsItems;

	
- (NSMutableSet*)installsItemsSet {
	[self willAccessValueForKey:@"installsItems"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"installsItems"];
	[self didAccessValueForKey:@"installsItems"];
	return result;
}
	

@dynamic itemsToCopy;

	
- (NSMutableSet*)itemsToCopySet {
	[self willAccessValueForKey:@"itemsToCopy"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"itemsToCopy"];
	[self didAccessValueForKey:@"itemsToCopy"];
	return result;
}
	

@dynamic packageInfos;

	
- (NSMutableSet*)packageInfosSet {
	[self willAccessValueForKey:@"packageInfos"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"packageInfos"];
	[self didAccessValueForKey:@"packageInfos"];
	return result;
}
	

@dynamic parentApplication;

	

@dynamic receipts;

	
- (NSMutableSet*)receiptsSet {
	[self willAccessValueForKey:@"receipts"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"receipts"];
	[self didAccessValueForKey:@"receipts"];
	return result;
}
	

@dynamic requirements;

	
- (NSMutableSet*)requirementsSet {
	[self willAccessValueForKey:@"requirements"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"requirements"];
	[self didAccessValueForKey:@"requirements"];
	return result;
}
	

@dynamic updateFor;

	
- (NSMutableSet*)updateForSet {
	[self willAccessValueForKey:@"updateFor"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"updateFor"];
	[self didAccessValueForKey:@"updateFor"];
	return result;
}
	





@end
