// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManifestMO.h instead.

#import <CoreData/CoreData.h>


extern const struct ManifestMOAttributes {
	__unsafe_unretained NSString *hasUnstagedChanges;
	__unsafe_unretained NSString *manifestURL;
	__unsafe_unretained NSString *originalManifest;
	__unsafe_unretained NSString *title;
} ManifestMOAttributes;

extern const struct ManifestMORelationships {
	__unsafe_unretained NSString *applications;
	__unsafe_unretained NSString *catalogInfos;
	__unsafe_unretained NSString *catalogs;
	__unsafe_unretained NSString *conditionalItems;
	__unsafe_unretained NSString *includedManifests;
	__unsafe_unretained NSString *includedManifestsFaster;
	__unsafe_unretained NSString *managedInstalls;
	__unsafe_unretained NSString *managedInstallsFaster;
	__unsafe_unretained NSString *managedUninstalls;
	__unsafe_unretained NSString *managedUninstallsFaster;
	__unsafe_unretained NSString *managedUpdates;
	__unsafe_unretained NSString *managedUpdatesFaster;
	__unsafe_unretained NSString *manifestInfos;
	__unsafe_unretained NSString *optionalInstalls;
	__unsafe_unretained NSString *optionalInstallsFaster;
} ManifestMORelationships;

extern const struct ManifestMOFetchedProperties {
	__unsafe_unretained NSString *allIncludedManifests;
	__unsafe_unretained NSString *allManagedInstalls;
	__unsafe_unretained NSString *allManagedUninstalls;
	__unsafe_unretained NSString *allManagedUpdates;
	__unsafe_unretained NSString *allOptionalInstalls;
} ManifestMOFetchedProperties;

@class ApplicationMO;
@class CatalogInfoMO;
@class CatalogMO;
@class ConditionalItemMO;
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


@class NSObject;
@class NSObject;


@interface ManifestMOID : NSManagedObjectID {}
@end

@interface _ManifestMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ManifestMOID*)objectID;





@property (nonatomic, strong) NSNumber* hasUnstagedChanges;



@property BOOL hasUnstagedChangesValue;
- (BOOL)hasUnstagedChangesValue;
- (void)setHasUnstagedChangesValue:(BOOL)value_;

//- (BOOL)validateHasUnstagedChanges:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id manifestURL;



//- (BOOL)validateManifestURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id originalManifest;



//- (BOOL)validateOriginalManifest:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *applications;

- (NSMutableSet*)applicationsSet;




@property (nonatomic, strong) NSSet *catalogInfos;

- (NSMutableSet*)catalogInfosSet;




@property (nonatomic, strong) NSSet *catalogs;

- (NSMutableSet*)catalogsSet;




@property (nonatomic, strong) NSSet *conditionalItems;

- (NSMutableSet*)conditionalItemsSet;




@property (nonatomic, strong) NSSet *includedManifests;

- (NSMutableSet*)includedManifestsSet;




@property (nonatomic, strong) NSSet *includedManifestsFaster;

- (NSMutableSet*)includedManifestsFasterSet;




@property (nonatomic, strong) NSSet *managedInstalls;

- (NSMutableSet*)managedInstallsSet;




@property (nonatomic, strong) NSSet *managedInstallsFaster;

- (NSMutableSet*)managedInstallsFasterSet;




@property (nonatomic, strong) NSSet *managedUninstalls;

- (NSMutableSet*)managedUninstallsSet;




@property (nonatomic, strong) NSSet *managedUninstallsFaster;

- (NSMutableSet*)managedUninstallsFasterSet;




@property (nonatomic, strong) NSSet *managedUpdates;

- (NSMutableSet*)managedUpdatesSet;




@property (nonatomic, strong) NSSet *managedUpdatesFaster;

- (NSMutableSet*)managedUpdatesFasterSet;




@property (nonatomic, strong) NSSet *manifestInfos;

