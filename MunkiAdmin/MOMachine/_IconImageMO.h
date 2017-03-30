// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to IconImageMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class PackageMO;

@class NSObject;

@class NSObject;

@interface IconImageMOID : NSManagedObjectID {}
@end

@interface _IconImageMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) IconImageMOID *objectID;

@property (nonatomic, strong, nullable) id imageRepresentation;

@property (nonatomic, strong, nullable) id originalURL;

@property (nonatomic, strong, nullable) NSSet<PackageMO*> *packages;
- (nullable NSMutableSet<PackageMO*>*)packagesSet;

@end

@interface _IconImageMO (PackagesCoreDataGeneratedAccessors)
- (void)addPackages:(NSSet<PackageMO*>*)value_;
- (void)removePackages:(NSSet<PackageMO*>*)value_;
- (void)addPackagesObject:(PackageMO*)value_;
- (void)removePackagesObject:(PackageMO*)value_;

@end

@interface _IconImageMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable id)primitiveImageRepresentation;
- (void)setPrimitiveImageRepresentation:(nullable id)value;

- (nullable id)primitiveOriginalURL;
- (void)setPrimitiveOriginalURL:(nullable id)value;

- (NSMutableSet<PackageMO*>*)primitivePackages;
- (void)setPrimitivePackages:(NSMutableSet<PackageMO*>*)value;

@end

@interface IconImageMOAttributes: NSObject 
+ (NSString *)imageRepresentation;
+ (NSString *)originalURL;
@end

@interface IconImageMORelationships: NSObject
+ (NSString *)packages;
@end

NS_ASSUME_NONNULL_END
