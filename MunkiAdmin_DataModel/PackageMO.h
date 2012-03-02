#import "_PackageMO.h"

@interface PackageMO : _PackageMO {

}

- (NSURL *)parentURL;
- (NSDictionary *)pkgInfoDictionary;
- (NSString *)titleWithVersion;
- (NSString *)formattedTitle;

@end
