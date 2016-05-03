// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PackageMO.h instead.

#import <CoreData/CoreData.h>

extern const struct PackageMOAttributes {
	__unsafe_unretained NSString *hasEmptyBlockingApplications;
	__unsafe_unretained NSString *hasUnstagedChanges;
	__unsafe_unretained NSString *munki_OnDemand;
	__unsafe_unretained NSString *munki_PayloadIdentifier;
	__unsafe_unretained NSString *munki_RestartAction;
	__unsafe_unretained NSString *munki_apple_item;
	__unsafe_unretained NSString *munki_autoremove;
	__unsafe_unretained NSString *munki_description;
	__unsafe_unretained NSString *munki_developer;
	__unsafe_unretained NSString *munki_display_name;
	__unsafe_unretained NSString *munki_force_install_after_date;
	__unsafe_unretained NSString *munki_forced_install;
	__unsafe_unretained NSString *munki_forced_uninstall;
	__unsafe_unretained NSString *munki_icon_hash;
	__unsafe_unretained NSString *munki_icon_name;
	__unsafe_unretained NSString *munki_installable_condition;
	__unsafe_unretained NSString *munki_installcheck_script;
	__unsafe_unretained NSString *munki_installed_size;
	__unsafe_unretained NSString *munki_installer_item_hash;
	__unsafe_unretained NSString *munki_installer_item_location;
	__unsafe_unretained NSString *munki_installer_item_size;
	__unsafe_unretained NSString *munki_installer_type;
	__unsafe_unretained NSString *munki_maximum_os_version;
	__unsafe_unretained NSString *munki_minimum_munki_version;
	__unsafe_unretained NSString *munki_minimum_os_version;
	__unsafe_unretained NSString *munki_name;
	__unsafe_unretained NSString *munki_notes;
	__unsafe_unretained NSString *munki_package_path;
	__unsafe_unretained NSString *munki_postinstall_script;
	__unsafe_unretained NSString *munki_postuninstall_script;
	__unsafe_unretained NSString *munki_preinstall_alert_alert_detail;
	__unsafe_unretained NSString *munki_preinstall_alert_alert_title;
	__unsafe_unretained NSString *munki_preinstall_alert_cancel_label;
	__unsafe_unretained NSString *munki_preinstall_alert_enabled;
	__unsafe_unretained NSString *munki_preinstall_alert_ok_label;
	__unsafe_unretained NSString *munki_preinstall_script;
	__unsafe_unretained NSString *munki_preuninstall_alert_alert_detail;
	__unsafe_unretained NSString *munki_preuninstall_alert_alert_title;
	__unsafe_unretained NSString *munki_preuninstall_alert_cancel_label;
	__unsafe_unretained NSString *munki_preuninstall_alert_enabled;
	__unsafe_unretained NSString *munki_preuninstall_alert_ok_label;
	__unsafe_unretained NSString *munki_preuninstall_script;
	__unsafe_unretained NSString *munki_receipts;
	__unsafe_unretained NSString *munki_suppress_bundle_relocation;
	__unsafe_unretained NSString *munki_unattended_install;
	__unsafe_unretained NSString *munki_unattended_uninstall;
	__unsafe_unretained NSString *munki_uninstall_method;
	__unsafe_unretained NSString *munki_uninstall_script;
	__unsafe_unretained NSString *munki_uninstallable;
	__unsafe_unretained NSString *munki_uninstallcheck_script;
	__unsafe_unretained NSString *munki_uninstaller_item_location;
	__unsafe_unretained NSString *munki_version;
	__unsafe_unretained NSString *originalPkginfo;
	__unsafe_unretained NSString *packageDateCreated;
	__unsafe_unretained NSString *packageDateLastOpened;
	__unsafe_unretained NSString *packageDateModified;
	__unsafe_unretained NSString *packageInfoDateCreated;
	__unsafe_unretained NSString *packageInfoDateLastOpened;
	__unsafe_unretained NSString *packageInfoDateModified;
	__unsafe_unretained NSString *packageInfoParentDirectoryURL;
	__unsafe_unretained NSString *packageInfoURL;
	__unsafe_unretained NSString *packageURL;
	__unsafe_unretained NSString *titleWithVersion;
} PackageMOAttributes;

