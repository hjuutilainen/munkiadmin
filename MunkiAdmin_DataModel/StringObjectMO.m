#import "StringObjectMO.h"
#import "PackageMO.h"
#import "ApplicationMO.h"

@implementation StringObjectMO

- (NSDictionary *)dictValue
{
    NSString *subtitle;
    NSUInteger numPkgs = [self.packagesWithSameTitle count];
    if (numPkgs == 0) {
        subtitle = @"--";
    } else {
        NSSortDescriptor *byVersion = [NSSortDescriptor sortDescriptorWithKey:@"munki_version" ascending:NO selector:@selector(localizedStandardCompare:)];
        NSArray *foundPkgs = [self.packagesWithSameTitle sortedArrayUsingDescriptors:[NSArray arrayWithObject:byVersion]];
        NSString *latestVersion = [[foundPkgs objectAtIndex:0] munki_version];
        if (numPkgs == 1) {
            subtitle = [NSString stringWithFormat:@"%i matching package (%@)", numPkgs, latestVersion];
        } else {
            subtitle = [NSString stringWithFormat:@"%i matching packages (%@)", numPkgs, latestVersion];
        }
    }
    
    NSString *newTitle;
    if (self.originalApplication != nil) {
        newTitle = self.originalApplication.munki_name;
    } else if (self.originalPackage != nil) {
        newTitle = self.title;
    } else {
        newTitle = self.title;
    }
    
	return [NSDictionary dictionaryWithObjectsAndKeys:
			newTitle, @"title",
            self.typeString, @"type",
            subtitle, @"subtitle",
			nil];
}

- (NSDictionary *)dictValueForNestedManifests
{
    NSUInteger numManifests = [self.manifestsWithSameTitle count];
    if (numManifests == 0) {
        NSString *subtitle = @"--";
        return [NSDictionary dictionaryWithObjectsAndKeys:
                self.title, @"title",
                self.typeString, @"type",
                subtitle, @"subtitle",
                nil];
    } else {
        return [[self.manifestsWithSameTitle objectAtIndex:0] dictValue];
    }
}


@end
