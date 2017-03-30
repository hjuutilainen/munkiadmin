// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallsItemCustomKeyMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class InstallsItemMO;

@interface InstallsItemCustomKeyMOID : NSManagedObjectID {}
@end

@interface _InstallsItemCustomKeyMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) InstallsItemCustomKeyMOID *objectID;

@property (nonatomic, strong, nullable) NSString* customKeyName;

@property (nonatomic, strong, nullable) NSString* customKeyValue;

@property (nonatomic, strong, nullable) InstallsItemMO *installsItem;

@end

@interface _InstallsItemCustomKeyMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveCustomKeyName;
- (void)setPrimitiveCustomKeyName:(nullable NSString*)value;

- (nullable NSString*)primitiveCustomKeyValue;
- (void)setPrimitiveCustomKeyValue:(nullable NSString*)value;

- (InstallsItemMO*)primitiveInstallsItem;
- (void)setPrimitiveInstallsItem:(InstallsItemMO*)value;

@end

@interface InstallsItemCustomKeyMOAttributes: NSObject 
+ (NSString *)customKeyName;
+ (NSString *)customKeyValue;
@end

@interface InstallsItemCustomKeyMORelationships: NSObject
+ (NSString *)installsItem;
@end

NS_ASSUME_NONNULL_END
