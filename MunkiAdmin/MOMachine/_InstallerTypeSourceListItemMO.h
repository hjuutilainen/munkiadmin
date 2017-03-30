// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallerTypeSourceListItemMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

#import "PackageSourceListItemMO.h"

NS_ASSUME_NONNULL_BEGIN

@interface InstallerTypeSourceListItemMOID : PackageSourceListItemMOID {}
@end

@interface _InstallerTypeSourceListItemMO : PackageSourceListItemMO
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) InstallerTypeSourceListItemMOID *objectID;

@end

@interface _InstallerTypeSourceListItemMO (CoreDataGeneratedPrimitiveAccessors)

@end

NS_ASSUME_NONNULL_END