extern const struct PackageMORelationships {
	__unsafe_unretained NSString *blockingApplications;
	__unsafe_unretained NSString *catalogInfos;
	__unsafe_unretained NSString *catalogs;
	__unsafe_unretained NSString *category;
	__unsafe_unretained NSString *developer;
	__unsafe_unretained NSString *iconImage;
	__unsafe_unretained NSString *installerChoicesItems;
	__unsafe_unretained NSString *installerEnvironmentVariables;
	__unsafe_unretained NSString *installsItems;
	__unsafe_unretained NSString *itemsToCopy;
	__unsafe_unretained NSString *packageInfos;
	__unsafe_unretained NSString *parentApplication;
	__unsafe_unretained NSString *parentApplicationFromLatestPackage;
	__unsafe_unretained NSString *receipts;
	__unsafe_unretained NSString *referencingStringObjects;
	__unsafe_unretained NSString *requirements;
	__unsafe_unretained NSString *supportedArchitectures;
	__unsafe_unretained NSString *updateFor;
} PackageMORelationships;

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

@interface PackageMOID : NSManagedObjectID {}
@end

@interface _PackageMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) PackageMOID* objectID;

@property (nonatomic, strong) NSNumber* hasEmptyBlockingApplications;

@property (atomic) BOOL hasEmptyBlockingApplicationsValue;
- (BOOL)hasEmptyBlockingApplicationsValue;
- (void)setHasEmptyBlockingApplicationsValue:(BOOL)value_;

//- (BOOL)validateHasEmptyBlockingApplications:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* hasUnstagedChanges;

@property (atomic) BOOL hasUnstagedChangesValue;
- (BOOL)hasUnstagedChangesValue;
- (void)setHasUnstagedChangesValue:(BOOL)value_;

//- (BOOL)validateHasUnstagedChanges:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* munki_OnDemand;

@property (atomic) BOOL munki_OnDemandValue;
- (BOOL)munki_OnDemandValue;
- (void)setMunki_OnDemandValue:(BOOL)value_;

//- (BOOL)validateMunki_OnDemand:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_PayloadIdentifier;

//- (BOOL)validateMunki_PayloadIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_RestartAction;

//- (BOOL)validateMunki_RestartAction:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* munki_apple_item;

@property (atomic) BOOL munki_apple_itemValue;
- (BOOL)munki_apple_itemValue;
- (void)setMunki_apple_itemValue:(BOOL)value_;

//- (BOOL)validateMunki_apple_item:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* munki_autoremove;

@property (atomic) BOOL munki_autoremoveValue;
- (BOOL)munki_autoremoveValue;
- (void)setMunki_autoremoveValue:(BOOL)value_;

//- (BOOL)validateMunki_autoremove:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_description;

//- (BOOL)validateMunki_description:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_developer;

//- (BOOL)validateMunki_developer:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_display_name;

//- (BOOL)validateMunki_display_name:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* munki_force_install_after_date;

//- (BOOL)validateMunki_force_install_after_date:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* munki_forced_install;

@property (atomic) BOOL munki_forced_installValue;
- (BOOL)munki_forced_installValue;
- (void)setMunki_forced_installValue:(BOOL)value_;

//- (BOOL)validateMunki_forced_install:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* munki_forced_uninstall;

@property (atomic) BOOL munki_forced_uninstallValue;
- (BOOL)munki_forced_uninstallValue;
- (void)setMunki_forced_uninstallValue:(BOOL)value_;

//- (BOOL)validateMunki_forced_uninstall:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_icon_hash;

//- (BOOL)validateMunki_icon_hash:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_icon_name;

//- (BOOL)validateMunki_icon_name:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_installable_condition;

//- (BOOL)validateMunki_installable_condition:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_installcheck_script;

//- (BOOL)validateMunki_installcheck_script:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* munki_installed_size;

@property (atomic) int64_t munki_installed_sizeValue;
- (int64_t)munki_installed_sizeValue;
- (void)setMunki_installed_sizeValue:(int64_t)value_;

//- (BOOL)validateMunki_installed_size:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_installer_item_hash;

//- (BOOL)validateMunki_installer_item_hash:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_installer_item_location;

//- (BOOL)validateMunki_installer_item_location:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* munki_installer_item_size;

