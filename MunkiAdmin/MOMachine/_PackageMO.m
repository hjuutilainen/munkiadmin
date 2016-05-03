// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PackageMO.m instead.

#import "_PackageMO.h"

const struct PackageMOAttributes PackageMOAttributes = {
	.hasEmptyBlockingApplications = @"hasEmptyBlockingApplications",
	.hasUnstagedChanges = @"hasUnstagedChanges",
	.munki_OnDemand = @"munki_OnDemand",
	.munki_PayloadIdentifier = @"munki_PayloadIdentifier",
	.munki_RestartAction = @"munki_RestartAction",
	.munki_apple_item = @"munki_apple_item",
	.munki_autoremove = @"munki_autoremove",
	.munki_description = @"munki_description",
	.munki_developer = @"munki_developer",
	.munki_display_name = @"munki_display_name",
	.munki_force_install_after_date = @"munki_force_install_after_date",
	.munki_forced_install = @"munki_forced_install",
	.munki_forced_uninstall = @"munki_forced_uninstall",
	.munki_icon_hash = @"munki_icon_hash",
	.munki_icon_name = @"munki_icon_name",
	.munki_installable_condition = @"munki_installable_condition",
	.munki_installcheck_script = @"munki_installcheck_script",
	.munki_installed_size = @"munki_installed_size",
	.munki_installer_item_hash = @"munki_installer_item_hash",
	.munki_installer_item_location = @"munki_installer_item_location",
	.munki_installer_item_size = @"munki_installer_item_size",
	.munki_installer_type = @"munki_installer_type",
	.munki_maximum_os_version = @"munki_maximum_os_version",
	.munki_minimum_munki_version = @"munki_minimum_munki_version",
	.munki_minimum_os_version = @"munki_minimum_os_version",
	.munki_name = @"munki_name",
	.munki_notes = @"munki_notes",
	.munki_package_path = @"munki_package_path",
	.munki_postinstall_script = @"munki_postinstall_script",
	.munki_postuninstall_script = @"munki_postuninstall_script",
	.munki_preinstall_alert_alert_detail = @"munki_preinstall_alert_alert_detail",
	.munki_preinstall_alert_alert_title = @"munki_preinstall_alert_alert_title",
	.munki_preinstall_alert_cancel_label = @"munki_preinstall_alert_cancel_label",
	.munki_preinstall_alert_enabled = @"munki_preinstall_alert_enabled",
	.munki_preinstall_alert_ok_label = @"munki_preinstall_alert_ok_label",
	.munki_preinstall_script = @"munki_preinstall_script",
	.munki_preuninstall_alert_alert_detail = @"munki_preuninstall_alert_alert_detail",
	.munki_preuninstall_alert_alert_title = @"munki_preuninstall_alert_alert_title",
	.munki_preuninstall_alert_cancel_label = @"munki_preuninstall_alert_cancel_label",
	.munki_preuninstall_alert_enabled = @"munki_preuninstall_alert_enabled",
	.munki_preuninstall_alert_ok_label = @"munki_preuninstall_alert_ok_label",
	.munki_preuninstall_script = @"munki_preuninstall_script",
	.munki_receipts = @"munki_receipts",
	.munki_suppress_bundle_relocation = @"munki_suppress_bundle_relocation",
	.munki_unattended_install = @"munki_unattended_install",
	.munki_unattended_uninstall = @"munki_unattended_uninstall",
	.munki_uninstall_method = @"munki_uninstall_method",
	.munki_uninstall_script = @"munki_uninstall_script",
	.munki_uninstallable = @"munki_uninstallable",
	.munki_uninstallcheck_script = @"munki_uninstallcheck_script",
	.munki_uninstaller_item_location = @"munki_uninstaller_item_location",
	.munki_version = @"munki_version",
	.originalPkginfo = @"originalPkginfo",
	.packageDateCreated = @"packageDateCreated",
	.packageDateLastOpened = @"packageDateLastOpened",
	.packageDateModified = @"packageDateModified",
	.packageInfoDateCreated = @"packageInfoDateCreated",
	.packageInfoDateLastOpened = @"packageInfoDateLastOpened",
	.packageInfoDateModified = @"packageInfoDateModified",
	.packageInfoParentDirectoryURL = @"packageInfoParentDirectoryURL",
	.packageInfoURL = @"packageInfoURL",
	.packageURL = @"packageURL",
	.titleWithVersion = @"titleWithVersion",
};

