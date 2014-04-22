// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CategoryMO.h instead.

#import <CoreData/CoreData.h>


extern const struct CategoryMOAttributes {
	__unsafe_unretained NSString *title;
} CategoryMOAttributes;

extern const struct CategoryMORelationships {
	__unsafe_unretained NSString *categorySourceListReference;
	__unsafe_unretained NSString *packages;
} CategoryMORelationships;

extern const struct CategoryMOFetchedProperties {
} CategoryMOFetchedProperties;

@class CategorySourceListItemMO;
@class PackageMO;



@interface CategoryMOID : NSManagedObjectID {}
@end

@interface _CategoryMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CategoryMOID*)objectID;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) CategorySourceListItemMO *categorySourceListReference;

//- (BOOL)validateCategorySourceListReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *packages;

- (NSMutableSet*)packagesSet;





@end

@interface _CategoryMO (CoreDataGeneratedAccessors)

- (void)addPackages:(NSSet*)value_;
- (void)removePackages:(NSSet*)value_;
- (void)addPackagesObject:(PackageMO*)value_;
- (void)removePackagesObject:(PackageMO*)value_;

@end

@interface _CategoryMO (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (CategorySourceListItemMO*)primitiveCategorySourceListReference;
- (void)setPrimitiveCategorySourceListReference:(CategorySourceListItemMO*)value;



- (NSMutableSet*)primitivePackages;
- (void)setPrimitivePackages:(NSMutableSet*)value;


@end
