// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallerChoicesItemMO.h instead.

#import <CoreData/CoreData.h>


@class PackageMO;






@interface InstallerChoicesItemMOID : NSManagedObjectID {}
@end

@interface _InstallerChoicesItemMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (InstallerChoicesItemMOID*)objectID;




@property (nonatomic, retain) NSNumber *munki_attributeSetting;


@property BOOL munki_attributeSettingValue;
- (BOOL)munki_attributeSettingValue;
- (void)setMunki_attributeSettingValue:(BOOL)value_;

//- (BOOL)validateMunki_attributeSetting:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *munki_choiceAttribute;


//- (BOOL)validateMunki_choiceAttribute:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *munki_choiceIdentifier;


//- (BOOL)validateMunki_choiceIdentifier:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *originalIndex;


@property int originalIndexValue;
- (int)originalIndexValue;
- (void)setOriginalIndexValue:(int)value_;

//- (BOOL)validateOriginalIndex:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) PackageMO* package;

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

- (int)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int)value_;





- (PackageMO*)primitivePackage;
- (void)setPrimitivePackage:(PackageMO*)value;


@end
