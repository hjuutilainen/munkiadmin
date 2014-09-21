// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallsItemMO.h instead.

#import <CoreData/CoreData.h>

extern const struct InstallsItemMOAttributes {
	__unsafe_unretained NSString *munki_CFBundleIdentifier;
	__unsafe_unretained NSString *munki_CFBundleName;
	__unsafe_unretained NSString *munki_CFBundleShortVersionString;
	__unsafe_unretained NSString *munki_CFBundleVersion;
	__unsafe_unretained NSString *munki_md5checksum;
	__unsafe_unretained NSString *munki_minosversion;
	__unsafe_unretained NSString *munki_path;
	__unsafe_unretained NSString *munki_type;
	__unsafe_unretained NSString *munki_version_comparison_key;
	__unsafe_unretained NSString *munki_version_comparison_key_value;
	__unsafe_unretained NSString *originalIndex;
	__unsafe_unretained NSString *originalInstallsItem;
} InstallsItemMOAttributes;

extern const struct InstallsItemMORelationships {
	__unsafe_unretained NSString *customKeys;
	__unsafe_unretained NSString *packages;
} InstallsItemMORelationships;

@class InstallsItemCustomKeyMO;
@class PackageMO;

@class NSObject;

@interface InstallsItemMOID : NSManagedObjectID {}
@end

@interface _InstallsItemMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) InstallsItemMOID* objectID;

@property (nonatomic, strong) NSString* munki_CFBundleIdentifier;

//- (BOOL)validateMunki_CFBundleIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_CFBundleName;

//- (BOOL)validateMunki_CFBundleName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_CFBundleShortVersionString;

//- (BOOL)validateMunki_CFBundleShortVersionString:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_CFBundleVersion;

//- (BOOL)validateMunki_CFBundleVersion:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_md5checksum;

//- (BOOL)validateMunki_md5checksum:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_minosversion;

//- (BOOL)validateMunki_minosversion:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_path;

//- (BOOL)validateMunki_path:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_type;

//- (BOOL)validateMunki_type:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_version_comparison_key;

//- (BOOL)validateMunki_version_comparison_key:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_version_comparison_key_value;

//- (BOOL)validateMunki_version_comparison_key_value:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* originalIndex;

@property (atomic) int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

//- (BOOL)validateOriginalIndex:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id originalInstallsItem;

//- (BOOL)validateOriginalInstallsItem:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *customKeys;

- (NSMutableSet*)customKeysSet;

@property (nonatomic, strong) NSSet *packages;

- (NSMutableSet*)packagesSet;

@end

@interface _InstallsItemMO (CustomKeysCoreDataGeneratedAccessors)
- (void)addCustomKeys:(NSSet*)value_;
- (void)removeCustomKeys:(NSSet*)value_;
- (void)addCustomKeysObject:(InstallsItemCustomKeyMO*)value_;
- (void)removeCustomKeysObject:(InstallsItemCustomKeyMO*)value_;

@end

@interface _InstallsItemMO (PackagesCoreDataGeneratedAccessors)
- (void)addPackages:(NSSet*)value_;
- (void)removePackages:(NSSet*)value_;
- (void)addPackagesObject:(PackageMO*)value_;
- (void)removePackagesObject:(PackageMO*)value_;

@end

@interface _InstallsItemMO (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveMunki_CFBundleIdentifier;
- (void)setPrimitiveMunki_CFBundleIdentifier:(NSString*)value;

- (NSString*)primitiveMunki_CFBundleName;
- (void)setPrimitiveMunki_CFBundleName:(NSString*)value;

- (NSString*)primitiveMunki_CFBundleShortVersionString;
- (void)setPrimitiveMunki_CFBundleShortVersionString:(NSString*)value;

- (NSString*)primitiveMunki_CFBundleVersion;
- (void)setPrimitiveMunki_CFBundleVersion:(NSString*)value;

- (NSString*)primitiveMunki_md5checksum;
- (void)setPrimitiveMunki_md5checksum:(NSString*)value;

- (NSString*)primitiveMunki_minosversion;
- (void)setPrimitiveMunki_minosversion:(NSString*)value;

- (NSString*)primitiveMunki_path;
- (void)setPrimitiveMunki_path:(NSString*)value;

- (NSString*)primitiveMunki_type;
- (void)setPrimitiveMunki_type:(NSString*)value;

- (NSString*)primitiveMunki_version_comparison_key;
- (void)setPrimitiveMunki_version_comparison_key:(NSString*)value;

- (NSString*)primitiveMunki_version_comparison_key_value;
- (void)setPrimitiveMunki_version_comparison_key_value:(NSString*)value;

- (NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(NSNumber*)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;

- (id)primitiveOriginalInstallsItem;
- (void)setPrimitiveOriginalInstallsItem:(id)value;

- (NSMutableSet*)primitiveCustomKeys;
- (void)setPrimitiveCustomKeys:(NSMutableSet*)value;

- (NSMutableSet*)primitivePackages;
- (void)setPrimitivePackages:(NSMutableSet*)value;

@end