- (NSMutableSet*)manifestInfosSet;




@property (nonatomic, strong) NSSet *optionalInstalls;

- (NSMutableSet*)optionalInstallsSet;




@property (nonatomic, strong) NSSet *optionalInstallsFaster;

- (NSMutableSet*)optionalInstallsFasterSet;




@property (nonatomic, readonly) NSArray *allIncludedManifests;

@property (nonatomic, readonly) NSArray *allManagedInstalls;

@property (nonatomic, readonly) NSArray *allManagedUninstalls;

@property (nonatomic, readonly) NSArray *allManagedUpdates;

@property (nonatomic, readonly) NSArray *allOptionalInstalls;


@end

@interface _ManifestMO (CoreDataGeneratedAccessors)

- (void)addApplications:(NSSet*)value_;
- (void)removeApplications:(NSSet*)value_;
- (void)addApplicationsObject:(ApplicationMO*)value_;
- (void)removeApplicationsObject:(ApplicationMO*)value_;

- (void)addCatalogInfos:(NSSet*)value_;
- (void)removeCatalogInfos:(NSSet*)value_;
- (void)addCatalogInfosObject:(CatalogInfoMO*)value_;
- (void)removeCatalogInfosObject:(CatalogInfoMO*)value_;

- (void)addCatalogs:(NSSet*)value_;
- (void)removeCatalogs:(NSSet*)value_;
- (void)addCatalogsObject:(CatalogMO*)value_;
- (void)removeCatalogsObject:(CatalogMO*)value_;

- (void)addConditionalItems:(NSSet*)value_;
- (void)removeConditionalItems:(NSSet*)value_;
- (void)addConditionalItemsObject:(ConditionalItemMO*)value_;
- (void)removeConditionalItemsObject:(ConditionalItemMO*)value_;

- (void)addIncludedManifests:(NSSet*)value_;
- (void)removeIncludedManifests:(NSSet*)value_;
- (void)addIncludedManifestsObject:(ManifestInfoMO*)value_;
- (void)removeIncludedManifestsObject:(ManifestInfoMO*)value_;

- (void)addIncludedManifestsFaster:(NSSet*)value_;
- (void)removeIncludedManifestsFaster:(NSSet*)value_;
- (void)addIncludedManifestsFasterObject:(StringObjectMO*)value_;
- (void)removeIncludedManifestsFasterObject:(StringObjectMO*)value_;

- (void)addManagedInstalls:(NSSet*)value_;
- (void)removeManagedInstalls:(NSSet*)value_;
- (void)addManagedInstallsObject:(ManagedInstallMO*)value_;
- (void)removeManagedInstallsObject:(ManagedInstallMO*)value_;

- (void)addManagedInstallsFaster:(NSSet*)value_;
- (void)removeManagedInstallsFaster:(NSSet*)value_;
- (void)addManagedInstallsFasterObject:(StringObjectMO*)value_;
- (void)removeManagedInstallsFasterObject:(StringObjectMO*)value_;

- (void)addManagedUninstalls:(NSSet*)value_;
- (void)removeManagedUninstalls:(NSSet*)value_;
- (void)addManagedUninstallsObject:(ManagedUninstallMO*)value_;
- (void)removeManagedUninstallsObject:(ManagedUninstallMO*)value_;

- (void)addManagedUninstallsFaster:(NSSet*)value_;
- (void)removeManagedUninstallsFaster:(NSSet*)value_;
- (void)addManagedUninstallsFasterObject:(StringObjectMO*)value_;
- (void)removeManagedUninstallsFasterObject:(StringObjectMO*)value_;

- (void)addManagedUpdates:(NSSet*)value_;
- (void)removeManagedUpdates:(NSSet*)value_;
- (void)addManagedUpdatesObject:(ManagedUpdateMO*)value_;
- (void)removeManagedUpdatesObject:(ManagedUpdateMO*)value_;

