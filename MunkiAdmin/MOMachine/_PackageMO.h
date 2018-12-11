// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PackageMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class StringObjectMO;
@class CatalogInfoMO;
@class CatalogMO;
@class CategoryMO;
@class DeveloperMO;
@class IconImageMO;
@class InstallerChoicesItemMO;
@class InstallerEnvironmentVariableMO;
@class InstallsItemMO;
@class ItemToCopyMO;
@class PackageInfoMO;
@class ApplicationMO;
@class ApplicationMO;
@class ReceiptMO;
@class StringObjectMO;
@class StringObjectMO;
@class StringObjectMO;
@class StringObjectMO;

@class NSObject;

@class NSObject;

@class NSObject;

@class NSObject;

@class NSObject;

@interface PackageMOID : NSManagedObjectID {}
@end

@interface _PackageMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) PackageMOID *objectID;

@property (nonatomic, strong, nullable) NSNumber* hasEmptyBlockingApplications;

@property (atomic) BOOL hasEmptyBlockingApplicationsValue;
- (BOOL)hasEmptyBlockingApplicationsValue;
- (void)setHasEmptyBlockingApplicationsValue:(BOOL)value_;

@property (nonatomic, strong) NSNumber* hasUnstagedChanges;

@property (atomic) BOOL hasUnstagedChangesValue;
- (BOOL)hasUnstagedChangesValue;
- (void)setHasUnstagedChangesValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSNumber* munki_OnDemand;

@property (atomic) BOOL munki_OnDemandValue;
- (BOOL)munki_OnDemandValue;
- (void)setMunki_OnDemandValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSString* munki_PayloadIdentifier;

@property (nonatomic, strong, nullable) NSString* munki_RestartAction;

@property (nonatomic, strong, nullable) NSNumber* munki_allow_untrusted;

@property (atomic) BOOL munki_allow_untrustedValue;
- (BOOL)munki_allow_untrustedValue;
- (void)setMunki_allow_untrustedValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSNumber* munki_apple_item;

@property (atomic) BOOL munki_apple_itemValue;
- (BOOL)munki_apple_itemValue;
- (void)setMunki_apple_itemValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSNumber* munki_autoremove;

@property (atomic) BOOL munki_autoremoveValue;
- (BOOL)munki_autoremoveValue;
- (void)setMunki_autoremoveValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSString* munki_description;

@property (nonatomic, strong, nullable) NSString* munki_developer;

@property (nonatomic, strong, nullable) NSString* munki_display_name;

@property (nonatomic, strong, nullable) NSDate* munki_force_install_after_date;

@property (nonatomic, strong, nullable) NSNumber* munki_forced_install;

@property (atomic) BOOL munki_forced_installValue;
- (BOOL)munki_forced_installValue;
- (void)setMunki_forced_installValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSNumber* munki_forced_uninstall;

@property (atomic) BOOL munki_forced_uninstallValue;
- (BOOL)munki_forced_uninstallValue;
- (void)setMunki_forced_uninstallValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSString* munki_icon_hash;

@property (nonatomic, strong, nullable) NSString* munki_icon_name;

@property (nonatomic, strong, nullable) NSString* munki_installable_condition;

@property (nonatomic, strong, nullable) NSString* munki_installcheck_script;

@property (nonatomic, strong, nullable) NSNumber* munki_installed_size;

@property (atomic) int64_t munki_installed_sizeValue;
- (int64_t)munki_installed_sizeValue;
- (void)setMunki_installed_sizeValue:(int64_t)value_;

@property (nonatomic, strong, nullable) NSString* munki_installer_item_hash;

@property (nonatomic, strong, nullable) NSString* munki_installer_item_location;

@property (nonatomic, strong, nullable) NSNumber* munki_installer_item_size;

@property (atomic) int64_t munki_installer_item_sizeValue;
- (int64_t)munki_installer_item_sizeValue;
- (void)setMunki_installer_item_sizeValue:(int64_t)value_;

@property (nonatomic, strong, nullable) NSString* munki_installer_type;

@property (nonatomic, strong, nullable) NSString* munki_maximum_os_version;

@property (nonatomic, strong, nullable) NSString* munki_minimum_munki_version;

@property (nonatomic, strong, nullable) NSString* munki_minimum_os_version;

@property (nonatomic, strong, nullable) NSString* munki_name;

