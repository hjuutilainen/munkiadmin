// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StringObjectMO.h instead.

#import <CoreData/CoreData.h>


@class PackageMO;
@class PackageMO;
@class PackageMO;





@interface StringObjectMOID : NSManagedObjectID {}
@end

@interface _StringObjectMO : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (StringObjectMOID*)objectID;




@property (nonatomic, retain) NSNumber *originalIndex;


@property int originalIndexValue;
- (int)originalIndexValue;
- (void)setOriginalIndexValue:(int)value_;

//- (BOOL)validateOriginalIndex:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *title;


//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *typeString;


//- (BOOL)validateTypeString:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) PackageMO* blockingApplicationReference;

//- (BOOL)validateBlockingApplicationReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) PackageMO* requiresReference;

//- (BOOL)validateRequiresReference:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) PackageMO* updateForReference;

//- (BOOL)validateUpdateForReference:(id*)value_ error:(NSError**)error_;




@end

@interface _StringObjectMO (CoreDataGeneratedAccessors)

@end

@interface _StringObjectMO (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveOriginalIndex;
- (void)setPrimitiveOriginalIndex:(NSNumber*)value;

- (int)primitiveOriginalIndexValue;
- (void)setPrimitiveOriginalIndexValue:(int)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveTypeString;
- (void)setPrimitiveTypeString:(NSString*)value;





- (PackageMO*)primitiveBlockingApplicationReference;
- (void)setPrimitiveBlockingApplicationReference:(PackageMO*)value;



- (PackageMO*)primitiveRequiresReference;
- (void)setPrimitiveRequiresReference:(PackageMO*)value;



- (PackageMO*)primitiveUpdateForReference;
- (void)setPrimitiveUpdateForReference:(PackageMO*)value;


@end