const struct PackageMORelationships PackageMORelationships = {
	.blockingApplications = @"blockingApplications",
	.catalogInfos = @"catalogInfos",
	.catalogs = @"catalogs",
	.category = @"category",
	.developer = @"developer",
	.iconImage = @"iconImage",
	.installerChoicesItems = @"installerChoicesItems",
	.installerEnvironmentVariables = @"installerEnvironmentVariables",
	.installsItems = @"installsItems",
	.itemsToCopy = @"itemsToCopy",
	.packageInfos = @"packageInfos",
	.parentApplication = @"parentApplication",
	.parentApplicationFromLatestPackage = @"parentApplicationFromLatestPackage",
	.receipts = @"receipts",
	.referencingStringObjects = @"referencingStringObjects",
	.requirements = @"requirements",
	.supportedArchitectures = @"supportedArchitectures",
	.updateFor = @"updateFor",
};

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

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"hasEmptyBlockingApplicationsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hasEmptyBlockingApplications"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"hasUnstagedChangesValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hasUnstagedChanges"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"munki_OnDemandValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_OnDemand"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"munki_apple_itemValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_apple_item"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"munki_autoremoveValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_autoremove"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"munki_forced_installValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_forced_install"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"munki_forced_uninstallValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_forced_uninstall"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"munki_installed_sizeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_installed_size"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"munki_installer_item_sizeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_installer_item_size"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"munki_preinstall_alert_enabledValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_preinstall_alert_enabled"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"munki_preuninstall_alert_enabledValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_preuninstall_alert_enabled"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"munki_suppress_bundle_relocationValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_suppress_bundle_relocation"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"munki_unattended_installValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_unattended_install"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"munki_unattended_uninstallValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_unattended_uninstall"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"munki_uninstallableValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_uninstallable"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic hasEmptyBlockingApplications;

- (BOOL)hasEmptyBlockingApplicationsValue {
	NSNumber *result = [self hasEmptyBlockingApplications];
	return [result boolValue];
}

