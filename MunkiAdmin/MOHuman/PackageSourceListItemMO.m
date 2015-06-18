#import "PackageSourceListItemMO.h"

@implementation PackageSourceListItemMO

- (NSDictionary *)dictValue
{
    if (self.isGroupItemValue) {
        return [NSDictionary dictionaryWithObjectsAndKeys:
                self.title, @"title",
                @"", @"subtitle",
                nil, @"icon",
                nil];
    } else {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.title, @"title",
			@"", @"subtitle",
			[self icon], @"icon",
			nil];
    }
}

@end
