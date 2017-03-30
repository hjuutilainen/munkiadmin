// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PackageInfoMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class CatalogMO;
@class PackageMO;

@interface PackageInfoMOID : NSManagedObjectID {}
@end

@interface _PackageInfoMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) PackageInfoMOID *objectID;

@property (nonatomic, strong, nullable) NSNumber* isEnabledForCatalog;

@property (atomic) BOOL isEnabledForCatalogValue;
- (BOOL)isEnabledForCatalogValue;
- (void)setIsEnabledForCatalogValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSNumber* originalIndex;

@property (atomic) int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

@property (nonatomic, strong, nullable) NSString* title;

@property (nonatomic, strong, nullable) CatalogMO *catalog;

@property (nonatomic, strong, nullable) PackageMO *package;

@end

@interface _PackageInfoMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSNumber*)primitiveIsEnabledForCatalog;
- (void)setPrimitiveIsEnabledForCatalog:(nullable NSNumber*)value;

- (BOOL)primitiveIsEnabledForCatalogValue;
- (void)setPrimitiveIsEnabledForCatalogValue:(BOOL)value_;

- (nullable NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(nullable NSNumber*)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;

- (nullable NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(nullable NSString*)value;

- (CatalogMO*)primitiveCatalog;
- (void)setPrimitiveCatalog:(CatalogMO*)value;

- (PackageMO*)primitivePackage;
- (void)setPrimitivePackage:(PackageMO*)value;

@end

@interface PackageInfoMOAttributes: NSObject 
+ (NSString *)isEnabledForCatalog;
+ (NSString *)originalIndex;
+ (NSString *)title;
@end

@interface PackageInfoMORelationships: NSObject
+ (NSString *)catalog;
+ (NSString *)package;
@end

NS_ASSUME_NONNULL_END
