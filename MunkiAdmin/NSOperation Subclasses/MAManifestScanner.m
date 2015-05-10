//
//  ManifestScanner.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 6.10.2010.
//

#import "MAManifestScanner.h"
#import "MAMunkiAdmin_AppDelegate.h"
#import "DataModelHeaders.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

@interface MAManifestScanner ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (strong) NSArray *allManifests;
@property (strong) NSDictionary *allManifestsByTitle;
@end

@implementation MAManifestScanner

- (NSUserDefaults *)defaults
{
	return [NSUserDefaults standardUserDefaults];
}


- (id)initWithURL:(NSURL *)src {
	if ((self = [super init])) {
		DDLogVerbose(@"Initializing read operation for manifest %@", [src path]);
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _context.parentContext = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
        _context.undoManager = nil;
		self.sourceURL = src;
		self.fileName = [self.sourceURL lastPathComponent];
		self.currentJobDescription = @"Initializing manifest scan operation";
		
	}
	return self;
}


- (id)matchingObjectForString:(NSString *)aString
{
    NSPredicate *appPred = [NSPredicate predicateWithFormat:@"munki_name == %@", aString];
    NSUInteger foundIndex = [apps indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [appPred evaluateWithObject:obj];
    }];
    
    if (foundIndex != NSNotFound) {
        return [apps objectAtIndex:foundIndex];
    } else {
        NSPredicate *pkgPred = [NSPredicate predicateWithFormat:@"titleWithVersion == %@", aString];
        NSUInteger foundPkgIndex = [packages indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [pkgPred evaluateWithObject:obj];
        }];
        if (foundPkgIndex != NSNotFound) {
            return [packages objectAtIndex:foundPkgIndex];
        } else {
            return nil;
        }
    }
}

