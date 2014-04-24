#import "DeveloperSourceListItemMO.h"


@interface DeveloperSourceListItemMO ()

// Private interface goes here.

@end


@implementation DeveloperSourceListItemMO

- (NSImage *)icon
{
    if ([self.type isEqualToString:@"regular"]) {
        NSImage *image = [NSImage imageNamed:NSImageNameActionTemplate];
        [image setTemplate:YES];
        return image;
    } else if ([self.type isEqualToString:@"smart"]) {
        return [NSImage imageNamed:NSImageNameFolderSmart];
    } else {
        NSImage *image = [NSImage imageNamed:NSImageNameFolder];
        [image setTemplate:YES];
        return image;
    }
}

@end
