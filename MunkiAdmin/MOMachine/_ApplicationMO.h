// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ApplicationMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class ApplicationProxyMO;
@class PackageMO;
@class ManifestMO;
@class PackageMO;
@class StringObjectMO;

@interface ApplicationMOID : NSManagedObjectID {}
@end

@interface _ApplicationMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ApplicationMOID *objectID;

@property (nonatomic, strong, nullable) NSString* munki_description;

@property (nonatomic, strong, nullable) NSString* munki_display_name;

@property (nonatomic, strong) NSString* munki_name;

@property (nonatomic, strong, nullable) NSSet<ApplicationProxyMO*> *applicationProxies;
- (nullable NSMutableSet<ApplicationProxyMO*>*)applicationProxiesSet;

@property (nonatomic, strong, nullable) PackageMO *latestPackage;

@property (nonatomic, strong, nullable) NSSet<ManifestMO*> *manifests;
- (nullable NSMutableSet<ManifestMO*>*)manifestsSet;

@property (nonatomic, strong, nullable) NSSet<PackageMO*> *packages;
- (nullable NSMutableSet<PackageMO*>*)packagesSet;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *referencingStringObjects;
- (nullable NSMutableSet<StringObjectMO*>*)referencingStringObjectsSet;

@end

@interface _ApplicationMO (ApplicationProxiesCoreDataGeneratedAccessors)
- (void)addApplicationProxies:(NSSet<ApplicationProxyMO*>*)value_;
- (void)removeApplicationProxies:(NSSet<ApplicationProxyMO*>*)value_;
- (void)addApplicationProxiesObject:(ApplicationProxyMO*)value_;
- (void)removeApplicationProxiesObject:(ApplicationProxyMO*)value_;

@end

@interface _ApplicationMO (ManifestsCoreDataGeneratedAccessors)
- (void)addManifests:(NSSet<ManifestMO*>*)value_;
- (void)removeManifests:(NSSet<ManifestMO*>*)value_;
- (void)addManifestsObject:(ManifestMO*)value_;
- (void)removeManifestsObject:(ManifestMO*)value_;

@end

@interface _ApplicationMO (PackagesCoreDataGeneratedAccessors)
- (void)addPackages:(NSSet<PackageMO*>*)value_;
- (void)removePackages:(NSSet<PackageMO*>*)value_;
- (void)addPackagesObject:(PackageMO*)value_;
- (void)removePackagesObject:(PackageMO*)value_;

@end

@interface _ApplicationMO (ReferencingStringObjectsCoreDataGeneratedAccessors)
- (void)addReferencingStringObjects:(NSSet<StringObjectMO*>*)value_;
- (void)removeReferencingStringObjects:(NSSet<StringObjectMO*>*)value_;
- (void)addReferencingStringObjectsObject:(StringObjectMO*)value_;
- (void)removeReferencingStringObjectsObject:(StringObjectMO*)value_;

@end

@interface _ApplicationMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveMunki_description;
- (void)setPrimitiveMunki_description:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_display_name;
- (void)setPrimitiveMunki_display_name:(nullable NSString*)value;

- (NSString*)primitiveMunki_name;
- (void)setPrimitiveMunki_name:(NSString*)value;

- (NSMutableSet<ApplicationProxyMO*>*)primitiveApplicationProxies;
- (void)setPrimitiveApplicationProxies:(NSMutableSet<ApplicationProxyMO*>*)value;

- (PackageMO*)primitiveLatestPackage;
- (void)setPrimitiveLatestPackage:(PackageMO*)value;

- (NSMutableSet<ManifestMO*>*)primitiveManifests;
- (void)setPrimitiveManifests:(NSMutableSet<ManifestMO*>*)value;

- (NSMutableSet<PackageMO*>*)primitivePackages;
- (void)setPrimitivePackages:(NSMutableSet<PackageMO*>*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveReferencingStringObjects;
- (void)setPrimitiveReferencingStringObjects:(NSMutableSet<StringObjectMO*>*)value;

@end

@interface ApplicationMOAttributes: NSObject 
+ (NSString *)munki_description;
+ (NSString *)munki_display_name;
+ (NSString *)munki_name;
@end

@interface ApplicationMORelationships: NSObject
+ (NSString *)applicationProxies;
+ (NSString *)latestPackage;
+ (NSString *)manifests;
+ (NSString *)packages;
+ (NSString *)referencingStringObjects;
@end

NS_ASSUME_NONNULL_END