@property (atomic) int64_t munki_installer_item_sizeValue;
- (int64_t)munki_installer_item_sizeValue;
- (void)setMunki_installer_item_sizeValue:(int64_t)value_;

//- (BOOL)validateMunki_installer_item_size:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_installer_type;

//- (BOOL)validateMunki_installer_type:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_maximum_os_version;

//- (BOOL)validateMunki_maximum_os_version:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_minimum_munki_version;

//- (BOOL)validateMunki_minimum_munki_version:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_minimum_os_version;

//- (BOOL)validateMunki_minimum_os_version:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_name;

//- (BOOL)validateMunki_name:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_notes;

//- (BOOL)validateMunki_notes:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_package_path;

//- (BOOL)validateMunki_package_path:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_postinstall_script;

//- (BOOL)validateMunki_postinstall_script:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_postuninstall_script;

//- (BOOL)validateMunki_postuninstall_script:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_preinstall_alert_alert_detail;

//- (BOOL)validateMunki_preinstall_alert_alert_detail:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_preinstall_alert_alert_title;

//- (BOOL)validateMunki_preinstall_alert_alert_title:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_preinstall_alert_cancel_label;

//- (BOOL)validateMunki_preinstall_alert_cancel_label:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* munki_preinstall_alert_enabled;

@property (atomic) BOOL munki_preinstall_alert_enabledValue;
- (BOOL)munki_preinstall_alert_enabledValue;
- (void)setMunki_preinstall_alert_enabledValue:(BOOL)value_;

//- (BOOL)validateMunki_preinstall_alert_enabled:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_preinstall_alert_ok_label;

//- (BOOL)validateMunki_preinstall_alert_ok_label:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_preinstall_script;

//- (BOOL)validateMunki_preinstall_script:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_preuninstall_alert_alert_detail;

//- (BOOL)validateMunki_preuninstall_alert_alert_detail:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_preuninstall_alert_alert_title;

//- (BOOL)validateMunki_preuninstall_alert_alert_title:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_preuninstall_alert_cancel_label;

//- (BOOL)validateMunki_preuninstall_alert_cancel_label:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* munki_preuninstall_alert_enabled;

@property (atomic) BOOL munki_preuninstall_alert_enabledValue;
- (BOOL)munki_preuninstall_alert_enabledValue;
- (void)setMunki_preuninstall_alert_enabledValue:(BOOL)value_;

//- (BOOL)validateMunki_preuninstall_alert_enabled:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_preuninstall_alert_ok_label;

//- (BOOL)validateMunki_preuninstall_alert_ok_label:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_preuninstall_script;

//- (BOOL)validateMunki_preuninstall_script:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_receipts;

//- (BOOL)validateMunki_receipts:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* munki_suppress_bundle_relocation;

@property (atomic) BOOL munki_suppress_bundle_relocationValue;
- (BOOL)munki_suppress_bundle_relocationValue;
- (void)setMunki_suppress_bundle_relocationValue:(BOOL)value_;

//- (BOOL)validateMunki_suppress_bundle_relocation:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* munki_unattended_install;

@property (atomic) BOOL munki_unattended_installValue;
- (BOOL)munki_unattended_installValue;
- (void)setMunki_unattended_installValue:(BOOL)value_;

//- (BOOL)validateMunki_unattended_install:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* munki_unattended_uninstall;

@property (atomic) BOOL munki_unattended_uninstallValue;
- (BOOL)munki_unattended_uninstallValue;
- (void)setMunki_unattended_uninstallValue:(BOOL)value_;

//- (BOOL)validateMunki_unattended_uninstall:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_uninstall_method;

//- (BOOL)validateMunki_uninstall_method:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_uninstall_script;

//- (BOOL)validateMunki_uninstall_script:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* munki_uninstallable;

@property (atomic) BOOL munki_uninstallableValue;
- (BOOL)munki_uninstallableValue;
- (void)setMunki_uninstallableValue:(BOOL)value_;

//- (BOOL)validateMunki_uninstallable:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_uninstallcheck_script;

//- (BOOL)validateMunki_uninstallcheck_script:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_uninstaller_item_location;

//- (BOOL)validateMunki_uninstaller_item_location:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_version;

//- (BOOL)validateMunki_version:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id originalPkginfo;

