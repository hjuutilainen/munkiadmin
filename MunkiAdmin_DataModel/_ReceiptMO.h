// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ReceiptMO.h instead.

#import <CoreData/CoreData.h>


@class PackageMO;







@interface ReceiptMOID : NSManagedObjectID {}
@end

@interface _ReceiptMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ReceiptMOID*)objectID;




@property (nonatomic, retain) NSString *munki_filename;


//- (BOOL)validateMunki_filename:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *munki_installed_size;


@property long long munki_installed_sizeValue;
- (long long)munki_installed_sizeValue;
- (void)setMunki_installed_sizeValue:(long long)value_;

//- (BOOL)validateMunki_installed_size:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *munki_name;


//- (BOOL)validateMunki_name:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *munki_packageid;


//- (BOOL)validateMunki_packageid:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *munki_version;


//- (BOOL)validateMunki_version:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) PackageMO* package;

//- (BOOL)validatePackage:(id*)value_ error:(NSError**)error_;




@end

@interface _ReceiptMO (CoreDataGeneratedAccessors)

@end

@interface _ReceiptMO (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveMunki_filename;
- (void)setPrimitiveMunki_filename:(NSString*)value;




- (NSNumber*)primitiveMunki_installed_size;
- (void)setPrimitiveMunki_installed_size:(NSNumber*)value;

- (long long)primitiveMunki_installed_sizeValue;
- (void)setPrimitiveMunki_installed_sizeValue:(long long)value_;




- (NSString*)primitiveMunki_name;
- (void)setPrimitiveMunki_name:(NSString*)value;




- (NSString*)primitiveMunki_packageid;
- (void)setPrimitiveMunki_packageid:(NSString*)value;




- (NSString*)primitiveMunki_version;
- (void)setPrimitiveMunki_version:(NSString*)value;





- (PackageMO*)primitivePackage;
- (void)setPrimitivePackage:(PackageMO*)value;


@end
