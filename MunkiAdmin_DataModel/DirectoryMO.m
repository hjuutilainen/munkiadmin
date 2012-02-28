#import "DirectoryMO.h"

@implementation DirectoryMO

- (NSImage *)icon
{
    if ([self.type isEqualToString:@"regular"]) {
        NSImage *regularFolder = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
        return regularFolder;
    } else if ([self.type isEqualToString:@"smart"]) {
        return [NSImage imageNamed:@"NSFolderSmart"];
    } else {
        return [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
    }
}

- (NSDictionary *)dictValue
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.title, @"title",
			@"", @"subtitle",
			[self icon], @"icon",
			nil];
}

@end
