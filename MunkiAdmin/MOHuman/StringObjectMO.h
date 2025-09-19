#import "_StringObjectMO.h"

@interface StringObjectMO : _StringObjectMO {}

@property (weak, readonly) NSString *nestedManifestContentsDescription;
@property (weak, readonly) NSImage *nestedManifestImage;
@property (weak, readonly) NSDictionary *dictValue;
@property (weak, readonly) NSImage *image;
@property (weak, readonly) NSString *subtitle;

- (void)invalidateManifestCountCaches;

@end
