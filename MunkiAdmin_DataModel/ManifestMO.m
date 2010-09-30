#import "ManifestMO.h"
#import "ManifestInfoMO.h"
#import "CatalogInfoMO.h"
#import "ApplicationInfoMO.h"

@implementation ManifestMO

- (NSArray *)enabledApplications
{
	NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:@"isEnabledForManifest == TRUE"];
	NSArray *tempArray = [[self.applicationInfos allObjects] filteredArrayUsingPredicate:enabledPredicate];
	return tempArray;
}

- (NSArray *)enabledCatalogs
{
	NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:@"isEnabledForManifest == TRUE"];
	NSArray *tempArray = [[self.catalogInfos allObjects] filteredArrayUsingPredicate:enabledPredicate];
	return tempArray;
}

- (NSArray *)enabledManifests
{
	NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:@"isEnabledForManifest == TRUE"];
	NSArray *tempArray = [[self.includedManifests allObjects] filteredArrayUsingPredicate:enabledPredicate];
	return tempArray;
}


- (NSDictionary *)dictValue
{
	NSString *subtitle;
	if ([self.applications count] == 0) {
		subtitle = @"No applications";
	} else if ([self.applications count] == 1) {
		subtitle = @"1 application included";
	} else {
		subtitle = [NSString stringWithFormat:@"%i applications included", [[self enabledApplications] count]];
	}
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.title, @"title",
			subtitle, @"subtitle",
			@"manifest", @"type",
			nil];
}

- (NSDictionary *)manifestInfoDictionary
{
	NSSortDescriptor *sortCatalogsByTitle = [[[NSSortDescriptor alloc] initWithKey:@"catalog.title" ascending:YES selector:@selector(localizedStandardCompare:)] autorelease];
	NSMutableArray *catalogs = [NSMutableArray arrayWithCapacity:[self.catalogInfos count]];
	for (CatalogInfoMO *catalogInfo in [self.catalogInfos sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortCatalogsByTitle]]) {
		if (([catalogInfo isEnabledForManifestValue]) && (![catalogs containsObject:[[catalogInfo catalog] title]])) {
			[catalogs addObject:[[catalogInfo catalog] title]];
		}
	}
	
	NSSortDescriptor *sortApplicationsByTitle = [[[NSSortDescriptor alloc] initWithKey:@"application.munki_name" ascending:YES selector:@selector(localizedStandardCompare:)] autorelease];
	NSMutableArray *managedInstalls = [NSMutableArray arrayWithCapacity:[self.applicationInfos count]];
	for (ApplicationInfoMO *applicationInfo in [self.applicationInfos sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortApplicationsByTitle]]) {
		if (([applicationInfo isEnabledForManifestValue]) && (![managedInstalls containsObject:[applicationInfo munki_name]])) {
			[managedInstalls addObject:[applicationInfo munki_name]];
		}
	}
	
	NSSortDescriptor *sortManifestsByTitle = [[[NSSortDescriptor alloc] initWithKey:@"parentManifest.title" ascending:YES selector:@selector(localizedStandardCompare:)] autorelease];
	NSMutableArray *includedManifests = [NSMutableArray arrayWithCapacity:[self.includedManifests count]];
	for (ManifestInfoMO *manifestInfo in [self.includedManifests sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortManifestsByTitle]]) {
		if (([manifestInfo isEnabledForManifestValue]) && (![includedManifests containsObject:[[manifestInfo parentManifest] title]])) {
			[includedManifests addObject:[[manifestInfo parentManifest] title]];
		}
	}
	
	NSDictionary *infoDictInMemory = [NSDictionary dictionaryWithObjectsAndKeys:
									  catalogs, @"catalogs",
									  managedInstalls, @"managed_installs",
									  includedManifests, @"included_manifests",
									  nil];
	
	return infoDictInMemory;
}


@end
