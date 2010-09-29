#import "ApplicationMO.h"
#import "PackageMO.h"

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
	NSString *version = [self valueForKeyPath:@"packages.@max.munki_version"];
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
	if ([self.packages count] == 0) {
		subtitle = @"No versions";
	} else if ([self.packages count] == 1) {
		subtitle = [NSString stringWithFormat:@"%@", [self latestVersion]];
	} else {
		subtitle = [NSString stringWithFormat:@"%@  (%i packages)", [self latestVersion], [self.packages count]];
	}
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.munki_display_name, @"title",
			subtitle, @"subtitle",
			@"application", @"type",
			nil];
}

@end
