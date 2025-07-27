// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManifestDirectorySourceListItemMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

#import "ManifestSourceListItemMO.h"

NS_ASSUME_NONNULL_BEGIN

@interface ManifestDirectorySourceListItemMOID : ManifestSourceListItemMOID {}
@end

@interface _ManifestDirectorySourceListItemMO : ManifestSourceListItemMO
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ManifestDirectorySourceListItemMOID *objectID;

@property (nonatomic, strong, nullable) NSString* representedFileURL;

@end

@interface _ManifestDirectorySourceListItemMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveRepresentedFileURL;
- (void)setPrimitiveRepresentedFileURL:(nullable NSString*)value;

@end

@interface ManifestDirectorySourceListItemMOAttributes: NSObject 
+ (NSString *)representedFileURL;
@end

NS_ASSUME_NONNULL_END
