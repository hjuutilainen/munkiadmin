#import "CategorySourceListItemMO.h"


@interface CategorySourceListItemMO ()

// Private interface goes here.

@end


@implementation CategorySourceListItemMO

- (NSImage *)icon
{
    NSImage *image;
    if ([self.type isEqualToString:@"regular"]) {
        image = [NSImage imageNamed:@"tagTemplate"];
        [image setTemplate:YES];
    } else if ([self.type isEqualToString:@"smart"]) {
        image = [NSImage imageNamed:NSImageNameFolderSmart];
    } else {
        image = [NSImage imageNamed:@"tagTemplate"];
        [image setTemplate:YES];
    }
    return image;
}

@end
