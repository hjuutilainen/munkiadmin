// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallerEnvironmentVariableMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class PackageMO;

@interface InstallerEnvironmentVariableMOID : NSManagedObjectID {}
@end

@interface _InstallerEnvironmentVariableMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) InstallerEnvironmentVariableMOID *objectID;

@property (nonatomic, strong) NSString* munki_installer_environment_key;

@property (nonatomic, strong, nullable) NSString* munki_installer_environment_value;

@property (nonatomic, strong, nullable) NSNumber* originalIndex;

@property (atomic) int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

@property (nonatomic, strong, nullable) NSSet<PackageMO*> *packages;
- (nullable NSMutableSet<PackageMO*>*)packagesSet;

@end

@interface _InstallerEnvironmentVariableMO (PackagesCoreDataGeneratedAccessors)
- (void)addPackages:(NSSet<PackageMO*>*)value_;
- (void)removePackages:(NSSet<PackageMO*>*)value_;
- (void)addPackagesObject:(PackageMO*)value_;
- (void)removePackagesObject:(PackageMO*)value_;

@end

@interface _InstallerEnvironmentVariableMO (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveMunki_installer_environment_key;
- (void)setPrimitiveMunki_installer_environment_key:(NSString*)value;

- (nullable NSString*)primitiveMunki_installer_environment_value;
- (void)setPrimitiveMunki_installer_environment_value:(nullable NSString*)value;

- (nullable NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(nullable NSNumber*)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;

- (NSMutableSet<PackageMO*>*)primitivePackages;
- (void)setPrimitivePackages:(NSMutableSet<PackageMO*>*)value;

@end

@interface InstallerEnvironmentVariableMOAttributes: NSObject 
+ (NSString *)munki_installer_environment_key;
+ (NSString *)munki_installer_environment_value;
+ (NSString *)originalIndex;
@end

@interface InstallerEnvironmentVariableMORelationships: NSObject
+ (NSString *)packages;
@end

NS_ASSUME_NONNULL_END
