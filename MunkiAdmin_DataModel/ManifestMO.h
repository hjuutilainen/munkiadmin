#import "_ManifestMO.h"

@interface ManifestMO : _ManifestMO {}

- (NSString *)fileName;
- (NSSet *)rootConditionalItems;
- (NSDictionary *)manifestInfoDictionary;

@end
