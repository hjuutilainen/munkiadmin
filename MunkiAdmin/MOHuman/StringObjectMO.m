#import "StringObjectMO.h"
#import "PackageMO.h"
#import "ApplicationMO.h"
#import "ConditionalItemMO.h"
#import "ManifestMO.h"
#import "CatalogMO.h"
#import "IconImageMO.h"

@implementation StringObjectMO

/*
 If we're setting conditional references to nil,
 we must be assigned to the manifest as a regular item
 */

- (void)setManagedInstallConditionalReference:(ConditionalItemMO *)managedInstallConditionalReference
{
    // Get the current state before changing anything
    ConditionalItemMO *oldConditionalReference = [self managedInstallConditionalReference];
    ManifestMO *currentManifestReference = [self managedInstallReference];

    [self willChangeValueForKey:@"managedInstallConditionalReference"];

    if (managedInstallConditionalReference) {
        // Moving to conditional: clear regular reference
        if (currentManifestReference) {
            [self setManagedInstallReference:nil];
        }
    } else {
        // Moving back to regular: clear conditional reference first, then set regular
        if (oldConditionalReference) {
            // First, set the conditional reference to nil to break the relationship
            [self setPrimitiveValue:nil forKey:@"managedInstallConditionalReference"];
            // Explicitly remove from the old conditional's managed installs
            [oldConditionalReference removeManagedInstallsObject:self];
            // Then set the regular reference
            [self setManagedInstallReference:[oldConditionalReference manifest]];
        }
        // Set the new conditional reference (which is nil in this case)
        [self setPrimitiveValue:managedInstallConditionalReference forKey:@"managedInstallConditionalReference"];
        [self didChangeValueForKey:@"managedInstallConditionalReference"];
        return; // Early return to avoid setting the value twice
    }

    // Set the new conditional reference
    [self setPrimitiveValue:managedInstallConditionalReference forKey:@"managedInstallConditionalReference"];
    [self didChangeValueForKey:@"managedInstallConditionalReference"];
}

- (void)setManagedUninstallConditionalReference:(ConditionalItemMO *)managedUninstallConditionalReference
{
    // Get the current state before changing anything
    ConditionalItemMO *oldConditionalReference = [self managedUninstallConditionalReference];
    ManifestMO *currentManifestReference = [self managedUninstallReference];

    [self willChangeValueForKey:@"managedUninstallConditionalReference"];

    if (managedUninstallConditionalReference) {
        // Moving to conditional: clear regular reference
        if (currentManifestReference) {
            [self setManagedUninstallReference:nil];
        }
    } else {
        // Moving back to regular: clear conditional reference first, then set regular
        if (oldConditionalReference) {
            // First, set the conditional reference to nil to break the relationship
            [self setPrimitiveValue:nil forKey:@"managedUninstallConditionalReference"];
            // Explicitly remove from the old conditional's managed uninstalls
            [oldConditionalReference removeManagedUninstallsObject:self];
            // Then set the regular reference
            [self setManagedUninstallReference:[oldConditionalReference manifest]];
        }
        // Set the new conditional reference (which is nil in this case)
        [self setPrimitiveValue:managedUninstallConditionalReference forKey:@"managedUninstallConditionalReference"];
        [self didChangeValueForKey:@"managedUninstallConditionalReference"];
        return; // Early return to avoid setting the value twice
    }

    // Set the new conditional reference
    [self setPrimitiveValue:managedUninstallConditionalReference forKey:@"managedUninstallConditionalReference"];
    [self didChangeValueForKey:@"managedUninstallConditionalReference"];
}

