// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CategorySourceListItemMO.h instead.

#import <CoreData/CoreData.h>
#import "PackageSourceListItemMO.h"

extern const struct CategorySourceListItemMOAttributes {
} CategorySourceListItemMOAttributes;

extern const struct CategorySourceListItemMORelationships {
	__unsafe_unretained NSString *categoryReference;
} CategorySourceListItemMORelationships;

extern const struct CategorySourceListItemMOFetchedProperties {
} CategorySourceListItemMOFetchedProperties;

@class CategoryMO;


@interface CategorySourceListItemMOID : NSManagedObjectID {}
@end

@interface _CategorySourceListItemMO : PackageSourceListItemMO {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CategorySourceListItemMOID*)objectID;





@property (nonatomic, strong) CategoryMO *categoryReference;

//- (BOOL)validateCategoryReference:(id*)value_ error:(NSError**)error_;





@end

@interface _CategorySourceListItemMO (CoreDataGeneratedAccessors)

@end

@interface _CategorySourceListItemMO (CoreDataGeneratedPrimitiveAccessors)



- (CategoryMO*)primitiveCategoryReference;
- (void)setPrimitiveCategoryReference:(CategoryMO*)value;


@end
