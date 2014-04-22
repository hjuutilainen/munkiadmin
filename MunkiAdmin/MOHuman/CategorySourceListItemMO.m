#import "CategorySourceListItemMO.h"


@interface CategorySourceListItemMO ()

// Private interface goes here.

@end


@implementation CategorySourceListItemMO

- (NSImage *)icon
{
    if ([self.type isEqualToString:@"regular"]) {
        NSImage *categoryImage = categoryImage = [NSImage imageNamed:NSImageNameActionTemplate];
        [categoryImage setTemplate:YES];
        return categoryImage;
    } else if ([self.type isEqualToString:@"smart"]) {
        return [NSImage imageNamed:NSImageNameFolderSmart];
    } else {
        NSImage *categoryImage = [NSImage imageNamed:NSImageNameBookmarksTemplate];
        [categoryImage setTemplate:YES];
        return categoryImage;
    }
}

@end
