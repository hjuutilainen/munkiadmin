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
#import "StringObjectMO.h"

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
		self.currentJobDescription = @"Initializing pkginfo scan operation";
		
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
		NSEntityDescription *manifestEntityDescr = [NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:moc];
        NSEntityDescription *applicationEntityDescr = [NSEntityDescription entityForName:@"Application" inManagedObjectContext:moc];
        NSEntityDescription *packageEntityDescr = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc];
		
		
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
			
            // =================================
			// Get "catalogs" items
            // =================================
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
					newCatalogInfo.originalIndexValue = 0;
                    newCatalogInfo.indexInManifestValue = 0;
				} else if ([catalogs containsObject:catalogTitle]) {
					newCatalogInfo.isEnabledForManifestValue = YES;
					newCatalogInfo.originalIndexValue = [catalogs indexOfObject:catalogTitle];
                    newCatalogInfo.indexInManifestValue = [catalogs indexOfObject:catalogTitle];
				} else {
					newCatalogInfo.isEnabledForManifestValue = NO;
					newCatalogInfo.originalIndexValue = ([catalogs count] + 1);
                    newCatalogInfo.indexInManifestValue = ([catalogs count] + 1);
				}
			}];
			
			
            
            // =================================
			// Get "managed_installs" items
			// =================================
            NSArray *managedInstalls = [manifestInfoDict objectForKey:@"managed_installs"];
            [managedInstalls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ managed_installs item %lu --> Name: %@", manifest.title, (unsigned long)idx, obj);
                StringObjectMO *newManagedInstall = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
                newManagedInstall.title = (NSString *)obj;
                newManagedInstall.typeString = @"managedInstall";
                newManagedInstall.originalIndexValue = idx;
                [manifest addManagedInstallsFasterObject:newManagedInstall];
                
                NSFetchRequest *getApplication = [[NSFetchRequest alloc] init];
                [getApplication setEntity:applicationEntityDescr];
                NSPredicate *appPred = [NSPredicate predicateWithFormat:@"munki_name == %@", newManagedInstall.title];
                [getApplication setPredicate:appPred];
                if ([moc countForFetchRequest:getApplication error:nil] > 0) {
                    NSArray *apps = [moc executeFetchRequest:getApplication error:nil];
                    newManagedInstall.originalApplication = [apps objectAtIndex:0];
                } else {
                    NSFetchRequest *getPackage = [[NSFetchRequest alloc] init];
                    [getPackage setEntity:packageEntityDescr];
                    NSPredicate *pkgPred = [NSPredicate predicateWithFormat:@"titleWithVersion == %@", newManagedInstall.title];
                    [getPackage setPredicate:pkgPred];
                    if ([moc countForFetchRequest:getPackage error:nil] > 0) {
                        NSArray *pkgs = [moc executeFetchRequest:getPackage error:nil];
                        newManagedInstall.originalPackage = [pkgs objectAtIndex:0];
                    }
                    [getPackage release];
                }
                [getApplication release];
                
            }];
            
            
            // =================================
			// Get "managed_uninstalls" items
			// =================================
            NSArray *managedUninstalls = [manifestInfoDict objectForKey:@"managed_uninstalls"];
            [managedUninstalls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ managed_uninstalls item %lu --> Name: %@", manifest.title, (unsigned long)idx, obj);
                StringObjectMO *newManagedUninstall = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
                newManagedUninstall.title = (NSString *)obj;
                newManagedUninstall.typeString = @"managedUninstall";
                newManagedUninstall.originalIndexValue = idx;
                [manifest addManagedUninstallsFasterObject:newManagedUninstall];
                
                NSFetchRequest *getApplication = [[NSFetchRequest alloc] init];
                [getApplication setEntity:applicationEntityDescr];
                NSPredicate *appPred = [NSPredicate predicateWithFormat:@"munki_name == %@", newManagedUninstall.title];
                [getApplication setPredicate:appPred];
                if ([moc countForFetchRequest:getApplication error:nil] > 0) {
                    NSArray *apps = [moc executeFetchRequest:getApplication error:nil];
                    newManagedUninstall.originalApplication = [apps objectAtIndex:0];
                } else {
                    NSFetchRequest *getPackage = [[NSFetchRequest alloc] init];
                    [getPackage setEntity:packageEntityDescr];
                    NSPredicate *pkgPred = [NSPredicate predicateWithFormat:@"titleWithVersion == %@", newManagedUninstall.title];
                    [getPackage setPredicate:pkgPred];
                    if ([moc countForFetchRequest:getPackage error:nil] > 0) {
                        NSArray *pkgs = [moc executeFetchRequest:getPackage error:nil];
                        newManagedUninstall.originalPackage = [pkgs objectAtIndex:0];
                    }
                    [getPackage release];
                }
                [getApplication release];
            }];
            
            
            // =================================
			// Get "managed_updates" items
			// =================================
            NSArray *managedUpdates = [manifestInfoDict objectForKey:@"managed_updates"];
            [managedUpdates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ managed_updates item %lu --> Name: %@", manifest.title, (unsigned long)idx, obj);
                StringObjectMO *newManagedUpdate = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
                newManagedUpdate.title = (NSString *)obj;
                newManagedUpdate.typeString = @"managedUpdate";
                newManagedUpdate.originalIndexValue = idx;
                [manifest addManagedUpdatesFasterObject:newManagedUpdate];
                
                NSFetchRequest *getApplication = [[NSFetchRequest alloc] init];
                [getApplication setEntity:applicationEntityDescr];
                NSPredicate *appPred = [NSPredicate predicateWithFormat:@"munki_name == %@", newManagedUpdate.title];
                [getApplication setPredicate:appPred];
                if ([moc countForFetchRequest:getApplication error:nil] > 0) {
                    NSArray *apps = [moc executeFetchRequest:getApplication error:nil];
                    newManagedUpdate.originalApplication = [apps objectAtIndex:0];
                } else {
                    NSFetchRequest *getPackage = [[NSFetchRequest alloc] init];
                    [getPackage setEntity:packageEntityDescr];
                    NSPredicate *pkgPred = [NSPredicate predicateWithFormat:@"titleWithVersion == %@", newManagedUpdate.title];
                    [getPackage setPredicate:pkgPred];
                    if ([moc countForFetchRequest:getPackage error:nil] > 0) {
                        NSArray *pkgs = [moc executeFetchRequest:getPackage error:nil];
                        newManagedUpdate.originalPackage = [pkgs objectAtIndex:0];
                    }
                    [getPackage release];
                }
                [getApplication release];
            }];
			
            
            // =================================
			// Get "optional_installs" items
			// =================================
            NSArray *optionalInstalls = [manifestInfoDict objectForKey:@"optional_installs"];
			[optionalInstalls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ optional_installs item %lu --> Name: %@", manifest.title, (unsigned long)idx, obj);
                StringObjectMO *newOptionalInstall = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
                newOptionalInstall.title = (NSString *)obj;
                newOptionalInstall.typeString = @"optionalInstall";
                newOptionalInstall.originalIndexValue = idx;
                [manifest addOptionalInstallsFasterObject:newOptionalInstall];
                
                NSFetchRequest *getApplication = [[NSFetchRequest alloc] init];
                [getApplication setEntity:applicationEntityDescr];
                NSPredicate *appPred = [NSPredicate predicateWithFormat:@"munki_name == %@", newOptionalInstall.title];
                [getApplication setPredicate:appPred];
                if ([moc countForFetchRequest:getApplication error:nil] > 0) {
                    NSArray *apps = [moc executeFetchRequest:getApplication error:nil];
                    newOptionalInstall.originalApplication = [apps objectAtIndex:0];
                } else {
                    NSFetchRequest *getPackage = [[NSFetchRequest alloc] init];
                    [getPackage setEntity:packageEntityDescr];
                    NSPredicate *pkgPred = [NSPredicate predicateWithFormat:@"titleWithVersion == %@", newOptionalInstall.title];
                    [getPackage setPredicate:pkgPred];
                    if ([moc countForFetchRequest:getPackage error:nil] > 0) {
                        NSArray *pkgs = [moc executeFetchRequest:getPackage error:nil];
                        newOptionalInstall.originalPackage = [pkgs objectAtIndex:0];
                    }
                    [getPackage release];
                }
                [getApplication release];
            }];
            
            
            // =================================
			// Get "included_manifests" items
			// =================================
			NSArray *includedManifests = [manifestInfoDict objectForKey:@"included_manifests"];
            [includedManifests enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ included_manifests item %lu --> Name: %@", manifest.title, (unsigned long)idx, obj);
                StringObjectMO *newIncludedManifest = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
                newIncludedManifest.title = (NSString *)obj;
                newIncludedManifest.typeString = @"includedManifest";
                newIncludedManifest.originalIndexValue = idx;
                newIncludedManifest.indexInNestedManifestValue = idx;
                [manifest addIncludedManifestsFasterObject:newIncludedManifest];
            }];
			
			/*NSArray *allManifests;
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
			}];*/
			
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
