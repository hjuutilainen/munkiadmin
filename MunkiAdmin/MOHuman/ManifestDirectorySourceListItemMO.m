#import "ManifestDirectorySourceListItemMO.h"

@implementation ManifestDirectorySourceListItemMO

- (NSURL *)representedFileURLValue
{
    if (self.representedFileURL) {
        return [NSURL URLWithString:self.representedFileURL];
    }
    return nil;
}

- (void)setRepresentedFileURLValue:(NSURL *)url
{
    if (url) {
        self.representedFileURL = [url absoluteString];
    } else {
        self.representedFileURL = nil;
    }
}

@end
