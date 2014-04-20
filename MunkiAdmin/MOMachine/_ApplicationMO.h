// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ApplicationMO.h instead.

#import <CoreData/CoreData.h>


extern const struct ApplicationMOAttributes {
	__unsafe_unretained NSString *munki_description;
	__unsafe_unretained NSString *munki_display_name;
	__unsafe_unretained NSString *munki_name;
} ApplicationMOAttributes;

extern const struct ApplicationMORelationships {
	__unsafe_unretained NSString *applicationProxies;
	__unsafe_unretained NSString *latestPackage;
	__unsafe_unretained NSString *manifests;
	__unsafe_unretained NSString *packages;
	__unsafe_unretained NSString *referencingStringObjects;
} ApplicationMORelationships;

extern const struct ApplicationMOFetchedProperties {
} ApplicationMOFetchedProperties;

@class ApplicationProxyMO;
@class PackageMO;
@class ManifestMO;
@class PackageMO;
@class StringObjectMO;





@interface ApplicationMOID : NSManagedObjectID {}
@end

@interface _ApplicationMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ApplicationMOID*)objectID;





@property (nonatomic, strong) NSString* munki_description;



//- (BOOL)validateMunki_description:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* munki_display_name;



//- (BOOL)validateMunki_display_name:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* munki_name;



//- (BOOL)validateMunki_name:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *applicationProxies;

- (NSMutableSet*)applicationProxiesSet;




@property (nonatomic, strong) PackageMO *latestPackage;

//- (BOOL)validateLatestPackage:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *manifests;

- (NSMutableSet*)manifestsSet;




@property (nonatomic, strong) NSSet *packages;

- (NSMutableSet*)packagesSet;




@property (nonatomic, strong) NSSet *referencingStringObjects;

- (NSMutableSet*)referencingStringObjectsSet;





@end

@interface _ApplicationMO (CoreDataGeneratedAccessors)

- (void)addApplicationProxies:(NSSet*)value_;
- (void)removeApplicationProxies:(NSSet*)value_;
- (void)addApplicationProxiesObject:(ApplicationProxyMO*)value_;
- (void)removeApplicationProxiesObject:(ApplicationProxyMO*)value_;

- (void)addManifests:(NSSet*)value_;
- (void)removeManifests:(NSSet*)value_;
- (void)addManifestsObject:(ManifestMO*)value_;
- (void)removeManifestsObject:(ManifestMO*)value_;

- (void)addPackages:(NSSet*)value_;
- (void)removePackages:(NSSet*)value_;
- (void)addPackagesObject:(PackageMO*)value_;
- (void)removePackagesObject:(PackageMO*)value_;

- (void)addReferencingStringObjects:(NSSet*)value_;
- (void)removeReferencingStringObjects:(NSSet*)value_;
- (void)addReferencingStringObjectsObject:(StringObjectMO*)value_;
- (void)removeReferencingStringObjectsObject:(StringObjectMO*)value_;

@end

@interface _ApplicationMO (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveMunki_description;
- (void)setPrimitiveMunki_description:(NSString*)value;




- (NSString*)primitiveMunki_display_name;
- (void)setPrimitiveMunki_display_name:(NSString*)value;




- (NSString*)primitiveMunki_name;
- (void)setPrimitiveMunki_name:(NSString*)value;





- (NSMutableSet*)primitiveApplicationProxies;
- (void)setPrimitiveApplicationProxies:(NSMutableSet*)value;



- (PackageMO*)primitiveLatestPackage;
- (void)setPrimitiveLatestPackage:(PackageMO*)value;



- (NSMutableSet*)primitiveManifests;
- (void)setPrimitiveManifests:(NSMutableSet*)value;



- (NSMutableSet*)primitivePackages;
- (void)setPrimitivePackages:(NSMutableSet*)value;



- (NSMutableSet*)primitiveReferencingStringObjects;
- (void)setPrimitiveReferencingStringObjects:(NSMutableSet*)value;


@end
