// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DirectoryMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

#import "PackageSourceListItemMO.h"

NS_ASSUME_NONNULL_BEGIN

@class NSObject;

@interface DirectoryMOID : PackageSourceListItemMOID {}
@end

@interface _DirectoryMO : PackageSourceListItemMO
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) DirectoryMOID *objectID;

@property (nonatomic, strong, nullable) id originalURL;

@property (nonatomic, readonly, nullable) NSArray *childPackages;

@end

@interface _DirectoryMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable id)primitiveOriginalURL;
- (void)setPrimitiveOriginalURL:(nullable id)value;

@end

@interface DirectoryMOAttributes: NSObject 
+ (NSString *)originalURL;
@end

@interface DirectoryMOFetchedProperties: NSObject
+ (NSString *)childPackages;
@end

NS_ASSUME_NONNULL_END
