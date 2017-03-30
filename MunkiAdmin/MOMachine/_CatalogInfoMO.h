// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CatalogInfoMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class CatalogMO;
@class ManifestMO;
@class PackageMO;

@interface CatalogInfoMOID : NSManagedObjectID {}
@end

@interface _CatalogInfoMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CatalogInfoMOID *objectID;

@property (nonatomic, strong, nullable) NSNumber* indexInManifest;

@property (atomic) int32_t indexInManifestValue;
- (int32_t)indexInManifestValue;
- (void)setIndexInManifestValue:(int32_t)value_;

@property (nonatomic, strong, nullable) NSNumber* isEnabledForManifest;

@property (atomic) BOOL isEnabledForManifestValue;
- (BOOL)isEnabledForManifestValue;
- (void)setIsEnabledForManifestValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSNumber* isEnabledForPackage;

@property (atomic) BOOL isEnabledForPackageValue;
- (BOOL)isEnabledForPackageValue;
- (void)setIsEnabledForPackageValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSNumber* originalIndex;

@property (atomic) int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

@property (nonatomic, strong, nullable) CatalogMO *catalog;

@property (nonatomic, strong, nullable) ManifestMO *manifest;

@property (nonatomic, strong, nullable) PackageMO *package;

@end

@interface _CatalogInfoMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSNumber*)primitiveIndexInManifest;
- (void)setPrimitiveIndexInManifest:(nullable NSNumber*)value;

- (int32_t)primitiveIndexInManifestValue;
- (void)setPrimitiveIndexInManifestValue:(int32_t)value_;

- (nullable NSNumber*)primitiveIsEnabledForManifest;
- (void)setPrimitiveIsEnabledForManifest:(nullable NSNumber*)value;

- (BOOL)primitiveIsEnabledForManifestValue;
- (void)setPrimitiveIsEnabledForManifestValue:(BOOL)value_;

- (nullable NSNumber*)primitiveIsEnabledForPackage;
- (void)setPrimitiveIsEnabledForPackage:(nullable NSNumber*)value;

- (BOOL)primitiveIsEnabledForPackageValue;
- (void)setPrimitiveIsEnabledForPackageValue:(BOOL)value_;

- (nullable NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(nullable NSNumber*)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;

- (CatalogMO*)primitiveCatalog;
- (void)setPrimitiveCatalog:(CatalogMO*)value;

- (ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(ManifestMO*)value;

- (PackageMO*)primitivePackage;
- (void)setPrimitivePackage:(PackageMO*)value;

@end

@interface CatalogInfoMOAttributes: NSObject 
+ (NSString *)indexInManifest;
+ (NSString *)isEnabledForManifest;
+ (NSString *)isEnabledForPackage;
+ (NSString *)originalIndex;
@end

@interface CatalogInfoMORelationships: NSObject
+ (NSString *)catalog;
+ (NSString *)manifest;
+ (NSString *)package;
@end

NS_ASSUME_NONNULL_END
