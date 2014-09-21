// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OptionalInstallMO.h instead.

#import <CoreData/CoreData.h>
#import "ApplicationProxyMO.h"

extern const struct OptionalInstallMORelationships {
	__unsafe_unretained NSString *manifest;
} OptionalInstallMORelationships;

@class ManifestMO;

@interface OptionalInstallMOID : ApplicationProxyMOID {}
@end

@interface _OptionalInstallMO : ApplicationProxyMO {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) OptionalInstallMOID* objectID;

@property (nonatomic, strong) ManifestMO *manifest;

//- (BOOL)validateManifest:(id*)value_ error:(NSError**)error_;

@end

@interface _OptionalInstallMO (CoreDataGeneratedPrimitiveAccessors)

- (ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(ManifestMO*)value;

@end
