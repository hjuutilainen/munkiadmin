// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ItemToCopyMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class PackageMO;

@interface ItemToCopyMOID : NSManagedObjectID {}
@end

@interface _ItemToCopyMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ItemToCopyMOID *objectID;

@property (nonatomic, strong, nullable) NSString* munki_destination_item;

@property (nonatomic, strong, nullable) NSString* munki_destination_path;

@property (nonatomic, strong, nullable) NSString* munki_group;

@property (nonatomic, strong, nullable) NSString* munki_mode;

@property (nonatomic, strong, nullable) NSString* munki_source_item;

@property (nonatomic, strong, nullable) NSString* munki_user;

@property (nonatomic, strong, nullable) NSNumber* originalIndex;

@property (atomic) int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

@property (nonatomic, strong, nullable) PackageMO *package;

@end

@interface _ItemToCopyMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveMunki_destination_item;
- (void)setPrimitiveMunki_destination_item:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_destination_path;
- (void)setPrimitiveMunki_destination_path:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_group;
- (void)setPrimitiveMunki_group:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_mode;
- (void)setPrimitiveMunki_mode:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_source_item;
- (void)setPrimitiveMunki_source_item:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_user;
- (void)setPrimitiveMunki_user:(nullable NSString*)value;

- (nullable NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(nullable NSNumber*)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;

- (PackageMO*)primitivePackage;
- (void)setPrimitivePackage:(PackageMO*)value;

@end

@interface ItemToCopyMOAttributes: NSObject 
+ (NSString *)munki_destination_item;
+ (NSString *)munki_destination_path;
+ (NSString *)munki_group;
+ (NSString *)munki_mode;
+ (NSString *)munki_source_item;
+ (NSString *)munki_user;
+ (NSString *)originalIndex;
@end

@interface ItemToCopyMORelationships: NSObject
+ (NSString *)package;
@end

NS_ASSUME_NONNULL_END
