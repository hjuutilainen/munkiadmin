// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to IconImageMO.h instead.

#import <CoreData/CoreData.h>

extern const struct IconImageMOAttributes {
	__unsafe_unretained NSString *fileSHA256Checksum;
	__unsafe_unretained NSString *imageRepresentation;
	__unsafe_unretained NSString *originalURL;
} IconImageMOAttributes;

extern const struct IconImageMORelationships {
	__unsafe_unretained NSString *packages;
} IconImageMORelationships;

@class PackageMO;

@class NSObject;

@class NSObject;

@interface IconImageMOID : NSManagedObjectID {}
@end

@interface _IconImageMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) IconImageMOID* objectID;

@property (nonatomic, strong) NSString* fileSHA256Checksum;

//- (BOOL)validateFileSHA256Checksum:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id imageRepresentation;

//- (BOOL)validateImageRepresentation:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id originalURL;

//- (BOOL)validateOriginalURL:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *packages;

- (NSMutableSet*)packagesSet;

@end

@interface _IconImageMO (PackagesCoreDataGeneratedAccessors)
- (void)addPackages:(NSSet*)value_;
- (void)removePackages:(NSSet*)value_;
- (void)addPackagesObject:(PackageMO*)value_;
- (void)removePackagesObject:(PackageMO*)value_;

@end

@interface _IconImageMO (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveFileSHA256Checksum;
- (void)setPrimitiveFileSHA256Checksum:(NSString*)value;

- (id)primitiveImageRepresentation;
- (void)setPrimitiveImageRepresentation:(id)value;

- (id)primitiveOriginalURL;
- (void)setPrimitiveOriginalURL:(id)value;

- (NSMutableSet*)primitivePackages;
- (void)setPrimitivePackages:(NSMutableSet*)value;

@end
