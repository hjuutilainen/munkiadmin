#import "_ConditionalItemMO.h"

@interface ConditionalItemMO : _ConditionalItemMO {}
- (NSString *)titleWithParentTitle;
- (NSDictionary *)dictValue;
- (NSDictionary *)dictValueForSave;
- (void)invalidateManifestCountCaches;
@end
