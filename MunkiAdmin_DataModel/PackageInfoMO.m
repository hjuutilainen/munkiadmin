#import "PackageInfoMO.h"

@implementation PackageInfoMO

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	// Define keys that depend on
    if ([key isEqualToString:@"isEnabledForCatalog"])
    {
        NSSet *affectingKeys = [NSSet setWithObjects:@"catalog.dictValue", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    } 
		
    return keyPaths;
}


@end
