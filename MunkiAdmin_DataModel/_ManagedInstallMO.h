// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManagedInstallMO.h instead.

#import <CoreData/CoreData.h>
#import "ApplicationProxyMO.h"

@class ManifestMO;


@interface ManagedInstallMOID : NSManagedObjectID {}
@end

@interface _ManagedInstallMO : ApplicationProxyMO {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ManagedInstallMOID*)objectID;




@property (nonatomic, retain) ManifestMO* manifest;
//- (BOOL)validateManifest:(id*)value_ error:(NSError**)error_;




@end

@interface _ManagedInstallMO (CoreDataGeneratedAccessors)

@end

@interface _ManagedInstallMO (CoreDataGeneratedPrimitiveAccessors)



- (ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(ManifestMO*)value;


@end
