// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CategorySourceListItemMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

#import "PackageSourceListItemMO.h"

NS_ASSUME_NONNULL_BEGIN

@class CategoryMO;

@interface CategorySourceListItemMOID : PackageSourceListItemMOID {}
@end

@interface _CategorySourceListItemMO : PackageSourceListItemMO
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CategorySourceListItemMOID *objectID;

@property (nonatomic, strong, nullable) CategoryMO *categoryReference;

@end

@interface _CategorySourceListItemMO (CoreDataGeneratedPrimitiveAccessors)

- (CategoryMO*)primitiveCategoryReference;
- (void)setPrimitiveCategoryReference:(CategoryMO*)value;

@end

@interface CategorySourceListItemMORelationships: NSObject
+ (NSString *)categoryReference;
@end

NS_ASSUME_NONNULL_END
