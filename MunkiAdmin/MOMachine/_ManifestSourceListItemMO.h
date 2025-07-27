// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManifestSourceListItemMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class ManifestSourceListItemMO;
@class ManifestSourceListItemMO;

@class NSObject;

@class NSObject;

@class NSObject;

@interface ManifestSourceListItemMOID : NSManagedObjectID {}
@end

@interface _ManifestSourceListItemMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ManifestSourceListItemMOID *objectID;

@property (nonatomic, strong, nullable) id filterPredicate;

@property (nonatomic, strong, nullable) id icon;

@property (nonatomic, strong) NSNumber* isGroupItem;

@property (atomic) BOOL isGroupItemValue;
- (BOOL)isGroupItemValue;
- (void)setIsGroupItemValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSString* itemType;

@property (nonatomic, strong, nullable) NSNumber* originalIndex;

@property (atomic) int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

@property (nonatomic, strong, nullable) id sortDescriptors;

@property (nonatomic, strong, nullable) NSString* title;

@property (nonatomic, strong, nullable) NSSet<ManifestSourceListItemMO*> *children;
- (nullable NSMutableSet<ManifestSourceListItemMO*>*)childrenSet;

@property (nonatomic, strong, nullable) ManifestSourceListItemMO *parent;

@end

@interface _ManifestSourceListItemMO (ChildrenCoreDataGeneratedAccessors)
- (void)addChildren:(NSSet<ManifestSourceListItemMO*>*)value_;
- (void)removeChildren:(NSSet<ManifestSourceListItemMO*>*)value_;
- (void)addChildrenObject:(ManifestSourceListItemMO*)value_;
- (void)removeChildrenObject:(ManifestSourceListItemMO*)value_;

@end

@interface _ManifestSourceListItemMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable id)primitiveFilterPredicate;
- (void)setPrimitiveFilterPredicate:(nullable id)value;

- (nullable id)primitiveIcon;
- (void)setPrimitiveIcon:(nullable id)value;

- (NSNumber*)primitiveIsGroupItem;
- (void)setPrimitiveIsGroupItem:(NSNumber*)value;

- (BOOL)primitiveIsGroupItemValue;
- (void)setPrimitiveIsGroupItemValue:(BOOL)value_;

- (nullable NSString*)primitiveItemType;
- (void)setPrimitiveItemType:(nullable NSString*)value;

- (nullable NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(nullable NSNumber*)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;

- (nullable id)primitiveSortDescriptors;
- (void)setPrimitiveSortDescriptors:(nullable id)value;

- (nullable NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(nullable NSString*)value;

- (NSMutableSet<ManifestSourceListItemMO*>*)primitiveChildren;
- (void)setPrimitiveChildren:(NSMutableSet<ManifestSourceListItemMO*>*)value;

- (nullable ManifestSourceListItemMO*)primitiveParent;
- (void)setPrimitiveParent:(nullable ManifestSourceListItemMO*)value;

@end

@interface ManifestSourceListItemMOAttributes: NSObject 
+ (NSString *)filterPredicate;
+ (NSString *)icon;
+ (NSString *)isGroupItem;
+ (NSString *)itemType;
+ (NSString *)originalIndex;
+ (NSString *)sortDescriptors;
+ (NSString *)title;
@end

@interface ManifestSourceListItemMORelationships: NSObject
+ (NSString *)children;
+ (NSString *)parent;
@end

NS_ASSUME_NONNULL_END
