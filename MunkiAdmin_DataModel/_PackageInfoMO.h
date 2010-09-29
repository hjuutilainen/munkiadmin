// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PackageInfoMO.h instead.

#import <CoreData/CoreData.h>


@class PackageMO;
@class CatalogMO;




@interface PackageInfoMOID : NSManagedObjectID {}
@end

@interface _PackageInfoMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PackageInfoMOID*)objectID;



@property (nonatomic, retain) NSNumber *isEnabledForCatalog;

@property BOOL isEnabledForCatalogValue;
- (BOOL)isEnabledForCatalogValue;
- (void)setIsEnabledForCatalogValue:(BOOL)value_;

//- (BOOL)validateIsEnabledForCatalog:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) PackageMO* package;
//- (BOOL)validatePackage:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) CatalogMO* catalog;
//- (BOOL)validateCatalog:(id*)value_ error:(NSError**)error_;



@end

@interface _PackageInfoMO (CoreDataGeneratedAccessors)

@end

@interface _PackageInfoMO (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveIsEnabledForCatalog;
- (void)setPrimitiveIsEnabledForCatalog:(NSNumber*)value;

- (BOOL)primitiveIsEnabledForCatalogValue;
- (void)setPrimitiveIsEnabledForCatalogValue:(BOOL)value_;


- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (PackageMO*)primitivePackage;
- (void)setPrimitivePackage:(PackageMO*)value;



- (CatalogMO*)primitiveCatalog;
- (void)setPrimitiveCatalog:(CatalogMO*)value;


@end
