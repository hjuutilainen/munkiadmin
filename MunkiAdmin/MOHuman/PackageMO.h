#import "_PackageMO.h"

@interface PackageMO : _PackageMO {

}

- (NSURL *)parentURL;
- (NSString *)relativePath;
- (NSDictionary *)pkgInfoDictionary;
- (NSString *)titleWithVersion;
- (NSString *)formattedTitle;
- (NSArray *)catalogStrings;
- (NSString *)catalogsDescriptionString;

@end
