// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ReceiptMO.h instead.

#import <CoreData/CoreData.h>

extern const struct ReceiptMOAttributes {
	__unsafe_unretained NSString *munki_filename;
	__unsafe_unretained NSString *munki_installed_size;
	__unsafe_unretained NSString *munki_name;
	__unsafe_unretained NSString *munki_optional;
	__unsafe_unretained NSString *munki_packageid;
	__unsafe_unretained NSString *munki_version;
	__unsafe_unretained NSString *originalIndex;
} ReceiptMOAttributes;

extern const struct ReceiptMORelationships {
	__unsafe_unretained NSString *package;
} ReceiptMORelationships;

@class PackageMO;

@interface ReceiptMOID : NSManagedObjectID {}
@end

@interface _ReceiptMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ReceiptMOID* objectID;

@property (nonatomic, strong) NSString* munki_filename;

//- (BOOL)validateMunki_filename:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* munki_installed_size;

@property (atomic) int64_t munki_installed_sizeValue;
- (int64_t)munki_installed_sizeValue;
- (void)setMunki_installed_sizeValue:(int64_t)value_;

//- (BOOL)validateMunki_installed_size:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_name;

//- (BOOL)validateMunki_name:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* munki_optional;

@property (atomic) BOOL munki_optionalValue;
- (BOOL)munki_optionalValue;
- (void)setMunki_optionalValue:(BOOL)value_;

//- (BOOL)validateMunki_optional:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_packageid;

//- (BOOL)validateMunki_packageid:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* munki_version;

//- (BOOL)validateMunki_version:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* originalIndex;

@property (atomic) int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

//- (BOOL)validateOriginalIndex:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) PackageMO *package;

//- (BOOL)validatePackage:(id*)value_ error:(NSError**)error_;

@end

@interface _ReceiptMO (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveMunki_filename;
- (void)setPrimitiveMunki_filename:(NSString*)value;

- (NSNumber*)primitiveMunki_installed_size;
- (void)setPrimitiveMunki_installed_size:(NSNumber*)value;

- (int64_t)primitiveMunki_installed_sizeValue;
- (void)setPrimitiveMunki_installed_sizeValue:(int64_t)value_;

- (NSString*)primitiveMunki_name;
- (void)setPrimitiveMunki_name:(NSString*)value;

- (NSNumber*)primitiveMunki_optional;
- (void)setPrimitiveMunki_optional:(NSNumber*)value;

- (BOOL)primitiveMunki_optionalValue;
- (void)setPrimitiveMunki_optionalValue:(BOOL)value_;

- (NSString*)primitiveMunki_packageid;
- (void)setPrimitiveMunki_packageid:(NSString*)value;

- (NSString*)primitiveMunki_version;
- (void)setPrimitiveMunki_version:(NSString*)value;

- (NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(NSNumber*)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;

- (PackageMO*)primitivePackage;
- (void)setPrimitivePackage:(PackageMO*)value;

@end
