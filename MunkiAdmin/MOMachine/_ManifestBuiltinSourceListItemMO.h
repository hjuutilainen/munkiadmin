// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManifestBuiltinSourceListItemMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

#import "ManifestSourceListItemMO.h"

NS_ASSUME_NONNULL_BEGIN

@interface ManifestBuiltinSourceListItemMOID : ManifestSourceListItemMOID {}
@end

@interface _ManifestBuiltinSourceListItemMO : ManifestSourceListItemMO
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ManifestBuiltinSourceListItemMOID *objectID;

@property (nonatomic, strong, nullable) NSString* identifier;

@end

@interface _ManifestBuiltinSourceListItemMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(nullable NSString*)value;

@end

@interface ManifestBuiltinSourceListItemMOAttributes: NSObject 
+ (NSString *)identifier;
@end

NS_ASSUME_NONNULL_END
