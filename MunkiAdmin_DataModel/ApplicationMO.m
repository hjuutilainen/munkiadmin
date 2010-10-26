#import "ApplicationMO.h"
#import "PackageMO.h"
#import "CatalogMO.h"

@implementation ApplicationMO

@dynamic hasCommonDescription;

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	// Define keys that depend on
    if ([key isEqualToString:@"packages"])
    {
        NSSet *affectingKeys = [NSSet setWithObjects:@"dictValue", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    } 
	
    return keyPaths;
}

- (NSString *)latestVersion
{
	NSSortDescriptor *sortByVersion = [NSSortDescriptor sortDescriptorWithKey:@"munki_version" ascending:NO selector:@selector(localizedStandardCompare:)];
	PackageMO *latestPkg = [[self.packages sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByVersion]] objectAtIndex:0];
	/*NSMutableArray *tempCatNames = [[[NSMutableArray alloc] init] autorelease];
	for (CatalogMO *aCatalog in latestPkg.catalogs) {
		[tempCatNames addObject:aCatalog.title];
	}*/
	
	NSString *version = [latestPkg valueForKey:@"munki_version"];
	//return [NSString stringWithFormat:@"%@ in %@", version, [tempCatNames componentsJoinedByString:@", "]];
	return version;
}

- (BOOL)hasCommonDescription
{
	BOOL allEqual = YES;
	NSString *firstDescr = [[self.packages anyObject] munki_description];
	for (PackageMO *aPkg in [self.packages allObjects]) {
		if (![[aPkg munki_description] isEqualToString:firstDescr]) {
			allEqual = NO;
			break;
		}
	}
	return allEqual;
}


- (NSDictionary *)dictValue
{
	NSString *subtitle;
	NSString *type;
	if ([self.packages count] == 0) {
		subtitle = @"No versions";
		type = @"applications";
	} else if ([self.packages count] == 1) {
		subtitle = [NSString stringWithFormat:@"%@", [self latestVersion]];
		type = @"applications";
	} else {
		subtitle = [NSString stringWithFormat:@"%@  (%i packages)", [self latestVersion], [self.packages count]];
		type = @"applications";
	}
	
	NSString *title;
	if (self.munki_display_name != nil) {
		title = self.munki_display_name;
	} else if ((self.munki_name != nil)) {
		title = self.munki_name;
	} else {
		title = @"--";
	}
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			title, @"title",
			subtitle, @"subtitle",
			type, @"type",
			nil];
}

@end
