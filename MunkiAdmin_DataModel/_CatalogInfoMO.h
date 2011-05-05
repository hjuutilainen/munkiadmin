// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CatalogInfoMO.h instead.

#import <CoreData/CoreData.h>


@class ManifestMO;
@class PackageMO;
@class CatalogMO;





@interface CatalogInfoMOID : NSManagedObjectID {}
@end

@interface _CatalogInfoMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CatalogInfoMOID*)objectID;



@property (nonatomic, retain) NSNumber *isEnabledForManifest;

@property BOOL isEnabledForManifestValue;
- (BOOL)isEnabledForManifestValue;
- (void)setIsEnabledForManifestValue:(BOOL)value_;

//- (BOOL)validateIsEnabledForManifest:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isEnabledForPackage;

@property BOOL isEnabledForPackageValue;
- (BOOL)isEnabledForPackageValue;
- (void)setIsEnabledForPackageValue:(BOOL)value_;

//- (BOOL)validateIsEnabledForPackage:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *originalIndex;

@property int originalIndexValue;
- (int)originalIndexValue;
- (void)setOriginalIndexValue:(int)value_;

//- (BOOL)validateOriginalIndex:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ManifestMO* manifest;
//- (BOOL)validateManifest:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) PackageMO* package;
//- (BOOL)validatePackage:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) CatalogMO* catalog;
//- (BOOL)validateCatalog:(id*)value_ error:(NSError**)error_;




@end

@interface _CatalogInfoMO (CoreDataGeneratedAccessors)

@end

@interface _CatalogInfoMO (CoreDataGeneratedPrimitiveAccessors)


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

- (int)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int)value_;





- (ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(ManifestMO*)value;



- (PackageMO*)primitivePackage;
- (void)setPrimitivePackage:(PackageMO*)value;



- (CatalogMO*)primitiveCatalog;
- (void)setPrimitiveCatalog:(CatalogMO*)value;


@end
