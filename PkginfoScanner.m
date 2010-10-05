//
//  PkginfoScanner.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 5.10.2010.
//

#import "PkginfoScanner.h"
#import "PackageMO.h"
#import "ReceiptMO.h"
#import "CatalogMO.h"
#import "CatalogInfoMO.h"
#import "InstallsItemMO.h"


@implementation PkginfoScanner

@synthesize currentJobDescription;
@synthesize fileName;
@synthesize sourceURL;
@synthesize delegate;

- (NSUserDefaults *)defaults
{
	return [NSUserDefaults standardUserDefaults];
}


- (id)initWithURL:(NSURL *)src {
	if (self = [super init]) {
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Initializing operation");
		self.sourceURL = src;
		self.fileName = [self.sourceURL lastPathComponent];
		self.currentJobDescription = @"Initializing scan...";
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
		
		// Define the keys we support
		NSMutableDictionary *pkginfoKeyMappings = [[[NSMutableDictionary alloc] init] autorelease];
		NSArray *pkginfoKeys = [NSArray arrayWithObjects:
								@"name", 
								@"display_name", 
								@"description", 
								@"installed_size", 
								@"autoremove", 
								@"installer_item_location", 
								@"installer_item_size", 
								@"installer_item_hash",
								@"minimum_os_version",
								@"uninstall_method",
								@"uninstallable",
								@"version",
								@"installer_type",
								nil];
		for (NSString *pkginfoKey in pkginfoKeys) {
			[pkginfoKeyMappings setObject:pkginfoKey forKey:[NSString stringWithFormat:@"munki_%@", pkginfoKey]];
		}
		// Receipt keys
		NSMutableDictionary *receiptKeyMappings = [[[NSMutableDictionary alloc] init] autorelease];
		NSArray *receiptKeys = [NSArray arrayWithObjects:
								@"filename",
								@"installed_size",
								@"packageid",
								@"version",
								nil];
		for (NSString *receiptKey in receiptKeys) {
			[receiptKeyMappings setObject:receiptKey forKey:[NSString stringWithFormat:@"munki_%@", receiptKey]];
		}
		// Installs item keys
		NSMutableDictionary *installsKeyMappings = [[[NSMutableDictionary alloc] init] autorelease];
		NSArray *installsKeys = [NSArray arrayWithObjects:
								 @"CFBundleIdentifier",
								 @"CFBundleName",
								 @"CFBundleShortVersionString",
								 @"path",
								 @"type",
								 nil];
		for (NSString *installsKey in installsKeys) {
			[installsKeyMappings setObject:installsKey forKey:[NSString stringWithFormat:@"munki_%@", installsKey]];
		}
		
		
		
		
		
		
		self.currentJobDescription = [NSString stringWithFormat:@"Reading %@", self.fileName];
		
		if ([self.defaults boolForKey:@"debug"]) {
			NSLog(@"Reading pkginfo file: %@", [self.sourceURL relativePath]);
		}
		
		NSDictionary *packageInfoDict = [NSDictionary dictionaryWithContentsOfURL:self.sourceURL];
		
		if (packageInfoDict != nil) {
			
			//PackageMO *aNewPackage = [NSEntityDescription insertNewObjectForEntityForName:@"Package" inManagedObjectContext:moc];
			PackageMO *aNewPackage = [[[PackageMO alloc] initWithEntity:packageEntityDescr insertIntoManagedObjectContext:moc] autorelease];
			aNewPackage.packageInfoURL = self.sourceURL;
			
			
			// Get basic package properties
			[pkginfoKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
				id value = [packageInfoDict objectForKey:obj];
				if (value != nil) {
					if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ --> %@: %@", self.fileName, obj, value);
					[aNewPackage setValue:value forKey:key];
				} else {
					if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ --> %@: nil (skipped)", self.fileName, key);
				}
			}];
			aNewPackage.packageURL = [[[NSApp delegate] pkgsURL] URLByAppendingPathComponent:aNewPackage.munki_installer_item_location];
			
			// Get "receipts" items
			NSArray *itemReceipts = [packageInfoDict objectForKey:@"receipts"];
			[itemReceipts enumerateObjectsUsingBlock:^(id aReceipt, NSUInteger idx, BOOL *stop) {
				ReceiptMO *aNewReceipt = [NSEntityDescription insertNewObjectForEntityForName:@"Receipt" inManagedObjectContext:moc];
				aNewReceipt.package = aNewPackage;
				[receiptKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
					id value = [aReceipt objectForKey:obj];
					if (value != nil) {
						if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@, receipt %i --> %@: %@", self.fileName, idx, obj, value);
						[aNewReceipt setValue:value forKey:key];
					} else {
						if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@, receipt %i --> %@: nil (skipped)", self.fileName, idx, key);
					}
				}];
			}];
			
			
			// Get "installs" items
			NSArray *installItems = [packageInfoDict objectForKey:@"installs"];
			[installItems enumerateObjectsUsingBlock:^(id anInstall, NSUInteger idx, BOOL *stop) {
				InstallsItemMO *aNewInstallsItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallsItem" inManagedObjectContext:moc];
				[aNewInstallsItem addPackagesObject:aNewPackage];
				[installsKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
					id value = [anInstall objectForKey:obj];
					if (value != nil) {
						if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@, installs item %i --> %@: %@", self.fileName, idx, obj, value);
						[aNewInstallsItem setValue:value forKey:key];
					} else {
						if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@, installs item %i --> %@: nil (skipped)", self.fileName, idx, key);
					}
				}];
			}];
			
			// Get "catalogs" items
			NSArray *catalogs = [packageInfoDict objectForKey:@"catalogs"];
			[catalogs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				
				
				// Check if we already have a catalog with this name
				NSFetchRequest *fetchForCatalogs = [[NSFetchRequest alloc] init];
				[fetchForCatalogs setEntity:catalogEntityDescr];
				
				NSPredicate *catalogTitlePredicate = [NSPredicate predicateWithFormat:@"title == %@", obj];
				[fetchForCatalogs setPredicate:catalogTitlePredicate];
				
				NSUInteger numFoundCatalogs = [moc countForFetchRequest:fetchForCatalogs error:nil];
				if (numFoundCatalogs == 0) {
					if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ catalogs item %i --> Name: %@ (new)", self.fileName, idx, obj);
					//CatalogMO *aNewCatalog = [NSEntityDescription insertNewObjectForEntityForName:@"Catalog" inManagedObjectContext:moc];
					CatalogMO *aNewCatalog = [[[CatalogMO alloc] initWithEntity:catalogEntityDescr insertIntoManagedObjectContext:moc] autorelease];
					aNewCatalog.title = obj;
					[aNewCatalog addPackagesObject:aNewPackage];
				} else if (numFoundCatalogs == 1) {
					if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ catalogs item %i --> Name: %@ (reused existing)", self.fileName, idx, obj);
					CatalogMO *existingCatalog = [[moc executeFetchRequest:fetchForCatalogs error:nil] objectAtIndex:0];
					[existingCatalog addPackagesObject:aNewPackage];
				}
				[fetchForCatalogs release];
			}];
			
			// Get "requires" items
			NSArray *requires = [packageInfoDict objectForKey:@"requires"];
			[requires enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ requires item %i --> Name: %@", self.fileName, idx, obj);
			}];
			
			// Get "update_for" items
			NSArray *update_for = [packageInfoDict objectForKey:@"update_for"];
			[update_for enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ update_for item %i --> Name: %@", self.fileName, idx, obj);
			}];
			
			
		} else {
			NSLog(@"Can't read pkginfo file %@", [self.sourceURL relativePath]);
		}

		
		NSError *error = nil;
		
		if (![moc save:&error]) {
			[NSApp presentError:error];
		}
		
		if ([self.delegate respondsToSelector:@selector(scannerDidProcessPkginfo:)]) {
			[self.delegate performSelectorOnMainThread:@selector(scannerDidProcessPkginfo:) 
											withObject:nil
										 waitUntilDone:NO];
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
