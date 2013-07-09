#import "StringObjectMO.h"
#import "PackageMO.h"
#import "ApplicationMO.h"
#import "ConditionalItemMO.h"
#import "ManifestMO.h"
#import "CatalogMO.h"

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

- (NSArray *)siblingPackagesWhenReferencedFromManifest:(ManifestMO *)manifest
{
    if (manifest == nil) {
        return nil;
    }
    
    NSArray *array = nil;
    
    /*
     Get the catalog titles for this manifest
     */
    NSSet *enabledCatalogInfos = [manifest.catalogInfos filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"isEnabledForManifest == TRUE"]];
    NSSet *enabledCatalogTitles = [enabledCatalogInfos valueForKeyPath:@"catalog.title"];
    
    /*
     Now fetch the actual catalog objects
     */
    NSFetchRequest *catalogFetch = [NSFetchRequest new];
    [catalogFetch setEntity:[NSEntityDescription entityForName:@"Catalog" inManagedObjectContext:self.managedObjectContext]];
    [catalogFetch setPredicate:[NSPredicate predicateWithFormat:@"title IN %@", enabledCatalogTitles]];
    if ([self.managedObjectContext countForFetchRequest:catalogFetch error:nil] > 0) {
        NSArray *catalogs = [self.managedObjectContext executeFetchRequest:catalogFetch error:nil];
        
        /*
         Get package proxy objects from catalog objects
         */
        NSMutableSet *mutableSet = [NSMutableSet setWithCapacity:[catalogs count]];
        for (CatalogMO *catalog in catalogs) {
            NSSet *enabledPackageInfos = [catalog.packageInfos filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"package.munki_name == %@ AND isEnabledForCatalog == TRUE", self.title]];
            [mutableSet addObject:enabledPackageInfos];
        }
        
        /*
         Create a set containing the distinct package objects and sort the by version key
         */
        NSSet *unionSet = [mutableSet valueForKeyPath:@"@distinctUnionOfSets.package"];
        NSSortDescriptor *byVersion = [NSSortDescriptor sortDescriptorWithKey:@"munki_version" ascending:NO selector:@selector(localizedStandardCompare:)];
        array = [unionSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:byVersion]];
    }
    
    return array;
}

- (NSDictionary *)dictValue
{
    NSString *subtitle;
    
    ManifestMO *currentManifest = nil;
    if (self.managedInstallReference) {
        currentManifest = self.managedInstallReference;
    } else if (self.managedUninstallReference) {
        currentManifest = self.managedUninstallReference;
    } else if (self.managedUpdateReference) {
        currentManifest = self.managedUpdateReference;
    } else if (self.optionalInstallReference) {
        currentManifest = self.optionalInstallReference;
    }
    
    /*
     Set the subtitle if referenced from a manifest
     */
    NSArray *packages = [self siblingPackagesWhenReferencedFromManifest:currentManifest];
    if (packages != nil) {
        NSString *latestVersion = [[packages objectAtIndex:0] munki_version];
        if ([packages count] == 1) {
            subtitle = [NSString stringWithFormat:@"%lu matching package (%@)", (unsigned long)[packages count], latestVersion];
        } else {
            subtitle = [NSString stringWithFormat:@"%lu matching packages (%@)", (unsigned long)[packages count], latestVersion];
        }
    }
    
    /*
     Or get all packages with same title
     */
    else {
        NSUInteger numPkgs = [self.packagesWithSameTitle count];
        if (numPkgs == 0) {
            subtitle = @"";
        } else {
            NSSortDescriptor *byVersion = [NSSortDescriptor sortDescriptorWithKey:@"munki_version" ascending:NO selector:@selector(localizedStandardCompare:)];
            NSArray *foundPkgs = [self.packagesWithSameTitle sortedArrayUsingDescriptors:[NSArray arrayWithObject:byVersion]];
            NSString *latestVersion = [[foundPkgs objectAtIndex:0] munki_version];
            if (numPkgs == 1) {
                subtitle = [NSString stringWithFormat:@"%lu matching package (%@)", (unsigned long)numPkgs, latestVersion];
            } else {
                subtitle = [NSString stringWithFormat:@"%lu matching packages (%@)", (unsigned long)numPkgs, latestVersion];
            }
        }
    }

	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.title, @"title",
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
