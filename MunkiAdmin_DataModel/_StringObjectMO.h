// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StringObjectMO.h instead.

#import <CoreData/CoreData.h>


@class PackageMO;
@class ManifestMO;
@class ManifestMO;
@class ManifestMO;
@class ManifestMO;
@class ManifestMO;
@class ApplicationMO;
@class PackageMO;
@class PackageMO;
@class PackageMO;






@interface StringObjectMOID : NSManagedObjectID {}
@end

@interface _StringObjectMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (StringObjectMOID*)objectID;




@property (nonatomic, retain) NSNumber *indexInNestedManifest;


@property int indexInNestedManifestValue;
- (int)indexInNestedManifestValue;
- (void)setIndexInNestedManifestValue:(int)value_;

//- (BOOL)validateIndexInNestedManifest:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *originalIndex;


@property int originalIndexValue;
- (int)originalIndexValue;
- (void)setOriginalIndexValue:(int)value_;

//- (BOOL)validateOriginalIndex:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *title;


//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *typeString;


//- (BOOL)validateTypeString:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) PackageMO* blockingApplicationReference;

//- (BOOL)validateBlockingApplicationReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ManifestMO* managedInstallReference;

//- (BOOL)validateManagedInstallReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ManifestMO* managedUninstallReference;

//- (BOOL)validateManagedUninstallReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ManifestMO* managedUpdateReference;

//- (BOOL)validateManagedUpdateReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ManifestMO* manifestReference;

//- (BOOL)validateManifestReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ManifestMO* optionalInstallReference;

//- (BOOL)validateOptionalInstallReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ApplicationMO* originalApplication;

//- (BOOL)validateOriginalApplication:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) PackageMO* originalPackage;

//- (BOOL)validateOriginalPackage:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) PackageMO* requiresReference;

//- (BOOL)validateRequiresReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) PackageMO* updateForReference;

//- (BOOL)validateUpdateForReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, readonly) NSArray *manifestsWithSameTitle;

@property (nonatomic, readonly) NSArray *packagesWithSameTitle;

@end

@interface _StringObjectMO (CoreDataGeneratedAccessors)

@end

@interface _StringObjectMO (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIndexInNestedManifest;
- (void)setPrimitiveIndexInNestedManifest:(NSNumber*)value;

- (int)primitiveIndexInNestedManifestValue;
- (void)setPrimitiveIndexInNestedManifestValue:(int)value_;




- (NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(NSNumber*)value;

- (int)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveTypeString;
- (void)setPrimitiveTypeString:(NSString*)value;





- (PackageMO*)primitiveBlockingApplicationReference;
- (void)setPrimitiveBlockingApplicationReference:(PackageMO*)value;



- (ManifestMO*)primitiveManagedInstallReference;
- (void)setPrimitiveManagedInstallReference:(ManifestMO*)value;



- (ManifestMO*)primitiveManagedUninstallReference;
- (void)setPrimitiveManagedUninstallReference:(ManifestMO*)value;



- (ManifestMO*)primitiveManagedUpdateReference;
- (void)setPrimitiveManagedUpdateReference:(ManifestMO*)value;



- (ManifestMO*)primitiveManifestReference;
- (void)setPrimitiveManifestReference:(ManifestMO*)value;



- (ManifestMO*)primitiveOptionalInstallReference;
- (void)setPrimitiveOptionalInstallReference:(ManifestMO*)value;



- (ApplicationMO*)primitiveOriginalApplication;
- (void)setPrimitiveOriginalApplication:(ApplicationMO*)value;



- (PackageMO*)primitiveOriginalPackage;
- (void)setPrimitiveOriginalPackage:(PackageMO*)value;



- (PackageMO*)primitiveRequiresReference;
- (void)setPrimitiveRequiresReference:(PackageMO*)value;



- (PackageMO*)primitiveUpdateForReference;
- (void)setPrimitiveUpdateForReference:(PackageMO*)value;


@end
