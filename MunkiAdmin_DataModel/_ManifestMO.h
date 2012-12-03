// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManifestMO.h instead.

#import <CoreData/CoreData.h>


extern const struct ManifestMOAttributes {
	 NSString *manifestURL;
	 NSString *originalManifest;
	 NSString *title;
} ManifestMOAttributes;

extern const struct ManifestMORelationships {
	 NSString *applications;
	 NSString *catalogInfos;
	 NSString *catalogs;
	 NSString *conditionalItems;
	 NSString *includedManifests;
	 NSString *includedManifestsFaster;
	 NSString *managedInstalls;
	 NSString *managedInstallsFaster;
	 NSString *managedUninstalls;
	 NSString *managedUninstallsFaster;
	 NSString *managedUpdates;
	 NSString *managedUpdatesFaster;
	 NSString *manifestInfos;
	 NSString *optionalInstalls;
	 NSString *optionalInstallsFaster;
} ManifestMORelationships;

extern const struct ManifestMOFetchedProperties {
	 NSString *allIncludedManifests;
	 NSString *allManagedInstalls;
	 NSString *allManagedUninstalls;
	 NSString *allManagedUpdates;
	 NSString *allOptionalInstalls;
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





@property (nonatomic, retain) id manifestURL;



//- (BOOL)validateManifestURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id originalManifest;



//- (BOOL)validateOriginalManifest:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet *applications;

- (NSMutableSet*)applicationsSet;




@property (nonatomic, retain) NSSet *catalogInfos;

- (NSMutableSet*)catalogInfosSet;




@property (nonatomic, retain) NSSet *catalogs;

- (NSMutableSet*)catalogsSet;




@property (nonatomic, retain) NSSet *conditionalItems;

- (NSMutableSet*)conditionalItemsSet;




@property (nonatomic, retain) NSSet *includedManifests;

- (NSMutableSet*)includedManifestsSet;




@property (nonatomic, retain) NSSet *includedManifestsFaster;

- (NSMutableSet*)includedManifestsFasterSet;




@property (nonatomic, retain) NSSet *managedInstalls;

- (NSMutableSet*)managedInstallsSet;




@property (nonatomic, retain) NSSet *managedInstallsFaster;

- (NSMutableSet*)managedInstallsFasterSet;




@property (nonatomic, retain) NSSet *managedUninstalls;

- (NSMutableSet*)managedUninstallsSet;




@property (nonatomic, retain) NSSet *managedUninstallsFaster;

- (NSMutableSet*)managedUninstallsFasterSet;




@property (nonatomic, retain) NSSet *managedUpdates;

- (NSMutableSet*)managedUpdatesSet;




@property (nonatomic, retain) NSSet *managedUpdatesFaster;

- (NSMutableSet*)managedUpdatesFasterSet;




@property (nonatomic, retain) NSSet *manifestInfos;

- (NSMutableSet*)manifestInfosSet;




@property (nonatomic, retain) NSSet *optionalInstalls;

- (NSMutableSet*)optionalInstallsSet;




@property (nonatomic, retain) NSSet *optionalInstallsFaster;

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