//- (BOOL)validateOriginalPkginfo:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* packageDateCreated;

//- (BOOL)validatePackageDateCreated:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* packageDateLastOpened;

//- (BOOL)validatePackageDateLastOpened:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* packageDateModified;

//- (BOOL)validatePackageDateModified:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* packageInfoDateCreated;

//- (BOOL)validatePackageInfoDateCreated:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* packageInfoDateLastOpened;

//- (BOOL)validatePackageInfoDateLastOpened:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* packageInfoDateModified;

//- (BOOL)validatePackageInfoDateModified:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id packageInfoParentDirectoryURL;

//- (BOOL)validatePackageInfoParentDirectoryURL:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id packageInfoURL;

//- (BOOL)validatePackageInfoURL:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id packageURL;

//- (BOOL)validatePackageURL:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* titleWithVersion;

//- (BOOL)validateTitleWithVersion:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *blockingApplications;

- (NSMutableSet*)blockingApplicationsSet;

@property (nonatomic, strong) NSSet *catalogInfos;

- (NSMutableSet*)catalogInfosSet;

@property (nonatomic, strong) NSSet *catalogs;

- (NSMutableSet*)catalogsSet;

@property (nonatomic, strong) CategoryMO *category;

//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) DeveloperMO *developer;

//- (BOOL)validateDeveloper:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) IconImageMO *iconImage;

//- (BOOL)validateIconImage:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *installerChoicesItems;

- (NSMutableSet*)installerChoicesItemsSet;

@property (nonatomic, strong) NSSet *installerEnvironmentVariables;

- (NSMutableSet*)installerEnvironmentVariablesSet;

@property (nonatomic, strong) NSSet *installsItems;

- (NSMutableSet*)installsItemsSet;

@property (nonatomic, strong) NSSet *itemsToCopy;

- (NSMutableSet*)itemsToCopySet;

@property (nonatomic, strong) NSSet *packageInfos;

- (NSMutableSet*)packageInfosSet;

@property (nonatomic, strong) ApplicationMO *parentApplication;

//- (BOOL)validateParentApplication:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) ApplicationMO *parentApplicationFromLatestPackage;

//- (BOOL)validateParentApplicationFromLatestPackage:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *receipts;

- (NSMutableSet*)receiptsSet;

@property (nonatomic, strong) NSSet *referencingStringObjects;

- (NSMutableSet*)referencingStringObjectsSet;

@property (nonatomic, strong) NSSet *requirements;

- (NSMutableSet*)requirementsSet;

@property (nonatomic, strong) NSSet *supportedArchitectures;

- (NSMutableSet*)supportedArchitecturesSet;

@property (nonatomic, strong) NSSet *updateFor;

- (NSMutableSet*)updateForSet;

@end

@interface _PackageMO (BlockingApplicationsCoreDataGeneratedAccessors)
- (void)addBlockingApplications:(NSSet*)value_;
- (void)removeBlockingApplications:(NSSet*)value_;
- (void)addBlockingApplicationsObject:(StringObjectMO*)value_;
- (void)removeBlockingApplicationsObject:(StringObjectMO*)value_;

@end

@interface _PackageMO (CatalogInfosCoreDataGeneratedAccessors)
- (void)addCatalogInfos:(NSSet*)value_;
- (void)removeCatalogInfos:(NSSet*)value_;
- (void)addCatalogInfosObject:(CatalogInfoMO*)value_;
- (void)removeCatalogInfosObject:(CatalogInfoMO*)value_;

@end

@interface _PackageMO (CatalogsCoreDataGeneratedAccessors)
- (void)addCatalogs:(NSSet*)value_;
- (void)removeCatalogs:(NSSet*)value_;
- (void)addCatalogsObject:(CatalogMO*)value_;
- (void)removeCatalogsObject:(CatalogMO*)value_;

@end

@interface _PackageMO (InstallerChoicesItemsCoreDataGeneratedAccessors)
- (void)addInstallerChoicesItems:(NSSet*)value_;
- (void)removeInstallerChoicesItems:(NSSet*)value_;
- (void)addInstallerChoicesItemsObject:(InstallerChoicesItemMO*)value_;
- (void)removeInstallerChoicesItemsObject:(InstallerChoicesItemMO*)value_;

@end

