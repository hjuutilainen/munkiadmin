//
//  PkginfoScanner.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 5.10.2010.
//

#import "MAPkginfoScanner.h"
#import "MAMunkiAdmin_AppDelegate.h"
#import "DataModelHeaders.h"
#import "MAMunkiRepositoryManager.h"
#import "MACoreDataManager.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

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
		_sourceDict = dict;
		_fileName = [_sourceDict valueForKey:@"name"];
		_currentJobDescription = @"Initializing pkginfo scan operation";
        DDLogDebug(@"Initializing read operation with pkginfo dictionary: %@", [dict description]);
	}
	return self;
}

- (id)initWithURL:(NSURL *)src
{
	if ((self = [super init])) {
		_sourceURL = src;
		_fileName = [_sourceURL lastPathComponent];
		_currentJobDescription = @"Initializing pkginfo scan operation";
        DDLogDebug(@"Initializing read operation for pkginfo %@", [src path]);
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
            MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
            
			NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
            [moc setUndoManager:nil];
            [moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
			[moc setPersistentStoreCoordinator:[appDelegate persistentStoreCoordinator]];
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(contextDidSave:)
														 name:NSManagedObjectContextDidSaveNotification
													   object:moc];
			NSEntityDescription *catalogEntityDescr = [NSEntityDescription entityForName:@"Catalog" inManagedObjectContext:moc];
			NSEntityDescription *packageEntityDescr = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc];
			NSEntityDescription *applicationEntityDescr = [NSEntityDescription entityForName:@"Application" inManagedObjectContext:moc];
			
			
			if (self.sourceURL != nil) {
                self.currentJobDescription = [NSString stringWithFormat:@"Reading file %@", self.fileName];
                DDLogDebug(@"%@: Reading file from disk", self.fileName);
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
				DDLogDebug(@"%@: Found %lu keys", self.fileName, [self.sourceDict count]);
				[repoManager.pkginfoBasicKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
					id value = [self.sourceDict objectForKey:obj];
					if (value != nil) {
                        DDLogVerbose(@"%@: %@: %@", self.fileName, obj, value);
						[aNewPackage setValue:value forKey:key];
					} else {
						//if ([self.defaults boolForKey:@"debugLogAllProperties"]) DDLogDebug(@"%@ --> %@: nil (skipped)", self.fileName, key);
                        //DDLogDebug(@"%@ --> %@: nil (skipped)", self.fileName, key);
                    }
				}];
                
                
                
                /*
                 Additional steps for deprecated forced_install
                 */
                if ((aNewPackage.munki_forced_install != nil) && (aNewPackage.munki_unattended_install != nil)) {
                    // pkginfo has both forced_install and unattended_install defined
                    if (aNewPackage.munki_forced_installValue != aNewPackage.munki_unattended_installValue) {
                        DDLogDebug(@"%@ has both forced_install and unattended_install defined with differing values. Favoring unattended_install", self.fileName);
                        aNewPackage.munki_forced_install = aNewPackage.munki_unattended_install;
                    }
                }
                else if ((aNewPackage.munki_forced_install != nil) && (aNewPackage.munki_unattended_install == nil)) {
                    // pkginfo has only forced_install defined
                    DDLogDebug(@"%@ has only forced_install defined. Migrating to unattended_install", self.fileName);
                    aNewPackage.munki_unattended_install = aNewPackage.munki_forced_install;
                }
                
                /*
                 Additional steps for deprecated forced_uninstall
                 */
                if ((aNewPackage.munki_forced_uninstall != nil) && (aNewPackage.munki_unattended_uninstall != nil)) {
                    // pkginfo has both values defined
                    if (aNewPackage.munki_forced_uninstallValue != aNewPackage.munki_unattended_uninstallValue) {
                        DDLogDebug(@"%@ has both forced_uninstall and unattended_uninstall defined with differing values. Favoring unattended_uninstall", self.fileName);
                        aNewPackage.munki_forced_uninstall = aNewPackage.munki_unattended_uninstall;
                    }
                }
                else if ((aNewPackage.munki_forced_uninstall != nil) && (aNewPackage.munki_unattended_uninstall == nil)) {
                    // pkginfo has only forced_uninstall defined
                    DDLogDebug(@"%@ has only forced_uninstall defined. Migrating to unattended_uninstall", self.fileName);
                    aNewPackage.munki_unattended_uninstall = aNewPackage.munki_forced_uninstall;
                }
                
                
                // Check if we have installer_item_location and expand it to absolute URL
                if (aNewPackage.munki_installer_item_location != nil) {
                    aNewPackage.packageURL = [[appDelegate pkgsURL] URLByAppendingPathComponent:aNewPackage.munki_installer_item_location];
                }
                
                /*
                 Get the "_metadata" key
                 */
                DDLogDebug(@"%@: Reading _metadata...", self.fileName);
                NSDictionary *munki_metadata = [self.sourceDict objectForKey:@"_metadata"];
                __block NSDate *pkginfoDateCreatedFromMetadata = nil;
                [munki_metadata enumerateKeysAndObjectsWithOptions:0 usingBlock:^(id key, id obj, BOOL *stop) {
                    DDLogVerbose(@"%@: _metadata --> %@: %@", self.fileName, key, obj);
                    if (([key isEqualToString:@"creation_date"]) && ([obj isKindOfClass:[NSDate class]])) {
                        pkginfoDateCreatedFromMetadata = obj;
                    }
                }];
                
                /*
                 This pkginfo is a file on disk
                 */
				if (self.sourceURL != nil) {
                    DDLogDebug(@"%@: Reading file modification and creation dates...", self.fileName);
                    
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
                    NSURL *newPkginfoURL = [[appDelegate pkgsInfoURL] URLByAppendingPathComponent:newNameAndVersion];
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
                if ([itemReceipts count] > 0) {
                    DDLogDebug(@"%@: Found %lu receipt items", self.fileName, (unsigned long)[itemReceipts count]);
                }
				[itemReceipts enumerateObjectsWithOptions:0 usingBlock:^(id aReceipt, NSUInteger idx, BOOL *stop) {
					ReceiptMO *aNewReceipt = [NSEntityDescription insertNewObjectForEntityForName:@"Receipt" inManagedObjectContext:moc];
					aNewReceipt.package = aNewPackage;
                    aNewReceipt.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
					[repoManager.receiptKeyMappings enumerateKeysAndObjectsUsingBlock:^(id receiptKey, id receiptObject, BOOL *stopMappingsEnum) {
						id value = [aReceipt objectForKey:receiptObject];
						if (value != nil) {
							DDLogVerbose(@"%@: receipt %lu --> %@: %@", self.fileName, (unsigned long)idx, receiptObject, value);
							[aNewReceipt setValue:value forKey:receiptKey];
						} else {
							//DDLogDebug(@"%@: receipt %lu --> %@: nil (skipped)", self.fileName, (unsigned long)idx, receiptKey);
						}
					}];
                    //DDLogDebug(@"%@: receipt %lu --> %@", self.fileName, (unsigned long)idx, aReceipt);
				}];
				
				/*
                 Get the "installs" items
                 */
				NSArray *installItems = [self.sourceDict objectForKey:@"installs"];
                if ([installItems count] > 0) {
                    DDLogDebug(@"%@: Found %lu installs items", self.fileName, (unsigned long)[installItems count]);
                }
				[installItems enumerateObjectsWithOptions:0 usingBlock:^(id anInstall, NSUInteger idx, BOOL *stop) {
                    InstallsItemMO *aNewInstallsItem = [coreDataManager createInstallsItemFromDictionary:anInstall inManagedObjectContext:moc];
                    [aNewInstallsItem addPackagesObject:aNewPackage];
                    aNewInstallsItem.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
                    [repoManager.installsKeyMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        id value = [anInstall objectForKey:obj];
                        if (value != nil) {
                            DDLogVerbose(@"%@: installs item %lu --> %@: %@", self.fileName, (unsigned long)idx, key, obj);
                        } else {
                            //DDLogDebug(@"%@: items_to_copy item %lu --> %@: nil (skipped)", self.fileName, (unsigned long)idx, itemsToCopyKey);
                        }
                    }];
                    //DDLogDebug(@"%@: installs %lu --> %@", self.fileName, (unsigned long)idx, anInstall);
				}];
				
				/*
                 Get the "items_to_copy" items
                 */
				NSArray *itemsToCopy = [self.sourceDict objectForKey:@"items_to_copy"];
                if ([itemsToCopy count] > 0) {
                    DDLogDebug(@"%@: Found %lu items_to_copy items", self.fileName, (unsigned long)[itemsToCopy count]);
                }
				[itemsToCopy enumerateObjectsWithOptions:0 usingBlock:^(id anItemToCopy, NSUInteger idx, BOOL *stop) {
					ItemToCopyMO *aNewItemToCopy = [NSEntityDescription insertNewObjectForEntityForName:@"ItemToCopy" inManagedObjectContext:moc];
					aNewItemToCopy.package = aNewPackage;
                    aNewItemToCopy.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
					[repoManager.itemsToCopyKeyMappings enumerateKeysAndObjectsUsingBlock:^(id itemsToCopyKey, id itemsToCopyObject, BOOL *stopItemsToCopyMappingsEnum) {
						id value = [anItemToCopy objectForKey:itemsToCopyObject];
						if (value != nil) {
							DDLogVerbose(@"%@: items_to_copy item %lu --> %@: %@", self.fileName, (unsigned long)idx, itemsToCopyObject, value);
							[aNewItemToCopy setValue:value forKey:itemsToCopyKey];
						} else {
							//DDLogDebug(@"%@: items_to_copy item %lu --> %@: nil (skipped)", self.fileName, (unsigned long)idx, itemsToCopyKey);
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
                if ([installerChoices count] > 0) {
                    DDLogDebug(@"%@: Found %lu installer_choices_xml items", self.fileName, (unsigned long)[installerChoices count]);
                }
				[installerChoices enumerateObjectsWithOptions:0 usingBlock:^(id aChoice, NSUInteger idx, BOOL *stop) {
					InstallerChoicesItemMO *aNewInstallerChoice = [NSEntityDescription insertNewObjectForEntityForName:@"InstallerChoicesItem" inManagedObjectContext:moc];
					aNewInstallerChoice.package = aNewPackage;
                    aNewInstallerChoice.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
					[repoManager.installerChoicesKeyMappings enumerateKeysAndObjectsUsingBlock:^(id choiceKey, id choiceObject, BOOL *stopChoiceMappingEnum) {
						id value = [aChoice objectForKey:choiceObject];
						if (value != nil) {
							DDLogVerbose(@"%@: installer_choices_xml item %lu --> %@: %@", self.fileName, (unsigned long)idx, choiceObject, value);
							[aNewInstallerChoice setValue:value forKey:choiceKey];
						} else {
							//DDLogVerbose(@"%@: installer_choices_xml item %lu --> %@: nil (skipped)", self.fileName, (unsigned long)idx, choiceKey);
						}
					}];
				}];
				
				
				/*
                 Get the "catalogs" items
                 */
				NSArray *catalogs = [self.sourceDict objectForKey:@"catalogs"];
                if ([catalogs count] > 0) {
                    DDLogDebug(@"%@: Found %lu catalog items", self.fileName, (unsigned long)[catalogs count]);
                }
				[catalogs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    DDLogVerbose(@"%@: catalogs item %lu --> %@", self.fileName, (unsigned long)idx, obj);
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
                if ([requires count] > 0) {
                    DDLogDebug(@"%@: Found %lu requires items", self.fileName, (unsigned long)[requires count]);
                }
				[requires enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					DDLogVerbose(@"%@: requires item %lu --> %@", self.fileName, (unsigned long)idx, obj);
					StringObjectMO *newRequiredPkgInfo = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
					newRequiredPkgInfo.title = obj;
					newRequiredPkgInfo.typeString = @"requires";
					newRequiredPkgInfo.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
					[aNewPackage addRequirementsObject:newRequiredPkgInfo];
				}];
				
                /*
                 Get the "update_for" items
                 */
				NSArray *update_for = [self.sourceDict objectForKey:@"update_for"];
                if ([update_for count] > 0) {
                    DDLogDebug(@"%@: Found %lu update_for items", self.fileName, (unsigned long)[update_for count]);
                }
				[update_for enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					DDLogVerbose(@"%@: update_for item %lu --> %@", self.fileName, (unsigned long)idx, obj);
					StringObjectMO *newRequiredPkgInfo = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
					newRequiredPkgInfo.title = obj;
					newRequiredPkgInfo.typeString = @"updateFor";
					newRequiredPkgInfo.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
					[aNewPackage addUpdateForObject:newRequiredPkgInfo];
				}];
                
                /*
                 Get the "blocking_applications" items
                 */
				NSArray *blocking_applications = [self.sourceDict objectForKey:@"blocking_applications"];
                if ([blocking_applications count] > 0) {
                    DDLogDebug(@"%@: Found %lu blocking_applications", self.fileName, (unsigned long)[blocking_applications count]);
                }
                if (!blocking_applications) {
                    aNewPackage.hasEmptyBlockingApplicationsValue = NO;
                } else if ([blocking_applications count] == 0) {
                    aNewPackage.hasEmptyBlockingApplicationsValue = YES;
                } else {
                    aNewPackage.hasEmptyBlockingApplicationsValue = NO;
                }
				[blocking_applications enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					DDLogVerbose(@"%@: blocking_applications item %lu --> %@", self.fileName, (unsigned long)idx, obj);
					StringObjectMO *newBlockingApplication = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
					newBlockingApplication.title = obj;
					newBlockingApplication.typeString = @"blockingApplication";
					newBlockingApplication.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
					[aNewPackage addBlockingApplicationsObject:newBlockingApplication];
				}];
                
                /*
                 Get the "supported_architectures" items
                 */
				NSArray *supported_architectures = [self.sourceDict objectForKey:@"supported_architectures"];
                if ([supported_architectures count] > 0) {
                    DDLogDebug(@"%@: Found %lu supported_architectures items", self.fileName, (unsigned long)[supported_architectures count]);
                }
				[supported_architectures enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					DDLogVerbose(@"%@: supported_architectures item %lu --> %@", self.fileName, (unsigned long)idx, obj);
					StringObjectMO *newSupportedArchitecture = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
					newSupportedArchitecture.title = obj;
					newSupportedArchitecture.typeString = @"supportedArchitecture";
					newSupportedArchitecture.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
					[aNewPackage addSupportedArchitecturesObject:newSupportedArchitecture];
				}];
				
                /*
                 Get the "installer_environment" items
                 */
				NSDictionary *installer_environment = [self.sourceDict objectForKey:@"installer_environment"];
                if ([installer_environment count] > 0) {
                    DDLogDebug(@"%@: Found %lu installer_environment items", self.fileName, (unsigned long)[installer_environment count]);
                }
                [installer_environment enumerateKeysAndObjectsWithOptions:0 usingBlock:^(id key, id obj, BOOL *stop) {
                    DDLogVerbose(@"%@: installer_environment --> %@: %@", self.fileName, key, obj);
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
					DDLogError(@"Found multiple Applications for package. This really shouldn't happen...");
				}
				
				
				
			} else {
				DDLogError(@"Can't read pkginfo file %@", [self.sourceURL relativePath]);
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