@property (nonatomic, strong, nullable) NSString* munki_notes;

@property (nonatomic, strong, nullable) NSString* munki_package_path;

@property (nonatomic, strong, nullable) NSString* munki_postinstall_script;

@property (nonatomic, strong, nullable) NSString* munki_postuninstall_script;

@property (nonatomic, strong, nullable) NSNumber* munki_precache;

@property (atomic) BOOL munki_precacheValue;
- (BOOL)munki_precacheValue;
- (void)setMunki_precacheValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSString* munki_preinstall_alert_alert_detail;

@property (nonatomic, strong, nullable) NSString* munki_preinstall_alert_alert_title;

@property (nonatomic, strong, nullable) NSString* munki_preinstall_alert_cancel_label;

@property (nonatomic, strong, nullable) NSNumber* munki_preinstall_alert_enabled;

@property (atomic) BOOL munki_preinstall_alert_enabledValue;
- (BOOL)munki_preinstall_alert_enabledValue;
- (void)setMunki_preinstall_alert_enabledValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSString* munki_preinstall_alert_ok_label;

@property (nonatomic, strong, nullable) NSString* munki_preinstall_script;

@property (nonatomic, strong, nullable) NSString* munki_preuninstall_alert_alert_detail;

@property (nonatomic, strong, nullable) NSString* munki_preuninstall_alert_alert_title;

@property (nonatomic, strong, nullable) NSString* munki_preuninstall_alert_cancel_label;

@property (nonatomic, strong, nullable) NSNumber* munki_preuninstall_alert_enabled;

@property (atomic) BOOL munki_preuninstall_alert_enabledValue;
- (BOOL)munki_preuninstall_alert_enabledValue;
- (void)setMunki_preuninstall_alert_enabledValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSString* munki_preuninstall_alert_ok_label;

@property (nonatomic, strong, nullable) NSString* munki_preuninstall_script;

@property (nonatomic, strong, nullable) NSString* munki_receipts;

@property (nonatomic, strong, nullable) NSNumber* munki_suppress_bundle_relocation;

@property (atomic) BOOL munki_suppress_bundle_relocationValue;
- (BOOL)munki_suppress_bundle_relocationValue;
- (void)setMunki_suppress_bundle_relocationValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSNumber* munki_unattended_install;

@property (atomic) BOOL munki_unattended_installValue;
- (BOOL)munki_unattended_installValue;
- (void)setMunki_unattended_installValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSNumber* munki_unattended_uninstall;

@property (atomic) BOOL munki_unattended_uninstallValue;
- (BOOL)munki_unattended_uninstallValue;
- (void)setMunki_unattended_uninstallValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSString* munki_uninstall_method;

@property (nonatomic, strong, nullable) NSString* munki_uninstall_script;

@property (nonatomic, strong, nullable) NSNumber* munki_uninstallable;

@property (atomic) BOOL munki_uninstallableValue;
- (BOOL)munki_uninstallableValue;
- (void)setMunki_uninstallableValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSString* munki_uninstallcheck_script;

@property (nonatomic, strong, nullable) NSString* munki_uninstaller_item_location;

@property (nonatomic, strong, nullable) NSString* munki_version;

@property (nonatomic, strong, nullable) id originalPkginfo;

@property (nonatomic, strong, nullable) NSDate* packageDateCreated;

@property (nonatomic, strong, nullable) NSDate* packageDateLastOpened;

@property (nonatomic, strong, nullable) NSDate* packageDateModified;

@property (nonatomic, strong, nullable) NSDate* packageInfoDateCreated;

@property (nonatomic, strong, nullable) NSDate* packageInfoDateLastOpened;

@property (nonatomic, strong, nullable) NSDate* packageInfoDateModified;

@property (nonatomic, strong, nullable) id packageInfoParentDirectoryURL;

@property (nonatomic, strong, nullable) id packageInfoURL;

@property (nonatomic, strong, nullable) id packageURL;

@property (nonatomic, strong, nullable) NSString* titleWithVersion;

@property (nonatomic, strong, nullable) id uninstallerItemURL;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *blockingApplications;
- (nullable NSMutableSet<StringObjectMO*>*)blockingApplicationsSet;

@property (nonatomic, strong, nullable) NSSet<CatalogInfoMO*> *catalogInfos;
- (nullable NSMutableSet<CatalogInfoMO*>*)catalogInfosSet;

