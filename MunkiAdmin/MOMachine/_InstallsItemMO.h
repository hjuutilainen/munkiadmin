// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallsItemMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class InstallsItemCustomKeyMO;
@class PackageMO;

@class NSObject;

@interface InstallsItemMOID : NSManagedObjectID {}
@end

@interface _InstallsItemMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) InstallsItemMOID *objectID;

@property (nonatomic, strong, nullable) NSString* munki_CFBundleIdentifier;

@property (nonatomic, strong, nullable) NSString* munki_CFBundleName;

@property (nonatomic, strong, nullable) NSString* munki_CFBundleShortVersionString;

@property (nonatomic, strong, nullable) NSString* munki_CFBundleVersion;

@property (nonatomic, strong, nullable) NSString* munki_md5checksum;

@property (nonatomic, strong, nullable) NSString* munki_minosversion;

@property (nonatomic, strong, nullable) NSString* munki_path;

@property (nonatomic, strong, nullable) NSString* munki_type;

@property (nonatomic, strong, nullable) NSString* munki_version_comparison_key;

@property (nonatomic, strong, nullable) NSString* munki_version_comparison_key_value;

@property (nonatomic, strong, nullable) NSNumber* originalIndex;

@property (atomic) int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

@property (nonatomic, strong, nullable) id originalInstallsItem;

@property (nonatomic, strong, nullable) NSSet<InstallsItemCustomKeyMO*> *customKeys;
- (nullable NSMutableSet<InstallsItemCustomKeyMO*>*)customKeysSet;

@property (nonatomic, strong, nullable) NSSet<PackageMO*> *packages;
- (nullable NSMutableSet<PackageMO*>*)packagesSet;

@end

@interface _InstallsItemMO (CustomKeysCoreDataGeneratedAccessors)
- (void)addCustomKeys:(NSSet<InstallsItemCustomKeyMO*>*)value_;
- (void)removeCustomKeys:(NSSet<InstallsItemCustomKeyMO*>*)value_;
- (void)addCustomKeysObject:(InstallsItemCustomKeyMO*)value_;
- (void)removeCustomKeysObject:(InstallsItemCustomKeyMO*)value_;

@end

@interface _InstallsItemMO (PackagesCoreDataGeneratedAccessors)
- (void)addPackages:(NSSet<PackageMO*>*)value_;
- (void)removePackages:(NSSet<PackageMO*>*)value_;
- (void)addPackagesObject:(PackageMO*)value_;
- (void)removePackagesObject:(PackageMO*)value_;

@end

@interface _InstallsItemMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveMunki_CFBundleIdentifier;
- (void)setPrimitiveMunki_CFBundleIdentifier:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_CFBundleName;
- (void)setPrimitiveMunki_CFBundleName:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_CFBundleShortVersionString;
- (void)setPrimitiveMunki_CFBundleShortVersionString:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_CFBundleVersion;
- (void)setPrimitiveMunki_CFBundleVersion:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_md5checksum;
- (void)setPrimitiveMunki_md5checksum:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_minosversion;
- (void)setPrimitiveMunki_minosversion:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_path;
- (void)setPrimitiveMunki_path:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_type;
- (void)setPrimitiveMunki_type:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_version_comparison_key;
- (void)setPrimitiveMunki_version_comparison_key:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_version_comparison_key_value;
- (void)setPrimitiveMunki_version_comparison_key_value:(nullable NSString*)value;

- (nullable NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(nullable NSNumber*)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;

- (nullable id)primitiveOriginalInstallsItem;
- (void)setPrimitiveOriginalInstallsItem:(nullable id)value;

- (NSMutableSet<InstallsItemCustomKeyMO*>*)primitiveCustomKeys;
- (void)setPrimitiveCustomKeys:(NSMutableSet<InstallsItemCustomKeyMO*>*)value;

- (NSMutableSet<PackageMO*>*)primitivePackages;
- (void)setPrimitivePackages:(NSMutableSet<PackageMO*>*)value;

@end

@interface InstallsItemMOAttributes: NSObject 
+ (NSString *)munki_CFBundleIdentifier;
+ (NSString *)munki_CFBundleName;
+ (NSString *)munki_CFBundleShortVersionString;
+ (NSString *)munki_CFBundleVersion;
+ (NSString *)munki_md5checksum;
+ (NSString *)munki_minosversion;
+ (NSString *)munki_path;
+ (NSString *)munki_type;
+ (NSString *)munki_version_comparison_key;
+ (NSString *)munki_version_comparison_key_value;
+ (NSString *)originalIndex;
+ (NSString *)originalInstallsItem;
@end

@interface InstallsItemMORelationships: NSObject
+ (NSString *)customKeys;
+ (NSString *)packages;
@end

NS_ASSUME_NONNULL_END
