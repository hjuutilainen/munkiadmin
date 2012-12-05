//
//  PkginfoScanner.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 5.10.2010.
//

#import "PkginfoScanner.h"
#import "MunkiAdmin_AppDelegate.h"
#import "DataModelHeaders.h"


@implementation PkginfoScanner

@synthesize currentJobDescription;
@synthesize fileName;
@synthesize sourceURL;
@synthesize sourceDict;
@synthesize delegate;
@synthesize pkginfoKeyMappings;
@synthesize receiptKeyMappings;
@synthesize installsKeyMappings;
@synthesize itemsToCopyKeyMappings;
@synthesize installerChoicesKeyMappings;
@synthesize canModify;

- (NSUserDefaults *)defaults
{
	return [NSUserDefaults standardUserDefaults];
}

+ (id)scannerWithURL:(NSURL *)url
{
	return [[[self alloc] initWithURL:url] autorelease];
}

+ (id)scannerWithDictionary:(NSDictionary *)dict
{
	return [[[self alloc] initWithDictionary:dict] autorelease];
}

- (void)setupMappings
{
	// Define the munki keys we support
	NSMutableDictionary *newPkginfoKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *pkginfoKey in [self.defaults arrayForKey:@"pkginfoKeys"]) {
		[newPkginfoKeyMappings setObject:pkginfoKey forKey:[NSString stringWithFormat:@"munki_%@", pkginfoKey]];
	}
	self.pkginfoKeyMappings = (NSDictionary *)newPkginfoKeyMappings;
	[newPkginfoKeyMappings release];
	
	// Receipt keys
	NSMutableDictionary *newReceiptKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *receiptKey in [self.defaults arrayForKey:@"receiptKeys"]) {
		[newReceiptKeyMappings setObject:receiptKey forKey:[NSString stringWithFormat:@"munki_%@", receiptKey]];
	}
	self.receiptKeyMappings = (NSDictionary *)newReceiptKeyMappings;
	[newReceiptKeyMappings release];
	
	// Installs item keys
	NSMutableDictionary *newInstallsKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *installsKey in [self.defaults arrayForKey:@"installsKeys"]) {
		[newInstallsKeyMappings setObject:installsKey forKey:[NSString stringWithFormat:@"munki_%@", installsKey]];
	}
	self.installsKeyMappings = (NSDictionary *)newInstallsKeyMappings;
	[newInstallsKeyMappings release];
	
	// items_to_copy keys
	NSMutableDictionary *newItemsToCopyKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *itemToCopy in [self.defaults arrayForKey:@"itemsToCopyKeys"]) {
		[newItemsToCopyKeyMappings setObject:itemToCopy forKey:[NSString stringWithFormat:@"munki_%@", itemToCopy]];
	}
	self.itemsToCopyKeyMappings = (NSDictionary *)newItemsToCopyKeyMappings;
	[newItemsToCopyKeyMappings release];
    
    // installer_choices_xml
    NSMutableDictionary *newInstallerChoicesKeyMappings = [[NSMutableDictionary alloc] init];
	for (NSString *installerChoice in [self.defaults arrayForKey:@"installerChoicesKeys"]) {
		[newInstallerChoicesKeyMappings setObject:installerChoice forKey:[NSString stringWithFormat:@"munki_%@", installerChoice]];
	}
	self.installerChoicesKeyMappings = (NSDictionary *)newInstallerChoicesKeyMappings;
	[newInstallerChoicesKeyMappings release];
}

- (id)initWithDictionary:(NSDictionary *)dict
{
	if ((self = [super init])) {
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Initializing operation");
		self.sourceDict = dict;
		self.fileName = [self.sourceDict valueForKey:@"name"];
		self.currentJobDescription = @"Initializing pkginfo scan operation";
		[self setupMappings];
	}
	return self;
}

- (id)initWithURL:(NSURL *)src
{
	if ((self = [super init])) {
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Initializing operation");
		self.sourceURL = src;
		self.fileName = [self.sourceURL lastPathComponent];
		self.currentJobDescription = @"Initializing pkginfo scan operation";
		[self setupMappings];
	}
	return self;
}

- (void)dealloc
{
	[fileName release];
	[currentJobDescription release];
	[sourceURL release];
	[sourceDict release];
	[delegate release];
	[pkginfoKeyMappings release];
	[receiptKeyMappings release];
	[installsKeyMappings release];
	[itemsToCopyKeyMappings release];
    
	[super dealloc];
}