@property (nonatomic, strong, nullable) NSSet<CatalogMO*> *catalogs;
- (nullable NSMutableSet<CatalogMO*>*)catalogsSet;

@property (nonatomic, strong, nullable) CategoryMO *category;

@property (nonatomic, strong, nullable) DeveloperMO *developer;

@property (nonatomic, strong, nullable) IconImageMO *iconImage;

@property (nonatomic, strong, nullable) NSSet<InstallerChoicesItemMO*> *installerChoicesItems;
- (nullable NSMutableSet<InstallerChoicesItemMO*>*)installerChoicesItemsSet;

@property (nonatomic, strong, nullable) NSSet<InstallerEnvironmentVariableMO*> *installerEnvironmentVariables;
- (nullable NSMutableSet<InstallerEnvironmentVariableMO*>*)installerEnvironmentVariablesSet;

@property (nonatomic, strong, nullable) NSSet<InstallsItemMO*> *installsItems;
- (nullable NSMutableSet<InstallsItemMO*>*)installsItemsSet;

@property (nonatomic, strong, nullable) NSSet<ItemToCopyMO*> *itemsToCopy;
- (nullable NSMutableSet<ItemToCopyMO*>*)itemsToCopySet;

@property (nonatomic, strong, nullable) NSSet<PackageInfoMO*> *packageInfos;
- (nullable NSMutableSet<PackageInfoMO*>*)packageInfosSet;

@property (nonatomic, strong, nullable) ApplicationMO *parentApplication;

@property (nonatomic, strong, nullable) ApplicationMO *parentApplicationFromLatestPackage;

@property (nonatomic, strong, nullable) NSSet<ReceiptMO*> *receipts;
- (nullable NSMutableSet<ReceiptMO*>*)receiptsSet;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *referencingStringObjects;
- (nullable NSMutableSet<StringObjectMO*>*)referencingStringObjectsSet;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *requirements;
- (nullable NSMutableSet<StringObjectMO*>*)requirementsSet;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *supportedArchitectures;
- (nullable NSMutableSet<StringObjectMO*>*)supportedArchitecturesSet;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *updateFor;
- (nullable NSMutableSet<StringObjectMO*>*)updateForSet;

@end

@interface _PackageMO (BlockingApplicationsCoreDataGeneratedAccessors)
- (void)addBlockingApplications:(NSSet<StringObjectMO*>*)value_;
- (void)removeBlockingApplications:(NSSet<StringObjectMO*>*)value_;
- (void)addBlockingApplicationsObject:(StringObjectMO*)value_;
- (void)removeBlockingApplicationsObject:(StringObjectMO*)value_;

@end

@interface _PackageMO (CatalogInfosCoreDataGeneratedAccessors)
- (void)addCatalogInfos:(NSSet<CatalogInfoMO*>*)value_;
- (void)removeCatalogInfos:(NSSet<CatalogInfoMO*>*)value_;
- (void)addCatalogInfosObject:(CatalogInfoMO*)value_;
- (void)removeCatalogInfosObject:(CatalogInfoMO*)value_;

@end

@interface _PackageMO (CatalogsCoreDataGeneratedAccessors)
- (void)addCatalogs:(NSSet<CatalogMO*>*)value_;
- (void)removeCatalogs:(NSSet<CatalogMO*>*)value_;
- (void)addCatalogsObject:(CatalogMO*)value_;
- (void)removeCatalogsObject:(CatalogMO*)value_;

@end

@interface _PackageMO (InstallerChoicesItemsCoreDataGeneratedAccessors)
- (void)addInstallerChoicesItems:(NSSet<InstallerChoicesItemMO*>*)value_;
- (void)removeInstallerChoicesItems:(NSSet<InstallerChoicesItemMO*>*)value_;
- (void)addInstallerChoicesItemsObject:(InstallerChoicesItemMO*)value_;
- (void)removeInstallerChoicesItemsObject:(InstallerChoicesItemMO*)value_;

@end

@interface _PackageMO (InstallerEnvironmentVariablesCoreDataGeneratedAccessors)
- (void)addInstallerEnvironmentVariables:(NSSet<InstallerEnvironmentVariableMO*>*)value_;
- (void)removeInstallerEnvironmentVariables:(NSSet<InstallerEnvironmentVariableMO*>*)value_;
- (void)addInstallerEnvironmentVariablesObject:(InstallerEnvironmentVariableMO*)value_;
- (void)removeInstallerEnvironmentVariablesObject:(InstallerEnvironmentVariableMO*)value_;

