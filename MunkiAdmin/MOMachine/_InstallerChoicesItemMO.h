// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallerChoicesItemMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class PackageMO;

@interface InstallerChoicesItemMOID : NSManagedObjectID {}
@end

@interface _InstallerChoicesItemMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) InstallerChoicesItemMOID *objectID;

@property (nonatomic, strong, nullable) NSNumber* munki_attributeSetting;

@property (atomic) BOOL munki_attributeSettingValue;
- (BOOL)munki_attributeSettingValue;
- (void)setMunki_attributeSettingValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSString* munki_choiceAttribute;

@property (nonatomic, strong, nullable) NSString* munki_choiceIdentifier;

@property (nonatomic, strong, nullable) NSNumber* originalIndex;

@property (atomic) int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

@property (nonatomic, strong, nullable) PackageMO *package;

@end

@interface _InstallerChoicesItemMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSNumber*)primitiveMunki_attributeSetting;
- (void)setPrimitiveMunki_attributeSetting:(nullable NSNumber*)value;

- (BOOL)primitiveMunki_attributeSettingValue;
- (void)setPrimitiveMunki_attributeSettingValue:(BOOL)value_;

- (nullable NSString*)primitiveMunki_choiceAttribute;
- (void)setPrimitiveMunki_choiceAttribute:(nullable NSString*)value;

- (nullable NSString*)primitiveMunki_choiceIdentifier;
- (void)setPrimitiveMunki_choiceIdentifier:(nullable NSString*)value;

- (nullable NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(nullable NSNumber*)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;

- (PackageMO*)primitivePackage;
- (void)setPrimitivePackage:(PackageMO*)value;

@end

@interface InstallerChoicesItemMOAttributes: NSObject 
+ (NSString *)munki_attributeSetting;
+ (NSString *)munki_choiceAttribute;
+ (NSString *)munki_choiceIdentifier;
+ (NSString *)originalIndex;
@end

@interface InstallerChoicesItemMORelationships: NSObject
+ (NSString *)package;
@end

NS_ASSUME_NONNULL_END
