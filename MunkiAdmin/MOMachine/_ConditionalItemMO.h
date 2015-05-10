// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConditionalItemMO.h instead.

#import <CoreData/CoreData.h>

extern const struct ConditionalItemMOAttributes {
	__unsafe_unretained NSString *munki_condition;
	__unsafe_unretained NSString *originalIndex;
} ConditionalItemMOAttributes;

extern const struct ConditionalItemMORelationships {
	__unsafe_unretained NSString *children;
	__unsafe_unretained NSString *includedManifests;
	__unsafe_unretained NSString *managedInstalls;
	__unsafe_unretained NSString *managedUninstalls;
	__unsafe_unretained NSString *managedUpdates;
	__unsafe_unretained NSString *manifest;
	__unsafe_unretained NSString *optionalInstalls;
	__unsafe_unretained NSString *parent;
	__unsafe_unretained NSString *referencingManifests;
} ConditionalItemMORelationships;

@class ConditionalItemMO;
@class StringObjectMO;
@class StringObjectMO;
@class StringObjectMO;
@class StringObjectMO;
@class ManifestMO;
@class StringObjectMO;
@class ConditionalItemMO;
@class StringObjectMO;

@interface ConditionalItemMOID : NSManagedObjectID {}
@end

@interface _ConditionalItemMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ConditionalItemMOID* objectID;

@property (nonatomic, strong) NSString* munki_condition;

//- (BOOL)validateMunki_condition:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* originalIndex;

@property (atomic) int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

//- (BOOL)validateOriginalIndex:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *children;

- (NSMutableSet*)childrenSet;

@property (nonatomic, strong) NSSet *includedManifests;

- (NSMutableSet*)includedManifestsSet;

@property (nonatomic, strong) NSSet *managedInstalls;

- (NSMutableSet*)managedInstallsSet;

@property (nonatomic, strong) NSSet *managedUninstalls;

- (NSMutableSet*)managedUninstallsSet;

@property (nonatomic, strong) NSSet *managedUpdates;

- (NSMutableSet*)managedUpdatesSet;

@property (nonatomic, strong) ManifestMO *manifest;

//- (BOOL)validateManifest:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *optionalInstalls;

- (NSMutableSet*)optionalInstallsSet;

@property (nonatomic, strong) ConditionalItemMO *parent;

//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) StringObjectMO *referencingManifests;

//- (BOOL)validateReferencingManifests:(id*)value_ error:(NSError**)error_;

@end

@interface _ConditionalItemMO (ChildrenCoreDataGeneratedAccessors)
- (void)addChildren:(NSSet*)value_;
- (void)removeChildren:(NSSet*)value_;
- (void)addChildrenObject:(ConditionalItemMO*)value_;
- (void)removeChildrenObject:(ConditionalItemMO*)value_;

@end

@interface _ConditionalItemMO (IncludedManifestsCoreDataGeneratedAccessors)
- (void)addIncludedManifests:(NSSet*)value_;
- (void)removeIncludedManifests:(NSSet*)value_;
- (void)addIncludedManifestsObject:(StringObjectMO*)value_;
- (void)removeIncludedManifestsObject:(StringObjectMO*)value_;

@end

@interface _ConditionalItemMO (ManagedInstallsCoreDataGeneratedAccessors)
- (void)addManagedInstalls:(NSSet*)value_;
- (void)removeManagedInstalls:(NSSet*)value_;
- (void)addManagedInstallsObject:(StringObjectMO*)value_;
- (void)removeManagedInstallsObject:(StringObjectMO*)value_;

@end

@interface _ConditionalItemMO (ManagedUninstallsCoreDataGeneratedAccessors)
- (void)addManagedUninstalls:(NSSet*)value_;
- (void)removeManagedUninstalls:(NSSet*)value_;
- (void)addManagedUninstallsObject:(StringObjectMO*)value_;
- (void)removeManagedUninstallsObject:(StringObjectMO*)value_;

@end

@interface _ConditionalItemMO (ManagedUpdatesCoreDataGeneratedAccessors)
- (void)addManagedUpdates:(NSSet*)value_;
- (void)removeManagedUpdates:(NSSet*)value_;
- (void)addManagedUpdatesObject:(StringObjectMO*)value_;
- (void)removeManagedUpdatesObject:(StringObjectMO*)value_;

@end

@interface _ConditionalItemMO (OptionalInstallsCoreDataGeneratedAccessors)
- (void)addOptionalInstalls:(NSSet*)value_;
- (void)removeOptionalInstalls:(NSSet*)value_;
- (void)addOptionalInstallsObject:(StringObjectMO*)value_;
- (void)removeOptionalInstallsObject:(StringObjectMO*)value_;

@end

@interface _ConditionalItemMO (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveMunki_condition;
- (void)setPrimitiveMunki_condition:(NSString*)value;

- (NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(NSNumber*)value;

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

- (StringObjectMO*)primitiveReferencingManifests;
- (void)setPrimitiveReferencingManifests:(StringObjectMO*)value;

@end
