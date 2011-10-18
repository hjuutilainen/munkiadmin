#import "StringObjectMO.h"

@implementation StringObjectMO

- (NSDictionary *)dictValue
{
    NSString *subtitle;
    NSUInteger numPkgs = [self.packagesWithSameTitle count];
    if (numPkgs == 1) {
        subtitle = [NSString stringWithFormat:@"%i matching package", numPkgs];
    } else {
        subtitle = [NSString stringWithFormat:@"%i matching packages", numPkgs];
    }
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.title, @"title",
            self.typeString, @"type",
            subtitle, @"subtitle",
			nil];
}


@end
