// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OptionalInstallMO.h instead.

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

@interface OptionalInstallMOID : ApplicationProxyMOID {}
@end

@interface _OptionalInstallMO : ApplicationProxyMO
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) OptionalInstallMOID *objectID;

@property (nonatomic, strong, nullable) ManifestMO *manifest;

@end

@interface _OptionalInstallMO (CoreDataGeneratedPrimitiveAccessors)

- (ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(ManifestMO*)value;

@end

@interface OptionalInstallMORelationships: NSObject
+ (NSString *)manifest;
@end

NS_ASSUME_NONNULL_END
