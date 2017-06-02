// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManifestMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class ApplicationMO;
@class CatalogInfoMO;
@class CatalogMO;
@class ConditionalItemMO;
@class StringObjectMO;
@class ManifestInfoMO;
@class StringObjectMO;
@class ManagedInstallMO;
@class StringObjectMO;
@class ManagedUninstallMO;
@class StringObjectMO;
@class ManagedUpdateMO;
@class StringObjectMO;
@class ManifestInfoMO;
@class OptionalInstallMO;
@class StringObjectMO;
@class StringObjectMO;

@class NSObject;

@class NSObject;

@class NSObject;

@interface ManifestMOID : NSManagedObjectID {}
@end

@interface _ManifestMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ManifestMOID *objectID;

@property (nonatomic, strong) NSNumber* hasUnstagedChanges;

@property (atomic) BOOL hasUnstagedChangesValue;
- (BOOL)hasUnstagedChangesValue;
- (void)setHasUnstagedChangesValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSString* manifestAdminNotes;

@property (nonatomic, strong, nullable) NSDate* manifestDateCreated;

@property (nonatomic, strong, nullable) NSDate* manifestDateLastOpened;

@property (nonatomic, strong, nullable) NSDate* manifestDateModified;

@property (nonatomic, strong, nullable) NSString* manifestDisplayName;

@property (nonatomic, strong, nullable) id manifestParentDirectoryURL;

@property (nonatomic, strong) id manifestURL;

@property (nonatomic, strong, nullable) NSString* manifestUserName;

@property (nonatomic, strong, nullable) id originalManifest;

@property (nonatomic, strong, nullable) NSString* title;

@property (nonatomic, strong, nullable) NSSet<ApplicationMO*> *applications;
- (nullable NSMutableSet<ApplicationMO*>*)applicationsSet;

@property (nonatomic, strong, nullable) NSSet<CatalogInfoMO*> *catalogInfos;
- (nullable NSMutableSet<CatalogInfoMO*>*)catalogInfosSet;

@property (nonatomic, strong, nullable) NSSet<CatalogMO*> *catalogs;
- (nullable NSMutableSet<CatalogMO*>*)catalogsSet;

@property (nonatomic, strong, nullable) NSSet<ConditionalItemMO*> *conditionalItems;
- (nullable NSMutableSet<ConditionalItemMO*>*)conditionalItemsSet;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *featuredItems;
- (nullable NSMutableSet<StringObjectMO*>*)featuredItemsSet;

@property (nonatomic, strong, nullable) NSSet<ManifestInfoMO*> *includedManifests;
- (nullable NSMutableSet<ManifestInfoMO*>*)includedManifestsSet;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *includedManifestsFaster;
- (nullable NSMutableSet<StringObjectMO*>*)includedManifestsFasterSet;

@property (nonatomic, strong, nullable) NSSet<ManagedInstallMO*> *managedInstalls;
- (nullable NSMutableSet<ManagedInstallMO*>*)managedInstallsSet;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *managedInstallsFaster;
- (nullable NSMutableSet<StringObjectMO*>*)managedInstallsFasterSet;

@property (nonatomic, strong, nullable) NSSet<ManagedUninstallMO*> *managedUninstalls;
- (nullable NSMutableSet<ManagedUninstallMO*>*)managedUninstallsSet;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *managedUninstallsFaster;
- (nullable NSMutableSet<StringObjectMO*>*)managedUninstallsFasterSet;

@property (nonatomic, strong, nullable) NSSet<ManagedUpdateMO*> *managedUpdates;
- (nullable NSMutableSet<ManagedUpdateMO*>*)managedUpdatesSet;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *managedUpdatesFaster;
- (nullable NSMutableSet<StringObjectMO*>*)managedUpdatesFasterSet;

@property (nonatomic, strong, nullable) NSSet<ManifestInfoMO*> *manifestInfos;
- (nullable NSMutableSet<ManifestInfoMO*>*)manifestInfosSet;

@property (nonatomic, strong, nullable) NSSet<OptionalInstallMO*> *optionalInstalls;
- (nullable NSMutableSet<OptionalInstallMO*>*)optionalInstallsSet;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *optionalInstallsFaster;
- (nullable NSMutableSet<StringObjectMO*>*)optionalInstallsFasterSet;

@property (nonatomic, strong, nullable) NSSet<StringObjectMO*> *referencingManifests;
- (nullable NSMutableSet<StringObjectMO*>*)referencingManifestsSet;

@property (nonatomic, readonly, nullable) NSArray *allFeaturedItems;

@property (nonatomic, readonly, nullable) NSArray *allIncludedManifests;

@property (nonatomic, readonly, nullable) NSArray *allManagedInstalls;

