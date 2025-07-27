// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManifestCatalogSourceListItemMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

#import "ManifestSourceListItemMO.h"

NS_ASSUME_NONNULL_BEGIN

@class CatalogMO;

@interface ManifestCatalogSourceListItemMOID : ManifestSourceListItemMOID {}
@end

@interface _ManifestCatalogSourceListItemMO : ManifestSourceListItemMO
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ManifestCatalogSourceListItemMOID *objectID;

@property (nonatomic, strong, nullable) CatalogMO *catalogReference;

@end

@interface _ManifestCatalogSourceListItemMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable CatalogMO*)primitiveCatalogReference;
- (void)setPrimitiveCatalogReference:(nullable CatalogMO*)value;

@end

@interface ManifestCatalogSourceListItemMORelationships: NSObject
+ (NSString *)catalogReference;
@end

NS_ASSUME_NONNULL_END
