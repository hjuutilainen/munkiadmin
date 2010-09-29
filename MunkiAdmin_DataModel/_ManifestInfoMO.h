// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManifestInfoMO.h instead.

#import <CoreData/CoreData.h>


@class ManifestMO;
@class ManifestMO;




@interface ManifestInfoMOID : NSManagedObjectID {}
@end

@interface _ManifestInfoMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ManifestInfoMOID*)objectID;



@property (nonatomic, retain) NSNumber *isEnabledForManifest;

@property BOOL isEnabledForManifestValue;
- (BOOL)isEnabledForManifestValue;
- (void)setIsEnabledForManifestValue:(BOOL)value_;

//- (BOOL)validateIsEnabledForManifest:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isAvailableForEditing;

@property BOOL isAvailableForEditingValue;
- (BOOL)isAvailableForEditingValue;
- (void)setIsAvailableForEditingValue:(BOOL)value_;

//- (BOOL)validateIsAvailableForEditing:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ManifestMO* manifest;
//- (BOOL)validateManifest:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) ManifestMO* parentManifest;
//- (BOOL)validateParentManifest:(id*)value_ error:(NSError**)error_;



@end

@interface _ManifestInfoMO (CoreDataGeneratedAccessors)

@end

@interface _ManifestInfoMO (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveIsEnabledForManifest;
- (void)setPrimitiveIsEnabledForManifest:(NSNumber*)value;

- (BOOL)primitiveIsEnabledForManifestValue;
- (void)setPrimitiveIsEnabledForManifestValue:(BOOL)value_;


- (NSNumber*)primitiveIsAvailableForEditing;
- (void)setPrimitiveIsAvailableForEditing:(NSNumber*)value;

- (BOOL)primitiveIsAvailableForEditingValue;
- (void)setPrimitiveIsAvailableForEditingValue:(BOOL)value_;




- (ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(ManifestMO*)value;



- (ManifestMO*)primitiveParentManifest;
- (void)setPrimitiveParentManifest:(ManifestMO*)value;


@end
