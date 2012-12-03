// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CatalogInfoMO.h instead.

#import <CoreData/CoreData.h>


extern const struct CatalogInfoMOAttributes {
	 NSString *indexInManifest;
	 NSString *isEnabledForManifest;
	 NSString *isEnabledForPackage;
	 NSString *originalIndex;
} CatalogInfoMOAttributes;

extern const struct CatalogInfoMORelationships {
	 NSString *catalog;
	 NSString *manifest;
	 NSString *package;
} CatalogInfoMORelationships;

extern const struct CatalogInfoMOFetchedProperties {
} CatalogInfoMOFetchedProperties;

@class CatalogMO;
@class ManifestMO;
@class PackageMO;






@interface CatalogInfoMOID : NSManagedObjectID {}
@end

@interface _CatalogInfoMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CatalogInfoMOID*)objectID;





@property (nonatomic, retain) NSNumber* indexInManifest;



@property int32_t indexInManifestValue;
- (int32_t)indexInManifestValue;
- (void)setIndexInManifestValue:(int32_t)value_;

//- (BOOL)validateIndexInManifest:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* isEnabledForManifest;



@property BOOL isEnabledForManifestValue;
- (BOOL)isEnabledForManifestValue;
- (void)setIsEnabledForManifestValue:(BOOL)value_;

//- (BOOL)validateIsEnabledForManifest:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* isEnabledForPackage;



@property BOOL isEnabledForPackageValue;
- (BOOL)isEnabledForPackageValue;
- (void)setIsEnabledForPackageValue:(BOOL)value_;

//- (BOOL)validateIsEnabledForPackage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* originalIndex;



@property int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

//- (BOOL)validateOriginalIndex:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) CatalogMO *catalog;

//- (BOOL)validateCatalog:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ManifestMO *manifest;

//- (BOOL)validateManifest:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) PackageMO *package;

//- (BOOL)validatePackage:(id*)value_ error:(NSError**)error_;





@end

@interface _CatalogInfoMO (CoreDataGeneratedAccessors)

@end

@interface _CatalogInfoMO (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIndexInManifest;
- (void)setPrimitiveIndexInManifest:(NSNumber*)value;

- (int32_t)primitiveIndexInManifestValue;
- (void)setPrimitiveIndexInManifestValue:(int32_t)value_;




- (NSNumber*)primitiveIsEnabledForManifest;
- (void)setPrimitiveIsEnabledForManifest:(NSNumber*)value;

- (BOOL)primitiveIsEnabledForManifestValue;
- (void)setPrimitiveIsEnabledForManifestValue:(BOOL)value_;




- (NSNumber*)primitiveIsEnabledForPackage;
- (void)setPrimitiveIsEnabledForPackage:(NSNumber*)value;

- (BOOL)primitiveIsEnabledForPackageValue;
- (void)setPrimitiveIsEnabledForPackageValue:(BOOL)value_;




- (NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(NSNumber*)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;





- (CatalogMO*)primitiveCatalog;
- (void)setPrimitiveCatalog:(CatalogMO*)value;



- (ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(ManifestMO*)value;



- (PackageMO*)primitivePackage;
- (void)setPrimitivePackage:(PackageMO*)value;


@end