@end

@interface _PackageMO (InstallsItemsCoreDataGeneratedAccessors)
- (void)addInstallsItems:(NSSet<InstallsItemMO*>*)value_;
- (void)removeInstallsItems:(NSSet<InstallsItemMO*>*)value_;
- (void)addInstallsItemsObject:(InstallsItemMO*)value_;
- (void)removeInstallsItemsObject:(InstallsItemMO*)value_;

@end

@interface _PackageMO (ItemsToCopyCoreDataGeneratedAccessors)
- (void)addItemsToCopy:(NSSet<ItemToCopyMO*>*)value_;
- (void)removeItemsToCopy:(NSSet<ItemToCopyMO*>*)value_;
- (void)addItemsToCopyObject:(ItemToCopyMO*)value_;
- (void)removeItemsToCopyObject:(ItemToCopyMO*)value_;

@end

@interface _PackageMO (PackageInfosCoreDataGeneratedAccessors)
- (void)addPackageInfos:(NSSet<PackageInfoMO*>*)value_;
- (void)removePackageInfos:(NSSet<PackageInfoMO*>*)value_;
- (void)addPackageInfosObject:(PackageInfoMO*)value_;
- (void)removePackageInfosObject:(PackageInfoMO*)value_;

@end

@interface _PackageMO (ReceiptsCoreDataGeneratedAccessors)
- (void)addReceipts:(NSSet<ReceiptMO*>*)value_;
- (void)removeReceipts:(NSSet<ReceiptMO*>*)value_;
- (void)addReceiptsObject:(ReceiptMO*)value_;
- (void)removeReceiptsObject:(ReceiptMO*)value_;

@end

@interface _PackageMO (ReferencingStringObjectsCoreDataGeneratedAccessors)
- (void)addReferencingStringObjects:(NSSet<StringObjectMO*>*)value_;
- (void)removeReferencingStringObjects:(NSSet<StringObjectMO*>*)value_;
- (void)addReferencingStringObjectsObject:(StringObjectMO*)value_;
- (void)removeReferencingStringObjectsObject:(StringObjectMO*)value_;

@end

@interface _PackageMO (RequirementsCoreDataGeneratedAccessors)
- (void)addRequirements:(NSSet<StringObjectMO*>*)value_;
- (void)removeRequirements:(NSSet<StringObjectMO*>*)value_;
- (void)addRequirementsObject:(StringObjectMO*)value_;
- (void)removeRequirementsObject:(StringObjectMO*)value_;

@end

@interface _PackageMO (SupportedArchitecturesCoreDataGeneratedAccessors)
- (void)addSupportedArchitectures:(NSSet<StringObjectMO*>*)value_;
- (void)removeSupportedArchitectures:(NSSet<StringObjectMO*>*)value_;
- (void)addSupportedArchitecturesObject:(StringObjectMO*)value_;
- (void)removeSupportedArchitecturesObject:(StringObjectMO*)value_;

@end

@interface _PackageMO (UpdateForCoreDataGeneratedAccessors)
- (void)addUpdateFor:(NSSet<StringObjectMO*>*)value_;
- (void)removeUpdateFor:(NSSet<StringObjectMO*>*)value_;
- (void)addUpdateForObject:(StringObjectMO*)value_;
- (void)removeUpdateForObject:(StringObjectMO*)value_;

@end

@interface _PackageMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSNumber*)primitiveHasEmptyBlockingApplications;
- (void)setPrimitiveHasEmptyBlockingApplications:(nullable NSNumber*)value;

- (BOOL)primitiveHasEmptyBlockingApplicationsValue;
- (void)setPrimitiveHasEmptyBlockingApplicationsValue:(BOOL)value_;

- (NSNumber*)primitiveHasUnstagedChanges;
- (void)setPrimitiveHasUnstagedChanges:(NSNumber*)value;

- (BOOL)primitiveHasUnstagedChangesValue;
- (void)setPrimitiveHasUnstagedChangesValue:(BOOL)value_;

- (nullable NSNumber*)primitiveMunki_OnDemand;
- (void)setPrimitiveMunki_OnDemand:(nullable NSNumber*)value;

