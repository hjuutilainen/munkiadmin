#import "CategorySourceListItemMO.h"


@interface CategorySourceListItemMO ()

// Private interface goes here.

@end


@implementation CategorySourceListItemMO

- (NSImage *)icon
{
    NSImage *image;
    if ([self.title isEqualToString:@"Uncategorized"] && [self.itemType isEqualToString:@"smart"]) {
        image = [NSImage imageNamed:@"tagMultipleTemplate"];
        [image setTemplate:YES];
    } else {
        image = [NSImage imageNamed:@"tagTemplate"];
        [image setTemplate:YES];
    }
    return image;
}

@end
