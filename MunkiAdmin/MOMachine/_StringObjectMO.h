// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StringObjectMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class PackageMO;
@class ConditionalItemMO;
@class ManifestMO;
@class ConditionalItemMO;
@class ConditionalItemMO;
@class ManifestMO;
@class ConditionalItemMO;
@class ManifestMO;
@class ConditionalItemMO;
@class ManifestMO;
@class ManifestMO;
@class ConditionalItemMO;
@class ManifestMO;
@class ApplicationMO;
@class ManifestMO;
@class ConditionalItemMO;
@class PackageMO;
@class PackageMO;
@class PackageMO;
@class PackageMO;

@interface StringObjectMOID : NSManagedObjectID {}
@end

@interface _StringObjectMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) StringObjectMOID *objectID;

@property (nonatomic, strong, nullable) NSNumber* indexInNestedManifest;

@property (atomic) int32_t indexInNestedManifestValue;
- (int32_t)indexInNestedManifestValue;
- (void)setIndexInNestedManifestValue:(int32_t)value_;

@property (nonatomic, strong, nullable) NSNumber* originalIndex;

@property (atomic) int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

@property (nonatomic, strong, nullable) NSString* title;

@property (nonatomic, strong, nullable) NSString* typeString;

@property (nonatomic, strong, nullable) PackageMO *blockingApplicationReference;

@property (nonatomic, strong, nullable) ConditionalItemMO *featuredItemConditionalReference;

@property (nonatomic, strong, nullable) ManifestMO *featuredItemReference;

@property (nonatomic, strong, nullable) ConditionalItemMO *includedManifestConditionalReference;

@property (nonatomic, strong, nullable) ConditionalItemMO *managedInstallConditionalReference;

@property (nonatomic, strong, nullable) ManifestMO *managedInstallReference;

@property (nonatomic, strong, nullable) ConditionalItemMO *managedUninstallConditionalReference;

@property (nonatomic, strong, nullable) ManifestMO *managedUninstallReference;

@property (nonatomic, strong, nullable) ConditionalItemMO *managedUpdateConditionalReference;

@property (nonatomic, strong, nullable) ManifestMO *managedUpdateReference;

@property (nonatomic, strong, nullable) ManifestMO *manifestReference;

@property (nonatomic, strong, nullable) ConditionalItemMO *optionalInstallConditionalReference;

@property (nonatomic, strong, nullable) ManifestMO *optionalInstallReference;

@property (nonatomic, strong, nullable) ApplicationMO *originalApplication;

@property (nonatomic, strong, nullable) ManifestMO *originalManifest;

@property (nonatomic, strong, nullable) ConditionalItemMO *originalManifestConditionalReference;

@property (nonatomic, strong, nullable) PackageMO *originalPackage;

@property (nonatomic, strong, nullable) PackageMO *requiresReference;

@property (nonatomic, strong, nullable) PackageMO *supportedArchitectureReference;

@property (nonatomic, strong, nullable) PackageMO *updateForReference;

@property (nonatomic, readonly, nullable) NSArray *manifestsWithSameTitle;

@property (nonatomic, readonly, nullable) NSArray *packagesWithSameTitle;

@end

@interface _StringObjectMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSNumber*)primitiveIndexInNestedManifest;
- (void)setPrimitiveIndexInNestedManifest:(nullable NSNumber*)value;

- (int32_t)primitiveIndexInNestedManifestValue;
- (void)setPrimitiveIndexInNestedManifestValue:(int32_t)value_;

