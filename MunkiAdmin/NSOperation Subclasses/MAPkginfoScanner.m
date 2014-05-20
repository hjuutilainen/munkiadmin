//
//  PkginfoScanner.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 5.10.2010.
//

#import "MAPkginfoScanner.h"
#import "MunkiAdmin_AppDelegate.h"
#import "DataModelHeaders.h"
#import "MAMunkiRepositoryManager.h"
#import "MACoreDataManager.h"


@implementation MAPkginfoScanner

- (NSUserDefaults *)defaults
{
	return [NSUserDefaults standardUserDefaults];
}

+ (id)scannerWithURL:(NSURL *)url
{
	return [[self alloc] initWithURL:url];
}

+ (id)scannerWithDictionary:(NSDictionary *)dict
{
	return [[self alloc] initWithDictionary:dict];
}


- (id)initWithDictionary:(NSDictionary *)dict
{
	if ((self = [super init])) {
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Initializing operation");
		self.sourceDict = dict;
		self.fileName = [self.sourceDict valueForKey:@"name"];
		self.currentJobDescription = @"Initializing pkginfo scan operation";
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
	}
	return self;
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
		@autoreleasepool {
            
			MAMunkiRepositoryManager *repoManager = [MAMunkiRepositoryManager sharedManager];
            MACoreDataManager *coreDataManager = [MACoreDataManager sharedManager];
            
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
				
				PackageMO *aNewPackage = [[PackageMO alloc] initWithEntity:packageEntityDescr insertIntoManagedObjectContext:moc];
                
				aNewPackage.originalPkginfo = self.sourceDict;
				
                /*
                 Get the basic package properties
                 
                 This loops over the "pkginfoBasicKeys" array from NSUserDefaults and will
                 take care of most of the standard pkginfo keys and values
                 */
				self.currentJobDescription = [NSString stringWithFormat:@"Reading basic info for %@", self.fileName];
				if ([self.defaults boolForKey:@"debug"]) NSLog(@"Reading basic info for %@", self.fileName);
				[repoManager.pkginfoBasicKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
					id value = [self.sourceDict objectForKey:obj];
					if (value != nil) {
						if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@ --> %@: %@", self.fileName, obj, value);
						[aNewPackage setValue:value forKey:key];
					} else {
						if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@ --> %@: nil (skipped)", self.fileName, key);
					}
				}];
                
                
                
                /*
                 Additional steps for deprecated forced_install
                 */
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
                
                /*
                 Additional steps for deprecated forced_uninstall
                 */
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
                
                /*
                 Get the "_metadata" key
                 */
                NSDictionary *munki_metadata = [self.sourceDict objectForKey:@"_metadata"];
                __block NSDate *pkginfoDateCreatedFromMetadata = nil;
                [munki_metadata enumerateKeysAndObjectsWithOptions:0 usingBlock:^(id key, id obj, BOOL *stop) {
                    if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ installer_environment key: %@, value: %@", self.fileName, key, obj);
                    if (([key isEqualToString:@"creation_date"]) && ([obj isKindOfClass:[NSDate class]])) {
                        pkginfoDateCreatedFromMetadata = obj;
                    }
                }];
                
                /*
                 This pkginfo is a file on disk
                 */
				if (self.sourceURL != nil) {
					aNewPackage.packageInfoURL = self.sourceURL;
                    
                    /*
                     If this package has a creation_date in its _metadata, use it
                     instead of the actual file creation date.
                     */
                    if (pkginfoDateCreatedFromMetadata != nil) {
                        aNewPackage.packageInfoDateCreated = pkginfoDateCreatedFromMetadata;
                    } else {
                        NSDate *pkginfoDateCreated;
                        [aNewPackage.packageInfoURL getResourceValue:&pkginfoDateCreated forKey:NSURLCreationDateKey error:nil];
                        aNewPackage.packageInfoDateCreated = pkginfoDateCreated;
                    }
                    
                    NSDate *pkginfoDateLastOpened;
                    [aNewPackage.packageInfoURL getResourceValue:&pkginfoDateLastOpened forKey:NSURLContentAccessDateKey error:nil];
                    aNewPackage.packageInfoDateLastOpened = pkginfoDateLastOpened;
                    
                    NSDate *pkginfoDateModified;
                    [aNewPackage.packageInfoURL getResourceValue:&pkginfoDateModified forKey:NSURLContentModificationDateKey error:nil];
                    aNewPackage.packageInfoDateModified = pkginfoDateModified;
                    
				}
                /*
                 This pkginfo does not exist on disk (yet).
                 */
                else {
                    NSString *newBaseName = [aNewPackage.munki_name stringByReplacingOccurrencesOfString:@" " withString:@"-"];
                    NSString *newNameAndVersion = [NSString stringWithFormat:@"%@-%@", newBaseName, aNewPackage.munki_version];
                    NSURL *newPkginfoURL = [[[NSApp delegate] pkgsInfoURL] URLByAppendingPathComponent:newNameAndVersion];
					newPkginfoURL = [newPkginfoURL URLByAppendingPathExtension:@"plist"];
					aNewPackage.packageInfoURL = newPkginfoURL;
                    
                    /*
                     If this package has a creation_date in its _metadata, use it
                     instead of the actual file creation date.
                     */
                    if (pkginfoDateCreatedFromMetadata != nil) {
                        aNewPackage.packageInfoDateCreated = pkginfoDateCreatedFromMetadata;
                    } else {
                        aNewPackage.packageInfoDateCreated = [NSDate date];
                    }
                    aNewPackage.packageInfoDateModified = [NSDate date];
                    aNewPackage.packageInfoDateLastOpened = [NSDate date];
				}
                
                /*
                 Get the installer item properties if this pkginfo has one.
                 */
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
				
                /*
                 Get the "receipts" items
                 */
				NSArray *itemReceipts = [self.sourceDict objectForKey:@"receipts"];
				[itemReceipts enumerateObjectsWithOptions:0 usingBlock:^(id aReceipt, NSUInteger idx, BOOL *stop) {
					ReceiptMO *aNewReceipt = [NSEntityDescription insertNewObjectForEntityForName:@"Receipt" inManagedObjectContext:moc];
					aNewReceipt.package = aNewPackage;
                    aNewReceipt.originalIndexValue = idx;
					[repoManager.receiptKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
						id value = [aReceipt objectForKey:obj];
						if (value != nil) {
							if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@, receipt %lu --> %@: %@", self.fileName, (unsigned long)idx, obj, value);
							[aNewReceipt setValue:value forKey:key];
						} else {
							if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@, receipt %lu --> %@: nil (skipped)", self.fileName, (unsigned long)idx, key);
						}
					}];
				}];
				
				/*
                 Get the "installs" items
                 */
				NSArray *installItems = [self.sourceDict objectForKey:@"installs"];
				[installItems enumerateObjectsWithOptions:0 usingBlock:^(id anInstall, NSUInteger idx, BOOL *stop) {
                    InstallsItemMO *aNewInstallsItem = [coreDataManager createInstallsItemFromDictionary:anInstall inManagedObjectContext:moc];
                    [aNewInstallsItem addPackagesObject:aNewPackage];
                    aNewInstallsItem.originalIndexValue = idx;
				}];
				
				/*
                 Get the "items_to_copy" items
                 */
				NSArray *itemsToCopy = [self.sourceDict objectForKey:@"items_to_copy"];
				[itemsToCopy enumerateObjectsWithOptions:0 usingBlock:^(id anItemToCopy, NSUInteger idx, BOOL *stop) {
					ItemToCopyMO *aNewItemToCopy = [NSEntityDescription insertNewObjectForEntityForName:@"ItemToCopy" inManagedObjectContext:moc];
					aNewItemToCopy.package = aNewPackage;
                    aNewItemToCopy.originalIndexValue = idx;
					[repoManager.itemsToCopyKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
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
                
                /*
                 Get the "installer_choices_xml" items
                 */
				NSArray *installerChoices = [self.sourceDict objectForKey:@"installer_choices_xml"];
				[installerChoices enumerateObjectsWithOptions:0 usingBlock:^(id aChoice, NSUInteger idx, BOOL *stop) {
					InstallerChoicesItemMO *aNewInstallerChoice = [NSEntityDescription insertNewObjectForEntityForName:@"InstallerChoicesItem" inManagedObjectContext:moc];
					aNewInstallerChoice.package = aNewPackage;
                    aNewInstallerChoice.originalIndexValue = idx;
					[repoManager.installerChoicesKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
						id value = [aChoice objectForKey:obj];
						if (value != nil) {
							if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@, installer_choices_xml item %lu --> %@: %@", self.fileName, (unsigned long)idx, obj, value);
							[aNewInstallerChoice setValue:value forKey:key];
						} else {
							if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"%@, installer_choices_xml item %lu --> %@: nil (skipped)", self.fileName, (unsigned long)idx, key);
						}
					}];
				}];
				
				
				/*
                 Get the "catalogs" items
                 */
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
				}];
				
				/*
                 Get the "requires" items
                 */
				NSArray *requires = [self.sourceDict objectForKey:@"requires"];
				[requires enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ requires item %lu --> Name: %@", self.fileName, (unsigned long)idx, obj);
					StringObjectMO *newRequiredPkgInfo = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
					newRequiredPkgInfo.title = obj;
					newRequiredPkgInfo.typeString = @"requires";
					newRequiredPkgInfo.originalIndexValue = idx;
					[aNewPackage addRequirementsObject:newRequiredPkgInfo];
				}];
				
                /*
                 Get the "update_for" items
                 */
				NSArray *update_for = [self.sourceDict objectForKey:@"update_for"];
				[update_for enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ update_for item %lu --> Name: %@", self.fileName, (unsigned long)idx, obj);
					StringObjectMO *newRequiredPkgInfo = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
					newRequiredPkgInfo.title = obj;
					newRequiredPkgInfo.typeString = @"updateFor";
					newRequiredPkgInfo.originalIndexValue = idx;
					[aNewPackage addUpdateForObject:newRequiredPkgInfo];
				}];
                
                /*
                 Get the "blocking_applications" items
                 */
				NSArray *blocking_applications = [self.sourceDict objectForKey:@"blocking_applications"];
                if (!blocking_applications) {
                    aNewPackage.hasEmptyBlockingApplicationsValue = NO;
                } else if ([blocking_applications count] == 0) {
                    aNewPackage.hasEmptyBlockingApplicationsValue = YES;
                } else {
                    aNewPackage.hasEmptyBlockingApplicationsValue = NO;
                }
				[blocking_applications enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ blocking_applications item %lu --> Name: %@", self.fileName, (unsigned long)idx, obj);
					StringObjectMO *newBlockingApplication = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
					newBlockingApplication.title = obj;
					newBlockingApplication.typeString = @"blockingApplication";
					newBlockingApplication.originalIndexValue = idx;
					[aNewPackage addBlockingApplicationsObject:newBlockingApplication];
				}];
                
                /*
                 Get the "supported_architectures" items
                 */
				NSArray *supported_architectures = [self.sourceDict objectForKey:@"supported_architectures"];
				[supported_architectures enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ blocking_applications item %lu --> Name: %@", self.fileName, (unsigned long)idx, obj);
					StringObjectMO *newSupportedArchitecture = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
					newSupportedArchitecture.title = obj;
					newSupportedArchitecture.typeString = @"supportedArchitecture";
					newSupportedArchitecture.originalIndexValue = idx;
					[aNewPackage addSupportedArchitecturesObject:newSupportedArchitecture];
				}];
				
                /*
                 Get the "installer_environment" items
                 */
				NSDictionary *installer_environment = [self.sourceDict objectForKey:@"installer_environment"];
                [installer_environment enumerateKeysAndObjectsWithOptions:0 usingBlock:^(id key, id obj, BOOL *stop) {
                    if ([self.defaults boolForKey:@"debug"]) NSLog(@"%@ installer_environment key: %@, value: %@", self.fileName, key, obj);
                    InstallerEnvironmentVariableMO *newInstallerEnvironmentVariable = [NSEntityDescription insertNewObjectForEntityForName:@"InstallerEnvironmentVariable" inManagedObjectContext:moc];
					newInstallerEnvironmentVariable.munki_installer_environment_key = key;
                    newInstallerEnvironmentVariable.munki_installer_environment_value = obj;
					[aNewPackage addInstallerEnvironmentVariablesObject:newInstallerEnvironmentVariable];
                }];
                
				// =====================================
				// Assimilate with existing
				// This is done only when adding new items to repo
				// =====================================
				/*
                 Assimilator functions moved to class MunkiRepositoryManager
                 */
				
				// =====================================
				// Group packages by the "name" key
				// =====================================
				NSFetchRequest *fetchForApplications = [[NSFetchRequest alloc] init];
				[fetchForApplications setEntity:applicationEntityDescr];
				NSPredicate *applicationTitlePredicate;
				applicationTitlePredicate = [NSPredicate predicateWithFormat:@"munki_name == %@", aNewPackage.munki_name];
				
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
				
				
				
			} else {
				NSLog(@"Can't read pkginfo file %@", [self.sourceURL relativePath]);
			}
            
			/*
             Save the context, this causes main app delegate to merge new items
             */
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
			
            moc = nil;
		}
	}
	@catch(...) {
		// Do not rethrow exceptions.
	}
}


@end
