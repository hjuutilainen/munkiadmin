#import "DeveloperSourceListItemMO.h"


@interface DeveloperSourceListItemMO ()

// Private interface goes here.

@end


@implementation DeveloperSourceListItemMO

- (NSImage *)icon
{
    NSImage *image;
    if ([self.type isEqualToString:@"regular"]) {
        image = [NSImage imageNamed:@"developerTemplate"];
        [image setTemplate:YES];
    } else if ([self.type isEqualToString:@"smart"]) {
        image = [NSImage imageNamed:@"developerUnknownTemplate"];
        [image setTemplate:YES];
    } else {
        image = [NSImage imageNamed:@"developerTemplate"];
        [image setTemplate:YES];
    }
    return image;
}

@end