- (void)conditionalItemsFrom:(NSArray *)items parent:(ConditionalItemMO *)parent manifest:(ManifestMO *)manifest context:(NSManagedObjectContext *)moc
{
    [items enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *condition = [(NSDictionary *)obj objectForKey:@"condition"];
        ConditionalItemMO *newConditionalItem = [NSEntityDescription insertNewObjectForEntityForName:@"ConditionalItem" inManagedObjectContext:moc];
        newConditionalItem.munki_condition = condition;
        newConditionalItem.manifest = manifest;
        newConditionalItem.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
        if (parent) {
            newConditionalItem.parent = parent;
            //newConditionalItem.joinedCondition = [NSString stringWithFormat:@"%@ - %@", parent.joinedCondition, newConditionalItem.munki_condition];
            DDLogVerbose(@"%@ Nested conditional_item %lu --> Condition: %@", manifest.title, (unsigned long)idx, condition);
        } else {
            //newConditionalItem.joinedCondition = [NSString stringWithFormat:@"%@", newConditionalItem.munki_condition];
            DDLogVerbose(@"%@ conditional_item %lu --> Condition: %@", manifest.title, (unsigned long)idx, condition);
        }
        
        NSArray *managedInstalls = [(NSDictionary *)obj objectForKey:@"managed_installs"];
        [managedInstalls enumerateObjectsWithOptions:0 usingBlock:^(id managedInstallName, NSUInteger managedInstallIndex, BOOL *stopManagedInstallsEnum) {
            DDLogVerbose(@"%@ conditional_item --> managed_installs item %lu --> Name: %@", manifest.title, (unsigned long)managedInstallIndex, managedInstallName);
            StringObjectMO *newManagedInstall = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
            newManagedInstall.title = (NSString *)managedInstallName;
            newManagedInstall.typeString = @"managedInstall";
            newManagedInstall.originalIndex = [NSNumber numberWithUnsignedInteger:managedInstallIndex];
            [newConditionalItem addManagedInstallsObject:newManagedInstall];
        }];
        NSArray *managedUninstalls = [(NSDictionary *)obj objectForKey:@"managed_uninstalls"];
        [managedUninstalls enumerateObjectsWithOptions:0 usingBlock:^(id managedUninstallName, NSUInteger managedUninstallIndex, BOOL *stopManagedUninstallsEnum) {
            DDLogVerbose(@"%@ conditional_item --> managed_uninstalls item %lu --> Name: %@", manifest.title, (unsigned long)managedUninstallIndex, managedUninstallName);
            StringObjectMO *newManagedUninstall = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
            newManagedUninstall.title = (NSString *)managedUninstallName;
            newManagedUninstall.typeString = @"managedUninstall";
            newManagedUninstall.originalIndex = [NSNumber numberWithUnsignedInteger:managedUninstallIndex];
            [newConditionalItem addManagedUninstallsObject:newManagedUninstall];
        }];
        NSArray *managedUpdates = [(NSDictionary *)obj objectForKey:@"managed_updates"];
        [managedUpdates enumerateObjectsWithOptions:0 usingBlock:^(id managedUpdateName, NSUInteger managedUpdateIndex, BOOL *stopManagedUpdatesEnum) {
            DDLogVerbose(@"%@ conditional_item --> managed_updates item %lu --> Name: %@", manifest.title, (unsigned long)managedUpdateIndex, managedUpdateName);
            StringObjectMO *newManagedUpdate = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
            newManagedUpdate.title = (NSString *)managedUpdateName;
            newManagedUpdate.typeString = @"managedUpdate";
            newManagedUpdate.originalIndex = [NSNumber numberWithUnsignedInteger:managedUpdateIndex];
            [newConditionalItem addManagedUpdatesObject:newManagedUpdate];
        }];
        NSArray *optionalInstalls = [(NSDictionary *)obj objectForKey:@"optional_installs"];
        [optionalInstalls enumerateObjectsWithOptions:0 usingBlock:^(id optionalInstallName, NSUInteger optionalInstallIndex, BOOL *stopOptionalInstallsEnum) {
            DDLogVerbose(@"%@ conditional_item --> optional_installs item %lu --> Name: %@", manifest.title, (unsigned long)optionalInstallIndex, optionalInstallName);
            StringObjectMO *newOptionalInstall = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
            newOptionalInstall.title = (NSString *)optionalInstallName;
            newOptionalInstall.typeString = @"optionalInstall";
            newOptionalInstall.originalIndex = [NSNumber numberWithUnsignedInteger:optionalInstallIndex];
            [newConditionalItem addOptionalInstallsObject:newOptionalInstall];
        }];
        NSArray *includedManifests = [(NSDictionary *)obj objectForKey:@"included_manifests"];
        [includedManifests enumerateObjectsWithOptions:0 usingBlock:^(id includedManifestName, NSUInteger includedManifestIndex, BOOL *stopIncludedManifestsEnum) {
            DDLogVerbose(@"%@ conditional_item --> included_manifests item %lu --> Name: %@", manifest.title, (unsigned long)includedManifestIndex, includedManifestName);
            StringObjectMO *newIncludedManifest = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
            newIncludedManifest.title = (NSString *)includedManifestName;
            newIncludedManifest.typeString = @"includedManifest";
            newIncludedManifest.originalIndex = [NSNumber numberWithUnsignedInteger:includedManifestIndex];
            newIncludedManifest.indexInNestedManifest = [NSNumber numberWithUnsignedInteger:includedManifestIndex];
            [newConditionalItem addIncludedManifestsObject:newIncludedManifest];
            
            /*
            if ([self.allManifestsByTitle objectForKey:(NSString *)obj]) {
                newIncludedManifest.originalManifest = [self.allManifestsByTitle objectForKey:(NSString *)obj];
            } else {
                DDLogError(@"%@ could not link item %lu --> Name: %@", manifest.title, (unsigned long)includedManifestIndex, includedManifestName);
            }
             */
        }];
        
        // If there are nested conditional items, loop through them with this same function
        NSArray *conditionalItems = [(NSDictionary *)obj objectForKey:@"conditional_items"];
        if (conditionalItems) {
            [self conditionalItemsFrom:conditionalItems parent:newConditionalItem manifest:manifest context:moc];
        }
    }];
}


