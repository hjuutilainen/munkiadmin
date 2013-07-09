#import "ApplicationProxyMO.h"

@implementation ApplicationProxyMO

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	// Define keys that depend on
    if ([key isEqualToString:@"isEnabled"])
    {
        NSSet *affectingKeys = [NSSet setWithObjects:@"manifest.dictValue", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    } 
	
    return keyPaths;
}


@end