@property (nonatomic, readonly, nullable) NSArray *allManagedUninstalls;

@property (nonatomic, readonly, nullable) NSArray *allManagedUpdates;

@property (nonatomic, readonly, nullable) NSArray *allOptionalInstalls;

@property (nonatomic, readonly, nullable) NSArray *allReferencingManifests;

@end

@interface _ManifestMO (ApplicationsCoreDataGeneratedAccessors)
- (void)addApplications:(NSSet<ApplicationMO*>*)value_;
- (void)removeApplications:(NSSet<ApplicationMO*>*)value_;
- (void)addApplicationsObject:(ApplicationMO*)value_;
- (void)removeApplicationsObject:(ApplicationMO*)value_;

@end

@interface _ManifestMO (CatalogInfosCoreDataGeneratedAccessors)
- (void)addCatalogInfos:(NSSet<CatalogInfoMO*>*)value_;
- (void)removeCatalogInfos:(NSSet<CatalogInfoMO*>*)value_;
- (void)addCatalogInfosObject:(CatalogInfoMO*)value_;
- (void)removeCatalogInfosObject:(CatalogInfoMO*)value_;

@end

@interface _ManifestMO (CatalogsCoreDataGeneratedAccessors)
- (void)addCatalogs:(NSSet<CatalogMO*>*)value_;
- (void)removeCatalogs:(NSSet<CatalogMO*>*)value_;
- (void)addCatalogsObject:(CatalogMO*)value_;
- (void)removeCatalogsObject:(CatalogMO*)value_;

@end

@interface _ManifestMO (ConditionalItemsCoreDataGeneratedAccessors)
- (void)addConditionalItems:(NSSet<ConditionalItemMO*>*)value_;
- (void)removeConditionalItems:(NSSet<ConditionalItemMO*>*)value_;
- (void)addConditionalItemsObject:(ConditionalItemMO*)value_;
- (void)removeConditionalItemsObject:(ConditionalItemMO*)value_;

@end

@interface _ManifestMO (FeaturedItemsCoreDataGeneratedAccessors)
- (void)addFeaturedItems:(NSSet<StringObjectMO*>*)value_;
- (void)removeFeaturedItems:(NSSet<StringObjectMO*>*)value_;
- (void)addFeaturedItemsObject:(StringObjectMO*)value_;
- (void)removeFeaturedItemsObject:(StringObjectMO*)value_;

@end

@interface _ManifestMO (IncludedManifestsCoreDataGeneratedAccessors)
- (void)addIncludedManifests:(NSSet<ManifestInfoMO*>*)value_;
- (void)removeIncludedManifests:(NSSet<ManifestInfoMO*>*)value_;
- (void)addIncludedManifestsObject:(ManifestInfoMO*)value_;
- (void)removeIncludedManifestsObject:(ManifestInfoMO*)value_;

@end

@interface _ManifestMO (IncludedManifestsFasterCoreDataGeneratedAccessors)
- (void)addIncludedManifestsFaster:(NSSet<StringObjectMO*>*)value_;
- (void)removeIncludedManifestsFaster:(NSSet<StringObjectMO*>*)value_;
- (void)addIncludedManifestsFasterObject:(StringObjectMO*)value_;
- (void)removeIncludedManifestsFasterObject:(StringObjectMO*)value_;

@end

@interface _ManifestMO (ManagedInstallsCoreDataGeneratedAccessors)
- (void)addManagedInstalls:(NSSet<ManagedInstallMO*>*)value_;
- (void)removeManagedInstalls:(NSSet<ManagedInstallMO*>*)value_;
- (void)addManagedInstallsObject:(ManagedInstallMO*)value_;
- (void)removeManagedInstallsObject:(ManagedInstallMO*)value_;

@end

@interface _ManifestMO (ManagedInstallsFasterCoreDataGeneratedAccessors)
- (void)addManagedInstallsFaster:(NSSet<StringObjectMO*>*)value_;
- (void)removeManagedInstallsFaster:(NSSet<StringObjectMO*>*)value_;
- (void)addManagedInstallsFasterObject:(StringObjectMO*)value_;
- (void)removeManagedInstallsFasterObject:(StringObjectMO*)value_;

@end

@interface _ManifestMO (ManagedUninstallsCoreDataGeneratedAccessors)
- (void)addManagedUninstalls:(NSSet<ManagedUninstallMO*>*)value_;
- (void)removeManagedUninstalls:(NSSet<ManagedUninstallMO*>*)value_;
- (void)addManagedUninstallsObject:(ManagedUninstallMO*)value_;
- (void)removeManagedUninstallsObject:(ManagedUninstallMO*)value_;

@end

