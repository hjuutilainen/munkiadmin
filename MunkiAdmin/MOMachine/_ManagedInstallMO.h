// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManagedInstallMO.h instead.

#import <CoreData/CoreData.h>
#import "ApplicationProxyMO.h"

extern const struct ManagedInstallMORelationships {
	__unsafe_unretained NSString *manifest;
} ManagedInstallMORelationships;

@class ManifestMO;

@interface ManagedInstallMOID : ApplicationProxyMOID {}
@end

@interface _ManagedInstallMO : ApplicationProxyMO {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ManagedInstallMOID* objectID;

@property (nonatomic, strong) ManifestMO *manifest;

//- (BOOL)validateManifest:(id*)value_ error:(NSError**)error_;

@end

@interface _ManagedInstallMO (CoreDataGeneratedPrimitiveAccessors)

- (ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(ManifestMO*)value;

@end
