#import "IconImageMO.h"
#import <Quartz/Quartz.h>

@interface IconImageMO ()

// Private interface goes here.

@end


@implementation IconImageMO

- (void)setImageRepresentation:(NSImage *)imageRep {
    [self willChangeValueForKey:@"imageRepresentation"];
    [self setPrimitiveImageRepresentation:imageRep];
    [self didChangeValueForKey:@"imageRepresentation"];
}

- (NSString *)imageRepresentationType {
    return IKImageBrowserNSImageRepresentationType;
}

- (NSString *)imageUID {
    // Use the NSManagedObjectID for the entity to generate a unique string.
    return [[self.objectID URIRepresentation] description];
}

- (NSString *)imageTitle
{
    if (self.originalURL) {
        return [[self.originalURL path] lastPathComponent];
    } else {
        return @"Default";
    }
	
}

@end
