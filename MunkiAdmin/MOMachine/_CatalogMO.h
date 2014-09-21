// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CatalogMO.h instead.

#import <CoreData/CoreData.h>

extern const struct CatalogMOAttributes {
	__unsafe_unretained NSString *title;
} CatalogMOAttributes;

extern const struct CatalogMORelationships {
	__unsafe_unretained NSString *catalogInfos;
	__unsafe_unretained NSString *manifests;
	__unsafe_unretained NSString *packageInfos;
	__unsafe_unretained NSString *packages;
} CatalogMORelationships;

@class CatalogInfoMO;
@class ManifestMO;
@class PackageInfoMO;
@class PackageMO;

@interface CatalogMOID : NSManagedObjectID {}
@end

@interface _CatalogMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CatalogMOID* objectID;

@property (nonatomic, strong) NSString* title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *catalogInfos;

- (NSMutableSet*)catalogInfosSet;

@property (nonatomic, strong) NSSet *manifests;

- (NSMutableSet*)manifestsSet;

@property (nonatomic, strong) NSSet *packageInfos;

- (NSMutableSet*)packageInfosSet;

@property (nonatomic, strong) NSSet *packages;

- (NSMutableSet*)packagesSet;

@end

@interface _CatalogMO (CatalogInfosCoreDataGeneratedAccessors)
- (void)addCatalogInfos:(NSSet*)value_;
- (void)removeCatalogInfos:(NSSet*)value_;
- (void)addCatalogInfosObject:(CatalogInfoMO*)value_;
- (void)removeCatalogInfosObject:(CatalogInfoMO*)value_;

@end

@interface _CatalogMO (ManifestsCoreDataGeneratedAccessors)
- (void)addManifests:(NSSet*)value_;
- (void)removeManifests:(NSSet*)value_;
- (void)addManifestsObject:(ManifestMO*)value_;
- (void)removeManifestsObject:(ManifestMO*)value_;

@end

@interface _CatalogMO (PackageInfosCoreDataGeneratedAccessors)
- (void)addPackageInfos:(NSSet*)value_;
- (void)removePackageInfos:(NSSet*)value_;
- (void)addPackageInfosObject:(PackageInfoMO*)value_;
- (void)removePackageInfosObject:(PackageInfoMO*)value_;

@end

@interface _CatalogMO (PackagesCoreDataGeneratedAccessors)
- (void)addPackages:(NSSet*)value_;
- (void)removePackages:(NSSet*)value_;
- (void)addPackagesObject:(PackageMO*)value_;
- (void)removePackagesObject:(PackageMO*)value_;

@end

@interface _CatalogMO (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;

- (NSMutableSet*)primitiveCatalogInfos;
- (void)setPrimitiveCatalogInfos:(NSMutableSet*)value;

- (NSMutableSet*)primitiveManifests;
- (void)setPrimitiveManifests:(NSMutableSet*)value;

- (NSMutableSet*)primitivePackageInfos;
- (void)setPrimitivePackageInfos:(NSMutableSet*)value;

- (NSMutableSet*)primitivePackages;
- (void)setPrimitivePackages:(NSMutableSet*)value;

@end
