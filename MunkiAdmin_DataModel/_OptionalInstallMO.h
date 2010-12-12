// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OptionalInstallMO.h instead.

#import <CoreData/CoreData.h>
#import "ApplicationProxyMO.h"

@class ManifestMO;


@interface OptionalInstallMOID : NSManagedObjectID {}
@end

@interface _OptionalInstallMO : ApplicationProxyMO {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OptionalInstallMOID*)objectID;




@property (nonatomic, retain) ManifestMO* manifest;
//- (BOOL)validateManifest:(id*)value_ error:(NSError**)error_;




@end

@interface _OptionalInstallMO (CoreDataGeneratedAccessors)

@end

@interface _OptionalInstallMO (CoreDataGeneratedPrimitiveAccessors)



- (ManifestMO*)primitiveManifest;
- (void)setPrimitiveManifest:(ManifestMO*)value;


@end