- (void)contextDidSave:(NSNotification*)notification 
{
	[[self delegate] performSelectorOnMainThread:@selector(mergeChanges:) 
									  withObject:notification 
								   waitUntilDone:YES];
}


-(void)main
{
	@try {
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
		NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
        [moc setUndoManager:nil];
        [moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
		[moc setPersistentStoreCoordinator:[[self delegate] persistentStoreCoordinator]];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(contextDidSave:)
													 name:NSManagedObjectContextDidSaveNotification
												   object:moc];
		NSEntityDescription *catalogEntityDescr = [NSEntityDescription entityForName:@"Catalog" inManagedObjectContext:moc];
		NSEntityDescription *packageEntityDescr = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc];
		NSEntityDescription *applicationEntityDescr = [NSEntityDescription entityForName:@"Application" inManagedObjectContext:moc];
		
		
		if (self.sourceURL != nil) {
            self.currentJobDescription = [NSString stringWithFormat:@"Reading file %@", self.fileName];
            if ([self.defaults boolForKey:@"debug"]) NSLog(@"Reading file %@", [self.sourceURL relativePath]);
            self.sourceDict = [[NSDictionary alloc] initWithContentsOfURL:self.sourceURL];
		}
		
		if (self.sourceDict != nil) {
			
			PackageMO *aNewPackage = [[[PackageMO alloc] initWithEntity:packageEntityDescr insertIntoManagedObjectContext:moc] autorelease];

			aNewPackage.originalPkginfo = self.sourceDict;
			
			// =================================
			// Get basic package properties
			// =================================
			self.currentJobDescription = [NSString stringWithFormat:@"Reading basic info for %@", self.fileName];
			if ([self.defaults boolForKey:@"debug"]) NSLog(@"Reading basic info for %@", self.fileName);
			[self.pkginfoKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
				id value = [self.sourceDict objectForKey:obj];
				if (value != nil) {
					if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@ --> %@: %@", self.fileName, obj, value);
					[aNewPackage setValue:value forKey:key];
				} else {
					if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@ --> %@: nil (skipped)", self.fileName, key);
				}
			}];
            
            // ==================================================
            // Additional steps for deprecated forced_install
            // ==================================================
            if ((aNewPackage.munki_forced_install != nil) && (aNewPackage.munki_unattended_install != nil)) {
                // pkginfo has both forced_install and unattended_install defined
                if (aNewPackage.munki_forced_installValue != aNewPackage.munki_unattended_installValue) {
                    if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ has both forced_install and unattended_install defined with differing values. Favoring unattended_install", self.fileName);
                    aNewPackage.munki_forced_install = aNewPackage.munki_unattended_install;
                }
            }
            else if ((aNewPackage.munki_forced_install != nil) && (aNewPackage.munki_unattended_install == nil)) {
                // pkginfo has only forced_install defined
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ has only forced_install defined. Migrating to unattended_install", self.fileName);
                aNewPackage.munki_unattended_install = aNewPackage.munki_forced_install;
            }
            
            // ==================================================
            // Additional steps for deprecated forced_uninstall
            // ==================================================
            if ((aNewPackage.munki_forced_uninstall != nil) && (aNewPackage.munki_unattended_uninstall != nil)) {
                // pkginfo has both values defined
                if (aNewPackage.munki_forced_uninstallValue != aNewPackage.munki_unattended_uninstallValue) {
                    if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ has both forced_uninstall and unattended_uninstall defined with differing values. Favoring unattended_uninstall", self.fileName);
                    aNewPackage.munki_forced_uninstall = aNewPackage.munki_unattended_uninstall;
                }
            }
            else if ((aNewPackage.munki_forced_uninstall != nil) && (aNewPackage.munki_unattended_uninstall == nil)) {
                // pkginfo has only forced_uninstall defined
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ has only forced_uninstall defined. Migrating to unattended_uninstall", self.fileName);
                aNewPackage.munki_unattended_uninstall = aNewPackage.munki_forced_uninstall;
            }
            
            
            // Check if we have installer_item_location and expand it to absolute URL
            if (aNewPackage.munki_installer_item_location != nil) {
                aNewPackage.packageURL = [[[NSApp delegate] pkgsURL] URLByAppendingPathComponent:aNewPackage.munki_installer_item_location];
            }
            
			if (self.sourceURL != nil) {
				aNewPackage.packageInfoURL = self.sourceURL;
                
                NSDate *pkginfoDateCreated;
                [aNewPackage.packageInfoURL getResourceValue:&pkginfoDateCreated forKey:NSURLCreationDateKey error:nil];
                aNewPackage.packageInfoDateCreated = pkginfoDateCreated;
                
                NSDate *pkginfoDateLastOpened;
                [aNewPackage.packageInfoURL getResourceValue:&pkginfoDateLastOpened forKey:NSURLContentAccessDateKey error:nil];
                aNewPackage.packageInfoDateLastOpened = pkginfoDateLastOpened;
                
                NSDate *pkginfoDateModified;
                [aNewPackage.packageInfoURL getResourceValue:&pkginfoDateModified forKey:NSURLContentModificationDateKey error:nil];
                aNewPackage.packageInfoDateModified = pkginfoDateModified;
                
			} else {
                NSString *newBaseName = [aNewPackage.munki_name stringByReplacingOccurrencesOfString:@" " withString:@"-"];
                NSString *newNameAndVersion = [NSString stringWithFormat:@"%@-%@", newBaseName, aNewPackage.munki_version];
                NSURL *newPkginfoURL = [[[NSApp delegate] pkgsInfoURL] URLByAppendingPathComponent:newNameAndVersion];
				newPkginfoURL = [newPkginfoURL URLByAppendingPathExtension:@"plist"];
				aNewPackage.packageInfoURL = newPkginfoURL;
                
                aNewPackage.packageInfoDateCreated = [NSDate date];
                aNewPackage.packageInfoDateModified = [NSDate date];
                aNewPackage.packageInfoDateLastOpened = [NSDate date];
			}
            
            if (aNewPackage.packageURL != nil) {
                NSFileManager *fm = [NSFileManager defaultManager];
                if ([fm fileExistsAtPath:[aNewPackage.packageURL relativePath]]) {
                NSDate *packageDateCreated;
                [aNewPackage.packageURL getResourceValue:&packageDateCreated forKey:NSURLCreationDateKey error:nil];
                aNewPackage.packageDateCreated = packageDateCreated;
                
                NSDate *packageDateLastOpened;
                [aNewPackage.packageURL getResourceValue:&packageDateLastOpened forKey:NSURLContentAccessDateKey error:nil];
                aNewPackage.packageDateLastOpened = packageDateLastOpened;
                
                NSDate *packageDateModified;
                [aNewPackage.packageURL getResourceValue:&packageDateModified forKey:NSURLContentModificationDateKey error:nil];
                aNewPackage.packageDateModified = packageDateModified;
                }
            }
			
			// =================================
			// Get "receipts" items
			// =================================
			NSArray *itemReceipts = [self.sourceDict objectForKey:@"receipts"];
			[itemReceipts enumerateObjectsWithOptions:0 usingBlock:^(id aReceipt, NSUInteger idx, BOOL *stop) {
				ReceiptMO *aNewReceipt = [NSEntityDescription insertNewObjectForEntityForName:@"Receipt" inManagedObjectContext:moc];
				aNewReceipt.package = aNewPackage;
                aNewReceipt.originalIndexValue = idx;
				[self.receiptKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
					id value = [aReceipt objectForKey:obj];
					if (value != nil) {
						if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@, receipt %lu --> %@: %@", self.fileName, (unsigned long)idx, obj, value);
						[aNewReceipt setValue:value forKey:key];
					} else {
						if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@, receipt %lu --> %@: nil (skipped)", self.fileName, (unsigned long)idx, key);
					}
				}];
			}];
			
			// =================================
			// Get "installs" items
			// =================================
			NSArray *installItems = [self.sourceDict objectForKey:@"installs"];
			[installItems enumerateObjectsWithOptions:0 usingBlock:^(id anInstall, NSUInteger idx, BOOL *stop) {
				InstallsItemMO *aNewInstallsItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallsItem" inManagedObjectContext:moc];
				[aNewInstallsItem addPackagesObject:aNewPackage];
                aNewInstallsItem.originalIndexValue = idx;
				[self.installsKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
					id value = [anInstall objectForKey:obj];
					if (value != nil) {
						if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@, installs item %lu --> %@: %@", self.fileName, (unsigned long)idx, obj, value);
						[aNewInstallsItem setValue:value forKey:key];
					} else {
						if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@, installs item %lu --> %@: nil (skipped)", self.fileName, (unsigned long)idx, key);
					}
				}];
			}];
			
			// =================================
			// Get "items_to_copy" items
			// =================================
			NSArray *itemsToCopy = [self.sourceDict objectForKey:@"items_to_copy"];
			[itemsToCopy enumerateObjectsWithOptions:0 usingBlock:^(id anItemToCopy, NSUInteger idx, BOOL *stop) {
				ItemToCopyMO *aNewItemToCopy = [NSEntityDescription insertNewObjectForEntityForName:@"ItemToCopy" inManagedObjectContext:moc];
				aNewItemToCopy.package = aNewPackage;
                aNewItemToCopy.originalIndexValue = idx;
				[self.itemsToCopyKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
					id value = [anItemToCopy objectForKey:obj];
					if (value != nil) {
						if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@, items_to_copy item %lu --> %@: %@", self.fileName, (unsigned long)idx, obj, value);
						[aNewItemToCopy setValue:value forKey:key];
					} else {
						if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@, items_to_copy item %lu --> %@: nil (skipped)", self.fileName, (unsigned long)idx, key);
					}
				}];
				if ([self.defaults boolForKey:@"items_to_copyUseDefaults"] && self.canModify) {
					aNewItemToCopy.munki_user = [self.defaults stringForKey:@"items_to_copyOwner"];
					aNewItemToCopy.munki_group = [self.defaults stringForKey:@"items_to_copyGroup"];
					aNewItemToCopy.munki_mode = [self.defaults stringForKey:@"items_to_copyMode"];
				}
			}];
            
            // =================================
			// Get "installer_choices_xml" items
			// =================================
			NSArray *installerChoices = [self.sourceDict objectForKey:@"installer_choices_xml"];
			[installerChoices enumerateObjectsWithOptions:0 usingBlock:^(id aChoice, NSUInteger idx, BOOL *stop) {
				InstallerChoicesItemMO *aNewInstallerChoice = [NSEntityDescription insertNewObjectForEntityForName:@"InstallerChoicesItem" inManagedObjectContext:moc];
				aNewInstallerChoice.package = aNewPackage;
                aNewInstallerChoice.originalIndexValue = idx;
				[self.installerChoicesKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
					id value = [aChoice objectForKey:obj];
					if (value != nil) {
						if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@, installer_choices_xml item %lu --> %@: %@", self.fileName, (unsigned long)idx, obj, value);
						[aNewInstallerChoice setValue:value forKey:key];
					} else {
						if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@, installer_choices_xml item %lu --> %@: nil (skipped)", self.fileName, (unsigned long)idx, key);
					}
				}];
			}];
			
			
			// =================================
			// Get "catalogs" items
			// =================================
            self.currentJobDescription = [NSString stringWithFormat:@"Parsing catalogs for %@", self.fileName];
			NSArray *catalogs = [self.sourceDict objectForKey:@"catalogs"];
			[catalogs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ catalogs item %lu --> Name: %@", self.fileName, (unsigned long)idx, obj);
				NSFetchRequest *fetchForCatalogs = [[NSFetchRequest alloc] init];
				[fetchForCatalogs setEntity:catalogEntityDescr];
				NSPredicate *catalogTitlePredicate = [NSPredicate predicateWithFormat:@"title == %@", obj];
				[fetchForCatalogs setPredicate:catalogTitlePredicate];
				NSUInteger numFoundCatalogs = [moc countForFetchRequest:fetchForCatalogs error:nil];
				if (numFoundCatalogs == 0) {
					CatalogMO *aNewCatalog = [NSEntityDescription insertNewObjectForEntityForName:@"Catalog" inManagedObjectContext:moc];
					aNewCatalog.title = obj;
				}
				[fetchForCatalogs release];
			}];
			
			// =================================
			// Get "requires" items
			// =================================
			NSArray *requires = [self.sourceDict objectForKey:@"requires"];
			[requires enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ requires item %lu --> Name: %@", self.fileName, (unsigned long)idx, obj);
				StringObjectMO *newRequiredPkgInfo = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
				newRequiredPkgInfo.title = obj;
				newRequiredPkgInfo.typeString = @"package";
				newRequiredPkgInfo.originalIndexValue = idx;
				[aNewPackage addRequirementsObject:newRequiredPkgInfo];
			}];
			
			// =================================
			// Get "update_for" items
			// =================================
			NSArray *update_for = [self.sourceDict objectForKey:@"update_for"];
			[update_for enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ update_for item %lu --> Name: %@", self.fileName, (unsigned long)idx, obj);
				StringObjectMO *newRequiredPkgInfo = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
				newRequiredPkgInfo.title = obj;
				newRequiredPkgInfo.typeString = @"package";
				newRequiredPkgInfo.originalIndexValue = idx;
				[aNewPackage addUpdateForObject:newRequiredPkgInfo];
			}];
            
            // =================================
			// Get "blocking_applications" items
			// =================================
			NSArray *blocking_applications = [self.sourceDict objectForKey:@"blocking_applications"];
			[blocking_applications enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ blocking_applications item %lu --> Name: %@", self.fileName, (unsigned long)idx, obj);
				StringObjectMO *newBlockingApplication = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
				newBlockingApplication.title = obj;
				newBlockingApplication.typeString = @"package";
				newBlockingApplication.originalIndexValue = idx;
				[aNewPackage addBlockingApplicationsObject:newBlockingApplication];
			}];
            
            // =================================
			// Get "supported_architectures" items
			// =================================
			NSArray *supported_architectures = [self.sourceDict objectForKey:@"supported_architectures"];
			[supported_architectures enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ blocking_applications item %lu --> Name: %@", self.fileName, (unsigned long)idx, obj);
				StringObjectMO *newSupportedArchitecture = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
				newSupportedArchitecture.title = obj;
				newSupportedArchitecture.typeString = @"architecture";
				newSupportedArchitecture.originalIndexValue = idx;
				[aNewPackage addSupportedArchitecturesObject:newSupportedArchitecture];
			}];
			
			
			// =====================================
			// Assimilate with existing
			// This is done only when adding new items to repo
			// =====================================
			if (self.canModify) {
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"Assimilating %@", self.fileName);
				NSFetchRequest *fetchForApplicationsLoose = [[NSFetchRequest alloc] init];
				[fetchForApplicationsLoose setEntity:applicationEntityDescr];
				NSPredicate *applicationTitlePredicateLoose;
				applicationTitlePredicateLoose = [NSPredicate predicateWithFormat:@"munki_name like[cd] %@", aNewPackage.munki_name];
                
				[fetchForApplicationsLoose setPredicate:applicationTitlePredicateLoose];
				
				NSUInteger numFoundApplications = [moc countForFetchRequest:fetchForApplicationsLoose error:nil];
				if (numFoundApplications == 0) {
					// No matching Applications found.
					NSLog(@"Assimilator found zero matching Applications for package.");
				} else if (numFoundApplications == 1) {
					ApplicationMO *existingApplication = [[moc executeFetchRequest:fetchForApplicationsLoose error:nil] objectAtIndex:0];
                    
                    // Get the latest package for comparison
                    NSSortDescriptor *sortPkgsByVersion = [NSSortDescriptor sortDescriptorWithKey:@"munki_version" ascending:NO selector:@selector(localizedStandardCompare:)];
                    PackageMO *latestPackage = [[[existingApplication packages] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortPkgsByVersion]] objectAtIndex:0];
                    if ([self.defaults boolForKey:@"debug"]) NSLog(@"Assimilating package with properties from: %@-%@", latestPackage.munki_name, latestPackage.munki_version);
                    
                    // If the existing matching packages have common description, use it with the new package
					if ([existingApplication hasCommonDescription]) {
						if ([self.defaults boolForKey:@"assimilate_description"]) {
							aNewPackage.munki_description = [latestPackage munki_description];
						}
					}
					
                    // Set the display name
					if ([self.defaults boolForKey:@"assimilate_display_name"]) {
						aNewPackage.munki_display_name = existingApplication.munki_display_name;
					}
                    
                    // Set the max OS version
                    if ([self.defaults boolForKey:@"assimilate_maximum_os_version"]) {
                        aNewPackage.munki_maximum_os_version = latestPackage.munki_maximum_os_version;
                    }
                    
                    // Set the minimum OS version
                    if ([self.defaults boolForKey:@"assimilate_minimum_os_version"]) {
                        aNewPackage.munki_minimum_os_version = latestPackage.munki_minimum_os_version;
                    }
                    
                    // Set the minimum munki version
                    if ([self.defaults boolForKey:@"assimilate_minimum_munki_version"]) {
                        aNewPackage.munki_minimum_munki_version = latestPackage.munki_minimum_munki_version;
                    }
                    
                    // Scripts
                    if ([self.defaults boolForKey:@"assimilate_preinstall_script"]) {
                        aNewPackage.munki_preinstall_script = latestPackage.munki_preinstall_script;
                    }
                    if ([self.defaults boolForKey:@"assimilate_preuninstall_script"]) {
                        aNewPackage.munki_preuninstall_script = latestPackage.munki_preuninstall_script;
                    }
                    if ([self.defaults boolForKey:@"assimilate_postinstall_script"]) {
                        aNewPackage.munki_postinstall_script = latestPackage.munki_postinstall_script;
                    }
                    if ([self.defaults boolForKey:@"assimilate_postuninstall_script"]) {
                        aNewPackage.munki_postuninstall_script = latestPackage.munki_postuninstall_script;
                    }
                    if ([self.defaults boolForKey:@"assimilate_installcheck_script"]) {
                        aNewPackage.munki_installcheck_script = latestPackage.munki_installcheck_script;
                    }
                    if ([self.defaults boolForKey:@"assimilate_uninstallcheck_script"]) {
                        aNewPackage.munki_uninstallcheck_script = latestPackage.munki_uninstallcheck_script;
                    }
                    
                    // Other properties
                    if ([self.defaults boolForKey:@"assimilate_autoremove"]) {
                        aNewPackage.munki_autoremove = latestPackage.munki_autoremove;
                    }
                    if ([self.defaults boolForKey:@"assimilate_installable_condition"]) {
                        aNewPackage.munki_installable_condition = latestPackage.munki_installable_condition;
                    }
                    if ([self.defaults boolForKey:@"assimilate_unattended_install"]) {
                        aNewPackage.munki_unattended_install = latestPackage.munki_unattended_install;
                    }
                    if ([self.defaults boolForKey:@"assimilate_unattended_uninstall"]) {
                        aNewPackage.munki_unattended_uninstall = latestPackage.munki_unattended_uninstall;
                    }
                    if ([self.defaults boolForKey:@"assimilate_uninstallable"]) {
                        aNewPackage.munki_uninstallable = latestPackage.munki_uninstallable;
                    }
                    if ([self.defaults boolForKey:@"assimilate_uninstall_method"]) {
                        aNewPackage.munki_uninstall_method = latestPackage.munki_uninstall_method;
                    }
                    if ([self.defaults boolForKey:@"assimilate_uninstall_script"]) {
                        aNewPackage.munki_uninstall_script = latestPackage.munki_uninstall_script;
                    }
                    if ([self.defaults boolForKey:@"assimilate_uninstaller_item_location"]) {
                        aNewPackage.munki_uninstaller_item_location = latestPackage.munki_uninstaller_item_location;
                    }
                    
                    
                    // Blocking applications
                    if ([self.defaults boolForKey:@"assimilate_blocking_applications"]) {
                        for (StringObjectMO *blockingApp in latestPackage.blockingApplications) {
                            StringObjectMO *newBlockingApplication = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
                            newBlockingApplication.title = blockingApp.title;
                            newBlockingApplication.typeString = @"package";
                            [aNewPackage addBlockingApplicationsObject:newBlockingApplication];
                        }
                    }
                    
                    // Requires
                    if ([self.defaults boolForKey:@"assimilate_requires"]) {
                        for (StringObjectMO *requiresItem in latestPackage.requirements) {
                            StringObjectMO *newRequiredPkgInfo = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
                            newRequiredPkgInfo.title = requiresItem.title;
                            newRequiredPkgInfo.typeString = @"package";
                            [aNewPackage addRequirementsObject:newRequiredPkgInfo];
                        }
                    }
                    
                    // Supported architectures
                    if ([self.defaults boolForKey:@"assimilate_supported_architectures"]) {
                        for (StringObjectMO *supportedArch in latestPackage.supportedArchitectures) {
                            StringObjectMO *newSupportedArchitecture = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
                            newSupportedArchitecture.title = supportedArch.title;
                            newSupportedArchitecture.typeString = @"architecture";
                            [aNewPackage addSupportedArchitecturesObject:newSupportedArchitecture];
                        }
                    }
                    
                    [existingApplication addPackagesObject:aNewPackage];
					
				} else {
					NSLog(@"Assimilator found multiple matching Applications for package. Can't decide on my own...");
					for (ApplicationMO *app in [moc executeFetchRequest:fetchForApplicationsLoose error:nil]) {
						NSLog(@"%@", app.munki_name);
					}
				}
				[fetchForApplicationsLoose release];
			}
			
			// =================================
			// Group packages by "name" property
			// =================================
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
