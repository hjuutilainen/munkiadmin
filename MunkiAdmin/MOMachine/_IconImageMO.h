// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to IconImageMO.h instead.

#import <CoreData/CoreData.h>


extern const struct IconImageMOAttributes {
	__unsafe_unretained NSString *image;
	__unsafe_unretained NSString *originalURL;
} IconImageMOAttributes;

extern const struct IconImageMORelationships {
	__unsafe_unretained NSString *packages;
} IconImageMORelationships;

extern const struct IconImageMOFetchedProperties {
} IconImageMOFetchedProperties;

@class PackageMO;

@class NSObject;
@class NSObject;

@interface IconImageMOID : NSManagedObjectID {}
@end

@interface _IconImageMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (IconImageMOID*)objectID;





@property (nonatomic, strong) id image;



//- (BOOL)validateImage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id originalURL;



//- (BOOL)validateOriginalURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *packages;

- (NSMutableSet*)packagesSet;





@end

@interface _IconImageMO (CoreDataGeneratedAccessors)

- (void)addPackages:(NSSet*)value_;
- (void)removePackages:(NSSet*)value_;
- (void)addPackagesObject:(PackageMO*)value_;
- (void)removePackagesObject:(PackageMO*)value_;

@end

@interface _IconImageMO (CoreDataGeneratedPrimitiveAccessors)


- (id)primitiveImage;
- (void)setPrimitiveImage:(id)value;




- (id)primitiveOriginalURL;
- (void)setPrimitiveOriginalURL:(id)value;





- (NSMutableSet*)primitivePackages;
- (void)setPrimitivePackages:(NSMutableSet*)value;


@end