- (void)setManagedUpdateConditionalReference:(ConditionalItemMO *)managedUpdateConditionalReference
{
    // Get the current state before changing anything
    ConditionalItemMO *oldConditionalReference = [self managedUpdateConditionalReference];
    ManifestMO *currentManifestReference = [self managedUpdateReference];

    [self willChangeValueForKey:@"managedUpdateConditionalReference"];

    if (managedUpdateConditionalReference) {
        // Moving to conditional: clear regular reference
        if (currentManifestReference) {
            [self setManagedUpdateReference:nil];
        }
    } else {
        // Moving back to regular: clear conditional reference first, then set regular
        if (oldConditionalReference) {
            // First, set the conditional reference to nil to break the relationship
            [self setPrimitiveValue:nil forKey:@"managedUpdateConditionalReference"];
            // Explicitly remove from the old conditional's managed updates
            [oldConditionalReference removeManagedUpdatesObject:self];
            // Then set the regular reference
            [self setManagedUpdateReference:[oldConditionalReference manifest]];
        }
        // Set the new conditional reference (which is nil in this case)
        [self setPrimitiveValue:managedUpdateConditionalReference forKey:@"managedUpdateConditionalReference"];
        [self didChangeValueForKey:@"managedUpdateConditionalReference"];
        return; // Early return to avoid setting the value twice
    }

    // Set the new conditional reference
    [self setPrimitiveValue:managedUpdateConditionalReference forKey:@"managedUpdateConditionalReference"];
    [self didChangeValueForKey:@"managedUpdateConditionalReference"];
}

- (void)setOptionalInstallConditionalReference:(ConditionalItemMO *)optionalInstallConditionalReference
{
    // Get the current state before changing anything
    ConditionalItemMO *oldConditionalReference = [self optionalInstallConditionalReference];
    ManifestMO *currentManifestReference = [self optionalInstallReference];

    [self willChangeValueForKey:@"optionalInstallConditionalReference"];

    if (optionalInstallConditionalReference) {
        // Moving to conditional: clear regular reference
        if (currentManifestReference) {
            [self setOptionalInstallReference:nil];
        }
    } else {
        // Moving back to regular: clear conditional reference first, then set regular
        if (oldConditionalReference) {
            // First, set the conditional reference to nil to break the relationship
            [self setPrimitiveValue:nil forKey:@"optionalInstallConditionalReference"];
            // Explicitly remove from the old conditional's optional installs
            [oldConditionalReference removeOptionalInstallsObject:self];
            // Then set the regular reference
            [self setOptionalInstallReference:[oldConditionalReference manifest]];
        }
        // Set the new conditional reference (which is nil in this case)
        [self setPrimitiveValue:optionalInstallConditionalReference forKey:@"optionalInstallConditionalReference"];
        [self didChangeValueForKey:@"optionalInstallConditionalReference"];
        return; // Early return to avoid setting the value twice
    }

    // Set the new conditional reference
    [self setPrimitiveValue:optionalInstallConditionalReference forKey:@"optionalInstallConditionalReference"];
    [self didChangeValueForKey:@"optionalInstallConditionalReference"];
}

- (void)setDefaultInstallConditionalReference:(ConditionalItemMO *)defaultInstallConditionalReference
{
    // Get the current state before changing anything
    ConditionalItemMO *oldConditionalReference = [self defaultInstallConditionalReference];
    ManifestMO *currentManifestReference = [self defaultInstallReference];

    [self willChangeValueForKey:@"defaultInstallConditionalReference"];

    if (defaultInstallConditionalReference) {
        // Moving to conditional: clear regular reference
        if (currentManifestReference) {
            [self setDefaultInstallReference:nil];
        }
    } else {
        // Moving back to regular: clear conditional reference first, then set regular
        if (oldConditionalReference) {
            // First, set the conditional reference to nil to break the relationship
            [self setPrimitiveValue:nil forKey:@"defaultInstallConditionalReference"];
            // Explicitly remove from the old conditional's default installs
            [oldConditionalReference removeDefaultInstallsObject:self];
            // Then set the regular reference
            [self setDefaultInstallReference:[oldConditionalReference manifest]];
        }
        // Set the new conditional reference (which is nil in this case)
        [self setPrimitiveValue:defaultInstallConditionalReference forKey:@"defaultInstallConditionalReference"];
        [self didChangeValueForKey:@"defaultInstallConditionalReference"];
        return; // Early return to avoid setting the value twice
    }

    // Set the new conditional reference
    [self setPrimitiveValue:defaultInstallConditionalReference forKey:@"defaultInstallConditionalReference"];
    [self didChangeValueForKey:@"defaultInstallConditionalReference"];
}

