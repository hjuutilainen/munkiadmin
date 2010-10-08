//
//  PkginfoScanner.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 5.10.2010.
//

#import "PkginfoScanner.h"
#import "MunkiAdmin_AppDelegate.h"
#import "PackageMO.h"
#import "ReceiptMO.h"
#import "CatalogMO.h"
#import "CatalogInfoMO.h"
#import "InstallsItemMO.h"
#import "ItemToCopyMO.h"


@implementation PkginfoScanner

@synthesize currentJobDescription;
@synthesize fileName;
@synthesize sourceURL;
@synthesize delegate;
@synthesize pkginfoKeyMappings;
@synthesize receiptKeyMappings;
@synthesize installsKeyMappings;
@synthesize itemsToCopyKeyMappings;

- (NSUserDefaults *)defaults
{
	return [NSUserDefaults standardUserDefaults];
}


- (id)initWithURL:(NSURL *)src {
	if (self = [super init]) {
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Initializing operation");
		self.sourceURL = src;
		self.fileName = [self.sourceURL lastPathComponent];
		self.currentJobDescription = @"Initializing pkginfo scan operation";
		
		// Define the munki keys we support
		NSMutableDictionary *newPkginfoKeyMappings = [[[NSMutableDictionary alloc] init] autorelease];
		for (NSString *pkginfoKey in [self.defaults arrayForKey:@"pkginfoKeys"]) {
			[newPkginfoKeyMappings setObject:pkginfoKey forKey:[NSString stringWithFormat:@"munki_%@", pkginfoKey]];
		}
		self.pkginfoKeyMappings = (NSDictionary *)newPkginfoKeyMappings;
		
		// Receipt keys
		NSMutableDictionary *newReceiptKeyMappings = [[[NSMutableDictionary alloc] init] autorelease];
		for (NSString *receiptKey in [self.defaults arrayForKey:@"receiptKeys"]) {
			[newReceiptKeyMappings setObject:receiptKey forKey:[NSString stringWithFormat:@"munki_%@", receiptKey]];
		}
		self.receiptKeyMappings = (NSDictionary *)newReceiptKeyMappings;
		
		// Installs item keys
		NSMutableDictionary *newInstallsKeyMappings = [[[NSMutableDictionary alloc] init] autorelease];
		for (NSString *installsKey in [self.defaults arrayForKey:@"installsKeys"]) {
			[newInstallsKeyMappings setObject:installsKey forKey:[NSString stringWithFormat:@"munki_%@", installsKey]];
		}
		self.installsKeyMappings = (NSDictionary *)newInstallsKeyMappings;
		
		// items_to_copy keys
		NSMutableDictionary *newItemsToCopyKeyMappings = [[[NSMutableDictionary alloc] init] autorelease];
		for (NSString *itemToCopy in [self.defaults arrayForKey:@"itemsToCopyKeys"]) {
			[newItemsToCopyKeyMappings setObject:itemToCopy forKey:[NSString stringWithFormat:@"munki_%@", itemToCopy]];
		}
		self.itemsToCopyKeyMappings = (NSDictionary *)newItemsToCopyKeyMappings;
	}
	return self;
}

