// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManagedInstallMO.h instead.

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

@interface ManagedInstallMOID : ApplicationProxyMOID {}
@end

@interface _ManagedInstallMO : ApplicationProxyMO
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ManagedInstallMOID *objectID;

@property (nonatomic, strong, nullable) ManifestMO *manifest;

@end

@interface _ManagedInstallMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(nullable ManifestMO*)value;

@end

@interface ManagedInstallMORelationships: NSObject
+ (NSString *)manifest;
@end

NS_ASSUME_NONNULL_END