@interface _ManifestMO (ManagedUninstallsFasterCoreDataGeneratedAccessors)
- (void)addManagedUninstallsFaster:(NSSet<StringObjectMO*>*)value_;
- (void)removeManagedUninstallsFaster:(NSSet<StringObjectMO*>*)value_;
- (void)addManagedUninstallsFasterObject:(StringObjectMO*)value_;
- (void)removeManagedUninstallsFasterObject:(StringObjectMO*)value_;

@end

@interface _ManifestMO (ManagedUpdatesCoreDataGeneratedAccessors)
- (void)addManagedUpdates:(NSSet<ManagedUpdateMO*>*)value_;
- (void)removeManagedUpdates:(NSSet<ManagedUpdateMO*>*)value_;
- (void)addManagedUpdatesObject:(ManagedUpdateMO*)value_;
- (void)removeManagedUpdatesObject:(ManagedUpdateMO*)value_;

@end

@interface _ManifestMO (ManagedUpdatesFasterCoreDataGeneratedAccessors)
- (void)addManagedUpdatesFaster:(NSSet<StringObjectMO*>*)value_;
- (void)removeManagedUpdatesFaster:(NSSet<StringObjectMO*>*)value_;
- (void)addManagedUpdatesFasterObject:(StringObjectMO*)value_;
- (void)removeManagedUpdatesFasterObject:(StringObjectMO*)value_;

@end

@interface _ManifestMO (ManifestInfosCoreDataGeneratedAccessors)
- (void)addManifestInfos:(NSSet<ManifestInfoMO*>*)value_;
- (void)removeManifestInfos:(NSSet<ManifestInfoMO*>*)value_;
- (void)addManifestInfosObject:(ManifestInfoMO*)value_;
- (void)removeManifestInfosObject:(ManifestInfoMO*)value_;

@end

@interface _ManifestMO (OptionalInstallsCoreDataGeneratedAccessors)
- (void)addOptionalInstalls:(NSSet<OptionalInstallMO*>*)value_;
- (void)removeOptionalInstalls:(NSSet<OptionalInstallMO*>*)value_;
- (void)addOptionalInstallsObject:(OptionalInstallMO*)value_;
- (void)removeOptionalInstallsObject:(OptionalInstallMO*)value_;

@end

@interface _ManifestMO (OptionalInstallsFasterCoreDataGeneratedAccessors)
- (void)addOptionalInstallsFaster:(NSSet<StringObjectMO*>*)value_;
- (void)removeOptionalInstallsFaster:(NSSet<StringObjectMO*>*)value_;
- (void)addOptionalInstallsFasterObject:(StringObjectMO*)value_;
- (void)removeOptionalInstallsFasterObject:(StringObjectMO*)value_;

@end

@interface _ManifestMO (ReferencingManifestsCoreDataGeneratedAccessors)
- (void)addReferencingManifests:(NSSet<StringObjectMO*>*)value_;
- (void)removeReferencingManifests:(NSSet<StringObjectMO*>*)value_;
- (void)addReferencingManifestsObject:(StringObjectMO*)value_;
- (void)removeReferencingManifestsObject:(StringObjectMO*)value_;

@end

