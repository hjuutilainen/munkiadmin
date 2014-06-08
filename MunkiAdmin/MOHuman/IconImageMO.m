#import "IconImageMO.h"
#import <Quartz/Quartz.h>

@interface IconImageMO ()

// Private interface goes here.

@end


@implementation IconImageMO

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"imageTitle"])
    {
        NSSet *affectingKeys = [NSSet setWithObjects:@"originalURL", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }
	
    return keyPaths;
}

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
    return [[[self objectID] URIRepresentation] description];
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
