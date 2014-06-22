#import "PackageInfoMO.h"
#import "CatalogMO.h"

@implementation PackageInfoMO

- (void)setIsEnabledForCatalog:(NSNumber *)isEnabledForCatalog
{
    [self willChangeValueForKey:@"isEnabledForCatalog"];
    if (self.catalog) {
        [self.catalog willChangeValueForKey:@"enabledPackagesDescription"];
    }
    
    [self setPrimitiveValue:isEnabledForCatalog forKey:@"isEnabledForCatalog"];
    
    if (self.catalog) {
        [self.catalog didChangeValueForKey:@"enabledPackagesDescription"];
    }
    [self didChangeValueForKey:@"isEnabledForCatalog"];
}

- (NSDictionary *)dictValue
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.title, @"title",
			@"", @"subtitle",
			@"package", @"type",
			nil];
}


@end
