// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConditionalItemMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class ConditionalItemMO;
@class StringObjectMO;
@class StringObjectMO;
@class StringObjectMO;
@class StringObjectMO;
@class StringObjectMO;
@class ManifestMO;
@class StringObjectMO;
@class ConditionalItemMO;
@class StringObjectMO;

@interface ConditionalItemMOID : NSManagedObjectID {}
@end

@interface _ConditionalItemMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ConditionalItemMOID *objectID;

@property (nonatomic, strong, nullable) NSString* munki_condition;

@property (nonatomic, strong, nullable) NSNumber* originalIndex;

@property (atomic) int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

@property (nonatomic, strong, nullable) NSSet<ConditionalItemMO*> *children;
- (nullable NSMutableSet<ConditionalItemMO*>*)childrenSet;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *featuredItems;
- (nullable NSMutableSet<StringObjectMO*>*)featuredItemsSet;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *includedManifests;
- (nullable NSMutableSet<StringObjectMO*>*)includedManifestsSet;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *managedInstalls;
- (nullable NSMutableSet<StringObjectMO*>*)managedInstallsSet;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *managedUninstalls;
- (nullable NSMutableSet<StringObjectMO*>*)managedUninstallsSet;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *managedUpdates;
- (nullable NSMutableSet<StringObjectMO*>*)managedUpdatesSet;

@property (nonatomic, strong, nullable) ManifestMO *manifest;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *optionalInstalls;
- (nullable NSMutableSet<StringObjectMO*>*)optionalInstallsSet;

@property (nonatomic, strong, nullable) ConditionalItemMO *parent;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *referencingManifests;
- (nullable NSMutableSet<StringObjectMO*>*)referencingManifestsSet;

@end

@interface _ConditionalItemMO (ChildrenCoreDataGeneratedAccessors)
- (void)addChildren:(NSSet<ConditionalItemMO*>*)value_;
- (void)removeChildren:(NSSet<ConditionalItemMO*>*)value_;
- (void)addChildrenObject:(ConditionalItemMO*)value_;
- (void)removeChildrenObject:(ConditionalItemMO*)value_;

@end

@interface _ConditionalItemMO (FeaturedItemsCoreDataGeneratedAccessors)
- (void)addFeaturedItems:(NSSet<StringObjectMO*>*)value_;
- (void)removeFeaturedItems:(NSSet<StringObjectMO*>*)value_;
- (void)addFeaturedItemsObject:(StringObjectMO*)value_;
- (void)removeFeaturedItemsObject:(StringObjectMO*)value_;

@end

@interface _ConditionalItemMO (IncludedManifestsCoreDataGeneratedAccessors)
- (void)addIncludedManifests:(NSSet<StringObjectMO*>*)value_;
- (void)removeIncludedManifests:(NSSet<StringObjectMO*>*)value_;
- (void)addIncludedManifestsObject:(StringObjectMO*)value_;
- (void)removeIncludedManifestsObject:(StringObjectMO*)value_;

@end

@interface _ConditionalItemMO (ManagedInstallsCoreDataGeneratedAccessors)
- (void)addManagedInstalls:(NSSet<StringObjectMO*>*)value_;
- (void)removeManagedInstalls:(NSSet<StringObjectMO*>*)value_;
- (void)addManagedInstallsObject:(StringObjectMO*)value_;
- (void)removeManagedInstallsObject:(StringObjectMO*)value_;

@end

@interface _ConditionalItemMO (ManagedUninstallsCoreDataGeneratedAccessors)
- (void)addManagedUninstalls:(NSSet<StringObjectMO*>*)value_;
- (void)removeManagedUninstalls:(NSSet<StringObjectMO*>*)value_;
- (void)addManagedUninstallsObject:(StringObjectMO*)value_;
- (void)removeManagedUninstallsObject:(StringObjectMO*)value_;

@end

@interface _ConditionalItemMO (ManagedUpdatesCoreDataGeneratedAccessors)
- (void)addManagedUpdates:(NSSet<StringObjectMO*>*)value_;
- (void)removeManagedUpdates:(NSSet<StringObjectMO*>*)value_;
- (void)addManagedUpdatesObject:(StringObjectMO*)value_;
- (void)removeManagedUpdatesObject:(StringObjectMO*)value_;

@end

@interface _ConditionalItemMO (OptionalInstallsCoreDataGeneratedAccessors)
- (void)addOptionalInstalls:(NSSet<StringObjectMO*>*)value_;
- (void)removeOptionalInstalls:(NSSet<StringObjectMO*>*)value_;
- (void)addOptionalInstallsObject:(StringObjectMO*)value_;
- (void)removeOptionalInstallsObject:(StringObjectMO*)value_;

@end

@interface _ConditionalItemMO (ReferencingManifestsCoreDataGeneratedAccessors)
- (void)addReferencingManifests:(NSSet<StringObjectMO*>*)value_;
- (void)removeReferencingManifests:(NSSet<StringObjectMO*>*)value_;
- (void)addReferencingManifestsObject:(StringObjectMO*)value_;
- (void)removeReferencingManifestsObject:(StringObjectMO*)value_;

@end

@interface _ConditionalItemMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveMunki_condition;
- (void)setPrimitiveMunki_condition:(nullable NSString*)value;

- (nullable NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(nullable NSNumber*)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;

- (NSMutableSet<ConditionalItemMO*>*)primitiveChildren;
- (void)setPrimitiveChildren:(NSMutableSet<ConditionalItemMO*>*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveFeaturedItems;
- (void)setPrimitiveFeaturedItems:(NSMutableSet<StringObjectMO*>*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveIncludedManifests;
- (void)setPrimitiveIncludedManifests:(NSMutableSet<StringObjectMO*>*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveManagedInstalls;
- (void)setPrimitiveManagedInstalls:(NSMutableSet<StringObjectMO*>*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveManagedUninstalls;
- (void)setPrimitiveManagedUninstalls:(NSMutableSet<StringObjectMO*>*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveManagedUpdates;
- (void)setPrimitiveManagedUpdates:(NSMutableSet<StringObjectMO*>*)value;

- (ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(ManifestMO*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveOptionalInstalls;
- (void)setPrimitiveOptionalInstalls:(NSMutableSet<StringObjectMO*>*)value;

- (ConditionalItemMO*)primitiveParent;
- (void)setPrimitiveParent:(ConditionalItemMO*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveReferencingManifests;
- (void)setPrimitiveReferencingManifests:(NSMutableSet<StringObjectMO*>*)value;

@end

@interface ConditionalItemMOAttributes: NSObject 
+ (NSString *)munki_condition;
+ (NSString *)originalIndex;
@end

@interface ConditionalItemMORelationships: NSObject
+ (NSString *)children;
+ (NSString *)featuredItems;
+ (NSString *)includedManifests;
+ (NSString *)managedInstalls;
+ (NSString *)managedUninstalls;
+ (NSString *)managedUpdates;
+ (NSString *)manifest;
+ (NSString *)optionalInstalls;
+ (NSString *)parent;
+ (NSString *)referencingManifests;
@end

NS_ASSUME_NONNULL_END
