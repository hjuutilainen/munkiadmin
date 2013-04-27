// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InstallerEnvironmentVariableMO.h instead.

#import <CoreData/CoreData.h>


extern const struct InstallerEnvironmentVariableMOAttributes {
	 NSString *munki_installer_environment_key;
	 NSString *munki_installer_environment_value;
	 NSString *originalIndex;
} InstallerEnvironmentVariableMOAttributes;

extern const struct InstallerEnvironmentVariableMORelationships {
	 NSString *packages;
} InstallerEnvironmentVariableMORelationships;

extern const struct InstallerEnvironmentVariableMOFetchedProperties {
} InstallerEnvironmentVariableMOFetchedProperties;

@class PackageMO;





@interface InstallerEnvironmentVariableMOID : NSManagedObjectID {}
@end

@interface _InstallerEnvironmentVariableMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (InstallerEnvironmentVariableMOID*)objectID;





@property (nonatomic, retain) NSString* munki_installer_environment_key;



//- (BOOL)validateMunki_installer_environment_key:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* munki_installer_environment_value;



//- (BOOL)validateMunki_installer_environment_value:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* originalIndex;



@property int32_t originalIndexValue;
- (int32_t)originalIndexValue;
- (void)setOriginalIndexValue:(int32_t)value_;

//- (BOOL)validateOriginalIndex:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet *packages;

- (NSMutableSet*)packagesSet;





@end

@interface _InstallerEnvironmentVariableMO (CoreDataGeneratedAccessors)

- (void)addPackages:(NSSet*)value_;
- (void)removePackages:(NSSet*)value_;
- (void)addPackagesObject:(PackageMO*)value_;
- (void)removePackagesObject:(PackageMO*)value_;

@end

@interface _InstallerEnvironmentVariableMO (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveMunki_installer_environment_key;
- (void)setPrimitiveMunki_installer_environment_key:(NSString*)value;




- (NSString*)primitiveMunki_installer_environment_value;
- (void)setPrimitiveMunki_installer_environment_value:(NSString*)value;




- (NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(NSNumber*)value;

- (int32_t)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int32_t)value_;





- (NSMutableSet*)primitivePackages;
- (void)setPrimitivePackages:(NSMutableSet*)value;


@end
