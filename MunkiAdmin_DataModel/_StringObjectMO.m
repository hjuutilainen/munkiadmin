// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StringObjectMO.m instead.

#import "_StringObjectMO.h"

@implementation StringObjectMOID
@end

@implementation _StringObjectMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"StringObject";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"StringObject" inManagedObjectContext:moc_];
}

- (StringObjectMOID*)objectID {
	return (StringObjectMOID*)[super objectID];
}




@dynamic originalIndex;



- (int)originalIndexValue {
	NSNumber *result = [self originalIndex];
	return [result intValue];
}

- (void)setOriginalIndexValue:(int)value_ {
	[self setOriginalIndex:[NSNumber numberWithInt:value_]];
}

- (int)primitiveOriginalIndexValue {
	NSNumber *result = [self primitiveOriginalIndex];
	return [result intValue];
}

- (void)setPrimitiveOriginalIndexValue:(int)value_ {
	[self setPrimitiveOriginalIndex:[NSNumber numberWithInt:value_]];
}





@dynamic title;






@dynamic typeString;






@dynamic requiresReference;

	

@dynamic updateForReference;

	





@end