@interface _ManifestMO (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveHasUnstagedChanges;
- (void)setPrimitiveHasUnstagedChanges:(NSNumber*)value;

- (BOOL)primitiveHasUnstagedChangesValue;
- (void)setPrimitiveHasUnstagedChangesValue:(BOOL)value_;

- (nullable NSString*)primitiveManifestAdminNotes;
- (void)setPrimitiveManifestAdminNotes:(nullable NSString*)value;

- (nullable NSDate*)primitiveManifestDateCreated;
- (void)setPrimitiveManifestDateCreated:(nullable NSDate*)value;

- (nullable NSDate*)primitiveManifestDateLastOpened;
- (void)setPrimitiveManifestDateLastOpened:(nullable NSDate*)value;

- (nullable NSDate*)primitiveManifestDateModified;
- (void)setPrimitiveManifestDateModified:(nullable NSDate*)value;

- (nullable NSString*)primitiveManifestDisplayName;
- (void)setPrimitiveManifestDisplayName:(nullable NSString*)value;

- (nullable id)primitiveManifestParentDirectoryURL;
- (void)setPrimitiveManifestParentDirectoryURL:(nullable id)value;

- (id)primitiveManifestURL;
- (void)setPrimitiveManifestURL:(id)value;

- (nullable NSString*)primitiveManifestUserName;
- (void)setPrimitiveManifestUserName:(nullable NSString*)value;

- (nullable id)primitiveOriginalManifest;
- (void)setPrimitiveOriginalManifest:(nullable id)value;

- (nullable NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(nullable NSString*)value;

- (NSMutableSet<ApplicationMO*>*)primitiveApplications;
- (void)setPrimitiveApplications:(NSMutableSet<ApplicationMO*>*)value;

- (NSMutableSet<CatalogInfoMO*>*)primitiveCatalogInfos;
- (void)setPrimitiveCatalogInfos:(NSMutableSet<CatalogInfoMO*>*)value;

- (NSMutableSet<CatalogMO*>*)primitiveCatalogs;
- (void)setPrimitiveCatalogs:(NSMutableSet<CatalogMO*>*)value;

- (NSMutableSet<ConditionalItemMO*>*)primitiveConditionalItems;
- (void)setPrimitiveConditionalItems:(NSMutableSet<ConditionalItemMO*>*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveFeaturedItems;
- (void)setPrimitiveFeaturedItems:(NSMutableSet<StringObjectMO*>*)value;

- (NSMutableSet<ManifestInfoMO*>*)primitiveIncludedManifests;
- (void)setPrimitiveIncludedManifests:(NSMutableSet<ManifestInfoMO*>*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveIncludedManifestsFaster;
- (void)setPrimitiveIncludedManifestsFaster:(NSMutableSet<StringObjectMO*>*)value;

- (NSMutableSet<ManagedInstallMO*>*)primitiveManagedInstalls;
- (void)setPrimitiveManagedInstalls:(NSMutableSet<ManagedInstallMO*>*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveManagedInstallsFaster;
- (void)setPrimitiveManagedInstallsFaster:(NSMutableSet<StringObjectMO*>*)value;

- (NSMutableSet<ManagedUninstallMO*>*)primitiveManagedUninstalls;
- (void)setPrimitiveManagedUninstalls:(NSMutableSet<ManagedUninstallMO*>*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveManagedUninstallsFaster;
- (void)setPrimitiveManagedUninstallsFaster:(NSMutableSet<StringObjectMO*>*)value;

- (NSMutableSet<ManagedUpdateMO*>*)primitiveManagedUpdates;
- (void)setPrimitiveManagedUpdates:(NSMutableSet<ManagedUpdateMO*>*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveManagedUpdatesFaster;
- (void)setPrimitiveManagedUpdatesFaster:(NSMutableSet<StringObjectMO*>*)value;

- (NSMutableSet<ManifestInfoMO*>*)primitiveManifestInfos;
- (void)setPrimitiveManifestInfos:(NSMutableSet<ManifestInfoMO*>*)value;

- (NSMutableSet<OptionalInstallMO*>*)primitiveOptionalInstalls;
- (void)setPrimitiveOptionalInstalls:(NSMutableSet<OptionalInstallMO*>*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveOptionalInstallsFaster;
- (void)setPrimitiveOptionalInstallsFaster:(NSMutableSet<StringObjectMO*>*)value;

- (NSMutableSet<StringObjectMO*>*)primitiveReferencingManifests;
- (void)setPrimitiveReferencingManifests:(NSMutableSet<StringObjectMO*>*)value;

@end

@interface ManifestMOAttributes: NSObject 
+ (NSString *)hasUnstagedChanges;
+ (NSString *)manifestAdminNotes;
+ (NSString *)manifestDateCreated;
+ (NSString *)manifestDateLastOpened;
+ (NSString *)manifestDateModified;
+ (NSString *)manifestDisplayName;
+ (NSString *)manifestParentDirectoryURL;
+ (NSString *)manifestURL;
+ (NSString *)manifestUserName;
+ (NSString *)originalManifest;
+ (NSString *)title;
@end

@interface ManifestMORelationships: NSObject
+ (NSString *)applications;
+ (NSString *)catalogInfos;
+ (NSString *)catalogs;
+ (NSString *)conditionalItems;
+ (NSString *)featuredItems;
+ (NSString *)includedManifests;
+ (NSString *)includedManifestsFaster;
+ (NSString *)managedInstalls;
+ (NSString *)managedInstallsFaster;
+ (NSString *)managedUninstalls;
+ (NSString *)managedUninstallsFaster;
+ (NSString *)managedUpdates;
+ (NSString *)managedUpdatesFaster;
+ (NSString *)manifestInfos;
+ (NSString *)optionalInstalls;
+ (NSString *)optionalInstallsFaster;
+ (NSString *)referencingManifests;
@end

@interface ManifestMOFetchedProperties: NSObject
+ (NSString *)allFeaturedItems;
+ (NSString *)allIncludedManifests;
+ (NSString *)allManagedInstalls;
+ (NSString *)allManagedUninstalls;
+ (NSString *)allManagedUpdates;
+ (NSString *)allOptionalInstalls;
+ (NSString *)allReferencingManifests;
@end

NS_ASSUME_NONNULL_END
