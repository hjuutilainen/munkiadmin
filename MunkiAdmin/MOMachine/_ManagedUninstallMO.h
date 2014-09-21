// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManagedUninstallMO.h instead.

#import <CoreData/CoreData.h>
#import "ApplicationProxyMO.h"

extern const struct ManagedUninstallMORelationships {
	__unsafe_unretained NSString *manifest;
} ManagedUninstallMORelationships;

@class ManifestMO;

@interface ManagedUninstallMOID : ApplicationProxyMOID {}
@end

@interface _ManagedUninstallMO : ApplicationProxyMO {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ManagedUninstallMOID* objectID;

@property (nonatomic, strong) ManifestMO *manifest;

//- (BOOL)validateManifest:(id*)value_ error:(NSError**)error_;

@end

@interface _ManagedUninstallMO (CoreDataGeneratedPrimitiveAccessors)

- (ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(ManifestMO*)value;

@end