- (ManifestMO *)matchingManifestForString:(NSString *)title inMoc:(NSManagedObjectContext *)moc
{
    // Get all application objects for later use
    NSFetchRequest *getManifests = [[NSFetchRequest alloc] init];
    [getManifests setEntity:[NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:moc]];
    [getManifests setReturnsObjectsAsFaults:NO];
    [getManifests setIncludesSubentities:NO];
    NSArray *manifests = [moc executeFetchRequest:getManifests error:nil];
    
    NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title == %@", title];
    NSUInteger foundIndex = [manifests indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [titlePredicate evaluateWithObject:obj];
    }];
    
    if (foundIndex != NSNotFound) {
        return [manifests objectAtIndex:foundIndex];
    } else {
        return nil;
    }
}

- (void)scan {
	@try {
		@autoreleasepool {
            
            MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
			NSManagedObjectContext *privateContext = self.context;
			self.currentJobDescription = [NSString stringWithFormat:@"Reading manifest %@", self.fileName];
			
            NSEntityDescription *manifestEntityDescr = [NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:privateContext];
            
            // Get manifests for later use
            NSFetchRequest *getManifests = [[NSFetchRequest alloc] init];
            [getManifests setEntity:manifestEntityDescr];
            
            self.allManifests = [privateContext executeFetchRequest:getManifests error:nil];
            NSMutableDictionary *manifestsAndTitles = [[NSMutableDictionary alloc] initWithCapacity:[self.allManifests count]];
            
            for (ManifestMO *manifest in self.allManifests) {
                manifestsAndTitles[manifest.title] = manifest;
            }
            
            self.allManifestsByTitle = [NSDictionary dictionaryWithDictionary:manifestsAndTitles];
            
            /*
             * Read the manifest dictionary from disk
             */
            DDLogDebug(@"%@: Reading file from disk", self.fileName);
			NSDictionary *manifestInfoDict = [NSDictionary dictionaryWithContentsOfURL:self.sourceURL];
			if (manifestInfoDict != nil) {
                
                /*
                 * Manifest name should be the relative path from manifests subdirectory
                 */
                NSArray *manifestComponents = [self.sourceURL pathComponents];
                NSArray *manifestDirComponents = [[appDelegate manifestsURL] pathComponents];
                NSMutableArray *relativePathComponents = [NSMutableArray arrayWithArray:manifestComponents];
                [relativePathComponents removeObjectsInArray:manifestDirComponents];
                NSString *manifestRelativePath = [relativePathComponents componentsJoinedByString:@"/"];
                
                /*
                 * Check if we already have a manifest with this name
                 */
                ManifestMO *manifest;
                if ([self.allManifestsByTitle objectForKey:manifestRelativePath]) {
                    manifest = [self.allManifestsByTitle objectForKey:manifestRelativePath];
                    DDLogVerbose(@"%@: Reusing existing manifest object from memory", self.fileName);
                } else {
                    manifest = [NSEntityDescription insertNewObjectForEntityForName:@"Manifest" inManagedObjectContext:privateContext];
                    manifest.title = manifestRelativePath;
                    manifest.manifestURL = self.sourceURL;
                    manifest.manifestParentDirectoryURL = [self.sourceURL URLByDeletingLastPathComponent];
                }
				
                
				manifest.originalManifest = manifestInfoDict;
                
                
                /*
                 * Get file properties
                 */
                NSDate *dateCreated;
                [manifest.manifestURL getResourceValue:&dateCreated forKey:NSURLCreationDateKey error:nil];
                manifest.manifestDateCreated = dateCreated;
            
                NSDate *dateLastOpened;
                [manifest.manifestURL getResourceValue:&dateLastOpened forKey:NSURLContentAccessDateKey error:nil];
                manifest.manifestDateLastOpened = dateLastOpened;
                
                NSDate *dateModified;
                [manifest.manifestURL getResourceValue:&dateModified forKey:NSURLContentModificationDateKey error:nil];
                manifest.manifestDateModified = dateModified;
				
                
                // =================================
				// Get "catalogs" items
                // =================================
				/*
                 Left here as a reminder: Catalogs are processed with RelationshipScanner
                 */
                
                
                // =================================
				// Get "managed_installs" items
				// =================================
                NSDate *startTime = [NSDate date];
                NSArray *managedInstalls = [manifestInfoDict objectForKey:@"managed_installs"];
                if ([managedInstalls count] > 0) {
                    DDLogVerbose(@"%@: Found %lu managed_installs items", self.fileName, (unsigned long)[managedInstalls count]);
                }
                [managedInstalls enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    @autoreleasepool {
                        DDLogVerbose(@"%@: managed_installs item %lu --> Name: %@", manifest.title, (unsigned long)idx, obj);
                        StringObjectMO *newManagedInstall = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:privateContext];
                        newManagedInstall.title = (NSString *)obj;
                        newManagedInstall.typeString = @"managedInstall";
                        newManagedInstall.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
                        [manifest addManagedInstallsFasterObject:newManagedInstall];
                        
                    }
                }];
                NSDate *now = [NSDate date];
                DDLogVerbose(@"Scanning managed_installs took %lf (ms)", [now timeIntervalSinceDate:startTime] * 1000.0);
                
                
                // =================================
				// Get "managed_uninstalls" items
				// =================================
                startTime = [NSDate date];
                NSArray *managedUninstalls = [manifestInfoDict objectForKey:@"managed_uninstalls"];
                if ([managedUninstalls count] > 0) {
                    DDLogVerbose(@"%@: Found %lu managed_uninstalls items", self.fileName, (unsigned long)[managedUninstalls count]);
                }
                [managedUninstalls enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    @autoreleasepool {
                        DDLogVerbose(@"%@ managed_uninstalls item %lu --> Name: %@", manifest.title, (unsigned long)idx, obj);
                        StringObjectMO *newManagedUninstall = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:privateContext];
                        newManagedUninstall.title = (NSString *)obj;
                        newManagedUninstall.typeString = @"managedUninstall";
                        newManagedUninstall.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
                        [manifest addManagedUninstallsFasterObject:newManagedUninstall];
                        
                    }
                }];
                now = [NSDate date];
                DDLogVerbose(@"Scanning managed_uninstalls took %lf (ms)", [now timeIntervalSinceDate:startTime] * 1000.0);
                
                
                // =================================
				// Get "managed_updates" items
				// =================================
                startTime = [NSDate date];
                NSArray *managedUpdates = [manifestInfoDict objectForKey:@"managed_updates"];
                if ([managedUpdates count] > 0) {
                    DDLogVerbose(@"%@: Found %lu managed_updates items", self.fileName, (unsigned long)[managedUpdates count]);
                }
                [managedUpdates enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    @autoreleasepool {
                        DDLogVerbose(@"%@ managed_updates item %lu --> Name: %@", manifest.title, (unsigned long)idx, obj);
                        StringObjectMO *newManagedUpdate = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:privateContext];
                        newManagedUpdate.title = (NSString *)obj;
                        newManagedUpdate.typeString = @"managedUpdate";
                        newManagedUpdate.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
                        [manifest addManagedUpdatesFasterObject:newManagedUpdate];
                        
                    }
                }];
				now = [NSDate date];
                DDLogVerbose(@"Scanning managed_updates took %lf (ms)", [now timeIntervalSinceDate:startTime] * 1000.0);
                
                
                // =================================
				// Get "optional_installs" items
				// =================================
                startTime = [NSDate date];
                NSArray *optionalInstalls = [manifestInfoDict objectForKey:@"optional_installs"];
                if ([optionalInstalls count] > 0) {
                    DDLogVerbose(@"%@: Found %lu optional_installs items", self.fileName, (unsigned long)[optionalInstalls count]);
                }
				[optionalInstalls enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    @autoreleasepool {
                        DDLogVerbose(@"%@ optional_installs item %lu --> Name: %@", manifest.title, (unsigned long)idx, obj);
                        StringObjectMO *newOptionalInstall = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:privateContext];
                        newOptionalInstall.title = (NSString *)obj;
                        newOptionalInstall.typeString = @"optionalInstall";
                        newOptionalInstall.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
                        [manifest addOptionalInstallsFasterObject:newOptionalInstall];
                        
                    }
                }];
                now = [NSDate date];
                DDLogVerbose(@"Scanning optional_installs took %lf (ms)", [now timeIntervalSinceDate:startTime] * 1000.0);
                
                
                // =================================
				// Get "included_manifests" items
				// =================================
                startTime = [NSDate date];
				NSArray *includedManifests = [manifestInfoDict objectForKey:@"included_manifests"];
                if ([includedManifests count] > 0) {
                    DDLogVerbose(@"%@: Found %lu included_manifests items", self.fileName, (unsigned long)[includedManifests count]);
                }
                [includedManifests enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    DDLogVerbose(@"%@ included_manifests item %lu --> Name: %@", manifest.title, (unsigned long)idx, obj);
                    StringObjectMO *newIncludedManifest = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:privateContext];
                    newIncludedManifest.title = (NSString *)obj;
                    newIncludedManifest.typeString = @"includedManifest";
                    newIncludedManifest.originalIndex = [NSNumber numberWithUnsignedInteger:idx];
                    newIncludedManifest.indexInNestedManifest = [NSNumber numberWithUnsignedInteger:idx];
                    [manifest addIncludedManifestsFasterObject:newIncludedManifest];
                    
                    /*
                    if ([self.allManifestsByTitle objectForKey:(NSString *)obj]) {
                        newIncludedManifest.originalManifest = [self.allManifestsByTitle objectForKey:(NSString *)obj];
                    } else {
                        DDLogError(@"%@ could not link item %lu --> Name: %@", manifest.title, (unsigned long)idx, (NSString *)obj);
                    }
                     */
                }];
                now = [NSDate date];
                DDLogVerbose(@"Scanning included_manifests took %lf (ms)", [now timeIntervalSinceDate:startTime] * 1000.0);
                
                
                // =================================
				// Get "conditional_items"
				// =================================
                startTime = [NSDate date];
				NSArray *conditionalItems = [manifestInfoDict objectForKey:@"conditional_items"];
                [self conditionalItemsFrom:conditionalItems parent:nil manifest:manifest context:privateContext];
                now = [NSDate date];
                DDLogVerbose(@"Scanning conditional_items took %lf (ms)", [now timeIntervalSinceDate:startTime] * 1000.0);
				
			} else {
				DDLogError(@"Can't read manifest file %@", [self.sourceURL relativePath]);
			}
			
			// Save the context
            NSError *error = nil;
            if ([privateContext save:&error]) {
                /*
                 We could save the parent context here but it would just slow us down
                 if done after every file read. Parent context is saved after both pkginfos
                 and manifests are fully read.
                 */
                /*
                [privateContext.parentContext performBlock:^{
                    NSError *parentError = nil;
                    [privateContext.parentContext save:&parentError];
                }];
                 */
            } else {
                DDLogError(@"Private context failed to save: %@", error);
            }
		}
	}
	@catch(...) {
		// Do not rethrow exceptions.
	}
}

- (void)main
{
    [self.context performBlockAndWait:^{
        [self scan];
    }];
}


@end