@interface _PackageMO (InstallerEnvironmentVariablesCoreDataGeneratedAccessors)
- (void)addInstallerEnvironmentVariables:(NSSet*)value_;
- (void)removeInstallerEnvironmentVariables:(NSSet*)value_;
- (void)addInstallerEnvironmentVariablesObject:(InstallerEnvironmentVariableMO*)value_;
- (void)removeInstallerEnvironmentVariablesObject:(InstallerEnvironmentVariableMO*)value_;

@end

@interface _PackageMO (InstallsItemsCoreDataGeneratedAccessors)
- (void)addInstallsItems:(NSSet*)value_;
- (void)removeInstallsItems:(NSSet*)value_;
- (void)addInstallsItemsObject:(InstallsItemMO*)value_;
- (void)removeInstallsItemsObject:(InstallsItemMO*)value_;

@end

@interface _PackageMO (ItemsToCopyCoreDataGeneratedAccessors)
- (void)addItemsToCopy:(NSSet*)value_;
- (void)removeItemsToCopy:(NSSet*)value_;
- (void)addItemsToCopyObject:(ItemToCopyMO*)value_;
- (void)removeItemsToCopyObject:(ItemToCopyMO*)value_;

@end

@interface _PackageMO (PackageInfosCoreDataGeneratedAccessors)
- (void)addPackageInfos:(NSSet*)value_;
- (void)removePackageInfos:(NSSet*)value_;
- (void)addPackageInfosObject:(PackageInfoMO*)value_;
- (void)removePackageInfosObject:(PackageInfoMO*)value_;

@end

@interface _PackageMO (ReceiptsCoreDataGeneratedAccessors)
- (void)addReceipts:(NSSet*)value_;
- (void)removeReceipts:(NSSet*)value_;
- (void)addReceiptsObject:(ReceiptMO*)value_;
- (void)removeReceiptsObject:(ReceiptMO*)value_;

@end

@interface _PackageMO (ReferencingStringObjectsCoreDataGeneratedAccessors)
- (void)addReferencingStringObjects:(NSSet*)value_;
- (void)removeReferencingStringObjects:(NSSet*)value_;
- (void)addReferencingStringObjectsObject:(StringObjectMO*)value_;
- (void)removeReferencingStringObjectsObject:(StringObjectMO*)value_;

@end

@interface _PackageMO (RequirementsCoreDataGeneratedAccessors)
- (void)addRequirements:(NSSet*)value_;
- (void)removeRequirements:(NSSet*)value_;
- (void)addRequirementsObject:(StringObjectMO*)value_;
- (void)removeRequirementsObject:(StringObjectMO*)value_;

@end

@interface _PackageMO (SupportedArchitecturesCoreDataGeneratedAccessors)
- (void)addSupportedArchitectures:(NSSet*)value_;
- (void)removeSupportedArchitectures:(NSSet*)value_;
- (void)addSupportedArchitecturesObject:(StringObjectMO*)value_;
- (void)removeSupportedArchitecturesObject:(StringObjectMO*)value_;

@end

@interface _PackageMO (UpdateForCoreDataGeneratedAccessors)
- (void)addUpdateFor:(NSSet*)value_;
- (void)removeUpdateFor:(NSSet*)value_;
- (void)addUpdateForObject:(StringObjectMO*)value_;
- (void)removeUpdateForObject:(StringObjectMO*)value_;

@end

