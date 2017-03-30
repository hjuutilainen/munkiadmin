// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManagedUpdateMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

#import "ApplicationProxyMO.h"

NS_ASSUME_NONNULL_BEGIN

@class ManifestMO;

@interface ManagedUpdateMOID : ApplicationProxyMOID {}
@end

@interface _ManagedUpdateMO : ApplicationProxyMO
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ManagedUpdateMOID *objectID;

@property (nonatomic, strong, nullable) ManifestMO *manifest;

@end

@interface _ManagedUpdateMO (CoreDataGeneratedPrimitiveAccessors)

- (ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(ManifestMO*)value;

@end

@interface ManagedUpdateMORelationships: NSObject
+ (NSString *)manifest;
@end

NS_ASSUME_NONNULL_END
