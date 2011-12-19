// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManagedUninstallMO.h instead.

#import <CoreData/CoreData.h>
#import "ApplicationProxyMO.h"

extern const struct ManagedUninstallMOAttributes {
} ManagedUninstallMOAttributes;

extern const struct ManagedUninstallMORelationships {
	 NSString *manifest;
} ManagedUninstallMORelationships;

extern const struct ManagedUninstallMOFetchedProperties {
} ManagedUninstallMOFetchedProperties;

@class ManifestMO;


@interface ManagedUninstallMOID : NSManagedObjectID {}
@end

@interface _ManagedUninstallMO : ApplicationProxyMO {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ManagedUninstallMOID*)objectID;





@property (nonatomic, retain) ManifestMO* manifest;

//- (BOOL)validateManifest:(id*)value_ error:(NSError**)error_;




@end

@interface _ManagedUninstallMO (CoreDataGeneratedAccessors)

@end

@interface _ManagedUninstallMO (CoreDataGeneratedPrimitiveAccessors)



- (ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(ManifestMO*)value;


@end
