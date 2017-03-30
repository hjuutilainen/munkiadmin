// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DeveloperSourceListItemMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

#import "PackageSourceListItemMO.h"

NS_ASSUME_NONNULL_BEGIN

@class DeveloperMO;

@interface DeveloperSourceListItemMOID : PackageSourceListItemMOID {}
@end

@interface _DeveloperSourceListItemMO : PackageSourceListItemMO
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) DeveloperSourceListItemMOID *objectID;

@property (nonatomic, strong, nullable) DeveloperMO *developerReference;

@end

@interface _DeveloperSourceListItemMO (CoreDataGeneratedPrimitiveAccessors)

- (DeveloperMO*)primitiveDeveloperReference;
- (void)setPrimitiveDeveloperReference:(DeveloperMO*)value;

@end

@interface DeveloperSourceListItemMORelationships: NSObject
+ (NSString *)developerReference;
@end

NS_ASSUME_NONNULL_END
