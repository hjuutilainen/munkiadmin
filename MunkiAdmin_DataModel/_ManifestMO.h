// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManifestMO.h instead.

#import <CoreData/CoreData.h>


@class ApplicationMO;
@class ManagedInstallMO;
@class ManagedUninstallMO;
@class OptionalInstallMO;
@class CatalogMO;
@class ManifestInfoMO;
@class ManagedUpdateMO;
@class ManifestInfoMO;
@class CatalogInfoMO;

@class NSObject;

@class NSObject;

@interface ManifestMOID : NSManagedObjectID {}
@end

@interface _ManifestMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ManifestMOID*)objectID;



@property (nonatomic, retain) NSObject *originalManifest;

//- (BOOL)validateOriginalManifest:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSObject *manifestURL;

//- (BOOL)validateManifestURL:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* applications;
- (NSMutableSet*)applicationsSet;



@property (nonatomic, retain) NSSet* managedInstalls;
- (NSMutableSet*)managedInstallsSet;



@property (nonatomic, retain) NSSet* managedUninstalls;
- (NSMutableSet*)managedUninstallsSet;



@property (nonatomic, retain) NSSet* optionalInstalls;
- (NSMutableSet*)optionalInstallsSet;



@property (nonatomic, retain) NSSet* catalogs;
- (NSMutableSet*)catalogsSet;



@property (nonatomic, retain) NSSet* includedManifests;
- (NSMutableSet*)includedManifestsSet;



@property (nonatomic, retain) NSSet* managedUpdates;
- (NSMutableSet*)managedUpdatesSet;



@property (nonatomic, retain) NSSet* manifestInfos;
- (NSMutableSet*)manifestInfosSet;



@property (nonatomic, retain) NSSet* catalogInfos;
- (NSMutableSet*)catalogInfosSet;




@end

@interface _ManifestMO (CoreDataGeneratedAccessors)

- (void)addApplications:(NSSet*)value_;
- (void)removeApplications:(NSSet*)value_;
- (void)addApplicationsObject:(ApplicationMO*)value_;
- (void)removeApplicationsObject:(ApplicationMO*)value_;

- (void)addManagedInstalls:(NSSet*)value_;
- (void)removeManagedInstalls:(NSSet*)value_;
- (void)addManagedInstallsObject:(ManagedInstallMO*)value_;
- (void)removeManagedInstallsObject:(ManagedInstallMO*)value_;

- (void)addManagedUninstalls:(NSSet*)value_;
- (void)removeManagedUninstalls:(NSSet*)value_;
- (void)addManagedUninstallsObject:(ManagedUninstallMO*)value_;
- (void)removeManagedUninstallsObject:(ManagedUninstallMO*)value_;

- (void)addOptionalInstalls:(NSSet*)value_;
- (void)removeOptionalInstalls:(NSSet*)value_;
- (void)addOptionalInstallsObject:(OptionalInstallMO*)value_;
- (void)removeOptionalInstallsObject:(OptionalInstallMO*)value_;

- (void)addCatalogs:(NSSet*)value_;
- (void)removeCatalogs:(NSSet*)value_;
- (void)addCatalogsObject:(CatalogMO*)value_;
- (void)removeCatalogsObject:(CatalogMO*)value_;

- (void)addIncludedManifests:(NSSet*)value_;
- (void)removeIncludedManifests:(NSSet*)value_;
- (void)addIncludedManifestsObject:(ManifestInfoMO*)value_;
- (void)removeIncludedManifestsObject:(ManifestInfoMO*)value_;

- (void)addManagedUpdates:(NSSet*)value_;
- (void)removeManagedUpdates:(NSSet*)value_;
- (void)addManagedUpdatesObject:(ManagedUpdateMO*)value_;
- (void)removeManagedUpdatesObject:(ManagedUpdateMO*)value_;

- (void)addManifestInfos:(NSSet*)value_;
- (void)removeManifestInfos:(NSSet*)value_;
- (void)addManifestInfosObject:(ManifestInfoMO*)value_;
- (void)removeManifestInfosObject:(ManifestInfoMO*)value_;

- (void)addCatalogInfos:(NSSet*)value_;
- (void)removeCatalogInfos:(NSSet*)value_;
- (void)addCatalogInfosObject:(CatalogInfoMO*)value_;
- (void)removeCatalogInfosObject:(CatalogInfoMO*)value_;

@end

@interface _ManifestMO (CoreDataGeneratedPrimitiveAccessors)

- (NSObject*)primitiveOriginalManifest;
- (void)setPrimitiveOriginalManifest:(NSObject*)value;


- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;


- (NSObject*)primitiveManifestURL;
- (void)setPrimitiveManifestURL:(NSObject*)value;




- (NSMutableSet*)primitiveApplications;
- (void)setPrimitiveApplications:(NSMutableSet*)value;



- (NSMutableSet*)primitiveManagedInstalls;
- (void)setPrimitiveManagedInstalls:(NSMutableSet*)value;



- (NSMutableSet*)primitiveManagedUninstalls;
- (void)setPrimitiveManagedUninstalls:(NSMutableSet*)value;



- (NSMutableSet*)primitiveOptionalInstalls;
- (void)setPrimitiveOptionalInstalls:(NSMutableSet*)value;



- (NSMutableSet*)primitiveCatalogs;
- (void)setPrimitiveCatalogs:(NSMutableSet*)value;



- (NSMutableSet*)primitiveIncludedManifests;
- (void)setPrimitiveIncludedManifests:(NSMutableSet*)value;



- (NSMutableSet*)primitiveManagedUpdates;
- (void)setPrimitiveManagedUpdates:(NSMutableSet*)value;



- (NSMutableSet*)primitiveManifestInfos;
- (void)setPrimitiveManifestInfos:(NSMutableSet*)value;



- (NSMutableSet*)primitiveCatalogInfos;
- (void)setPrimitiveCatalogInfos:(NSMutableSet*)value;


@end
