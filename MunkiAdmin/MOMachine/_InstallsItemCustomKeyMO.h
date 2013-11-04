// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallsItemCustomKeyMO.h instead.

#import <CoreData/CoreData.h>


extern const struct InstallsItemCustomKeyMOAttributes {
	__unsafe_unretained NSString *customKeyName;
	__unsafe_unretained NSString *customKeyValue;
} InstallsItemCustomKeyMOAttributes;

extern const struct InstallsItemCustomKeyMORelationships {
	__unsafe_unretained NSString *installsItem;
} InstallsItemCustomKeyMORelationships;

extern const struct InstallsItemCustomKeyMOFetchedProperties {
} InstallsItemCustomKeyMOFetchedProperties;

@class InstallsItemMO;




@interface InstallsItemCustomKeyMOID : NSManagedObjectID {}
@end

@interface _InstallsItemCustomKeyMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (InstallsItemCustomKeyMOID*)objectID;





@property (nonatomic, strong) NSString* customKeyName;



//- (BOOL)validateCustomKeyName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* customKeyValue;



//- (BOOL)validateCustomKeyValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) InstallsItemMO *installsItem;

//- (BOOL)validateInstallsItem:(id*)value_ error:(NSError**)error_;





@end

@interface _InstallsItemCustomKeyMO (CoreDataGeneratedAccessors)

@end

@interface _InstallsItemCustomKeyMO (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCustomKeyName;
- (void)setPrimitiveCustomKeyName:(NSString*)value;




- (NSString*)primitiveCustomKeyValue;
- (void)setPrimitiveCustomKeyValue:(NSString*)value;





- (InstallsItemMO*)primitiveInstallsItem;
- (void)setPrimitiveInstallsItem:(InstallsItemMO*)value;


@end