- (void)dealloc {
	[fileName release];
	[currentJobDescription release];
	[sourceURL release];
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
		NSEntityDescription *packageEntityDescr = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc];
		
		
		
		
		self.currentJobDescription = [NSString stringWithFormat:@"Reading file %@", self.fileName];
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Reading file %@", [self.sourceURL relativePath]);
		
		NSDictionary *packageInfoDict = [NSDictionary dictionaryWithContentsOfURL:self.sourceURL];
		
		if (packageInfoDict != nil) {
			
			//PackageMO *aNewPackage = [NSEntityDescription insertNewObjectForEntityForName:@"Package" inManagedObjectContext:moc];
			PackageMO *aNewPackage = [[[PackageMO alloc] initWithEntity:packageEntityDescr insertIntoManagedObjectContext:moc] autorelease];
			aNewPackage.packageInfoURL = self.sourceURL;
			aNewPackage.originalPkginfo = packageInfoDict;
			
			// =================================
			// Get basic package properties
			// =================================
			self.currentJobDescription = [NSString stringWithFormat:@"Reading basic info for %@", self.fileName];
			if ([self.defaults boolForKey:@"debug"]) NSLog(@"Reading basic info for %@", self.fileName);
			[self.pkginfoKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
				id value = [packageInfoDict objectForKey:obj];
				if (value != nil) {
					if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@ --> %@: %@", self.fileName, obj, value);
					[aNewPackage setValue:value forKey:key];
				} else {
					if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@ --> %@: nil (skipped)", self.fileName, key);
				}
			}];
			aNewPackage.packageURL = [[[NSApp delegate] pkgsURL] URLByAppendingPathComponent:aNewPackage.munki_installer_item_location];
			
			// =================================
			// Get "receipts" items
			// =================================
			NSArray *itemReceipts = [packageInfoDict objectForKey:@"receipts"];
			[itemReceipts enumerateObjectsUsingBlock:^(id aReceipt, NSUInteger idx, BOOL *stop) {
				ReceiptMO *aNewReceipt = [NSEntityDescription insertNewObjectForEntityForName:@"Receipt" inManagedObjectContext:moc];
				aNewReceipt.package = aNewPackage;
				[self.receiptKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
					id value = [aReceipt objectForKey:obj];
					if (value != nil) {
						if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@, receipt %i --> %@: %@", self.fileName, idx, obj, value);
						[aNewReceipt setValue:value forKey:key];
					} else {
						if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@, receipt %i --> %@: nil (skipped)", self.fileName, idx, key);
					}
				}];
			}];
			
			// =================================
			// Get "installs" items
			// =================================
			NSArray *installItems = [packageInfoDict objectForKey:@"installs"];
			[installItems enumerateObjectsUsingBlock:^(id anInstall, NSUInteger idx, BOOL *stop) {
				InstallsItemMO *aNewInstallsItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallsItem" inManagedObjectContext:moc];
				[aNewInstallsItem addPackagesObject:aNewPackage];
				[self.installsKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
					id value = [anInstall objectForKey:obj];
					if (value != nil) {
						if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@, installs item %i --> %@: %@", self.fileName, idx, obj, value);
						[aNewInstallsItem setValue:value forKey:key];
					} else {
						if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@, installs item %i --> %@: nil (skipped)", self.fileName, idx, key);
					}
				}];
			}];
			
			// =================================
			// Get "items_to_copy" items
			// =================================
			NSArray *itemsToCopy = [packageInfoDict objectForKey:@"items_to_copy"];
			[itemsToCopy enumerateObjectsUsingBlock:^(id anItemToCopy, NSUInteger idx, BOOL *stop) {
				ItemToCopyMO *aNewItemToCopy = [NSEntityDescription insertNewObjectForEntityForName:@"ItemToCopy" inManagedObjectContext:moc];
				aNewItemToCopy.package = aNewPackage;
				[self.itemsToCopyKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
					id value = [anItemToCopy objectForKey:obj];
					if (value != nil) {
						if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@, items_to_copy item %i --> %@: %@", self.fileName, idx, obj, value);
						[aNewItemToCopy setValue:value forKey:key];
					} else {
						if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@, items_to_copy item %i --> %@: nil (skipped)", self.fileName, idx, key);
					}
				}];
			}];
			
			
			// =================================
			// Get "catalogs" items
			// =================================
			NSArray *catalogs = [packageInfoDict objectForKey:@"catalogs"];
			
			self.currentJobDescription = [NSString stringWithFormat:@"Parsing catalogs for %@", self.fileName];
			if ([self.defaults boolForKey:@"debug"]) NSLog(@"Parsing catalogs for %@", self.fileName);
			
			// Loop through Catalog managed objects and create a relationship to current pkg
			NSArray *allCatalogs;
			NSFetchRequest *getAllCatalogs = [[NSFetchRequest alloc] init];
			[getAllCatalogs setEntity:catalogEntityDescr];
			allCatalogs = [moc executeFetchRequest:getAllCatalogs error:nil];
			[getAllCatalogs release];
			
			for (CatalogMO *aCatalog in allCatalogs) {
				CatalogInfoMO *newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:moc];
				newCatalogInfo.package = aNewPackage;
				newCatalogInfo.catalog.title = aCatalog.title;
				
				[aCatalog addPackagesObject:aNewPackage];
				[aCatalog addCatalogInfosObject:newCatalogInfo];
				
				PackageInfoMO *newPackageInfo = [NSEntityDescription insertNewObjectForEntityForName:@"PackageInfo" inManagedObjectContext:moc];
				newPackageInfo.catalog = aCatalog;
				newPackageInfo.title = [aNewPackage.munki_display_name stringByAppendingFormat:@" %@", aNewPackage.munki_version];
				newPackageInfo.package = aNewPackage;
				
				if ([catalogs containsObject:aCatalog.title]) {
					newCatalogInfo.isEnabledForPackageValue = YES;
					newCatalogInfo.originalIndexValue = [catalogs indexOfObject:aCatalog.title];
					newPackageInfo.isEnabledForCatalogValue = YES;
				} else {
					newCatalogInfo.isEnabledForPackageValue = NO;
					newCatalogInfo.originalIndexValue = 10000;
					newPackageInfo.isEnabledForCatalogValue = NO;
				}
			}
			
			// Loop through the "catalogs" key in pkginfo file
			[catalogs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				// Check if we already have a catalog with this name
				NSFetchRequest *fetchForCatalogs = [[NSFetchRequest alloc] init];
				[fetchForCatalogs setEntity:catalogEntityDescr];
				
				NSPredicate *catalogTitlePredicate = [NSPredicate predicateWithFormat:@"title == %@", obj];
				[fetchForCatalogs setPredicate:catalogTitlePredicate];
				
				NSUInteger numFoundCatalogs = [moc countForFetchRequest:fetchForCatalogs error:nil];
				if (numFoundCatalogs == 0) {
					//NSLog(@"Creating a new catalog %@", aCatalog);
					CatalogMO *aNewCatalog = [NSEntityDescription insertNewObjectForEntityForName:@"Catalog" inManagedObjectContext:moc];
					aNewCatalog.title = obj;
					[aNewCatalog addPackagesObject:aNewPackage];
					CatalogInfoMO *newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:moc];
					newCatalogInfo.package = aNewPackage;
					newCatalogInfo.catalog.title = aNewCatalog.title;
					newCatalogInfo.isEnabledForPackageValue = YES;
					newCatalogInfo.originalIndexValue = [catalogs indexOfObject:obj];
					[aNewCatalog addCatalogInfosObject:newCatalogInfo];
				}
				[fetchForCatalogs release];
			}];
			
			// =================================
			// Get "requires" items
			// =================================
			NSArray *requires = [packageInfoDict objectForKey:@"requires"];
			[requires enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ requires item %i --> Name: %@", self.fileName, idx, obj);
			}];
			
			// =================================
			// Get "update_for" items
			// =================================
			NSArray *update_for = [packageInfoDict objectForKey:@"update_for"];
			[update_for enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ update_for item %i --> Name: %@", self.fileName, idx, obj);
			}];
			
			// =================================
			// Group packages by "name" property
			// =================================
			NSEntityDescription *applicationEntityDescr = [NSEntityDescription entityForName:@"Application" inManagedObjectContext:moc];
			
			NSFetchRequest *fetchForApplications = [[NSFetchRequest alloc] init];
			[fetchForApplications setEntity:applicationEntityDescr];
			NSPredicate *applicationTitlePredicate;
			applicationTitlePredicate = [NSPredicate predicateWithFormat:@"munki_name == %@ AND munki_display_name == %@", aNewPackage.munki_name, aNewPackage.munki_display_name];
			
			[fetchForApplications setPredicate:applicationTitlePredicate];
			
			NSUInteger numFoundApplications = [moc countForFetchRequest:fetchForApplications error:nil];
			if (numFoundApplications == 0) {
				ApplicationMO *aNewApplication = [NSEntityDescription insertNewObjectForEntityForName:@"Application" inManagedObjectContext:moc];
				aNewApplication.munki_display_name = aNewPackage.munki_display_name;
				aNewApplication.munki_name = aNewPackage.munki_name;
				aNewApplication.munki_description = aNewPackage.munki_description;
				[aNewApplication addPackagesObject:aNewPackage];
			} else if (numFoundApplications == 1) {
				ApplicationMO *existingApplication = [[moc executeFetchRequest:fetchForApplications error:nil] objectAtIndex:0];
				[existingApplication addPackagesObject:aNewPackage];
				
			} else {
				NSLog(@"Found multiple Applications for package. This really shouldn't happen...");
			}
			
			[fetchForApplications release];
			
			
			
			
		} else {
			NSLog(@"Can't read pkginfo file %@", [self.sourceURL relativePath]);
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
