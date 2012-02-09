#import "StringObjectMO.h"
#import "PackageMO.h"
#import "ApplicationMO.h"
#import "ConditionalItemMO.h"

@implementation StringObjectMO

/*
 If we're setting conditional references to nil,
 we must be assigned to the manifest as a regular item
 */

- (void)setManagedInstallConditionalReference:(ConditionalItemMO *)managedInstallConditionalReference
{
    [self willChangeValueForKey:@"managedInstallConditionalReference"];
    if (managedInstallConditionalReference) {
        [self setManagedInstallReference:nil];
    } else {
        [self setManagedInstallReference:[[self managedInstallConditionalReference] manifest]];
    }
    // Set the new value
    [self setPrimitiveValue:managedInstallConditionalReference forKey:@"managedInstallConditionalReference"];
    [self didChangeValueForKey:@"managedInstallConditionalReference"];
}

- (void)setManagedUninstallConditionalReference:(ConditionalItemMO *)managedUninstallConditionalReference
{
    [self willChangeValueForKey:@"managedUninstallConditionalReference"];
    if (managedUninstallConditionalReference) {
        [self setManagedUninstallReference:nil];
    } else {
        [self setManagedUninstallReference:[[self managedUninstallConditionalReference] manifest]];
    }
    // Set the new value
    [self setPrimitiveValue:managedUninstallConditionalReference forKey:@"managedUninstallConditionalReference"];
    [self didChangeValueForKey:@"managedUninstallConditionalReference"];
}

- (void)setManagedUpdateConditionalReference:(ConditionalItemMO *)managedUpdateConditionalReference
{
    [self willChangeValueForKey:@"managedUpdateConditionalReference"];
    if (managedUpdateConditionalReference) {
        [self setManagedUpdateReference:nil];
    } else {
        [self setManagedUpdateReference:[[self managedUpdateConditionalReference] manifest]];
    }
    // Set the new value
    [self setPrimitiveValue:managedUpdateConditionalReference forKey:@"managedUpdateConditionalReference"];
    [self didChangeValueForKey:@"managedUpdateConditionalReference"];
}

- (void)setOptionalInstallConditionalReference:(ConditionalItemMO *)optionalInstallConditionalReference
{
    [self willChangeValueForKey:@"optionalInstallConditionalReference"];
    if (optionalInstallConditionalReference) {
        [self setOptionalInstallReference:nil];
    } else {
        [self setOptionalInstallReference:[[self optionalInstallConditionalReference] manifest]];
    }
    // Set the new value
    [self setPrimitiveValue:optionalInstallConditionalReference forKey:@"optionalInstallConditionalReference"];
    [self didChangeValueForKey:@"optionalInstallConditionalReference"];
}

- (void)setIncludedManifestConditionalReference:(ConditionalItemMO *)includedManifestConditionalReference
{
    [self willChangeValueForKey:@"includedManifestConditionalReference"];
    if (includedManifestConditionalReference) {
        [self setManifestReference:nil];
    } else {
        [self setManifestReference:[[self includedManifestConditionalReference] manifest]];
    }
    // Set the new value
    [self setPrimitiveValue:includedManifestConditionalReference forKey:@"includedManifestConditionalReference"];
    [self didChangeValueForKey:@"includedManifestConditionalReference"];
}

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
