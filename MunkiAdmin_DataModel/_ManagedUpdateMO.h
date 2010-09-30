// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManagedUpdateMO.h instead.

#import <CoreData/CoreData.h>
#import "ApplicationProxyMO.h"

@class ManifestMO;


@interface ManagedUpdateMOID : NSManagedObjectID {}
@end

@interface _ManagedUpdateMO : ApplicationProxyMO {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ManagedUpdateMOID*)objectID;




@property (nonatomic, retain) ManifestMO* manifest;
//- (BOOL)validateManifest:(id*)value_ error:(NSError**)error_;



@end

@interface _ManagedUpdateMO (CoreDataGeneratedAccessors)

@end

@interface _ManagedUpdateMO (CoreDataGeneratedPrimitiveAccessors)



- (ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(ManifestMO*)value;


@end
