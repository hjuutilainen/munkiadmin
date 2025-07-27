#import "ManifestSourceListItemMO.h"

@implementation ManifestSourceListItemMO

- (NSDictionary *)dictValue
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (self.title) {
        dict[@"title"] = self.title;
    }
    if (self.itemType) {
        dict[@"itemType"] = self.itemType;
    }
    dict[@"isGroupItem"] = self.isGroupItem;
    dict[@"originalIndex"] = self.originalIndex;
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
