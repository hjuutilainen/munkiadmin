// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ItemToCopyMO.h instead.

#import <CoreData/CoreData.h>

extern const struct ItemToCopyMOAttributes {
	__unsafe_unretained NSString *munki_destination_item;
	__unsafe_unretained NSString *munki_destination_path;
	__unsafe_unretained NSString *munki_group;
	__unsafe_unretained NSString *munki_mode;
	__unsafe_unretained NSString *munki_source_item;
	__unsafe_unretained NSString *munki_user;
	__unsafe_unretained NSString *originalIndex;
} ItemToCopyMOAttributes;

extern const struct ItemToCopyMORelationships {
	__unsafe_unretained NSString *package;
} ItemToCopyMORelationships;

@class PackageMO;

@interface ItemToCopyMOID : NSManagedObjectID {}
@end

@interface _ItemToCopyMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ItemToCopyMOID* objectID;

@property (nonatomic, strong) NSString* munki_destination_item;

//- (BOOL)validateMunki_destination_item:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_destination_path;

//- (BOOL)validateMunki_destination_path:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_group;

//- (BOOL)validateMunki_group:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_mode;

//- (BOOL)validateMunki_mode:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_source_item;

//- (BOOL)validateMunki_source_item:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_user;

//- (BOOL)validateMunki_user:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* originalIndex;

@property (atomic) int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

//- (BOOL)validateOriginalIndex:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) PackageMO *package;

//- (BOOL)validatePackage:(id*)value_ error:(NSError**)error_;

@end

@interface _ItemToCopyMO (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveMunki_destination_item;
- (void)setPrimitiveMunki_destination_item:(NSString*)value;

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
