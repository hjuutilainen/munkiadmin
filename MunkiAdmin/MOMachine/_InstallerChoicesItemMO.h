// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallerChoicesItemMO.h instead.

#import <CoreData/CoreData.h>


extern const struct InstallerChoicesItemMOAttributes {
	__unsafe_unretained NSString *munki_attributeSetting;
	__unsafe_unretained NSString *munki_choiceAttribute;
	__unsafe_unretained NSString *munki_choiceIdentifier;
	__unsafe_unretained NSString *originalIndex;
} InstallerChoicesItemMOAttributes;

extern const struct InstallerChoicesItemMORelationships {
	__unsafe_unretained NSString *package;
} InstallerChoicesItemMORelationships;

extern const struct InstallerChoicesItemMOFetchedProperties {
} InstallerChoicesItemMOFetchedProperties;

@class PackageMO;






@interface InstallerChoicesItemMOID : NSManagedObjectID {}
@end

@interface _InstallerChoicesItemMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (InstallerChoicesItemMOID*)objectID;





@property (nonatomic, strong) NSNumber* munki_attributeSetting;



@property BOOL munki_attributeSettingValue;
- (BOOL)munki_attributeSettingValue;
- (void)setMunki_attributeSettingValue:(BOOL)value_;

//- (BOOL)validateMunki_attributeSetting:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* munki_choiceAttribute;



//- (BOOL)validateMunki_choiceAttribute:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* munki_choiceIdentifier;



//- (BOOL)validateMunki_choiceIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* originalIndex;



@property int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

//- (BOOL)validateOriginalIndex:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) PackageMO *package;

//- (BOOL)validatePackage:(id*)value_ error:(NSError**)error_;





@end

@interface _InstallerChoicesItemMO (CoreDataGeneratedAccessors)

@end

@interface _InstallerChoicesItemMO (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveMunki_attributeSetting;
- (void)setPrimitiveMunki_attributeSetting:(NSNumber*)value;

- (BOOL)primitiveMunki_attributeSettingValue;
- (void)setPrimitiveMunki_attributeSettingValue:(BOOL)value_;




- (NSString*)primitiveMunki_choiceAttribute;
- (void)setPrimitiveMunki_choiceAttribute:(NSString*)value;




- (NSString*)primitiveMunki_choiceIdentifier;
- (void)setPrimitiveMunki_choiceIdentifier:(NSString*)value;




- (NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(NSNumber*)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;





- (PackageMO*)primitivePackage;
- (void)setPrimitivePackage:(PackageMO*)value;


@end