@interface _PackageMO (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveHasEmptyBlockingApplications;
- (void)setPrimitiveHasEmptyBlockingApplications:(NSNumber*)value;

- (BOOL)primitiveHasEmptyBlockingApplicationsValue;
- (void)setPrimitiveHasEmptyBlockingApplicationsValue:(BOOL)value_;

- (NSNumber*)primitiveHasUnstagedChanges;
- (void)setPrimitiveHasUnstagedChanges:(NSNumber*)value;

- (BOOL)primitiveHasUnstagedChangesValue;
- (void)setPrimitiveHasUnstagedChangesValue:(BOOL)value_;

- (NSNumber*)primitiveMunki_OnDemand;
- (void)setPrimitiveMunki_OnDemand:(NSNumber*)value;

- (BOOL)primitiveMunki_OnDemandValue;
- (void)setPrimitiveMunki_OnDemandValue:(BOOL)value_;

- (NSString*)primitiveMunki_PayloadIdentifier;
- (void)setPrimitiveMunki_PayloadIdentifier:(NSString*)value;

- (NSString*)primitiveMunki_RestartAction;
- (void)setPrimitiveMunki_RestartAction:(NSString*)value;

- (NSNumber*)primitiveMunki_apple_item;
- (void)setPrimitiveMunki_apple_item:(NSNumber*)value;

- (BOOL)primitiveMunki_apple_itemValue;
- (void)setPrimitiveMunki_apple_itemValue:(BOOL)value_;

- (NSNumber*)primitiveMunki_autoremove;
- (void)setPrimitiveMunki_autoremove:(NSNumber*)value;

- (BOOL)primitiveMunki_autoremoveValue;
- (void)setPrimitiveMunki_autoremoveValue:(BOOL)value_;

- (NSString*)primitiveMunki_description;
- (void)setPrimitiveMunki_description:(NSString*)value;

- (NSString*)primitiveMunki_developer;
- (void)setPrimitiveMunki_developer:(NSString*)value;

- (NSString*)primitiveMunki_display_name;
- (void)setPrimitiveMunki_display_name:(NSString*)value;

- (NSDate*)primitiveMunki_force_install_after_date;
- (void)setPrimitiveMunki_force_install_after_date:(NSDate*)value;

- (NSNumber*)primitiveMunki_forced_install;
- (void)setPrimitiveMunki_forced_install:(NSNumber*)value;

- (BOOL)primitiveMunki_forced_installValue;
- (void)setPrimitiveMunki_forced_installValue:(BOOL)value_;

- (NSNumber*)primitiveMunki_forced_uninstall;
- (void)setPrimitiveMunki_forced_uninstall:(NSNumber*)value;

- (BOOL)primitiveMunki_forced_uninstallValue;
- (void)setPrimitiveMunki_forced_uninstallValue:(BOOL)value_;

- (NSString*)primitiveMunki_icon_hash;
- (void)setPrimitiveMunki_icon_hash:(NSString*)value;

- (NSString*)primitiveMunki_icon_name;
- (void)setPrimitiveMunki_icon_name:(NSString*)value;

- (NSString*)primitiveMunki_installable_condition;
- (void)setPrimitiveMunki_installable_condition:(NSString*)value;

- (NSString*)primitiveMunki_installcheck_script;
- (void)setPrimitiveMunki_installcheck_script:(NSString*)value;

- (NSNumber*)primitiveMunki_installed_size;
- (void)setPrimitiveMunki_installed_size:(NSNumber*)value;

- (int64_t)primitiveMunki_installed_sizeValue;
- (void)setPrimitiveMunki_installed_sizeValue:(int64_t)value_;

- (NSString*)primitiveMunki_installer_item_hash;
- (void)setPrimitiveMunki_installer_item_hash:(NSString*)value;

- (NSString*)primitiveMunki_installer_item_location;
- (void)setPrimitiveMunki_installer_item_location:(NSString*)value;

- (NSNumber*)primitiveMunki_installer_item_size;
- (void)setPrimitiveMunki_installer_item_size:(NSNumber*)value;

- (int64_t)primitiveMunki_installer_item_sizeValue;
- (void)setPrimitiveMunki_installer_item_sizeValue:(int64_t)value_;

- (NSString*)primitiveMunki_installer_type;
- (void)setPrimitiveMunki_installer_type:(NSString*)value;

- (NSString*)primitiveMunki_maximum_os_version;
- (void)setPrimitiveMunki_maximum_os_version:(NSString*)value;

- (NSString*)primitiveMunki_minimum_munki_version;
- (void)setPrimitiveMunki_minimum_munki_version:(NSString*)value;

- (NSString*)primitiveMunki_minimum_os_version;
- (void)setPrimitiveMunki_minimum_os_version:(NSString*)value;

- (NSString*)primitiveMunki_name;
- (void)setPrimitiveMunki_name:(NSString*)value;

- (NSString*)primitiveMunki_notes;
- (void)setPrimitiveMunki_notes:(NSString*)value;

- (NSString*)primitiveMunki_package_path;
- (void)setPrimitiveMunki_package_path:(NSString*)value;

- (NSString*)primitiveMunki_postinstall_script;
- (void)setPrimitiveMunki_postinstall_script:(NSString*)value;

- (NSString*)primitiveMunki_postuninstall_script;
- (void)setPrimitiveMunki_postuninstall_script:(NSString*)value;

- (NSString*)primitiveMunki_preinstall_alert_alert_detail;
- (void)setPrimitiveMunki_preinstall_alert_alert_detail:(NSString*)value;

- (NSString*)primitiveMunki_preinstall_alert_alert_title;
- (void)setPrimitiveMunki_preinstall_alert_alert_title:(NSString*)value;

- (NSString*)primitiveMunki_preinstall_alert_cancel_label;
- (void)setPrimitiveMunki_preinstall_alert_cancel_label:(NSString*)value;

- (NSNumber*)primitiveMunki_preinstall_alert_enabled;
- (void)setPrimitiveMunki_preinstall_alert_enabled:(NSNumber*)value;

- (BOOL)primitiveMunki_preinstall_alert_enabledValue;
- (void)setPrimitiveMunki_preinstall_alert_enabledValue:(BOOL)value_;

- (NSString*)primitiveMunki_preinstall_alert_ok_label;
- (void)setPrimitiveMunki_preinstall_alert_ok_label:(NSString*)value;

- (NSString*)primitiveMunki_preinstall_script;
- (void)setPrimitiveMunki_preinstall_script:(NSString*)value;

- (NSString*)primitiveMunki_preuninstall_alert_alert_detail;
- (void)setPrimitiveMunki_preuninstall_alert_alert_detail:(NSString*)value;

- (NSString*)primitiveMunki_preuninstall_alert_alert_title;
- (void)setPrimitiveMunki_preuninstall_alert_alert_title:(NSString*)value;

- (NSString*)primitiveMunki_preuninstall_alert_cancel_label;
- (void)setPrimitiveMunki_preuninstall_alert_cancel_label:(NSString*)value;

- (NSNumber*)primitiveMunki_preuninstall_alert_enabled;
- (void)setPrimitiveMunki_preuninstall_alert_enabled:(NSNumber*)value;

- (BOOL)primitiveMunki_preuninstall_alert_enabledValue;
- (void)setPrimitiveMunki_preuninstall_alert_enabledValue:(BOOL)value_;

- (NSString*)primitiveMunki_preuninstall_alert_ok_label;
- (void)setPrimitiveMunki_preuninstall_alert_ok_label:(NSString*)value;

- (NSString*)primitiveMunki_preuninstall_script;
- (void)setPrimitiveMunki_preuninstall_script:(NSString*)value;

- (NSString*)primitiveMunki_receipts;
- (void)setPrimitiveMunki_receipts:(NSString*)value;

- (NSNumber*)primitiveMunki_suppress_bundle_relocation;
- (void)setPrimitiveMunki_suppress_bundle_relocation:(NSNumber*)value;

- (BOOL)primitiveMunki_suppress_bundle_relocationValue;
- (void)setPrimitiveMunki_suppress_bundle_relocationValue:(BOOL)value_;

- (NSNumber*)primitiveMunki_unattended_install;
- (void)setPrimitiveMunki_unattended_install:(NSNumber*)value;

- (BOOL)primitiveMunki_unattended_installValue;
- (void)setPrimitiveMunki_unattended_installValue:(BOOL)value_;

- (NSNumber*)primitiveMunki_unattended_uninstall;
- (void)setPrimitiveMunki_unattended_uninstall:(NSNumber*)value;

- (BOOL)primitiveMunki_unattended_uninstallValue;
- (void)setPrimitiveMunki_unattended_uninstallValue:(BOOL)value_;

- (NSString*)primitiveMunki_uninstall_method;
- (void)setPrimitiveMunki_uninstall_method:(NSString*)value;

- (NSString*)primitiveMunki_uninstall_script;
- (void)setPrimitiveMunki_uninstall_script:(NSString*)value;

- (NSNumber*)primitiveMunki_uninstallable;
- (void)setPrimitiveMunki_uninstallable:(NSNumber*)value;

- (BOOL)primitiveMunki_uninstallableValue;
- (void)setPrimitiveMunki_uninstallableValue:(BOOL)value_;

- (NSString*)primitiveMunki_uninstallcheck_script;
- (void)setPrimitiveMunki_uninstallcheck_script:(NSString*)value;

- (NSString*)primitiveMunki_uninstaller_item_location;
- (void)setPrimitiveMunki_uninstaller_item_location:(NSString*)value;

- (NSString*)primitiveMunki_version;
- (void)setPrimitiveMunki_version:(NSString*)value;

- (id)primitiveOriginalPkginfo;
- (void)setPrimitiveOriginalPkginfo:(id)value;

- (NSDate*)primitivePackageDateCreated;
- (void)setPrimitivePackageDateCreated:(NSDate*)value;

- (NSDate*)primitivePackageDateLastOpened;
- (void)setPrimitivePackageDateLastOpened:(NSDate*)value;

- (NSDate*)primitivePackageDateModified;
- (void)setPrimitivePackageDateModified:(NSDate*)value;

- (NSDate*)primitivePackageInfoDateCreated;
- (void)setPrimitivePackageInfoDateCreated:(NSDate*)value;

- (NSDate*)primitivePackageInfoDateLastOpened;
- (void)setPrimitivePackageInfoDateLastOpened:(NSDate*)value;

- (NSDate*)primitivePackageInfoDateModified;
- (void)setPrimitivePackageInfoDateModified:(NSDate*)value;

- (id)primitivePackageInfoParentDirectoryURL;
- (void)setPrimitivePackageInfoParentDirectoryURL:(id)value;

- (id)primitivePackageInfoURL;
- (void)setPrimitivePackageInfoURL:(id)value;

- (id)primitivePackageURL;
- (void)setPrimitivePackageURL:(id)value;

- (NSString*)primitiveTitleWithVersion;
- (void)setPrimitiveTitleWithVersion:(NSString*)value;

- (NSMutableSet*)primitiveBlockingApplications;
- (void)setPrimitiveBlockingApplications:(NSMutableSet*)value;

- (NSMutableSet*)primitiveCatalogInfos;
- (void)setPrimitiveCatalogInfos:(NSMutableSet*)value;

- (NSMutableSet*)primitiveCatalogs;
- (void)setPrimitiveCatalogs:(NSMutableSet*)value;

- (CategoryMO*)primitiveCategory;
- (void)setPrimitiveCategory:(CategoryMO*)value;

- (DeveloperMO*)primitiveDeveloper;
- (void)setPrimitiveDeveloper:(DeveloperMO*)value;

- (IconImageMO*)primitiveIconImage;
- (void)setPrimitiveIconImage:(IconImageMO*)value;

- (NSMutableSet*)primitiveInstallerChoicesItems;
- (void)setPrimitiveInstallerChoicesItems:(NSMutableSet*)value;

- (NSMutableSet*)primitiveInstallerEnvironmentVariables;
- (void)setPrimitiveInstallerEnvironmentVariables:(NSMutableSet*)value;

- (NSMutableSet*)primitiveInstallsItems;
- (void)setPrimitiveInstallsItems:(NSMutableSet*)value;

- (NSMutableSet*)primitiveItemsToCopy;
- (void)setPrimitiveItemsToCopy:(NSMutableSet*)value;

- (NSMutableSet*)primitivePackageInfos;
- (void)setPrimitivePackageInfos:(NSMutableSet*)value;

- (ApplicationMO*)primitiveParentApplication;
- (void)setPrimitiveParentApplication:(ApplicationMO*)value;

- (ApplicationMO*)primitiveParentApplicationFromLatestPackage;
- (void)setPrimitiveParentApplicationFromLatestPackage:(ApplicationMO*)value;

- (NSMutableSet*)primitiveReceipts;
- (void)setPrimitiveReceipts:(NSMutableSet*)value;

- (NSMutableSet*)primitiveReferencingStringObjects;
- (void)setPrimitiveReferencingStringObjects:(NSMutableSet*)value;

- (NSMutableSet*)primitiveRequirements;
- (void)setPrimitiveRequirements:(NSMutableSet*)value;

- (NSMutableSet*)primitiveSupportedArchitectures;
- (void)setPrimitiveSupportedArchitectures:(NSMutableSet*)value;

- (NSMutableSet*)primitiveUpdateFor;
- (void)setPrimitiveUpdateFor:(NSMutableSet*)value;

@end
