// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CatalogMO.h instead.

#import <CoreData/CoreData.h>


@class CatalogInfoMO;
@class PackageMO;
@class ManifestMO;
@class PackageInfoMO;



@interface CatalogMOID : NSManagedObjectID {}
@end

@interface _CatalogMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CatalogMOID*)objectID;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* catalogInfos;
- (NSMutableSet*)catalogInfosSet;



@property (nonatomic, retain) NSSet* packages;
- (NSMutableSet*)packagesSet;



@property (nonatomic, retain) NSSet* manifests;
- (NSMutableSet*)manifestsSet;



@property (nonatomic, retain) NSSet* packageInfos;
- (NSMutableSet*)packageInfosSet;



@end

@interface _CatalogMO (CoreDataGeneratedAccessors)

- (void)addCatalogInfos:(NSSet*)value_;
- (void)removeCatalogInfos:(NSSet*)value_;
- (void)addCatalogInfosObject:(CatalogInfoMO*)value_;
- (void)removeCatalogInfosObject:(CatalogInfoMO*)value_;

- (void)addPackages:(NSSet*)value_;
- (void)removePackages:(NSSet*)value_;
- (void)addPackagesObject:(PackageMO*)value_;
- (void)removePackagesObject:(PackageMO*)value_;

- (void)addManifests:(NSSet*)value_;
- (void)removeManifests:(NSSet*)value_;
- (void)addManifestsObject:(ManifestMO*)value_;
- (void)removeManifestsObject:(ManifestMO*)value_;

- (void)addPackageInfos:(NSSet*)value_;
- (void)removePackageInfos:(NSSet*)value_;
- (void)addPackageInfosObject:(PackageInfoMO*)value_;
- (void)removePackageInfosObject:(PackageInfoMO*)value_;

@end

@interface _CatalogMO (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSMutableSet*)primitiveCatalogInfos;
- (void)setPrimitiveCatalogInfos:(NSMutableSet*)value;



- (NSMutableSet*)primitivePackages;
- (void)setPrimitivePackages:(NSMutableSet*)value;



- (NSMutableSet*)primitiveManifests;
- (void)setPrimitiveManifests:(NSMutableSet*)value;



- (NSMutableSet*)primitivePackageInfos;
- (void)setPrimitivePackageInfos:(NSMutableSet*)value;


@end
