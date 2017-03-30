// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ApplicationProxyMO.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class ApplicationMO;

@interface ApplicationProxyMOID : NSManagedObjectID {}
@end

@interface _ApplicationProxyMO : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ApplicationProxyMOID *objectID;

@property (nonatomic, strong, nullable) NSNumber* isEnabled;

@property (atomic) BOOL isEnabledValue;
- (BOOL)isEnabledValue;
- (void)setIsEnabledValue:(BOOL)value_;

@property (nonatomic, strong, nullable) ApplicationMO *parentApplication;

@end

@interface _ApplicationProxyMO (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSNumber*)primitiveIsEnabled;
- (void)setPrimitiveIsEnabled:(nullable NSNumber*)value;

- (BOOL)primitiveIsEnabledValue;
- (void)setPrimitiveIsEnabledValue:(BOOL)value_;

- (ApplicationMO*)primitiveParentApplication;
- (void)setPrimitiveParentApplication:(ApplicationMO*)value;

@end

@interface ApplicationProxyMOAttributes: NSObject 
+ (NSString *)isEnabled;
@end

@interface ApplicationProxyMORelationships: NSObject
+ (NSString *)parentApplication;
@end

NS_ASSUME_NONNULL_END
