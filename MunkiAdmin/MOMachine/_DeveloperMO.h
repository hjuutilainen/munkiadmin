// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DeveloperMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class DeveloperSourceListItemMO;
@class PackageMO;

@interface DeveloperMOID : NSManagedObjectID {}
@end

@interface _DeveloperMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) DeveloperMOID *objectID;

@property (nonatomic, strong, nullable) NSString* title;

@property (nonatomic, strong, nullable) DeveloperSourceListItemMO *developerSourceListReference;

@property (nonatomic, strong, nullable) NSSet<PackageMO*> *packages;
- (nullable NSMutableSet<PackageMO*>*)packagesSet;

@end

@interface _DeveloperMO (PackagesCoreDataGeneratedAccessors)
- (void)addPackages:(NSSet<PackageMO*>*)value_;
- (void)removePackages:(NSSet<PackageMO*>*)value_;
- (void)addPackagesObject:(PackageMO*)value_;
- (void)removePackagesObject:(PackageMO*)value_;

@end

@interface _DeveloperMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(nullable NSString*)value;

- (DeveloperSourceListItemMO*)primitiveDeveloperSourceListReference;
- (void)setPrimitiveDeveloperSourceListReference:(DeveloperSourceListItemMO*)value;

- (NSMutableSet<PackageMO*>*)primitivePackages;
- (void)setPrimitivePackages:(NSMutableSet<PackageMO*>*)value;

@end

@interface DeveloperMOAttributes: NSObject 
+ (NSString *)title;
@end

@interface DeveloperMORelationships: NSObject
+ (NSString *)developerSourceListReference;
+ (NSString *)packages;
@end

NS_ASSUME_NONNULL_END