- (void)setFeaturedItemConditionalReference:(ConditionalItemMO *)featuredItemConditionalReference
{
    // Get the current state before changing anything
    ConditionalItemMO *oldConditionalReference = [self featuredItemConditionalReference];
    ManifestMO *currentManifestReference = [self featuredItemReference];

    [self willChangeValueForKey:@"featuredItemConditionalReference"];

    if (featuredItemConditionalReference) {
        // Moving to conditional: clear regular reference
        if (currentManifestReference) {
            [self setFeaturedItemReference:nil];
        }
    } else {
        // Moving back to regular: clear conditional reference first, then set regular
        if (oldConditionalReference) {
            // First, set the conditional reference to nil to break the relationship
            [self setPrimitiveValue:nil forKey:@"featuredItemConditionalReference"];
            // Explicitly remove from the old conditional's featured items
            [oldConditionalReference removeFeaturedItemsObject:self];
            // Then set the regular reference
            [self setFeaturedItemReference:[oldConditionalReference manifest]];
        }
        // Set the new conditional reference (which is nil in this case)
        [self setPrimitiveValue:featuredItemConditionalReference forKey:@"featuredItemConditionalReference"];
        [self didChangeValueForKey:@"featuredItemConditionalReference"];
        return; // Early return to avoid setting the value twice
    }

    // Set the new conditional reference
    [self setPrimitiveValue:featuredItemConditionalReference forKey:@"featuredItemConditionalReference"];
    [self didChangeValueForKey:@"featuredItemConditionalReference"];
}

- (void)setIncludedManifestConditionalReference:(ConditionalItemMO *)includedManifestConditionalReference
{
    // Get the current state before changing anything
    ConditionalItemMO *oldConditionalReference = [self includedManifestConditionalReference];
    ManifestMO *currentManifestReference = [self manifestReference];

    [self willChangeValueForKey:@"includedManifestConditionalReference"];

    if (includedManifestConditionalReference) {
        // Moving to conditional: clear regular reference
        if (currentManifestReference) {
            [self setManifestReference:nil];
        }
    } else {
        // Moving back to regular: clear conditional reference first, then set regular
        if (oldConditionalReference) {
            // First, set the conditional reference to nil to break the relationship
            [self setPrimitiveValue:nil forKey:@"includedManifestConditionalReference"];
            // Explicitly remove from the old conditional's included manifests
            [oldConditionalReference removeIncludedManifestsObject:self];
            // Then set the regular reference
            [self setManifestReference:[oldConditionalReference manifest]];
        }
        // Set the new conditional reference (which is nil in this case)
        [self setPrimitiveValue:includedManifestConditionalReference forKey:@"includedManifestConditionalReference"];
        [self didChangeValueForKey:@"includedManifestConditionalReference"];
        return; // Early return to avoid setting the value twice
    }

    // Set the new conditional reference
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
        NSPredicate *packagePredicate = [NSPredicate predicateWithFormat:@"(package.munki_name == %@ OR package.titleWithVersion == %@) AND isEnabledForCatalog == TRUE", self.title, self.title];
        NSMutableSet *mutableSet = [NSMutableSet setWithCapacity:[catalogs count]];
        for (CatalogMO *catalog in catalogs) {
            NSSet *enabledPackageInfos = [catalog.packageInfos filteredSetUsingPredicate:packagePredicate];
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


- (NSString *)subtitle
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
    } else if (self.defaultInstallReference) {
        currentManifest = self.defaultInstallReference;
    } else if (self.featuredItemReference) {
        currentManifest = self.featuredItemReference;
    }
    
    /*
     Set the subtitle if referenced from a manifest
     */
    NSArray *packages = [self siblingPackagesWhenReferencedFromManifest:currentManifest];
    if (packages) {
        if ([packages count] == 0) {
            subtitle = @"No matching packages in selected catalogs";
        } else if ([packages count] == 1) {
            NSString *latestVersion = [[packages objectAtIndex:0] munki_version];
            //subtitle = [NSString stringWithFormat:@"%lu package (%@)", (unsigned long)[packages count], latestVersion];
            subtitle = [NSString stringWithFormat:@"%@", latestVersion];
        } else if ([packages count] > 1) {
            NSString *latestVersion = [[packages objectAtIndex:0] munki_version];
            //subtitle = [NSString stringWithFormat:@"%lu packages (%@)", (unsigned long)[packages count], latestVersion];
            subtitle = [NSString stringWithFormat:@"%@", latestVersion];
        }
    }
    
    /*
     Or get all packages with same title
     */
    else {
        NSUInteger numPkgs = [self.packagesWithSameTitle count];
        if (numPkgs == 0) {
            subtitle = @"No matching packages in any catalog";
        } else {
            NSSortDescriptor *byVersion = [NSSortDescriptor sortDescriptorWithKey:@"munki_version" ascending:NO selector:@selector(localizedStandardCompare:)];
            NSArray *foundPkgs = [self.packagesWithSameTitle sortedArrayUsingDescriptors:[NSArray arrayWithObject:byVersion]];
            NSString *latestVersion = [[foundPkgs objectAtIndex:0] munki_version];
            if (numPkgs == 1) {
                //subtitle = [NSString stringWithFormat:@"%lu package (%@)", (unsigned long)numPkgs, latestVersion];
                subtitle = [NSString stringWithFormat:@"%@", latestVersion];
            } else {
                //subtitle = [NSString stringWithFormat:@"%lu packages (%@)", (unsigned long)numPkgs, latestVersion];
                subtitle = [NSString stringWithFormat:@"%@", latestVersion];
            }
        }
    }
    return subtitle;
}


