// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DirectoryMO.h instead.

#import <CoreData/CoreData.h>
#import "PackageSourceListItemMO.h"

extern const struct DirectoryMOAttributes {
	__unsafe_unretained NSString *originalURL;
} DirectoryMOAttributes;

extern const struct DirectoryMOFetchedProperties {
	__unsafe_unretained NSString *childPackages;
} DirectoryMOFetchedProperties;

@class NSObject;

@interface DirectoryMOID : PackageSourceListItemMOID {}
@end

@interface _DirectoryMO : PackageSourceListItemMO {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) DirectoryMOID* objectID;

@property (nonatomic, strong) id originalURL;

//- (BOOL)validateOriginalURL:(id*)value_ error:(NSError**)error_;

@property (nonatomic, readonly) NSArray *childPackages;

@end

@interface _DirectoryMO (CoreDataGeneratedPrimitiveAccessors)

- (id)primitiveOriginalURL;
- (void)setPrimitiveOriginalURL:(id)value;

@end
