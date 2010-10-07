#import "ManifestMO.h"
#import "ManifestInfoMO.h"
#import "CatalogInfoMO.h"
#import "ApplicationMO.h"
#import "ManagedUpdateMO.h"
#import "ManagedInstallMO.h"
#import "ManagedUninstallMO.h"
#import "OptionalInstallMO.h"

@implementation ManifestMO

- (NSArray *)enabledManagedUpdates
{
	NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:@"isEnabled == TRUE"];
	NSArray *tempArray = [[self.managedUpdates allObjects] filteredArrayUsingPredicate:enabledPredicate];
	return tempArray;
}

- (NSArray *)enabledManagedInstalls
{
	NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:@"isEnabled == TRUE"];
	NSArray *tempArray = [[self.managedInstalls allObjects] filteredArrayUsingPredicate:enabledPredicate];
	return tempArray;
}

- (NSArray *)enabledManagedUninstalls
{
	NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:@"isEnabled == TRUE"];
	NSArray *tempArray = [[self.managedUninstalls allObjects] filteredArrayUsingPredicate:enabledPredicate];
	return tempArray;
}

- (NSArray *)enabledOptionalInstalls
{
	NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:@"isEnabled == TRUE"];
	NSArray *tempArray = [[self.optionalInstalls allObjects] filteredArrayUsingPredicate:enabledPredicate];
	return tempArray;
}

- (NSArray *)enabledCatalogs
{
	NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:@"isEnabledForManifest == TRUE"];
	NSArray *tempArray = [[self.catalogInfos allObjects] filteredArrayUsingPredicate:enabledPredicate];
	return tempArray;
}

- (NSArray *)enabledIncludedManifests
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
		subtitle = [NSString stringWithFormat:@"%i managed installs", [[self enabledManagedInstalls] count]];
	}
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.title, @"title",
			subtitle, @"subtitle",
			@"manifest", @"type",
			nil];
}

- (NSDictionary *)manifestInfoDictionary
{
	NSMutableDictionary *tmpDict = [[[NSMutableDictionary alloc] init] autorelease];
	
	if (self.catalogInfos != nil) {
		NSSortDescriptor *sortCatalogsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"catalog.title" ascending:YES selector:@selector(localizedStandardCompare:)];
		NSSortDescriptor *sortCatalogsByOrigIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
		NSMutableArray *catalogs = [NSMutableArray arrayWithCapacity:[self.catalogInfos count]];
		for (CatalogInfoMO *catalogInfo in [self.catalogInfos sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortCatalogsByOrigIndex, sortCatalogsByTitle,nil]]) {
			if (([catalogInfo isEnabledForManifestValue]) && (![catalogs containsObject:[[catalogInfo catalog] title]])) {
				[catalogs addObject:[[catalogInfo catalog] title]];
			}
		}
		[tmpDict setObject:catalogs forKey:@"catalogs"];
	}
	
	NSSortDescriptor *sortApplicationsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"parentApplication.munki_name" ascending:YES selector:@selector(localizedStandardCompare:)];
	
	if ([[self enabledManagedInstalls] count] > 0) {
		NSMutableArray *managedInstalls = [NSMutableArray arrayWithCapacity:[self.managedInstalls count]];
		for (ManagedInstallMO *managedInstall in [self.managedInstalls sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortApplicationsByTitle]]) {
			if (([managedInstall isEnabledValue]) && (![managedInstalls containsObject:[[managedInstall parentApplication] munki_name]])) {
				[managedInstalls addObject:[[managedInstall parentApplication] munki_name]];
			}
		}
		[tmpDict setObject:managedInstalls forKey:@"managed_installs"];
	} else {
		if ([(NSDictionary *)self.originalManifest objectForKey:@"managed_installs"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"managed_installs"];
		}
	}
	
	if ([[self enabledManagedUninstalls] count] > 0) {
		NSMutableArray *managedUninstalls = [NSMutableArray arrayWithCapacity:[self.managedUninstalls count]];
		for (ManagedUninstallMO *managedUninstall in [self.managedUninstalls sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortApplicationsByTitle]]) {
			if (([managedUninstall isEnabledValue]) && (![managedUninstalls containsObject:[[managedUninstall parentApplication] munki_name]])) {
				[managedUninstalls addObject:[[managedUninstall parentApplication] munki_name]];
			}
		}
		[tmpDict setObject:managedUninstalls forKey:@"managed_uninstalls"];
	} else {
		if ([(NSDictionary *)self.originalManifest objectForKey:@"managed_uninstalls"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"managed_uninstalls"];
		}
	}
	
	if ([[self enabledManagedUpdates] count] > 0) {
		NSMutableArray *managedUpdates = [NSMutableArray arrayWithCapacity:[self.managedUpdates count]];
		for (ManagedUpdateMO *managedUpdate in [self.managedUpdates sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortApplicationsByTitle]]) {
			if (([managedUpdate isEnabledValue]) && (![managedUpdates containsObject:[[managedUpdate parentApplication] munki_name]])) {
				[managedUpdates addObject:[[managedUpdate parentApplication] munki_name]];
			}
		}
		[tmpDict setObject:managedUpdates forKey:@"managed_updates"];
	} else {
		if ([(NSDictionary *)self.originalManifest objectForKey:@"managed_updates"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"managed_updates"];
		}
	}
	
	if ([[self enabledOptionalInstalls] count] > 0) {
		NSMutableArray *optionalInstalls = [NSMutableArray arrayWithCapacity:[self.optionalInstalls count]];
		for (OptionalInstallMO *optionalUpdate in [self.optionalInstalls sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortApplicationsByTitle]]) {
			if (([optionalUpdate isEnabledValue]) && (![optionalInstalls containsObject:[[optionalUpdate parentApplication] munki_name]])) {
				[optionalInstalls addObject:[[optionalUpdate parentApplication] munki_name]];
			}
		}
		[tmpDict setObject:optionalInstalls forKey:@"optional_installs"];
	} else {
		if ([(NSDictionary *)self.originalManifest objectForKey:@"optional_installs"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"optional_installs"];
		}
	}
	
	if ([[self enabledIncludedManifests] count] > 0) {
		NSSortDescriptor *sortManifestsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"parentManifest.title" ascending:YES selector:@selector(localizedStandardCompare:)];
		NSMutableArray *includedManifests = [NSMutableArray arrayWithCapacity:[self.includedManifests count]];
		for (ManifestInfoMO *manifestInfo in [self.includedManifests sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortManifestsByTitle]]) {
			if (([manifestInfo isEnabledForManifestValue]) && (![includedManifests containsObject:[[manifestInfo parentManifest] title]])) {
				[includedManifests addObject:[[manifestInfo parentManifest] title]];
			}
		}
		[tmpDict setObject:includedManifests forKey:@"included_manifests"];
	} else {
		if ([(NSDictionary *)self.originalManifest objectForKey:@"included_manifests"] != nil) {
			[tmpDict setObject:[NSArray array] forKey:@"included_manifests"];
		}
	}
	
	NSDictionary *infoDictInMemory = [NSDictionary dictionaryWithDictionary:tmpDict];
	
	return infoDictInMemory;
}


@end
