// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StringObjectMO.h instead.

#import <CoreData/CoreData.h>


extern const struct StringObjectMOAttributes {
	 NSString *indexInNestedManifest;
	 NSString *originalIndex;
	 NSString *title;
	 NSString *typeString;
} StringObjectMOAttributes;

extern const struct StringObjectMORelationships {
	 NSString *blockingApplicationReference;
	 NSString *includedManifestConditionalReference;
	 NSString *managedInstallConditionalReference;
	 NSString *managedInstallReference;
	 NSString *managedUninstallConditionalReference;
	 NSString *managedUninstallReference;
	 NSString *managedUpdateConditionalReference;
	 NSString *managedUpdateReference;
	 NSString *manifestReference;
	 NSString *optionalInstallConditionalReference;
	 NSString *optionalInstallReference;
	 NSString *originalApplication;
	 NSString *originalPackage;
	 NSString *requiresReference;
	 NSString *supportedArchitectureReference;
	 NSString *updateForReference;
} StringObjectMORelationships;

extern const struct StringObjectMOFetchedProperties {
	 NSString *manifestsWithSameTitle;
	 NSString *packagesWithSameTitle;
} StringObjectMOFetchedProperties;

@class PackageMO;
@class ConditionalItemMO;
@class ConditionalItemMO;
@class ManifestMO;
@class ConditionalItemMO;
@class ManifestMO;
@class ConditionalItemMO;
@class ManifestMO;
@class ManifestMO;
@class ConditionalItemMO;
@class ManifestMO;
@class ApplicationMO;
@class PackageMO;
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


@property int32_t indexInNestedManifestValue;
- (int32_t)indexInNestedManifestValue;
- (void)setIndexInNestedManifestValue:(int32_t)value_;

//- (BOOL)validateIndexInNestedManifest:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *originalIndex;


@property int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

//- (BOOL)validateOriginalIndex:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *title;


//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *typeString;


//- (BOOL)validateTypeString:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) PackageMO* blockingApplicationReference;

//- (BOOL)validateBlockingApplicationReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ConditionalItemMO* includedManifestConditionalReference;

//- (BOOL)validateIncludedManifestConditionalReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ConditionalItemMO* managedInstallConditionalReference;

//- (BOOL)validateManagedInstallConditionalReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ManifestMO* managedInstallReference;

//- (BOOL)validateManagedInstallReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ConditionalItemMO* managedUninstallConditionalReference;

//- (BOOL)validateManagedUninstallConditionalReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ManifestMO* managedUninstallReference;

//- (BOOL)validateManagedUninstallReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ConditionalItemMO* managedUpdateConditionalReference;

//- (BOOL)validateManagedUpdateConditionalReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ManifestMO* managedUpdateReference;

//- (BOOL)validateManagedUpdateReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ManifestMO* manifestReference;

//- (BOOL)validateManifestReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ConditionalItemMO* optionalInstallConditionalReference;

//- (BOOL)validateOptionalInstallConditionalReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ManifestMO* optionalInstallReference;

//- (BOOL)validateOptionalInstallReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ApplicationMO* originalApplication;

//- (BOOL)validateOriginalApplication:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) PackageMO* originalPackage;

//- (BOOL)validateOriginalPackage:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) PackageMO* requiresReference;

//- (BOOL)validateRequiresReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) PackageMO* supportedArchitectureReference;

//- (BOOL)validateSupportedArchitectureReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) PackageMO* updateForReference;

//- (BOOL)validateUpdateForReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, readonly) NSArray *manifestsWithSameTitle;

@property (nonatomic, readonly) NSArray *packagesWithSameTitle;


@end

@interface _StringObjectMO (CoreDataGeneratedAccessors)

@end

@interface _StringObjectMO (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber *)primitiveIndexInNestedManifest;
- (void)setPrimitiveIndexInNestedManifest:(NSNumber *)value;

- (int32_t)primitiveIndexInNestedManifestValue;
- (void)setPrimitiveIndexInNestedManifestValue:(int32_t)value_;




- (NSNumber *)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(NSNumber *)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;




- (NSString *)primitiveTitle;
- (void)setPrimitiveTitle:(NSString *)value;




- (NSString *)primitiveTypeString;
- (void)setPrimitiveTypeString:(NSString *)value;





- (PackageMO*)primitiveBlockingApplicationReference;
- (void)setPrimitiveBlockingApplicationReference:(PackageMO*)value;



- (ConditionalItemMO*)primitiveIncludedManifestConditionalReference;
- (void)setPrimitiveIncludedManifestConditionalReference:(ConditionalItemMO*)value;



- (ConditionalItemMO*)primitiveManagedInstallConditionalReference;
- (void)setPrimitiveManagedInstallConditionalReference:(ConditionalItemMO*)value;



- (ManifestMO*)primitiveManagedInstallReference;
- (void)setPrimitiveManagedInstallReference:(ManifestMO*)value;



- (ConditionalItemMO*)primitiveManagedUninstallConditionalReference;
- (void)setPrimitiveManagedUninstallConditionalReference:(ConditionalItemMO*)value;



- (ManifestMO*)primitiveManagedUninstallReference;
- (void)setPrimitiveManagedUninstallReference:(ManifestMO*)value;



- (ConditionalItemMO*)primitiveManagedUpdateConditionalReference;
- (void)setPrimitiveManagedUpdateConditionalReference:(ConditionalItemMO*)value;



- (ManifestMO*)primitiveManagedUpdateReference;
- (void)setPrimitiveManagedUpdateReference:(ManifestMO*)value;



- (ManifestMO*)primitiveManifestReference;
- (void)setPrimitiveManifestReference:(ManifestMO*)value;



- (ConditionalItemMO*)primitiveOptionalInstallConditionalReference;
- (void)setPrimitiveOptionalInstallConditionalReference:(ConditionalItemMO*)value;



- (ManifestMO*)primitiveOptionalInstallReference;
- (void)setPrimitiveOptionalInstallReference:(ManifestMO*)value;



- (ApplicationMO*)primitiveOriginalApplication;
- (void)setPrimitiveOriginalApplication:(ApplicationMO*)value;



- (PackageMO*)primitiveOriginalPackage;
- (void)setPrimitiveOriginalPackage:(PackageMO*)value;



- (PackageMO*)primitiveRequiresReference;
- (void)setPrimitiveRequiresReference:(PackageMO*)value;



- (PackageMO*)primitiveSupportedArchitectureReference;
- (void)setPrimitiveSupportedArchitectureReference:(PackageMO*)value;



- (PackageMO*)primitiveUpdateForReference;
- (void)setPrimitiveUpdateForReference:(PackageMO*)value;


@end
