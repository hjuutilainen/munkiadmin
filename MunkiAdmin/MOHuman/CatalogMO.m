#import "CatalogMO.h"
#import "PackageInfoMO.h"

@implementation CatalogMO


 
- (NSArray *)enabledPackages
{
	NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:@"isEnabledForCatalog == TRUE"];
	NSArray *tempArray = [[self.packageInfos allObjects] filteredArrayUsingPredicate:enabledPredicate];
	return tempArray;
}


- (NSDictionary *)dictValue
{	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.title, @"title",
			self.enabledPackagesDescription, @"subtitle",
			@"catalog", @"type",
			nil];
}


- (NSString *)enabledPackagesDescription
{
    NSString *descriptionString;
    NSUInteger enabledPackagesCount = [[self enabledPackages] count];
    if (enabledPackagesCount == 0) {
        descriptionString = @"No packages enabled";
    } else if (enabledPackagesCount == 1) {
        descriptionString = @"1 package enabled";
    } else {
        descriptionString = [NSString stringWithFormat:@"%lu packages enabled", (unsigned long)enabledPackagesCount];
    }
    return descriptionString;
}

- (NSImage *)image
{
    return [NSImage imageNamed:@"catalogIcon_32x32"];
}

@end
