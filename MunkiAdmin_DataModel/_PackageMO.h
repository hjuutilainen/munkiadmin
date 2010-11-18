// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PackageMO.h instead.

#import <CoreData/CoreData.h>


@class ApplicationMO;
@class PackageInfoMO;
@class StringObjectMO;
@class CatalogMO;
@class InstallsItemMO;
@class StringObjectMO;
@class ReceiptMO;
@class ItemToCopyMO;
@class CatalogInfoMO;












@class NSObject;

@class NSObject;


@class NSObject;



@interface PackageMOID : NSManagedObjectID {}
@end

@interface _PackageMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PackageMOID*)objectID;



@property (nonatomic, retain) NSNumber *munki_autoremove;

@property BOOL munki_autoremoveValue;
- (BOOL)munki_autoremoveValue;
- (void)setMunki_autoremoveValue:(BOOL)value_;

//- (BOOL)validateMunki_autoremove:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *munki_receipts;

//- (BOOL)validateMunki_receipts:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *munki_description;

//- (BOOL)validateMunki_description:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *munki_name;

//- (BOOL)validateMunki_name:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *munki_uninstall_method;

//- (BOOL)validateMunki_uninstall_method:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *munki_version;

//- (BOOL)validateMunki_version:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *munki_forced_install;

@property BOOL munki_forced_installValue;
- (BOOL)munki_forced_installValue;
- (void)setMunki_forced_installValue:(BOOL)value_;

//- (BOOL)validateMunki_forced_install:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *munki_minimum_os_version;

//- (BOOL)validateMunki_minimum_os_version:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *munki_uninstallable;

@property BOOL munki_uninstallableValue;
- (BOOL)munki_uninstallableValue;
- (void)setMunki_uninstallableValue:(BOOL)value_;

//- (BOOL)validateMunki_uninstallable:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *munki_installer_item_hash;

//- (BOOL)validateMunki_installer_item_hash:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *munki_display_name;

//- (BOOL)validateMunki_display_name:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSObject *originalPkginfo;

//- (BOOL)validateOriginalPkginfo:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *munki_installer_type;

//- (BOOL)validateMunki_installer_type:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSObject *packageURL;

//- (BOOL)validatePackageURL:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *munki_forced_uninstall;

@property BOOL munki_forced_uninstallValue;
- (BOOL)munki_forced_uninstallValue;
- (void)setMunki_forced_uninstallValue:(BOOL)value_;

//- (BOOL)validateMunki_forced_uninstall:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *munki_installer_item_size;

@property long long munki_installer_item_sizeValue;
- (long long)munki_installer_item_sizeValue;
- (void)setMunki_installer_item_sizeValue:(long long)value_;

//- (BOOL)validateMunki_installer_item_size:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSObject *packageInfoURL;

//- (BOOL)validatePackageInfoURL:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *munki_installed_size;

@property long long munki_installed_sizeValue;
- (long long)munki_installed_sizeValue;
- (void)setMunki_installed_sizeValue:(long long)value_;

//- (BOOL)validateMunki_installed_size:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *munki_installer_item_location;

//- (BOOL)validateMunki_installer_item_location:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ApplicationMO* parentApplication;
//- (BOOL)validateParentApplication:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSSet* packageInfos;
- (NSMutableSet*)packageInfosSet;



@property (nonatomic, retain) NSSet* updateFor;
- (NSMutableSet*)updateForSet;



@property (nonatomic, retain) NSSet* catalogs;
- (NSMutableSet*)catalogsSet;



@property (nonatomic, retain) NSSet* installsItems;
- (NSMutableSet*)installsItemsSet;



@property (nonatomic, retain) NSSet* requirements;
- (NSMutableSet*)requirementsSet;



@property (nonatomic, retain) NSSet* receipts;
- (NSMutableSet*)receiptsSet;



@property (nonatomic, retain) NSSet* itemsToCopy;
- (NSMutableSet*)itemsToCopySet;



@property (nonatomic, retain) NSSet* catalogInfos;
- (NSMutableSet*)catalogInfosSet;



@end

@interface _PackageMO (CoreDataGeneratedAccessors)

- (void)addPackageInfos:(NSSet*)value_;
- (void)removePackageInfos:(NSSet*)value_;
- (void)addPackageInfosObject:(PackageInfoMO*)value_;
- (void)removePackageInfosObject:(PackageInfoMO*)value_;

- (void)addUpdateFor:(NSSet*)value_;
- (void)removeUpdateFor:(NSSet*)value_;
- (void)addUpdateForObject:(StringObjectMO*)value_;
- (void)removeUpdateForObject:(StringObjectMO*)value_;

- (void)addCatalogs:(NSSet*)value_;
- (void)removeCatalogs:(NSSet*)value_;
- (void)addCatalogsObject:(CatalogMO*)value_;
- (void)removeCatalogsObject:(CatalogMO*)value_;

- (void)addInstallsItems:(NSSet*)value_;
- (void)removeInstallsItems:(NSSet*)value_;
- (void)addInstallsItemsObject:(InstallsItemMO*)value_;
- (void)removeInstallsItemsObject:(InstallsItemMO*)value_;

- (void)addRequirements:(NSSet*)value_;
- (void)removeRequirements:(NSSet*)value_;
- (void)addRequirementsObject:(StringObjectMO*)value_;
- (void)removeRequirementsObject:(StringObjectMO*)value_;

