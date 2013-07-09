// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallsItemCustomKeyMO.h instead.

#import <CoreData/CoreData.h>


extern const struct InstallsItemCustomKeyMOAttributes {
	 NSString *customKeyName;
	 NSString *customKeyValue;
} InstallsItemCustomKeyMOAttributes;

extern const struct InstallsItemCustomKeyMORelationships {
	 NSString *installsItem;
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





@property (nonatomic, retain) NSString* customKeyName;



//- (BOOL)validateCustomKeyName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* customKeyValue;



//- (BOOL)validateCustomKeyValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) InstallsItemMO *installsItem;

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
