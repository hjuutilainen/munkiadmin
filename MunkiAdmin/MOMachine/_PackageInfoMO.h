// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PackageInfoMO.h instead.

#import <CoreData/CoreData.h>


extern const struct PackageInfoMOAttributes {
	__unsafe_unretained NSString *isEnabledForCatalog;
	__unsafe_unretained NSString *originalIndex;
	__unsafe_unretained NSString *title;
} PackageInfoMOAttributes;

extern const struct PackageInfoMORelationships {
	__unsafe_unretained NSString *catalog;
	__unsafe_unretained NSString *package;
} PackageInfoMORelationships;

extern const struct PackageInfoMOFetchedProperties {
} PackageInfoMOFetchedProperties;

@class CatalogMO;
@class PackageMO;





@interface PackageInfoMOID : NSManagedObjectID {}
@end

@interface _PackageInfoMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PackageInfoMOID*)objectID;





@property (nonatomic, strong) NSNumber* isEnabledForCatalog;



@property BOOL isEnabledForCatalogValue;
- (BOOL)isEnabledForCatalogValue;
- (void)setIsEnabledForCatalogValue:(BOOL)value_;

//- (BOOL)validateIsEnabledForCatalog:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* originalIndex;



@property int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

//- (BOOL)validateOriginalIndex:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) CatalogMO *catalog;

//- (BOOL)validateCatalog:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) PackageMO *package;

//- (BOOL)validatePackage:(id*)value_ error:(NSError**)error_;





@end

@interface _PackageInfoMO (CoreDataGeneratedAccessors)

@end

@interface _PackageInfoMO (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIsEnabledForCatalog;
- (void)setPrimitiveIsEnabledForCatalog:(NSNumber*)value;

- (BOOL)primitiveIsEnabledForCatalogValue;
- (void)setPrimitiveIsEnabledForCatalogValue:(BOOL)value_;




- (NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(NSNumber*)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (CatalogMO*)primitiveCatalog;
- (void)setPrimitiveCatalog:(CatalogMO*)value;



- (PackageMO*)primitivePackage;
- (void)setPrimitivePackage:(PackageMO*)value;


@end