- (BOOL)primitiveMunki_OnDemandValue;
- (void)setPrimitiveMunki_OnDemandValue:(BOOL)value_;

- (nullable NSString*)primitiveMunki_PayloadIdentifier;
- (void)setPrimitiveMunki_PayloadIdentifier:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_RestartAction;
- (void)setPrimitiveMunki_RestartAction:(nullable NSString*)value;

- (nullable NSNumber*)primitiveMunki_allow_untrusted;
- (void)setPrimitiveMunki_allow_untrusted:(nullable NSNumber*)value;

- (BOOL)primitiveMunki_allow_untrustedValue;
- (void)setPrimitiveMunki_allow_untrustedValue:(BOOL)value_;

- (nullable NSNumber*)primitiveMunki_apple_item;
- (void)setPrimitiveMunki_apple_item:(nullable NSNumber*)value;

- (BOOL)primitiveMunki_apple_itemValue;
- (void)setPrimitiveMunki_apple_itemValue:(BOOL)value_;

- (nullable NSNumber*)primitiveMunki_autoremove;
- (void)setPrimitiveMunki_autoremove:(nullable NSNumber*)value;

- (BOOL)primitiveMunki_autoremoveValue;
- (void)setPrimitiveMunki_autoremoveValue:(BOOL)value_;

- (nullable NSString*)primitiveMunki_description;
- (void)setPrimitiveMunki_description:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_developer;
- (void)setPrimitiveMunki_developer:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_display_name;
- (void)setPrimitiveMunki_display_name:(nullable NSString*)value;

- (nullable NSDate*)primitiveMunki_force_install_after_date;
- (void)setPrimitiveMunki_force_install_after_date:(nullable NSDate*)value;

- (nullable NSNumber*)primitiveMunki_forced_install;
- (void)setPrimitiveMunki_forced_install:(nullable NSNumber*)value;

- (BOOL)primitiveMunki_forced_installValue;
- (void)setPrimitiveMunki_forced_installValue:(BOOL)value_;

- (nullable NSNumber*)primitiveMunki_forced_uninstall;
- (void)setPrimitiveMunki_forced_uninstall:(nullable NSNumber*)value;

- (BOOL)primitiveMunki_forced_uninstallValue;
- (void)setPrimitiveMunki_forced_uninstallValue:(BOOL)value_;

- (nullable NSString*)primitiveMunki_icon_hash;
- (void)setPrimitiveMunki_icon_hash:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_icon_name;
- (void)setPrimitiveMunki_icon_name:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_installable_condition;
- (void)setPrimitiveMunki_installable_condition:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_installcheck_script;
- (void)setPrimitiveMunki_installcheck_script:(nullable NSString*)value;

- (nullable NSNumber*)primitiveMunki_installed_size;
- (void)setPrimitiveMunki_installed_size:(nullable NSNumber*)value;

- (int64_t)primitiveMunki_installed_sizeValue;
- (void)setPrimitiveMunki_installed_sizeValue:(int64_t)value_;

- (nullable NSString*)primitiveMunki_installer_item_hash;
- (void)setPrimitiveMunki_installer_item_hash:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_installer_item_location;
- (void)setPrimitiveMunki_installer_item_location:(nullable NSString*)value;

- (nullable NSNumber*)primitiveMunki_installer_item_size;
- (void)setPrimitiveMunki_installer_item_size:(nullable NSNumber*)value;

- (int64_t)primitiveMunki_installer_item_sizeValue;
- (void)setPrimitiveMunki_installer_item_sizeValue:(int64_t)value_;

- (nullable NSString*)primitiveMunki_installer_type;
- (void)setPrimitiveMunki_installer_type:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_maximum_os_version;
- (void)setPrimitiveMunki_maximum_os_version:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_minimum_munki_version;
- (void)setPrimitiveMunki_minimum_munki_version:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_minimum_os_version;
- (void)setPrimitiveMunki_minimum_os_version:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_name;
- (void)setPrimitiveMunki_name:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_notes;
- (void)setPrimitiveMunki_notes:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_package_path;
- (void)setPrimitiveMunki_package_path:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_postinstall_script;
- (void)setPrimitiveMunki_postinstall_script:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_postuninstall_script;
- (void)setPrimitiveMunki_postuninstall_script:(nullable NSString*)value;

