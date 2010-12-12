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





@dynamic munki_display_name;






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





@dynamic packageInfoURL;






@dynamic munki_installer_item_location;






@dynamic munki_installer_type;






@dynamic munki_receipts;






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





@dynamic munki_package_path;






@dynamic munki_installer_item_hash;






@dynamic munki_uninstall_method;






@dynamic munki_version;






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






@dynamic munki_minimum_os_version;






@dynamic munki_name;






@dynamic packageURL;






@dynamic originalPkginfo;






@dynamic parentApplication;

	

@dynamic packageInfos;

	
- (NSMutableSet*)packageInfosSet {
	[self willAccessValueForKey:@"packageInfos"];
	NSMutableSet *result = [self mutableSetValueForKey:@"packageInfos"];
	[self didAccessValueForKey:@"packageInfos"];
	return result;
}
	

@dynamic updateFor;

	
- (NSMutableSet*)updateForSet {
	[self willAccessValueForKey:@"updateFor"];
	NSMutableSet *result = [self mutableSetValueForKey:@"updateFor"];
	[self didAccessValueForKey:@"updateFor"];
	return result;
}
	

@dynamic catalogs;

	
- (NSMutableSet*)catalogsSet {
	[self willAccessValueForKey:@"catalogs"];
	NSMutableSet *result = [self mutableSetValueForKey:@"catalogs"];
	[self didAccessValueForKey:@"catalogs"];
	return result;
}
	

@dynamic installsItems;

	
- (NSMutableSet*)installsItemsSet {
	[self willAccessValueForKey:@"installsItems"];
	NSMutableSet *result = [self mutableSetValueForKey:@"installsItems"];
	[self didAccessValueForKey:@"installsItems"];
	return result;
}
	

@dynamic requirements;

	
- (NSMutableSet*)requirementsSet {
	[self willAccessValueForKey:@"requirements"];
	NSMutableSet *result = [self mutableSetValueForKey:@"requirements"];
	[self didAccessValueForKey:@"requirements"];
	return result;
}
	

@dynamic receipts;

	
- (NSMutableSet*)receiptsSet {
	[self willAccessValueForKey:@"receipts"];
	NSMutableSet *result = [self mutableSetValueForKey:@"receipts"];
	[self didAccessValueForKey:@"receipts"];
	return result;
}
	

@dynamic itemsToCopy;

	
- (NSMutableSet*)itemsToCopySet {
	[self willAccessValueForKey:@"itemsToCopy"];
	NSMutableSet *result = [self mutableSetValueForKey:@"itemsToCopy"];
	[self didAccessValueForKey:@"itemsToCopy"];
	return result;
}
	

@dynamic catalogInfos;

	
- (NSMutableSet*)catalogInfosSet {
	[self willAccessValueForKey:@"catalogInfos"];
	NSMutableSet *result = [self mutableSetValueForKey:@"catalogInfos"];
	[self didAccessValueForKey:@"catalogInfos"];
	return result;
}
	





@end