- (NSDictionary *)dictValue
{
    NSString *subtitle = [self subtitle];

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

- (NSString *)nestedManifestContentsDescription
{
    NSUInteger numManifests = [self.manifestsWithSameTitle count];
    if (numManifests == 0) {
        return @"--";
    } else {
        return [self.manifestsWithSameTitle[0] manifestContentsDescription];
    }
}

- (NSImage *)nestedManifestImage
{
    return [NSImage imageNamed:@"manifestIcon_32x32"];
}


- (NSImage *)image
{
    NSUInteger numPkgs = [self.packagesWithSameTitle count];
    if (numPkgs > 0) {
        NSSortDescriptor *byVersion = [NSSortDescriptor sortDescriptorWithKey:@"munki_version" ascending:NO selector:@selector(localizedStandardCompare:)];
        NSArray *foundPkgs = [self.packagesWithSameTitle sortedArrayUsingDescriptors:[NSArray arrayWithObject:byVersion]];
        IconImageMO *iconImage = [[foundPkgs objectAtIndex:0] iconImage];
        return iconImage.imageRepresentation;
    }
    
    return [[NSWorkspace sharedWorkspace] iconForFileType:@"pkg"];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self invalidateManifestCountCaches];
}

- (void)willSave
{
    [super willSave];
    if ([self isUpdated] || [self isInserted] || [self isDeleted]) {
        [self invalidateManifestCountCaches];
    }
}

- (void)invalidateManifestCountCaches
{
    // Invalidate cache for any manifest this string object is related to

    // Direct manifest references
    [[self managedInstallReference] invalidateCountCaches];
    [[self managedUninstallReference] invalidateCountCaches];
    [[self managedUpdateReference] invalidateCountCaches];
    [[self optionalInstallReference] invalidateCountCaches];
    [[self defaultInstallReference] invalidateCountCaches];
    [[self featuredItemReference] invalidateCountCaches];
    [[self manifestReference] invalidateCountCaches];

    // Conditional manifest references (via conditional items)
    [[[self managedInstallConditionalReference] manifest] invalidateCountCaches];
    [[[self managedUninstallConditionalReference] manifest] invalidateCountCaches];
    [[[self managedUpdateConditionalReference] manifest] invalidateCountCaches];
    [[[self optionalInstallConditionalReference] manifest] invalidateCountCaches];
    [[[self defaultInstallConditionalReference] manifest] invalidateCountCaches];
    [[[self featuredItemConditionalReference] manifest] invalidateCountCaches];
    [[[self includedManifestConditionalReference] manifest] invalidateCountCaches];
}


@end