- (nullable NSNumber*)primitiveMunki_precache;
- (void)setPrimitiveMunki_precache:(nullable NSNumber*)value;

- (BOOL)primitiveMunki_precacheValue;
- (void)setPrimitiveMunki_precacheValue:(BOOL)value_;

- (nullable NSString*)primitiveMunki_preinstall_alert_alert_detail;
- (void)setPrimitiveMunki_preinstall_alert_alert_detail:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_preinstall_alert_alert_title;
- (void)setPrimitiveMunki_preinstall_alert_alert_title:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_preinstall_alert_cancel_label;
- (void)setPrimitiveMunki_preinstall_alert_cancel_label:(nullable NSString*)value;

- (nullable NSNumber*)primitiveMunki_preinstall_alert_enabled;
- (void)setPrimitiveMunki_preinstall_alert_enabled:(nullable NSNumber*)value;

- (BOOL)primitiveMunki_preinstall_alert_enabledValue;
- (void)setPrimitiveMunki_preinstall_alert_enabledValue:(BOOL)value_;

- (nullable NSString*)primitiveMunki_preinstall_alert_ok_label;
- (void)setPrimitiveMunki_preinstall_alert_ok_label:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_preinstall_script;
- (void)setPrimitiveMunki_preinstall_script:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_preuninstall_alert_alert_detail;
- (void)setPrimitiveMunki_preuninstall_alert_alert_detail:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_preuninstall_alert_alert_title;
- (void)setPrimitiveMunki_preuninstall_alert_alert_title:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_preuninstall_alert_cancel_label;
- (void)setPrimitiveMunki_preuninstall_alert_cancel_label:(nullable NSString*)value;

- (nullable NSNumber*)primitiveMunki_preuninstall_alert_enabled;
- (void)setPrimitiveMunki_preuninstall_alert_enabled:(nullable NSNumber*)value;

- (BOOL)primitiveMunki_preuninstall_alert_enabledValue;
- (void)setPrimitiveMunki_preuninstall_alert_enabledValue:(BOOL)value_;

- (nullable NSString*)primitiveMunki_preuninstall_alert_ok_label;
- (void)setPrimitiveMunki_preuninstall_alert_ok_label:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_preuninstall_script;
- (void)setPrimitiveMunki_preuninstall_script:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_receipts;
- (void)setPrimitiveMunki_receipts:(nullable NSString*)value;

- (nullable NSNumber*)primitiveMunki_suppress_bundle_relocation;
- (void)setPrimitiveMunki_suppress_bundle_relocation:(nullable NSNumber*)value;

- (BOOL)primitiveMunki_suppress_bundle_relocationValue;
- (void)setPrimitiveMunki_suppress_bundle_relocationValue:(BOOL)value_;

- (nullable NSNumber*)primitiveMunki_unattended_install;
- (void)setPrimitiveMunki_unattended_install:(nullable NSNumber*)value;

- (BOOL)primitiveMunki_unattended_installValue;
- (void)setPrimitiveMunki_unattended_installValue:(BOOL)value_;

- (nullable NSNumber*)primitiveMunki_unattended_uninstall;
- (void)setPrimitiveMunki_unattended_uninstall:(nullable NSNumber*)value;

- (BOOL)primitiveMunki_unattended_uninstallValue;
- (void)setPrimitiveMunki_unattended_uninstallValue:(BOOL)value_;

- (nullable NSString*)primitiveMunki_uninstall_method;
- (void)setPrimitiveMunki_uninstall_method:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_uninstall_script;
- (void)setPrimitiveMunki_uninstall_script:(nullable NSString*)value;

- (nullable NSNumber*)primitiveMunki_uninstallable;
- (void)setPrimitiveMunki_uninstallable:(nullable NSNumber*)value;

- (BOOL)primitiveMunki_uninstallableValue;
- (void)setPrimitiveMunki_uninstallableValue:(BOOL)value_;

- (nullable NSString*)primitiveMunki_uninstallcheck_script;
- (void)setPrimitiveMunki_uninstallcheck_script:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_uninstaller_item_location;
- (void)setPrimitiveMunki_uninstaller_item_location:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_version;
- (void)setPrimitiveMunki_version:(nullable NSString*)value;

- (nullable id)primitiveOriginalPkginfo;
- (void)setPrimitiveOriginalPkginfo:(nullable id)value;

