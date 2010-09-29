// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManifestMO.h instead.

#import <CoreData/CoreData.h>


@class CatalogInfoMO;
@class CatalogMO;
@class ApplicationMO;
@class ManifestInfoMO;
@class ApplicationInfoMO;
@class ManifestInfoMO;


@class NSObject;

@interface ManifestMOID : NSManagedObjectID {}
@end

@interface _ManifestMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ManifestMOID*)objectID;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSObject *manifestURL;

//- (BOOL)validateManifestURL:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* catalogInfos;
- (NSMutableSet*)catalogInfosSet;



@property (nonatomic, retain) NSSet* catalogs;
- (NSMutableSet*)catalogsSet;



@property (nonatomic, retain) NSSet* applications;
- (NSMutableSet*)applicationsSet;



@property (nonatomic, retain) NSSet* manifestInfos;
- (NSMutableSet*)manifestInfosSet;



@property (nonatomic, retain) NSSet* applicationInfos;
- (NSMutableSet*)applicationInfosSet;



@property (nonatomic, retain) NSSet* includedManifests;
- (NSMutableSet*)includedManifestsSet;



@end

@interface _ManifestMO (CoreDataGeneratedAccessors)

- (void)addCatalogInfos:(NSSet*)value_;
- (void)removeCatalogInfos:(NSSet*)value_;
- (void)addCatalogInfosObject:(CatalogInfoMO*)value_;
- (void)removeCatalogInfosObject:(CatalogInfoMO*)value_;

- (void)addCatalogs:(NSSet*)value_;
- (void)removeCatalogs:(NSSet*)value_;
- (void)addCatalogsObject:(CatalogMO*)value_;
- (void)removeCatalogsObject:(CatalogMO*)value_;

- (void)addApplications:(NSSet*)value_;
- (void)removeApplications:(NSSet*)value_;
- (void)addApplicationsObject:(ApplicationMO*)value_;
- (void)removeApplicationsObject:(ApplicationMO*)value_;

- (void)addManifestInfos:(NSSet*)value_;
- (void)removeManifestInfos:(NSSet*)value_;
- (void)addManifestInfosObject:(ManifestInfoMO*)value_;
- (void)removeManifestInfosObject:(ManifestInfoMO*)value_;

- (void)addApplicationInfos:(NSSet*)value_;
- (void)removeApplicationInfos:(NSSet*)value_;
- (void)addApplicationInfosObject:(ApplicationInfoMO*)value_;
- (void)removeApplicationInfosObject:(ApplicationInfoMO*)value_;

- (void)addIncludedManifests:(NSSet*)value_;
- (void)removeIncludedManifests:(NSSet*)value_;
- (void)addIncludedManifestsObject:(ManifestInfoMO*)value_;
- (void)removeIncludedManifestsObject:(ManifestInfoMO*)value_;

@end

@interface _ManifestMO (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;


- (NSObject*)primitiveManifestURL;
- (void)setPrimitiveManifestURL:(NSObject*)value;




- (NSMutableSet*)primitiveCatalogInfos;
- (void)setPrimitiveCatalogInfos:(NSMutableSet*)value;



- (NSMutableSet*)primitiveCatalogs;
- (void)setPrimitiveCatalogs:(NSMutableSet*)value;



- (NSMutableSet*)primitiveApplications;
- (void)setPrimitiveApplications:(NSMutableSet*)value;



- (NSMutableSet*)primitiveManifestInfos;
- (void)setPrimitiveManifestInfos:(NSMutableSet*)value;



- (NSMutableSet*)primitiveApplicationInfos;
- (void)setPrimitiveApplicationInfos:(NSMutableSet*)value;



- (NSMutableSet*)primitiveIncludedManifests;
- (void)setPrimitiveIncludedManifests:(NSMutableSet*)value;


@end
