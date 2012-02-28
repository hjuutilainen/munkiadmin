#import "PackageSourceListItemMO.h"

@implementation PackageSourceListItemMO

- (NSImage *)icon
{
    if ([self.type isEqualToString:@"regular"]) {
        NSImage *regularFolder = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
        return regularFolder;
    } else if ([self.type isEqualToString:@"smart"]) {
        return [NSImage imageNamed:@"NSFolderSmart"];
    } else if (self.isGroupItemValue) {
        return nil;
    }
    else {
        return [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
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
