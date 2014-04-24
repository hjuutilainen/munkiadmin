// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DeveloperMO.h instead.

#import <CoreData/CoreData.h>


extern const struct DeveloperMOAttributes {
	__unsafe_unretained NSString *title;
} DeveloperMOAttributes;

extern const struct DeveloperMORelationships {
	__unsafe_unretained NSString *developerSourceListReference;
	__unsafe_unretained NSString *packages;
} DeveloperMORelationships;

extern const struct DeveloperMOFetchedProperties {
} DeveloperMOFetchedProperties;

@class DeveloperSourceListItemMO;
@class PackageMO;



@interface DeveloperMOID : NSManagedObjectID {}
@end

@interface _DeveloperMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DeveloperMOID*)objectID;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) DeveloperSourceListItemMO *developerSourceListReference;

//- (BOOL)validateDeveloperSourceListReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *packages;

- (NSMutableSet*)packagesSet;





@end

@interface _DeveloperMO (CoreDataGeneratedAccessors)

- (void)addPackages:(NSSet*)value_;
- (void)removePackages:(NSSet*)value_;
- (void)addPackagesObject:(PackageMO*)value_;
- (void)removePackagesObject:(PackageMO*)value_;

@end

@interface _DeveloperMO (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (DeveloperSourceListItemMO*)primitiveDeveloperSourceListReference;
- (void)setPrimitiveDeveloperSourceListReference:(DeveloperSourceListItemMO*)value;



- (NSMutableSet*)primitivePackages;
- (void)setPrimitivePackages:(NSMutableSet*)value;


@end
