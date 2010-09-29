// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ApplicationInfoMO.h instead.

#import <CoreData/CoreData.h>


@class ManifestMO;
@class ApplicationMO;





@interface ApplicationInfoMOID : NSManagedObjectID {}
@end

@interface _ApplicationInfoMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ApplicationInfoMOID*)objectID;



@property (nonatomic, retain) NSNumber *isEnabledForManifest;

@property BOOL isEnabledForManifestValue;
- (BOOL)isEnabledForManifestValue;
- (void)setIsEnabledForManifestValue:(BOOL)value_;

//- (BOOL)validateIsEnabledForManifest:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *munki_name;

//- (BOOL)validateMunki_name:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ManifestMO* manifest;
//- (BOOL)validateManifest:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) ApplicationMO* application;
//- (BOOL)validateApplication:(id*)value_ error:(NSError**)error_;



@end

@interface _ApplicationInfoMO (CoreDataGeneratedAccessors)

@end

@interface _ApplicationInfoMO (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveIsEnabledForManifest;
- (void)setPrimitiveIsEnabledForManifest:(NSNumber*)value;

- (BOOL)primitiveIsEnabledForManifestValue;
- (void)setPrimitiveIsEnabledForManifestValue:(BOOL)value_;


- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;


- (NSString*)primitiveMunki_name;
- (void)setPrimitiveMunki_name:(NSString*)value;




- (ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(ManifestMO*)value;



- (ApplicationMO*)primitiveApplication;
- (void)setPrimitiveApplication:(ApplicationMO*)value;


@end