- (nullable NSDate*)primitivePackageDateCreated;
- (void)setPrimitivePackageDateCreated:(nullable NSDate*)value;

- (nullable NSDate*)primitivePackageDateLastOpened;
- (void)setPrimitivePackageDateLastOpened:(nullable NSDate*)value;

- (nullable NSDate*)primitivePackageDateModified;
- (void)setPrimitivePackageDateModified:(nullable NSDate*)value;

- (nullable NSDate*)primitivePackageInfoDateCreated;
- (void)setPrimitivePackageInfoDateCreated:(nullable NSDate*)value;

- (nullable NSDate*)primitivePackageInfoDateLastOpened;
- (void)setPrimitivePackageInfoDateLastOpened:(nullable NSDate*)value;

- (nullable NSDate*)primitivePackageInfoDateModified;
- (void)setPrimitivePackageInfoDateModified:(nullable NSDate*)value;

- (nullable id)primitivePackageInfoParentDirectoryURL;
- (void)setPrimitivePackageInfoParentDirectoryURL:(nullable id)value;

- (nullable id)primitivePackageInfoURL;
- (void)setPrimitivePackageInfoURL:(nullable id)value;

- (nullable id)primitivePackageURL;
- (void)setPrimitivePackageURL:(nullable id)value;

- (nullable NSString*)primitiveTitleWithVersion;
- (void)setPrimitiveTitleWithVersion:(nullable NSString*)value;

- (nullable id)primitiveUninstallerItemURL;
- (void)setPrimitiveUninstallerItemURL:(nullable id)value;

- (NSMutableSet<StringObjectMO*>*)primitiveBlockingApplications;
- (void)setPrimitiveBlockingApplications:(NSMutableSet<StringObjectMO*>*)value;

- (NSMutableSet<CatalogInfoMO*>*)primitiveCatalogInfos;
- (void)setPrimitiveCatalogInfos:(NSMutableSet<CatalogInfoMO*>*)value;

- (NSMutableSet<CatalogMO*>*)primitiveCatalogs;
- (void)setPrimitiveCatalogs:(NSMutableSet<CatalogMO*>*)value;

- (CategoryMO*)primitiveCategory;
- (void)setPrimitiveCategory:(CategoryMO*)value;

- (DeveloperMO*)primitiveDeveloper;
- (void)setPrimitiveDeveloper:(DeveloperMO*)value;

- (IconImageMO*)primitiveIconImage;
- (void)setPrimitiveIconImage:(IconImageMO*)value;

- (NSMutableSet<InstallerChoicesItemMO*>*)primitiveInstallerChoicesItems;
- (void)setPrimitiveInstallerChoicesItems:(NSMutableSet<InstallerChoicesItemMO*>*)value;

- (NSMutableSet<InstallerEnvironmentVariableMO*>*)primitiveInstallerEnvironmentVariables;
- (void)setPrimitiveInstallerEnvironmentVariables:(NSMutableSet<InstallerEnvironmentVariableMO*>*)value;

- (NSMutableSet<InstallsItemMO*>*)primitiveInstallsItems;
- (void)setPrimitiveInstallsItems:(NSMutableSet<InstallsItemMO*>*)value;

- (NSMutableSet<ItemToCopyMO*>*)primitiveItemsToCopy;
- (void)setPrimitiveItemsToCopy:(NSMutableSet<ItemToCopyMO*>*)value;

- (NSMutableSet<PackageInfoMO*>*)primitivePackageInfos;
- (void)setPrimitivePackageInfos:(NSMutableSet<PackageInfoMO*>*)value;

- (ApplicationMO*)primitiveParentApplication;
- (void)setPrimitiveParentApplication:(ApplicationMO*)value;

- (ApplicationMO*)primitiveParentApplicationFromLatestPackage;
- (void)setPrimitiveParentApplicationFromLatestPackage:(ApplicationMO*)value;

