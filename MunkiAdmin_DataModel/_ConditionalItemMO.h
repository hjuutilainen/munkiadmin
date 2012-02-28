// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConditionalItemMO.h instead.

#import <CoreData/CoreData.h>


extern const struct ConditionalItemMOAttributes {
	 NSString *munki_condition;
	 NSString *originalIndex;
} ConditionalItemMOAttributes;

extern const struct ConditionalItemMORelationships {
	 NSString *children;
	 NSString *includedManifests;
	 NSString *managedInstalls;
	 NSString *managedUninstalls;
	 NSString *managedUpdates;
	 NSString *manifest;
	 NSString *optionalInstalls;
	 NSString *parent;
} ConditionalItemMORelationships;

extern const struct ConditionalItemMOFetchedProperties {
} ConditionalItemMOFetchedProperties;

@class ConditionalItemMO;
@class StringObjectMO;
@class StringObjectMO;
@class StringObjectMO;
@class StringObjectMO;
@class ManifestMO;
@class StringObjectMO;
@class ConditionalItemMO;




@interface ConditionalItemMOID : NSManagedObjectID {}
@end

@interface _ConditionalItemMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ConditionalItemMOID*)objectID;




@property (nonatomic, retain) NSString *munki_condition;


//- (BOOL)validateMunki_condition:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *originalIndex;


@property int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

//- (BOOL)validateOriginalIndex:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet* children;

- (NSMutableSet*)childrenSet;




@property (nonatomic, retain) NSSet* includedManifests;

- (NSMutableSet*)includedManifestsSet;




@property (nonatomic, retain) NSSet* managedInstalls;

- (NSMutableSet*)managedInstallsSet;




@property (nonatomic, retain) NSSet* managedUninstalls;

- (NSMutableSet*)managedUninstallsSet;




@property (nonatomic, retain) NSSet* managedUpdates;

- (NSMutableSet*)managedUpdatesSet;




@property (nonatomic, retain) ManifestMO* manifest;

//- (BOOL)validateManifest:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* optionalInstalls;

- (NSMutableSet*)optionalInstallsSet;




@property (nonatomic, retain) ConditionalItemMO* parent;

//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;





@end

@interface _ConditionalItemMO (CoreDataGeneratedAccessors)

- (void)addChildren:(NSSet*)value_;
- (void)removeChildren:(NSSet*)value_;
- (void)addChildrenObject:(ConditionalItemMO*)value_;
- (void)removeChildrenObject:(ConditionalItemMO*)value_;

- (void)addIncludedManifests:(NSSet*)value_;
- (void)removeIncludedManifests:(NSSet*)value_;
- (void)addIncludedManifestsObject:(StringObjectMO*)value_;
- (void)removeIncludedManifestsObject:(StringObjectMO*)value_;

- (void)addManagedInstalls:(NSSet*)value_;
- (void)removeManagedInstalls:(NSSet*)value_;
- (void)addManagedInstallsObject:(StringObjectMO*)value_;
- (void)removeManagedInstallsObject:(StringObjectMO*)value_;

- (void)addManagedUninstalls:(NSSet*)value_;
- (void)removeManagedUninstalls:(NSSet*)value_;
- (void)addManagedUninstallsObject:(StringObjectMO*)value_;
- (void)removeManagedUninstallsObject:(StringObjectMO*)value_;

- (void)addManagedUpdates:(NSSet*)value_;
- (void)removeManagedUpdates:(NSSet*)value_;
- (void)addManagedUpdatesObject:(StringObjectMO*)value_;
- (void)removeManagedUpdatesObject:(StringObjectMO*)value_;

- (void)addOptionalInstalls:(NSSet*)value_;
- (void)removeOptionalInstalls:(NSSet*)value_;
- (void)addOptionalInstallsObject:(StringObjectMO*)value_;
- (void)removeOptionalInstallsObject:(StringObjectMO*)value_;

@end

@interface _ConditionalItemMO (CoreDataGeneratedPrimitiveAccessors)


- (NSString *)primitiveMunki_condition;
- (void)setPrimitiveMunki_condition:(NSString *)value;




- (NSNumber *)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(NSNumber *)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;





- (NSMutableSet*)primitiveChildren;
- (void)setPrimitiveChildren:(NSMutableSet*)value;



- (NSMutableSet*)primitiveIncludedManifests;
- (void)setPrimitiveIncludedManifests:(NSMutableSet*)value;



- (NSMutableSet*)primitiveManagedInstalls;
- (void)setPrimitiveManagedInstalls:(NSMutableSet*)value;



- (NSMutableSet*)primitiveManagedUninstalls;
- (void)setPrimitiveManagedUninstalls:(NSMutableSet*)value;



- (NSMutableSet*)primitiveManagedUpdates;
- (void)setPrimitiveManagedUpdates:(NSMutableSet*)value;



- (ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(ManifestMO*)value;



- (NSMutableSet*)primitiveOptionalInstalls;
- (void)setPrimitiveOptionalInstalls:(NSMutableSet*)value;



- (ConditionalItemMO*)primitiveParent;
- (void)setPrimitiveParent:(ConditionalItemMO*)value;


@end
