// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ReceiptMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class PackageMO;

@interface ReceiptMOID : NSManagedObjectID {}
@end

@interface _ReceiptMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ReceiptMOID *objectID;

@property (nonatomic, strong, nullable) NSString* munki_filename;

@property (nonatomic, strong, nullable) NSNumber* munki_installed_size;

@property (atomic) int64_t munki_installed_sizeValue;
- (int64_t)munki_installed_sizeValue;
- (void)setMunki_installed_sizeValue:(int64_t)value_;

@property (nonatomic, strong, nullable) NSString* munki_name;

@property (nonatomic, strong, nullable) NSNumber* munki_optional;

@property (atomic) BOOL munki_optionalValue;
- (BOOL)munki_optionalValue;
- (void)setMunki_optionalValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSString* munki_packageid;

@property (nonatomic, strong, nullable) NSString* munki_version;

@property (nonatomic, strong, nullable) NSNumber* originalIndex;

@property (atomic) int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

@property (nonatomic, strong, nullable) PackageMO *package;

@end

@interface _ReceiptMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveMunki_filename;
- (void)setPrimitiveMunki_filename:(nullable NSString*)value;

- (nullable NSNumber*)primitiveMunki_installed_size;
- (void)setPrimitiveMunki_installed_size:(nullable NSNumber*)value;

- (int64_t)primitiveMunki_installed_sizeValue;
- (void)setPrimitiveMunki_installed_sizeValue:(int64_t)value_;

- (nullable NSString*)primitiveMunki_name;
- (void)setPrimitiveMunki_name:(nullable NSString*)value;

- (nullable NSNumber*)primitiveMunki_optional;
- (void)setPrimitiveMunki_optional:(nullable NSNumber*)value;

- (BOOL)primitiveMunki_optionalValue;
- (void)setPrimitiveMunki_optionalValue:(BOOL)value_;

- (nullable NSString*)primitiveMunki_packageid;
- (void)setPrimitiveMunki_packageid:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_version;
- (void)setPrimitiveMunki_version:(nullable NSString*)value;

- (nullable NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(nullable NSNumber*)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;

- (PackageMO*)primitivePackage;
- (void)setPrimitivePackage:(PackageMO*)value;

@end

@interface ReceiptMOAttributes: NSObject 
+ (NSString *)munki_filename;
+ (NSString *)munki_installed_size;
+ (NSString *)munki_name;
+ (NSString *)munki_optional;
+ (NSString *)munki_packageid;
+ (NSString *)munki_version;
+ (NSString *)originalIndex;
@end

@interface ReceiptMORelationships: NSObject
+ (NSString *)package;
@end

NS_ASSUME_NONNULL_END