- (void)addReceipts:(NSSet*)value_;
- (void)removeReceipts:(NSSet*)value_;
- (void)addReceiptsObject:(ReceiptMO*)value_;
- (void)removeReceiptsObject:(ReceiptMO*)value_;

- (void)addItemsToCopy:(NSSet*)value_;
- (void)removeItemsToCopy:(NSSet*)value_;
- (void)addItemsToCopyObject:(ItemToCopyMO*)value_;
- (void)removeItemsToCopyObject:(ItemToCopyMO*)value_;

- (void)addCatalogInfos:(NSSet*)value_;
- (void)removeCatalogInfos:(NSSet*)value_;
- (void)addCatalogInfosObject:(CatalogInfoMO*)value_;
- (void)removeCatalogInfosObject:(CatalogInfoMO*)value_;

@end

@interface _PackageMO (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveMunki_autoremove;
- (void)setPrimitiveMunki_autoremove:(NSNumber*)value;

- (BOOL)primitiveMunki_autoremoveValue;
- (void)setPrimitiveMunki_autoremoveValue:(BOOL)value_;


- (NSString*)primitiveMunki_receipts;
- (void)setPrimitiveMunki_receipts:(NSString*)value;


- (NSString*)primitiveMunki_description;
- (void)setPrimitiveMunki_description:(NSString*)value;


- (NSString*)primitiveMunki_name;
- (void)setPrimitiveMunki_name:(NSString*)value;


- (NSString*)primitiveMunki_uninstall_method;
- (void)setPrimitiveMunki_uninstall_method:(NSString*)value;


- (NSString*)primitiveMunki_version;
- (void)setPrimitiveMunki_version:(NSString*)value;


- (NSNumber*)primitiveMunki_forced_install;
- (void)setPrimitiveMunki_forced_install:(NSNumber*)value;

- (BOOL)primitiveMunki_forced_installValue;
- (void)setPrimitiveMunki_forced_installValue:(BOOL)value_;


- (NSString*)primitiveMunki_minimum_os_version;
- (void)setPrimitiveMunki_minimum_os_version:(NSString*)value;


- (NSNumber*)primitiveMunki_uninstallable;
- (void)setPrimitiveMunki_uninstallable:(NSNumber*)value;

- (BOOL)primitiveMunki_uninstallableValue;
- (void)setPrimitiveMunki_uninstallableValue:(BOOL)value_;


- (NSString*)primitiveMunki_installer_item_hash;
- (void)setPrimitiveMunki_installer_item_hash:(NSString*)value;


- (NSString*)primitiveMunki_display_name;
- (void)setPrimitiveMunki_display_name:(NSString*)value;


- (NSObject*)primitiveOriginalPkginfo;
- (void)setPrimitiveOriginalPkginfo:(NSObject*)value;


- (NSString*)primitiveMunki_installer_type;
- (void)setPrimitiveMunki_installer_type:(NSString*)value;


- (NSObject*)primitivePackageURL;
- (void)setPrimitivePackageURL:(NSObject*)value;


- (NSNumber*)primitiveMunki_forced_uninstall;
- (void)setPrimitiveMunki_forced_uninstall:(NSNumber*)value;

- (BOOL)primitiveMunki_forced_uninstallValue;
- (void)setPrimitiveMunki_forced_uninstallValue:(BOOL)value_;


- (NSNumber*)primitiveMunki_installer_item_size;
- (void)setPrimitiveMunki_installer_item_size:(NSNumber*)value;

- (long long)primitiveMunki_installer_item_sizeValue;
- (void)setPrimitiveMunki_installer_item_sizeValue:(long long)value_;


- (NSObject*)primitivePackageInfoURL;
- (void)setPrimitivePackageInfoURL:(NSObject*)value;


- (NSNumber*)primitiveMunki_installed_size;
- (void)setPrimitiveMunki_installed_size:(NSNumber*)value;

- (long long)primitiveMunki_installed_sizeValue;
- (void)setPrimitiveMunki_installed_sizeValue:(long long)value_;


- (NSString*)primitiveMunki_installer_item_location;
- (void)setPrimitiveMunki_installer_item_location:(NSString*)value;




- (ApplicationMO*)primitiveParentApplication;
- (void)setPrimitiveParentApplication:(ApplicationMO*)value;



- (NSMutableSet*)primitivePackageInfos;
- (void)setPrimitivePackageInfos:(NSMutableSet*)value;



- (NSMutableSet*)primitiveUpdateFor;
- (void)setPrimitiveUpdateFor:(NSMutableSet*)value;



- (NSMutableSet*)primitiveCatalogs;
- (void)setPrimitiveCatalogs:(NSMutableSet*)value;



- (NSMutableSet*)primitiveInstallsItems;
- (void)setPrimitiveInstallsItems:(NSMutableSet*)value;



- (NSMutableSet*)primitiveRequirements;
- (void)setPrimitiveRequirements:(NSMutableSet*)value;



- (NSMutableSet*)primitiveReceipts;
- (void)setPrimitiveReceipts:(NSMutableSet*)value;



- (NSMutableSet*)primitiveItemsToCopy;
- (void)setPrimitiveItemsToCopy:(NSMutableSet*)value;



- (NSMutableSet*)primitiveCatalogInfos;
- (void)setPrimitiveCatalogInfos:(NSMutableSet*)value;


@end
