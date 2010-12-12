// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ReceiptMO.m instead.

#import "_ReceiptMO.h"

@implementation ReceiptMOID
@end

@implementation _ReceiptMO

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Receipt" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Receipt";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Receipt" inManagedObjectContext:moc_];
}

- (ReceiptMOID*)objectID {
	return (ReceiptMOID*)[super objectID];
}




@dynamic munki_installed_size;



- (long long)munki_installed_sizeValue {
	NSNumber *result = [self munki_installed_size];
	return [result longLongValue];
}

- (void)setMunki_installed_sizeValue:(long long)value_ {
	[self setMunki_installed_size:[NSNumber numberWithLongLong:value_]];
}

- (long long)primitiveMunki_installed_sizeValue {
	NSNumber *result = [self primitiveMunki_installed_size];
	return [result longLongValue];
}

- (void)setPrimitiveMunki_installed_sizeValue:(long long)value_ {
	[self setPrimitiveMunki_installed_size:[NSNumber numberWithLongLong:value_]];
}





@dynamic munki_packageid;






@dynamic munki_version;






@dynamic munki_filename;






@dynamic package;

	





@end
