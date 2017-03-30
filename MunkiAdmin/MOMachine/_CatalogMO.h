// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CatalogMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class CatalogInfoMO;
@class ManifestMO;
@class PackageInfoMO;
@class PackageMO;

@interface CatalogMOID : NSManagedObjectID {}
@end

@interface _CatalogMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CatalogMOID *objectID;

@property (nonatomic, strong, nullable) NSString* title;

@property (nonatomic, strong, nullable) NSSet<CatalogInfoMO*> *catalogInfos;
- (nullable NSMutableSet<CatalogInfoMO*>*)catalogInfosSet;

@property (nonatomic, strong, nullable) NSSet<ManifestMO*> *manifests;
- (nullable NSMutableSet<ManifestMO*>*)manifestsSet;

@property (nonatomic, strong, nullable) NSSet<PackageInfoMO*> *packageInfos;
- (nullable NSMutableSet<PackageInfoMO*>*)packageInfosSet;

@property (nonatomic, strong, nullable) NSSet<PackageMO*> *packages;
- (nullable NSMutableSet<PackageMO*>*)packagesSet;

@end

@interface _CatalogMO (CatalogInfosCoreDataGeneratedAccessors)
- (void)addCatalogInfos:(NSSet<CatalogInfoMO*>*)value_;
- (void)removeCatalogInfos:(NSSet<CatalogInfoMO*>*)value_;
- (void)addCatalogInfosObject:(CatalogInfoMO*)value_;
- (void)removeCatalogInfosObject:(CatalogInfoMO*)value_;

@end

@interface _CatalogMO (ManifestsCoreDataGeneratedAccessors)
- (void)addManifests:(NSSet<ManifestMO*>*)value_;
- (void)removeManifests:(NSSet<ManifestMO*>*)value_;
- (void)addManifestsObject:(ManifestMO*)value_;
- (void)removeManifestsObject:(ManifestMO*)value_;

@end

@interface _CatalogMO (PackageInfosCoreDataGeneratedAccessors)
- (void)addPackageInfos:(NSSet<PackageInfoMO*>*)value_;
- (void)removePackageInfos:(NSSet<PackageInfoMO*>*)value_;
- (void)addPackageInfosObject:(PackageInfoMO*)value_;
- (void)removePackageInfosObject:(PackageInfoMO*)value_;

@end

@interface _CatalogMO (PackagesCoreDataGeneratedAccessors)
- (void)addPackages:(NSSet<PackageMO*>*)value_;
- (void)removePackages:(NSSet<PackageMO*>*)value_;
- (void)addPackagesObject:(PackageMO*)value_;
- (void)removePackagesObject:(PackageMO*)value_;

@end

@interface _CatalogMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(nullable NSString*)value;

- (NSMutableSet<CatalogInfoMO*>*)primitiveCatalogInfos;
- (void)setPrimitiveCatalogInfos:(NSMutableSet<CatalogInfoMO*>*)value;

- (NSMutableSet<ManifestMO*>*)primitiveManifests;
- (void)setPrimitiveManifests:(NSMutableSet<ManifestMO*>*)value;

- (NSMutableSet<PackageInfoMO*>*)primitivePackageInfos;
- (void)setPrimitivePackageInfos:(NSMutableSet<PackageInfoMO*>*)value;

- (NSMutableSet<PackageMO*>*)primitivePackages;
- (void)setPrimitivePackages:(NSMutableSet<PackageMO*>*)value;

@end

@interface CatalogMOAttributes: NSObject 
+ (NSString *)title;
@end

@interface CatalogMORelationships: NSObject
+ (NSString *)catalogInfos;
+ (NSString *)manifests;
+ (NSString *)packageInfos;
+ (NSString *)packages;
@end

NS_ASSUME_NONNULL_END
