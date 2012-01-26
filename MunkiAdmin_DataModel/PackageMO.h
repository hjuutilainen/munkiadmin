#import "_PackageMO.h"

@interface PackageMO : _PackageMO {

}

- (NSDictionary *)pkgInfoDictionary;
- (NSString *)titleWithVersion;
- (NSString *)formattedTitle;

@end