- (void)setHasEmptyBlockingApplicationsValue:(BOOL)value_ {
	[self setHasEmptyBlockingApplications:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveHasEmptyBlockingApplicationsValue {
	NSNumber *result = [self primitiveHasEmptyBlockingApplications];
	return [result boolValue];
}

- (void)setPrimitiveHasEmptyBlockingApplicationsValue:(BOOL)value_ {
	[self setPrimitiveHasEmptyBlockingApplications:[NSNumber numberWithBool:value_]];
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

@dynamic munki_OnDemand;

- (BOOL)munki_OnDemandValue {
	NSNumber *result = [self munki_OnDemand];
	return [result boolValue];
}

- (void)setMunki_OnDemandValue:(BOOL)value_ {
	[self setMunki_OnDemand:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveMunki_OnDemandValue {
	NSNumber *result = [self primitiveMunki_OnDemand];
	return [result boolValue];
}

- (void)setPrimitiveMunki_OnDemandValue:(BOOL)value_ {
	[self setPrimitiveMunki_OnDemand:[NSNumber numberWithBool:value_]];
}

@dynamic munki_PayloadIdentifier;

@dynamic munki_RestartAction;

@dynamic munki_apple_item;

- (BOOL)munki_apple_itemValue {
	NSNumber *result = [self munki_apple_item];
	return [result boolValue];
}

- (void)setMunki_apple_itemValue:(BOOL)value_ {
	[self setMunki_apple_item:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveMunki_apple_itemValue {
	NSNumber *result = [self primitiveMunki_apple_item];
	return [result boolValue];
}

- (void)setPrimitiveMunki_apple_itemValue:(BOOL)value_ {
	[self setPrimitiveMunki_apple_item:[NSNumber numberWithBool:value_]];
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

@dynamic munki_developer;

@dynamic munki_display_name;

@dynamic munki_force_install_after_date;

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

@dynamic munki_icon_hash;

@dynamic munki_icon_name;

@dynamic munki_installable_condition;

@dynamic munki_installcheck_script;

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

@dynamic munki_installer_item_hash;

@dynamic munki_installer_item_location;

@dynamic munki_installer_item_size;

- (int64_t)munki_installer_item_sizeValue {
	NSNumber *result = [self munki_installer_item_size];
	return [result longLongValue];
}

- (void)setMunki_installer_item_sizeValue:(int64_t)value_ {
	[self setMunki_installer_item_size:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveMunki_installer_item_sizeValue {
	NSNumber *result = [self primitiveMunki_installer_item_size];
	return [result longLongValue];
}

- (void)setPrimitiveMunki_installer_item_sizeValue:(int64_t)value_ {
	[self setPrimitiveMunki_installer_item_size:[NSNumber numberWithLongLong:value_]];
}

@dynamic munki_installer_type;

@dynamic munki_maximum_os_version;

@dynamic munki_minimum_munki_version;

@dynamic munki_minimum_os_version;

@dynamic munki_name;

@dynamic munki_notes;

@dynamic munki_package_path;

@dynamic munki_postinstall_script;

@dynamic munki_postuninstall_script;

@dynamic munki_preinstall_alert_alert_detail;

@dynamic munki_preinstall_alert_alert_title;

@dynamic munki_preinstall_alert_cancel_label;

@dynamic munki_preinstall_alert_enabled;

- (BOOL)munki_preinstall_alert_enabledValue {
	NSNumber *result = [self munki_preinstall_alert_enabled];
	return [result boolValue];
}

- (void)setMunki_preinstall_alert_enabledValue:(BOOL)value_ {
	[self setMunki_preinstall_alert_enabled:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveMunki_preinstall_alert_enabledValue {
	NSNumber *result = [self primitiveMunki_preinstall_alert_enabled];
	return [result boolValue];
}

- (void)setPrimitiveMunki_preinstall_alert_enabledValue:(BOOL)value_ {
	[self setPrimitiveMunki_preinstall_alert_enabled:[NSNumber numberWithBool:value_]];
}

@dynamic munki_preinstall_alert_ok_label;

@dynamic munki_preinstall_script;

@dynamic munki_preuninstall_alert_alert_detail;

@dynamic munki_preuninstall_alert_alert_title;

@dynamic munki_preuninstall_alert_cancel_label;

@dynamic munki_preuninstall_alert_enabled;

- (BOOL)munki_preuninstall_alert_enabledValue {
	NSNumber *result = [self munki_preuninstall_alert_enabled];
	return [result boolValue];
}

- (void)setMunki_preuninstall_alert_enabledValue:(BOOL)value_ {
	[self setMunki_preuninstall_alert_enabled:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveMunki_preuninstall_alert_enabledValue {
	NSNumber *result = [self primitiveMunki_preuninstall_alert_enabled];
	return [result boolValue];
}

- (void)setPrimitiveMunki_preuninstall_alert_enabledValue:(BOOL)value_ {
	[self setPrimitiveMunki_preuninstall_alert_enabled:[NSNumber numberWithBool:value_]];
}

@dynamic munki_preuninstall_alert_ok_label;

@dynamic munki_preuninstall_script;

@dynamic munki_receipts;

@dynamic munki_suppress_bundle_relocation;

- (BOOL)munki_suppress_bundle_relocationValue {
	NSNumber *result = [self munki_suppress_bundle_relocation];
	return [result boolValue];
}

- (void)setMunki_suppress_bundle_relocationValue:(BOOL)value_ {
	[self setMunki_suppress_bundle_relocation:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveMunki_suppress_bundle_relocationValue {
	NSNumber *result = [self primitiveMunki_suppress_bundle_relocation];
	return [result boolValue];
}

- (void)setPrimitiveMunki_suppress_bundle_relocationValue:(BOOL)value_ {
	[self setPrimitiveMunki_suppress_bundle_relocation:[NSNumber numberWithBool:value_]];
}

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

@dynamic munki_uninstallcheck_script;

@dynamic munki_uninstaller_item_location;

@dynamic munki_version;

@dynamic originalPkginfo;

@dynamic packageDateCreated;

@dynamic packageDateLastOpened;

@dynamic packageDateModified;

@dynamic packageInfoDateCreated;

@dynamic packageInfoDateLastOpened;

@dynamic packageInfoDateModified;

@dynamic packageInfoParentDirectoryURL;

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

@dynamic category;

@dynamic developer;

@dynamic iconImage;

@dynamic installerChoicesItems;

- (NSMutableSet*)installerChoicesItemsSet {
	[self willAccessValueForKey:@"installerChoicesItems"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"installerChoicesItems"];

	[self didAccessValueForKey:@"installerChoicesItems"];
	return result;
}

@dynamic installerEnvironmentVariables;

- (NSMutableSet*)installerEnvironmentVariablesSet {
	[self willAccessValueForKey:@"installerEnvironmentVariables"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"installerEnvironmentVariables"];

	[self didAccessValueForKey:@"installerEnvironmentVariables"];
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

@dynamic parentApplicationFromLatestPackage;

@dynamic receipts;

- (NSMutableSet*)receiptsSet {
	[self willAccessValueForKey:@"receipts"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"receipts"];

	[self didAccessValueForKey:@"receipts"];
	return result;
}

@dynamic referencingStringObjects;

- (NSMutableSet*)referencingStringObjectsSet {
	[self willAccessValueForKey:@"referencingStringObjects"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"referencingStringObjects"];

	[self didAccessValueForKey:@"referencingStringObjects"];
	return result;
}

@dynamic requirements;

- (NSMutableSet*)requirementsSet {
	[self willAccessValueForKey:@"requirements"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"requirements"];

	[self didAccessValueForKey:@"requirements"];
	return result;
}

@dynamic supportedArchitectures;

- (NSMutableSet*)supportedArchitecturesSet {
	[self willAccessValueForKey:@"supportedArchitectures"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"supportedArchitectures"];

	[self didAccessValueForKey:@"supportedArchitectures"];
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

