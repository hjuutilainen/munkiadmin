// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManifestInfoMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class ManifestMO;
@class ManifestMO;

@interface ManifestInfoMOID : NSManagedObjectID {}
@end

@interface _ManifestInfoMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ManifestInfoMOID *objectID;

@property (nonatomic, strong, nullable) NSNumber* isAvailableForEditing;

@property (atomic) BOOL isAvailableForEditingValue;
- (BOOL)isAvailableForEditingValue;
- (void)setIsAvailableForEditingValue:(BOOL)value_;

@property (nonatomic, strong) NSNumber* isEnabledForManifest;

@property (atomic) BOOL isEnabledForManifestValue;
- (BOOL)isEnabledForManifestValue;
- (void)setIsEnabledForManifestValue:(BOOL)value_;

@property (nonatomic, strong, nullable) ManifestMO *manifest;

@property (nonatomic, strong, nullable) ManifestMO *parentManifest;

@end

@interface _ManifestInfoMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSNumber*)primitiveIsAvailableForEditing;
- (void)setPrimitiveIsAvailableForEditing:(nullable NSNumber*)value;

- (BOOL)primitiveIsAvailableForEditingValue;
- (void)setPrimitiveIsAvailableForEditingValue:(BOOL)value_;

- (NSNumber*)primitiveIsEnabledForManifest;
- (void)setPrimitiveIsEnabledForManifest:(NSNumber*)value;

- (BOOL)primitiveIsEnabledForManifestValue;
- (void)setPrimitiveIsEnabledForManifestValue:(BOOL)value_;

- (ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(ManifestMO*)value;

- (ManifestMO*)primitiveParentManifest;
- (void)setPrimitiveParentManifest:(ManifestMO*)value;

@end

@interface ManifestInfoMOAttributes: NSObject 
+ (NSString *)isAvailableForEditing;
+ (NSString *)isEnabledForManifest;
@end

@interface ManifestInfoMORelationships: NSObject
+ (NSString *)manifest;
+ (NSString *)parentManifest;
@end

NS_ASSUME_NONNULL_END