- (nullable NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(nullable NSNumber*)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;

- (nullable NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(nullable NSString*)value;

- (nullable NSString*)primitiveTypeString;
- (void)setPrimitiveTypeString:(nullable NSString*)value;

- (PackageMO*)primitiveBlockingApplicationReference;
- (void)setPrimitiveBlockingApplicationReference:(PackageMO*)value;

- (ConditionalItemMO*)primitiveFeaturedItemConditionalReference;
- (void)setPrimitiveFeaturedItemConditionalReference:(ConditionalItemMO*)value;

- (ManifestMO*)primitiveFeaturedItemReference;
- (void)setPrimitiveFeaturedItemReference:(ManifestMO*)value;

- (ConditionalItemMO*)primitiveIncludedManifestConditionalReference;
- (void)setPrimitiveIncludedManifestConditionalReference:(ConditionalItemMO*)value;

- (ConditionalItemMO*)primitiveManagedInstallConditionalReference;
- (void)setPrimitiveManagedInstallConditionalReference:(ConditionalItemMO*)value;

- (ManifestMO*)primitiveManagedInstallReference;
- (void)setPrimitiveManagedInstallReference:(ManifestMO*)value;

- (ConditionalItemMO*)primitiveManagedUninstallConditionalReference;
- (void)setPrimitiveManagedUninstallConditionalReference:(ConditionalItemMO*)value;

- (ManifestMO*)primitiveManagedUninstallReference;
- (void)setPrimitiveManagedUninstallReference:(ManifestMO*)value;

- (ConditionalItemMO*)primitiveManagedUpdateConditionalReference;
- (void)setPrimitiveManagedUpdateConditionalReference:(ConditionalItemMO*)value;

- (ManifestMO*)primitiveManagedUpdateReference;
- (void)setPrimitiveManagedUpdateReference:(ManifestMO*)value;

- (ManifestMO*)primitiveManifestReference;
- (void)setPrimitiveManifestReference:(ManifestMO*)value;

- (ConditionalItemMO*)primitiveOptionalInstallConditionalReference;
- (void)setPrimitiveOptionalInstallConditionalReference:(ConditionalItemMO*)value;

- (ManifestMO*)primitiveOptionalInstallReference;
- (void)setPrimitiveOptionalInstallReference:(ManifestMO*)value;

- (ApplicationMO*)primitiveOriginalApplication;
- (void)setPrimitiveOriginalApplication:(ApplicationMO*)value;

- (ManifestMO*)primitiveOriginalManifest;
- (void)setPrimitiveOriginalManifest:(ManifestMO*)value;

- (ConditionalItemMO*)primitiveOriginalManifestConditionalReference;
- (void)setPrimitiveOriginalManifestConditionalReference:(ConditionalItemMO*)value;

- (PackageMO*)primitiveOriginalPackage;
- (void)setPrimitiveOriginalPackage:(PackageMO*)value;

- (PackageMO*)primitiveRequiresReference;
- (void)setPrimitiveRequiresReference:(PackageMO*)value;

- (PackageMO*)primitiveSupportedArchitectureReference;
- (void)setPrimitiveSupportedArchitectureReference:(PackageMO*)value;

- (PackageMO*)primitiveUpdateForReference;
- (void)setPrimitiveUpdateForReference:(PackageMO*)value;

@end

@interface StringObjectMOAttributes: NSObject 
+ (NSString *)indexInNestedManifest;
+ (NSString *)originalIndex;
+ (NSString *)title;
+ (NSString *)typeString;
@end

@interface StringObjectMORelationships: NSObject
+ (NSString *)blockingApplicationReference;
+ (NSString *)featuredItemConditionalReference;
+ (NSString *)featuredItemReference;
+ (NSString *)includedManifestConditionalReference;
+ (NSString *)managedInstallConditionalReference;
+ (NSString *)managedInstallReference;
+ (NSString *)managedUninstallConditionalReference;
+ (NSString *)managedUninstallReference;
+ (NSString *)managedUpdateConditionalReference;
+ (NSString *)managedUpdateReference;
+ (NSString *)manifestReference;
+ (NSString *)optionalInstallConditionalReference;
+ (NSString *)optionalInstallReference;
+ (NSString *)originalApplication;
+ (NSString *)originalManifest;
+ (NSString *)originalManifestConditionalReference;
+ (NSString *)originalPackage;
+ (NSString *)requiresReference;
+ (NSString *)supportedArchitectureReference;
+ (NSString *)updateForReference;
@end

@interface StringObjectMOFetchedProperties: NSObject
+ (NSString *)manifestsWithSameTitle;
+ (NSString *)packagesWithSameTitle;
@end

NS_ASSUME_NONNULL_END
