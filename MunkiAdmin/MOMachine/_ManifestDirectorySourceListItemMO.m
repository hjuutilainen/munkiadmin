// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManifestDirectorySourceListItemMO.m instead.

#import "_ManifestDirectorySourceListItemMO.h"

@implementation ManifestDirectorySourceListItemMOID
@end

@implementation _ManifestDirectorySourceListItemMO

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ManifestDirectorySourceListItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ManifestDirectorySourceListItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ManifestDirectorySourceListItem" inManagedObjectContext:moc_];
}

- (ManifestDirectorySourceListItemMOID*)objectID {
	return (ManifestDirectorySourceListItemMOID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic representedFileURL;

@end

@implementation ManifestDirectorySourceListItemMOAttributes 
+ (NSString *)representedFileURL {
	return @"representedFileURL";
}
@end

