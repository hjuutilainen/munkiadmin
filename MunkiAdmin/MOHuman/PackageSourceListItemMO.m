#import "PackageSourceListItemMO.h"

@implementation PackageSourceListItemMO

- (NSImage *)icon
{
    if ([self.itemType isEqualToString:@"regular"]) {
        NSImage *regularFolder = [NSImage imageNamed:NSImageNameFolder];
        return regularFolder;
    } else if ([self.itemType isEqualToString:@"smart"]) {
        return [NSImage imageNamed:@"NSFolderSmart"];
    } else if (self.isGroupItemValue) {
        return nil;
    }
    else {
        return [NSImage imageNamed:NSImageNameFolder];
    }
}


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