- (void)addManagedUpdatesFaster:(NSSet*)value_;
- (void)removeManagedUpdatesFaster:(NSSet*)value_;
- (void)addManagedUpdatesFasterObject:(StringObjectMO*)value_;
- (void)removeManagedUpdatesFasterObject:(StringObjectMO*)value_;

- (void)addManifestInfos:(NSSet*)value_;
- (void)removeManifestInfos:(NSSet*)value_;
- (void)addManifestInfosObject:(ManifestInfoMO*)value_;
- (void)removeManifestInfosObject:(ManifestInfoMO*)value_;

- (void)addOptionalInstalls:(NSSet*)value_;
- (void)removeOptionalInstalls:(NSSet*)value_;
- (void)addOptionalInstallsObject:(OptionalInstallMO*)value_;
- (void)removeOptionalInstallsObject:(OptionalInstallMO*)value_;

- (void)addOptionalInstallsFaster:(NSSet*)value_;
- (void)removeOptionalInstallsFaster:(NSSet*)value_;
- (void)addOptionalInstallsFasterObject:(StringObjectMO*)value_;
- (void)removeOptionalInstallsFasterObject:(StringObjectMO*)value_;

@end

@interface _ManifestMO (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveHasUnstagedChanges;
- (void)setPrimitiveHasUnstagedChanges:(NSNumber*)value;

- (BOOL)primitiveHasUnstagedChangesValue;
- (void)setPrimitiveHasUnstagedChangesValue:(BOOL)value_;




- (id)primitiveManifestURL;
- (void)setPrimitiveManifestURL:(id)value;




- (id)primitiveOriginalManifest;
- (void)setPrimitiveOriginalManifest:(id)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (NSMutableSet*)primitiveApplications;
- (void)setPrimitiveApplications:(NSMutableSet*)value;



- (NSMutableSet*)primitiveCatalogInfos;
- (void)setPrimitiveCatalogInfos:(NSMutableSet*)value;



- (NSMutableSet*)primitiveCatalogs;
- (void)setPrimitiveCatalogs:(NSMutableSet*)value;



- (NSMutableSet*)primitiveConditionalItems;
- (void)setPrimitiveConditionalItems:(NSMutableSet*)value;



- (NSMutableSet*)primitiveIncludedManifests;
- (void)setPrimitiveIncludedManifests:(NSMutableSet*)value;



- (NSMutableSet*)primitiveIncludedManifestsFaster;
- (void)setPrimitiveIncludedManifestsFaster:(NSMutableSet*)value;



- (NSMutableSet*)primitiveManagedInstalls;
- (void)setPrimitiveManagedInstalls:(NSMutableSet*)value;



- (NSMutableSet*)primitiveManagedInstallsFaster;
- (void)setPrimitiveManagedInstallsFaster:(NSMutableSet*)value;



- (NSMutableSet*)primitiveManagedUninstalls;
- (void)setPrimitiveManagedUninstalls:(NSMutableSet*)value;



- (NSMutableSet*)primitiveManagedUninstallsFaster;
- (void)setPrimitiveManagedUninstallsFaster:(NSMutableSet*)value;



- (NSMutableSet*)primitiveManagedUpdates;
- (void)setPrimitiveManagedUpdates:(NSMutableSet*)value;



- (NSMutableSet*)primitiveManagedUpdatesFaster;
- (void)setPrimitiveManagedUpdatesFaster:(NSMutableSet*)value;



- (NSMutableSet*)primitiveManifestInfos;
- (void)setPrimitiveManifestInfos:(NSMutableSet*)value;



- (NSMutableSet*)primitiveOptionalInstalls;
- (void)setPrimitiveOptionalInstalls:(NSMutableSet*)value;



- (NSMutableSet*)primitiveOptionalInstallsFaster;
- (void)setPrimitiveOptionalInstallsFaster:(NSMutableSet*)value;


@end
