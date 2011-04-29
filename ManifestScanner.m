//
//  ManifestScanner.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 6.10.2010.
//

#import "ManifestScanner.h"
#import "CatalogMO.h"
#import "CatalogInfoMO.h"
#import "ApplicationMO.h"
#import "ApplicationProxyMO.h"
#import "ManagedInstallMO.h"
#import "ManagedUninstallMO.h"
#import "ManagedUpdateMO.h"
#import "OptionalInstallMO.h"

@implementation ManifestScanner

@synthesize currentJobDescription;
@synthesize fileName;
@synthesize sourceURL;
@synthesize delegate;
@synthesize pkginfoKeyMappings;
@synthesize receiptKeyMappings;
@synthesize installsKeyMappings;

- (NSUserDefaults *)defaults
{
	return [NSUserDefaults standardUserDefaults];
}


- (id)initWithURL:(NSURL *)src {
	if ((self = [super init])) {
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Initializing manifest operation");
		self.sourceURL = src;
		self.fileName = [self.sourceURL lastPathComponent];
		self.currentJobDescription = @"Initializing pkginfo scan operaiton";
		
	}
	return self;
}

- (void)dealloc {
	[fileName release];
	[currentJobDescription release];
	[sourceURL release];
	[delegate release];
	[pkginfoKeyMappings release];
	[receiptKeyMappings release];
	[installsKeyMappings release];
	[super dealloc];
}

- (void)contextDidSave:(NSNotification*)notification 
{
	[[self delegate] performSelectorOnMainThread:@selector(mergeChanges:) 
									  withObject:notification 
								   waitUntilDone:YES];
}


