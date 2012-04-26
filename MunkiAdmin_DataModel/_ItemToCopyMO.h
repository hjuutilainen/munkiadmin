// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ItemToCopyMO.h instead.

#import <CoreData/CoreData.h>


extern const struct ItemToCopyMOAttributes {
	 NSString *munki_destination_path;
	 NSString *munki_group;
	 NSString *munki_mode;
	 NSString *munki_source_item;
	 NSString *munki_user;
	 NSString *originalIndex;
} ItemToCopyMOAttributes;

extern const struct ItemToCopyMORelationships {
	 NSString *package;
} ItemToCopyMORelationships;

extern const struct ItemToCopyMOFetchedProperties {
} ItemToCopyMOFetchedProperties;

@class PackageMO;








@interface ItemToCopyMOID : NSManagedObjectID {}
@end

@interface _ItemToCopyMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ItemToCopyMOID*)objectID;




@property (nonatomic, retain) NSString* munki_destination_path;


//- (BOOL)validateMunki_destination_path:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString* munki_group;


//- (BOOL)validateMunki_group:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString* munki_mode;


//- (BOOL)validateMunki_mode:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString* munki_source_item;


//- (BOOL)validateMunki_source_item:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString* munki_user;


//- (BOOL)validateMunki_user:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber* originalIndex;


@property int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

//- (BOOL)validateOriginalIndex:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) PackageMO* package;

//- (BOOL)validatePackage:(id*)value_ error:(NSError**)error_;





@end

@interface _ItemToCopyMO (CoreDataGeneratedAccessors)

@end

@interface _ItemToCopyMO (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveMunki_destination_path;
- (void)setPrimitiveMunki_destination_path:(NSString*)value;




- (NSString*)primitiveMunki_group;
- (void)setPrimitiveMunki_group:(NSString*)value;




- (NSString*)primitiveMunki_mode;
- (void)setPrimitiveMunki_mode:(NSString*)value;




- (NSString*)primitiveMunki_source_item;
- (void)setPrimitiveMunki_source_item:(NSString*)value;




- (NSString*)primitiveMunki_user;
- (void)setPrimitiveMunki_user:(NSString*)value;




- (NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(NSNumber*)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;





- (PackageMO*)primitivePackage;
- (void)setPrimitivePackage:(PackageMO*)value;


@end
