#import "CatalogMO.h"

@implementation CatalogMO

- (NSArray *)enabledPackages
{
	NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:@"isEnabledForCatalog == TRUE"];
	NSArray *tempArray = [[self.packageInfos allObjects] filteredArrayUsingPredicate:enabledPredicate];
	return tempArray;
}

- (NSDictionary *)dictValue
{
	NSString *subtitle;
	int enabledPackagesCount = [[self enabledPackages] count];
	if (enabledPackagesCount == 0) {
		subtitle = @"No packages enabled";
	} else if (enabledPackagesCount == 1) {
		subtitle = @"1 package enabled";
	} else {
		subtitle = [NSString stringWithFormat:@"%i packages enabled", enabledPackagesCount];
	}
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.title, @"title",
			subtitle, @"subtitle",
			@"catalog", @"type",
			nil];
}

@end
