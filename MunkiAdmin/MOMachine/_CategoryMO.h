// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CategoryMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class CategorySourceListItemMO;
@class PackageMO;

@interface CategoryMOID : NSManagedObjectID {}
@end

@interface _CategoryMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CategoryMOID *objectID;

@property (nonatomic, strong, nullable) NSString* title;

@property (nonatomic, strong, nullable) CategorySourceListItemMO *categorySourceListReference;

@property (nonatomic, strong, nullable) NSSet<PackageMO*> *packages;
- (nullable NSMutableSet<PackageMO*>*)packagesSet;

@end

@interface _CategoryMO (PackagesCoreDataGeneratedAccessors)
- (void)addPackages:(NSSet<PackageMO*>*)value_;
- (void)removePackages:(NSSet<PackageMO*>*)value_;
- (void)addPackagesObject:(PackageMO*)value_;
- (void)removePackagesObject:(PackageMO*)value_;

@end

@interface _CategoryMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(nullable NSString*)value;

- (CategorySourceListItemMO*)primitiveCategorySourceListReference;
- (void)setPrimitiveCategorySourceListReference:(CategorySourceListItemMO*)value;

- (NSMutableSet<PackageMO*>*)primitivePackages;
- (void)setPrimitivePackages:(NSMutableSet<PackageMO*>*)value;

@end

@interface CategoryMOAttributes: NSObject 
+ (NSString *)title;
@end

@interface CategoryMORelationships: NSObject
+ (NSString *)categorySourceListReference;
+ (NSString *)packages;
@end

NS_ASSUME_NONNULL_END