-(void)main {
	@try {
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
		NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
		[moc setPersistentStoreCoordinator:[[self delegate] persistentStoreCoordinator]];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(contextDidSave:)
													 name:NSManagedObjectContextDidSaveNotification
												   object:moc];
		NSEntityDescription *catalogEntityDescr = [NSEntityDescription entityForName:@"Catalog" inManagedObjectContext:moc];
		//NSEntityDescription *packageEntityDescr = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc];
		NSEntityDescription *manifestEntityDescr = [NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:moc];
		NSEntityDescription *applicationEntityDescr = [NSEntityDescription entityForName:@"Application" inManagedObjectContext:moc];
		
		
		
		
		self.currentJobDescription = [NSString stringWithFormat:@"Reading manifest %@", self.fileName];
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Reading manifest %@", [self.sourceURL relativePath]);
		
		NSDictionary *manifestInfoDict = [NSDictionary dictionaryWithContentsOfURL:self.sourceURL];
		if (manifestInfoDict != nil) {
			
			NSString *filename = nil;
			[self.sourceURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
						
			// Check if we already have a manifest with this name
			NSFetchRequest *request = [[NSFetchRequest alloc] init];
			[request setEntity:manifestEntityDescr];
			
			NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title == %@", filename];
			[request setPredicate:titlePredicate];
			ManifestMO *manifest;
			NSUInteger foundItems = [moc countForFetchRequest:request error:nil];
			if (foundItems == 0) {
				manifest = [NSEntityDescription insertNewObjectForEntityForName:@"Manifest" inManagedObjectContext:moc];
				manifest.title = filename;
				manifest.manifestURL = self.sourceURL;
			} else {
				manifest = [[moc executeFetchRequest:request error:nil] objectAtIndex:0];
				if ([self.defaults boolForKey:@"debug"]) {
					NSLog(@"Found existing manifest %@", manifest.title);
				}
			}
			[request release];
			
			manifest.originalManifest = manifestInfoDict;
			
			// Parse manifests catalog array
			NSArray *catalogs = [manifestInfoDict objectForKey:@"catalogs"];
			
			NSArray *allCatalogs;
			NSFetchRequest *getAllCatalogs = [[NSFetchRequest alloc] init];
			[getAllCatalogs setEntity:catalogEntityDescr];
			[getAllCatalogs setReturnsObjectsAsFaults:NO];
            [getAllCatalogs setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"catalogInfos", @"manifests", @"packageInfos", nil]];
            allCatalogs = [moc executeFetchRequest:getAllCatalogs error:nil];
			[getAllCatalogs release];
			
			[allCatalogs enumerateObjectsUsingBlock:^(id aCatalog, NSUInteger idx, BOOL *stop) {
                NSString *catalogTitle = [aCatalog title];
				CatalogInfoMO *newCatalogInfo;
				newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:moc];
				newCatalogInfo.catalog.title = catalogTitle;
				[aCatalog addManifestsObject:manifest];
				newCatalogInfo.manifest = manifest;
				[aCatalog addCatalogInfosObject:newCatalogInfo];
				
				if (catalogs == nil) {
					newCatalogInfo.isEnabledForManifestValue = NO;
					newCatalogInfo.originalIndexValue = 1000;
				} else if ([catalogs containsObject:catalogTitle]) {
					newCatalogInfo.isEnabledForManifestValue = YES;
					newCatalogInfo.originalIndexValue = [catalogs indexOfObject:catalogTitle];
				} else {
					newCatalogInfo.isEnabledForManifestValue = NO;
					newCatalogInfo.originalIndexValue = 1000;
				}
			}];
			
            
			// Parse manifests managed_installs array
			NSArray *managedInstalls = [manifestInfoDict objectForKey:@"managed_installs"];
			NSArray *managedUninstalls = [manifestInfoDict objectForKey:@"managed_uninstalls"];
			NSArray *managedUpdates = [manifestInfoDict objectForKey:@"managed_updates"];
			NSArray *optionalInstalls = [manifestInfoDict objectForKey:@"optional_installs"];
			
			NSArray *allApplications;
			NSFetchRequest *getAllApplications = [[NSFetchRequest alloc] init];
			[getAllApplications setEntity:applicationEntityDescr];
            [getAllApplications setReturnsObjectsAsFaults:NO];
            [getAllApplications setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"manifests", @"applicationProxies", nil]];
			allApplications = [moc executeFetchRequest:getAllApplications error:nil];
			[getAllApplications release];
			
            [allApplications enumerateObjectsUsingBlock:^(id anApplication, NSUInteger idx, BOOL *stop) {
				[anApplication addManifestsObject:manifest];
                
                NSString *tempAppName = [anApplication munki_name];
				
				ManagedInstallMO *newManagedInstall = [NSEntityDescription insertNewObjectForEntityForName:@"ManagedInstall" inManagedObjectContext:moc];
				newManagedInstall.manifest = manifest;
				[anApplication addApplicationProxiesObject:newManagedInstall];
				if (managedInstalls == nil) {
					newManagedInstall.isEnabledValue = NO;
				} else if ([managedInstalls containsObject:tempAppName]) {
					newManagedInstall.isEnabledValue = YES;
				} else {
					newManagedInstall.isEnabledValue = NO;
				}
				
				ManagedUninstallMO *newManagedUninstall = [NSEntityDescription insertNewObjectForEntityForName:@"ManagedUninstall" inManagedObjectContext:moc];
				newManagedUninstall.manifest = manifest;
				[anApplication addApplicationProxiesObject:newManagedUninstall];
				if (managedUninstalls == nil) {
					newManagedUninstall.isEnabledValue = NO;
				} else if ([managedUninstalls containsObject:tempAppName]) {
					newManagedUninstall.isEnabledValue = YES;
				} else {
					newManagedUninstall.isEnabledValue = NO;
				}
				
				ManagedUpdateMO *newManagedUpdate = [NSEntityDescription insertNewObjectForEntityForName:@"ManagedUpdate" inManagedObjectContext:moc];
				newManagedUpdate.manifest = manifest;
				[anApplication addApplicationProxiesObject:newManagedUpdate];
				if (managedUpdates == nil) {
					newManagedUpdate.isEnabledValue = NO;
				} else if ([managedUpdates containsObject:tempAppName]) {
					newManagedUpdate.isEnabledValue = YES;
				} else {
					newManagedUpdate.isEnabledValue = NO;
				}
				
				OptionalInstallMO *newOptionalInstall = [NSEntityDescription insertNewObjectForEntityForName:@"OptionalInstall" inManagedObjectContext:moc];
				newOptionalInstall.manifest = manifest;
				[anApplication addApplicationProxiesObject:newOptionalInstall];
				if (optionalInstalls == nil) {
					newOptionalInstall.isEnabledValue = NO;
				} else if ([optionalInstalls containsObject:tempAppName]) {
					newOptionalInstall.isEnabledValue = YES;
				} else {
					newOptionalInstall.isEnabledValue = NO;
				}
			}];
			
			
			
			// Parse manifests included_manifests array
			NSArray *includedManifests = [manifestInfoDict objectForKey:@"included_manifests"];
			
			NSArray *allManifests;
			NSFetchRequest *getAllManifests = [[NSFetchRequest alloc] init];
			[getAllManifests setEntity:manifestEntityDescr];
            [getAllManifests setReturnsObjectsAsFaults:NO];
            [getAllManifests setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"manifestInfos", @"includedManifests", nil]];
			allManifests = [moc executeFetchRequest:getAllManifests error:nil];
			[getAllManifests release];
			
            [allManifests enumerateObjectsUsingBlock:^(id aManifest, NSUInteger idx, BOOL *stop) {
                NSString *manifestTitle = [aManifest title];
				ManifestInfoMO *newManifestInfo = [NSEntityDescription insertNewObjectForEntityForName:@"ManifestInfo" inManagedObjectContext:moc];
				newManifestInfo.parentManifest = aManifest;
				newManifestInfo.manifest = manifest;
				
				if ([self.defaults boolForKey:@"debug"]) {
					NSLog(@"Linking nested manifest %@ -> %@", manifest.title, manifestTitle);
				}
				
				if (includedManifests == nil) {
					newManifestInfo.isEnabledForManifestValue = NO;
				} else if ([includedManifests containsObject:manifestTitle]) {
					newManifestInfo.isEnabledForManifestValue = YES;
				} else {
					newManifestInfo.isEnabledForManifestValue = NO;
				}
				if (manifest != aManifest) {
					newManifestInfo.isAvailableForEditingValue = YES;
				} else {
					newManifestInfo.isAvailableForEditingValue = NO;
				}
				
			}];
			
		} else {
			NSLog(@"Can't read manifest file %@", [self.sourceURL relativePath]);
		}
		
		// Save the context, this causes main app delegate to merge new items
		NSError *error = nil;
		if (![moc save:&error]) {
			[NSApp presentError:error];
		}
		
		if ([self.delegate respondsToSelector:@selector(scannerDidProcessPkginfo)]) {
			[self.delegate performSelectorOnMainThread:@selector(scannerDidProcessPkginfo) 
											withObject:nil
										 waitUntilDone:YES];
		}
		
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:NSManagedObjectContextDidSaveNotification
													  object:moc];
		[moc release], moc = nil;
		[pool release];
	}
	@catch(...) {
		// Do not rethrow exceptions.
	}
}

@end
