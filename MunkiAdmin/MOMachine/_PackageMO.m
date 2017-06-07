// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PackageMO.m instead.

#import "_PackageMO.h"

@implementation PackageMOID
@end

@implementation _PackageMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
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
	if ([key isEqualToString:@"munki_allow_untrustedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"munki_allow_untrusted"];
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
	[self setHasEmptyBlockingApplications:@(value_)];
}

- (BOOL)primitiveHasEmptyBlockingApplicationsValue {
	NSNumber *result = [self primitiveHasEmptyBlockingApplications];
	return [result boolValue];
}

- (void)setPrimitiveHasEmptyBlockingApplicationsValue:(BOOL)value_ {
	[self setPrimitiveHasEmptyBlockingApplications:@(value_)];
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

@dynamic munki_OnDemand;

- (BOOL)munki_OnDemandValue {
	NSNumber *result = [self munki_OnDemand];
	return [result boolValue];
}

- (void)setMunki_OnDemandValue:(BOOL)value_ {
	[self setMunki_OnDemand:@(value_)];
}

- (BOOL)primitiveMunki_OnDemandValue {
	NSNumber *result = [self primitiveMunki_OnDemand];
	return [result boolValue];
}

- (void)setPrimitiveMunki_OnDemandValue:(BOOL)value_ {
	[self setPrimitiveMunki_OnDemand:@(value_)];
}

@dynamic munki_PayloadIdentifier;

@dynamic munki_RestartAction;

@dynamic munki_allow_untrusted;

- (BOOL)munki_allow_untrustedValue {
	NSNumber *result = [self munki_allow_untrusted];
	return [result boolValue];
}

- (void)setMunki_allow_untrustedValue:(BOOL)value_ {
	[self setMunki_allow_untrusted:@(value_)];
}

- (BOOL)primitiveMunki_allow_untrustedValue {
	NSNumber *result = [self primitiveMunki_allow_untrusted];
	return [result boolValue];
}

- (void)setPrimitiveMunki_allow_untrustedValue:(BOOL)value_ {
	[self setPrimitiveMunki_allow_untrusted:@(value_)];
}

@dynamic munki_apple_item;

- (BOOL)munki_apple_itemValue {
	NSNumber *result = [self munki_apple_item];
	return [result boolValue];
}

- (void)setMunki_apple_itemValue:(BOOL)value_ {
	[self setMunki_apple_item:@(value_)];
}

- (BOOL)primitiveMunki_apple_itemValue {
	NSNumber *result = [self primitiveMunki_apple_item];
	return [result boolValue];
}

- (void)setPrimitiveMunki_apple_itemValue:(BOOL)value_ {
	[self setPrimitiveMunki_apple_item:@(value_)];
}

@dynamic munki_autoremove;

- (BOOL)munki_autoremoveValue {
	NSNumber *result = [self munki_autoremove];
	return [result boolValue];
}

- (void)setMunki_autoremoveValue:(BOOL)value_ {
	[self setMunki_autoremove:@(value_)];
}

- (BOOL)primitiveMunki_autoremoveValue {
	NSNumber *result = [self primitiveMunki_autoremove];
	return [result boolValue];
}

- (void)setPrimitiveMunki_autoremoveValue:(BOOL)value_ {
	[self setPrimitiveMunki_autoremove:@(value_)];
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
	[self setMunki_forced_install:@(value_)];
}

- (BOOL)primitiveMunki_forced_installValue {
	NSNumber *result = [self primitiveMunki_forced_install];
	return [result boolValue];
}

- (void)setPrimitiveMunki_forced_installValue:(BOOL)value_ {
	[self setPrimitiveMunki_forced_install:@(value_)];
}

@dynamic munki_forced_uninstall;

- (BOOL)munki_forced_uninstallValue {
	NSNumber *result = [self munki_forced_uninstall];
	return [result boolValue];
}

- (void)setMunki_forced_uninstallValue:(BOOL)value_ {
	[self setMunki_forced_uninstall:@(value_)];
}

- (BOOL)primitiveMunki_forced_uninstallValue {
	NSNumber *result = [self primitiveMunki_forced_uninstall];
	return [result boolValue];
}

- (void)setPrimitiveMunki_forced_uninstallValue:(BOOL)value_ {
	[self setPrimitiveMunki_forced_uninstall:@(value_)];
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
	[self setMunki_installed_size:@(value_)];
}

- (int64_t)primitiveMunki_installed_sizeValue {
	NSNumber *result = [self primitiveMunki_installed_size];
	return [result longLongValue];
}

- (void)setPrimitiveMunki_installed_sizeValue:(int64_t)value_ {
	[self setPrimitiveMunki_installed_size:@(value_)];
}

@dynamic munki_installer_item_hash;

@dynamic munki_installer_item_location;

@dynamic munki_installer_item_size;

- (int64_t)munki_installer_item_sizeValue {
	NSNumber *result = [self munki_installer_item_size];
	return [result longLongValue];
}

- (void)setMunki_installer_item_sizeValue:(int64_t)value_ {
	[self setMunki_installer_item_size:@(value_)];
}

- (int64_t)primitiveMunki_installer_item_sizeValue {
	NSNumber *result = [self primitiveMunki_installer_item_size];
	return [result longLongValue];
}

- (void)setPrimitiveMunki_installer_item_sizeValue:(int64_t)value_ {
	[self setPrimitiveMunki_installer_item_size:@(value_)];
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
	[self setMunki_preinstall_alert_enabled:@(value_)];
}

- (BOOL)primitiveMunki_preinstall_alert_enabledValue {
	NSNumber *result = [self primitiveMunki_preinstall_alert_enabled];
	return [result boolValue];
}

- (void)setPrimitiveMunki_preinstall_alert_enabledValue:(BOOL)value_ {
	[self setPrimitiveMunki_preinstall_alert_enabled:@(value_)];
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
	[self setMunki_preuninstall_alert_enabled:@(value_)];
}

- (BOOL)primitiveMunki_preuninstall_alert_enabledValue {
	NSNumber *result = [self primitiveMunki_preuninstall_alert_enabled];
	return [result boolValue];
}

- (void)setPrimitiveMunki_preuninstall_alert_enabledValue:(BOOL)value_ {
	[self setPrimitiveMunki_preuninstall_alert_enabled:@(value_)];
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
	[self setMunki_suppress_bundle_relocation:@(value_)];
}

- (BOOL)primitiveMunki_suppress_bundle_relocationValue {
	NSNumber *result = [self primitiveMunki_suppress_bundle_relocation];
	return [result boolValue];
}

- (void)setPrimitiveMunki_suppress_bundle_relocationValue:(BOOL)value_ {
	[self setPrimitiveMunki_suppress_bundle_relocation:@(value_)];
}

@dynamic munki_unattended_install;

- (BOOL)munki_unattended_installValue {
	NSNumber *result = [self munki_unattended_install];
	return [result boolValue];
}

- (void)setMunki_unattended_installValue:(BOOL)value_ {
	[self setMunki_unattended_install:@(value_)];
}

- (BOOL)primitiveMunki_unattended_installValue {
	NSNumber *result = [self primitiveMunki_unattended_install];
	return [result boolValue];
}

- (void)setPrimitiveMunki_unattended_installValue:(BOOL)value_ {
	[self setPrimitiveMunki_unattended_install:@(value_)];
}

@dynamic munki_unattended_uninstall;

- (BOOL)munki_unattended_uninstallValue {
	NSNumber *result = [self munki_unattended_uninstall];
	return [result boolValue];
}

- (void)setMunki_unattended_uninstallValue:(BOOL)value_ {
	[self setMunki_unattended_uninstall:@(value_)];
}

- (BOOL)primitiveMunki_unattended_uninstallValue {
	NSNumber *result = [self primitiveMunki_unattended_uninstall];
	return [result boolValue];
}

- (void)setPrimitiveMunki_unattended_uninstallValue:(BOOL)value_ {
	[self setPrimitiveMunki_unattended_uninstall:@(value_)];
}

@dynamic munki_uninstall_method;

@dynamic munki_uninstall_script;

@dynamic munki_uninstallable;

- (BOOL)munki_uninstallableValue {
	NSNumber *result = [self munki_uninstallable];
	return [result boolValue];
}

- (void)setMunki_uninstallableValue:(BOOL)value_ {
	[self setMunki_uninstallable:@(value_)];
}

- (BOOL)primitiveMunki_uninstallableValue {
	NSNumber *result = [self primitiveMunki_uninstallable];
	return [result boolValue];
}

- (void)setPrimitiveMunki_uninstallableValue:(BOOL)value_ {
	[self setPrimitiveMunki_uninstallable:@(value_)];
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

@dynamic uninstallerItemURL;

@dynamic blockingApplications;

- (NSMutableSet<StringObjectMO*>*)blockingApplicationsSet {
	[self willAccessValueForKey:@"blockingApplications"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"blockingApplications"];

	[self didAccessValueForKey:@"blockingApplications"];
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

@dynamic category;

@dynamic developer;

@dynamic iconImage;

@dynamic installerChoicesItems;

- (NSMutableSet<InstallerChoicesItemMO*>*)installerChoicesItemsSet {
	[self willAccessValueForKey:@"installerChoicesItems"];

	NSMutableSet<InstallerChoicesItemMO*> *result = (NSMutableSet<InstallerChoicesItemMO*>*)[self mutableSetValueForKey:@"installerChoicesItems"];

	[self didAccessValueForKey:@"installerChoicesItems"];
	return result;
}

@dynamic installerEnvironmentVariables;

- (NSMutableSet<InstallerEnvironmentVariableMO*>*)installerEnvironmentVariablesSet {
	[self willAccessValueForKey:@"installerEnvironmentVariables"];

	NSMutableSet<InstallerEnvironmentVariableMO*> *result = (NSMutableSet<InstallerEnvironmentVariableMO*>*)[self mutableSetValueForKey:@"installerEnvironmentVariables"];

	[self didAccessValueForKey:@"installerEnvironmentVariables"];
	return result;
}

@dynamic installsItems;

- (NSMutableSet<InstallsItemMO*>*)installsItemsSet {
	[self willAccessValueForKey:@"installsItems"];

	NSMutableSet<InstallsItemMO*> *result = (NSMutableSet<InstallsItemMO*>*)[self mutableSetValueForKey:@"installsItems"];

	[self didAccessValueForKey:@"installsItems"];
	return result;
}

@dynamic itemsToCopy;

- (NSMutableSet<ItemToCopyMO*>*)itemsToCopySet {
	[self willAccessValueForKey:@"itemsToCopy"];

	NSMutableSet<ItemToCopyMO*> *result = (NSMutableSet<ItemToCopyMO*>*)[self mutableSetValueForKey:@"itemsToCopy"];

	[self didAccessValueForKey:@"itemsToCopy"];
	return result;
}

@dynamic packageInfos;

- (NSMutableSet<PackageInfoMO*>*)packageInfosSet {
	[self willAccessValueForKey:@"packageInfos"];

	NSMutableSet<PackageInfoMO*> *result = (NSMutableSet<PackageInfoMO*>*)[self mutableSetValueForKey:@"packageInfos"];

	[self didAccessValueForKey:@"packageInfos"];
	return result;
}

@dynamic parentApplication;

@dynamic parentApplicationFromLatestPackage;

@dynamic receipts;

- (NSMutableSet<ReceiptMO*>*)receiptsSet {
	[self willAccessValueForKey:@"receipts"];

	NSMutableSet<ReceiptMO*> *result = (NSMutableSet<ReceiptMO*>*)[self mutableSetValueForKey:@"receipts"];

	[self didAccessValueForKey:@"receipts"];
	return result;
}

@dynamic referencingStringObjects;

- (NSMutableSet<StringObjectMO*>*)referencingStringObjectsSet {
	[self willAccessValueForKey:@"referencingStringObjects"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"referencingStringObjects"];

	[self didAccessValueForKey:@"referencingStringObjects"];
	return result;
}

@dynamic requirements;

- (NSMutableSet<StringObjectMO*>*)requirementsSet {
	[self willAccessValueForKey:@"requirements"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"requirements"];

	[self didAccessValueForKey:@"requirements"];
	return result;
}

@dynamic supportedArchitectures;

- (NSMutableSet<StringObjectMO*>*)supportedArchitecturesSet {
	[self willAccessValueForKey:@"supportedArchitectures"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"supportedArchitectures"];

	[self didAccessValueForKey:@"supportedArchitectures"];
	return result;
}

@dynamic updateFor;

- (NSMutableSet<StringObjectMO*>*)updateForSet {
	[self willAccessValueForKey:@"updateFor"];

	NSMutableSet<StringObjectMO*> *result = (NSMutableSet<StringObjectMO*>*)[self mutableSetValueForKey:@"updateFor"];

	[self didAccessValueForKey:@"updateFor"];
	return result;
}

@end

@implementation PackageMOAttributes 
+ (NSString *)hasEmptyBlockingApplications {
	return @"hasEmptyBlockingApplications";
}
+ (NSString *)hasUnstagedChanges {
	return @"hasUnstagedChanges";
}
+ (NSString *)munki_OnDemand {
	return @"munki_OnDemand";
}
+ (NSString *)munki_PayloadIdentifier {
	return @"munki_PayloadIdentifier";
}
+ (NSString *)munki_RestartAction {
	return @"munki_RestartAction";
}
+ (NSString *)munki_allow_untrusted {
	return @"munki_allow_untrusted";
}
+ (NSString *)munki_apple_item {
	return @"munki_apple_item";
}
+ (NSString *)munki_autoremove {
	return @"munki_autoremove";
}
+ (NSString *)munki_description {
	return @"munki_description";
}
+ (NSString *)munki_developer {
	return @"munki_developer";
}
+ (NSString *)munki_display_name {
	return @"munki_display_name";
}
+ (NSString *)munki_force_install_after_date {
	return @"munki_force_install_after_date";
}
+ (NSString *)munki_forced_install {
	return @"munki_forced_install";
}
+ (NSString *)munki_forced_uninstall {
	return @"munki_forced_uninstall";
}
+ (NSString *)munki_icon_hash {
	return @"munki_icon_hash";
}
+ (NSString *)munki_icon_name {
	return @"munki_icon_name";
}
+ (NSString *)munki_installable_condition {
	return @"munki_installable_condition";
}
+ (NSString *)munki_installcheck_script {
	return @"munki_installcheck_script";
}
+ (NSString *)munki_installed_size {
	return @"munki_installed_size";
}
+ (NSString *)munki_installer_item_hash {
	return @"munki_installer_item_hash";
}
+ (NSString *)munki_installer_item_location {
	return @"munki_installer_item_location";
}
+ (NSString *)munki_installer_item_size {
	return @"munki_installer_item_size";
}
+ (NSString *)munki_installer_type {
	return @"munki_installer_type";
}
+ (NSString *)munki_maximum_os_version {
	return @"munki_maximum_os_version";
}
+ (NSString *)munki_minimum_munki_version {
	return @"munki_minimum_munki_version";
}
+ (NSString *)munki_minimum_os_version {
	return @"munki_minimum_os_version";
}
+ (NSString *)munki_name {
	return @"munki_name";
}
+ (NSString *)munki_notes {
	return @"munki_notes";
}
+ (NSString *)munki_package_path {
	return @"munki_package_path";
}
+ (NSString *)munki_postinstall_script {
	return @"munki_postinstall_script";
}
+ (NSString *)munki_postuninstall_script {
	return @"munki_postuninstall_script";
}
+ (NSString *)munki_preinstall_alert_alert_detail {
	return @"munki_preinstall_alert_alert_detail";
}
+ (NSString *)munki_preinstall_alert_alert_title {
	return @"munki_preinstall_alert_alert_title";
}
+ (NSString *)munki_preinstall_alert_cancel_label {
	return @"munki_preinstall_alert_cancel_label";
}
+ (NSString *)munki_preinstall_alert_enabled {
	return @"munki_preinstall_alert_enabled";
}
+ (NSString *)munki_preinstall_alert_ok_label {
	return @"munki_preinstall_alert_ok_label";
}
+ (NSString *)munki_preinstall_script {
	return @"munki_preinstall_script";
}
+ (NSString *)munki_preuninstall_alert_alert_detail {
	return @"munki_preuninstall_alert_alert_detail";
}
+ (NSString *)munki_preuninstall_alert_alert_title {
	return @"munki_preuninstall_alert_alert_title";
}
+ (NSString *)munki_preuninstall_alert_cancel_label {
	return @"munki_preuninstall_alert_cancel_label";
}
+ (NSString *)munki_preuninstall_alert_enabled {
	return @"munki_preuninstall_alert_enabled";
}
+ (NSString *)munki_preuninstall_alert_ok_label {
	return @"munki_preuninstall_alert_ok_label";
}
+ (NSString *)munki_preuninstall_script {
	return @"munki_preuninstall_script";
}
+ (NSString *)munki_receipts {
	return @"munki_receipts";
}
+ (NSString *)munki_suppress_bundle_relocation {
	return @"munki_suppress_bundle_relocation";
}
+ (NSString *)munki_unattended_install {
	return @"munki_unattended_install";
}
+ (NSString *)munki_unattended_uninstall {
	return @"munki_unattended_uninstall";
}
+ (NSString *)munki_uninstall_method {
	return @"munki_uninstall_method";
}
+ (NSString *)munki_uninstall_script {
	return @"munki_uninstall_script";
}
+ (NSString *)munki_uninstallable {
	return @"munki_uninstallable";
}
+ (NSString *)munki_uninstallcheck_script {
	return @"munki_uninstallcheck_script";
}
+ (NSString *)munki_uninstaller_item_location {
	return @"munki_uninstaller_item_location";
}
+ (NSString *)munki_version {
	return @"munki_version";
}
+ (NSString *)originalPkginfo {
	return @"originalPkginfo";
}
+ (NSString *)packageDateCreated {
	return @"packageDateCreated";
}
+ (NSString *)packageDateLastOpened {
	return @"packageDateLastOpened";
}
+ (NSString *)packageDateModified {
	return @"packageDateModified";
}
+ (NSString *)packageInfoDateCreated {
	return @"packageInfoDateCreated";
}
+ (NSString *)packageInfoDateLastOpened {
	return @"packageInfoDateLastOpened";
}
+ (NSString *)packageInfoDateModified {
	return @"packageInfoDateModified";
}
+ (NSString *)packageInfoParentDirectoryURL {
	return @"packageInfoParentDirectoryURL";
}
+ (NSString *)packageInfoURL {
	return @"packageInfoURL";
}
+ (NSString *)packageURL {
	return @"packageURL";
}
+ (NSString *)titleWithVersion {
	return @"titleWithVersion";
}
+ (NSString *)uninstallerItemURL {
	return @"uninstallerItemURL";
}
@end

@implementation PackageMORelationships 
+ (NSString *)blockingApplications {
	return @"blockingApplications";
}
+ (NSString *)catalogInfos {
	return @"catalogInfos";
}
+ (NSString *)catalogs {
	return @"catalogs";
}
+ (NSString *)category {
	return @"category";
}
+ (NSString *)developer {
	return @"developer";
}
+ (NSString *)iconImage {
	return @"iconImage";
}
+ (NSString *)installerChoicesItems {
	return @"installerChoicesItems";
}
+ (NSString *)installerEnvironmentVariables {
	return @"installerEnvironmentVariables";
}
+ (NSString *)installsItems {
	return @"installsItems";
}
+ (NSString *)itemsToCopy {
	return @"itemsToCopy";
}
+ (NSString *)packageInfos {
	return @"packageInfos";
}
+ (NSString *)parentApplication {
	return @"parentApplication";
}
+ (NSString *)parentApplicationFromLatestPackage {
	return @"parentApplicationFromLatestPackage";
}
+ (NSString *)receipts {
	return @"receipts";
}
+ (NSString *)referencingStringObjects {
	return @"referencingStringObjects";
}
+ (NSString *)requirements {
	return @"requirements";
}
+ (NSString *)supportedArchitectures {
	return @"supportedArchitectures";
}
+ (NSString *)updateFor {
	return @"updateFor";
}
@end

