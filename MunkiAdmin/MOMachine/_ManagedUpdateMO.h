// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManagedUpdateMO.h instead.

#import <CoreData/CoreData.h>
#import "ApplicationProxyMO.h"

extern const struct ManagedUpdateMORelationships {
	__unsafe_unretained NSString *manifest;
} ManagedUpdateMORelationships;

@class ManifestMO;

@interface ManagedUpdateMOID : ApplicationProxyMOID {}
@end

@interface _ManagedUpdateMO : ApplicationProxyMO {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ManagedUpdateMOID* objectID;

@property (nonatomic, strong) ManifestMO *manifest;

//- (BOOL)validateManifest:(id*)value_ error:(NSError**)error_;

@end

@interface _ManagedUpdateMO (CoreDataGeneratedPrimitiveAccessors)

- (ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(ManifestMO*)value;

@end