- (NSMutableSet<ReceiptMO*>*)primitiveReceipts;
- (void)setPrimitiveReceipts:(NSMutableSet<ReceiptMO*>*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveReferencingStringObjects;
- (void)setPrimitiveReferencingStringObjects:(NSMutableSet<StringObjectMO*>*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveRequirements;
- (void)setPrimitiveRequirements:(NSMutableSet<StringObjectMO*>*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveSupportedArchitectures;
- (void)setPrimitiveSupportedArchitectures:(NSMutableSet<StringObjectMO*>*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveUpdateFor;
- (void)setPrimitiveUpdateFor:(NSMutableSet<StringObjectMO*>*)value;

@end

@interface PackageMOAttributes: NSObject 
+ (NSString *)hasEmptyBlockingApplications;
+ (NSString *)hasUnstagedChanges;
+ (NSString *)munki_OnDemand;
+ (NSString *)munki_PayloadIdentifier;
+ (NSString *)munki_RestartAction;
+ (NSString *)munki_allow_untrusted;
+ (NSString *)munki_apple_item;
+ (NSString *)munki_autoremove;
+ (NSString *)munki_description;
+ (NSString *)munki_developer;
+ (NSString *)munki_display_name;
+ (NSString *)munki_force_install_after_date;
+ (NSString *)munki_forced_install;
+ (NSString *)munki_forced_uninstall;
+ (NSString *)munki_icon_hash;
+ (NSString *)munki_icon_name;
+ (NSString *)munki_installable_condition;
+ (NSString *)munki_installcheck_script;
+ (NSString *)munki_installed_size;
+ (NSString *)munki_installer_item_hash;
+ (NSString *)munki_installer_item_location;
+ (NSString *)munki_installer_item_size;
+ (NSString *)munki_installer_type;
+ (NSString *)munki_maximum_os_version;
+ (NSString *)munki_minimum_munki_version;
+ (NSString *)munki_minimum_os_version;
+ (NSString *)munki_name;
+ (NSString *)munki_notes;
+ (NSString *)munki_package_path;
+ (NSString *)munki_postinstall_script;
+ (NSString *)munki_postuninstall_script;
+ (NSString *)munki_precache;
+ (NSString *)munki_preinstall_alert_alert_detail;
+ (NSString *)munki_preinstall_alert_alert_title;
+ (NSString *)munki_preinstall_alert_cancel_label;
+ (NSString *)munki_preinstall_alert_enabled;
+ (NSString *)munki_preinstall_alert_ok_label;
+ (NSString *)munki_preinstall_script;
+ (NSString *)munki_preuninstall_alert_alert_detail;
+ (NSString *)munki_preuninstall_alert_alert_title;
+ (NSString *)munki_preuninstall_alert_cancel_label;
+ (NSString *)munki_preuninstall_alert_enabled;
+ (NSString *)munki_preuninstall_alert_ok_label;
+ (NSString *)munki_preuninstall_script;
+ (NSString *)munki_receipts;
+ (NSString *)munki_suppress_bundle_relocation;
+ (NSString *)munki_unattended_install;
+ (NSString *)munki_unattended_uninstall;
+ (NSString *)munki_uninstall_method;
+ (NSString *)munki_uninstall_script;
+ (NSString *)munki_uninstallable;
+ (NSString *)munki_uninstallcheck_script;
+ (NSString *)munki_uninstaller_item_location;
+ (NSString *)munki_version;
+ (NSString *)originalPkginfo;
+ (NSString *)packageDateCreated;
+ (NSString *)packageDateLastOpened;
+ (NSString *)packageDateModified;
+ (NSString *)packageInfoDateCreated;
+ (NSString *)packageInfoDateLastOpened;
+ (NSString *)packageInfoDateModified;
+ (NSString *)packageInfoParentDirectoryURL;
+ (NSString *)packageInfoURL;
+ (NSString *)packageURL;
+ (NSString *)titleWithVersion;
+ (NSString *)uninstallerItemURL;
@end

@interface PackageMORelationships: NSObject
+ (NSString *)blockingApplications;
+ (NSString *)catalogInfos;
+ (NSString *)catalogs;
+ (NSString *)category;
+ (NSString *)developer;
+ (NSString *)iconImage;
+ (NSString *)installerChoicesItems;
+ (NSString *)installerEnvironmentVariables;
+ (NSString *)installsItems;
+ (NSString *)itemsToCopy;
+ (NSString *)packageInfos;
+ (NSString *)parentApplication;
+ (NSString *)parentApplicationFromLatestPackage;
+ (NSString *)receipts;
+ (NSString *)referencingStringObjects;
+ (NSString *)requirements;
+ (NSString *)supportedArchitectures;
+ (NSString *)updateFor;
@end

NS_ASSUME_NONNULL_END
