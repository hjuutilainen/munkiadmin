//
//  MAManifestImporter.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 4.5.2017.
//
//

#import "MAManifestImporter.h"
#import "CHCSVParser.h"
#import "CocoaLumberjack.h"
#import "MAMunkiRepositoryManager.h"
#import "MAMunkiAdmin_AppDelegate.h"
#import "MACoreDataManager.h"

DDLogLevel ddLogLevel;

@interface MAManifestImporter ()

@end

@implementation MAManifestImporter

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.shouldCreateNewManifests = YES;
    
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"titleOrDisplayName"
                                                                  ascending:YES
                                                                   selector:@selector(localizedStandardCompare:)];
    self.manifestsArrayController.sortDescriptors = @[sortByTitle];
    
    NSSortDescriptor *sortByFileName = [NSSortDescriptor sortDescriptorWithKey:@"fileName"
                                                                     ascending:YES
                                                                      selector:@selector(localizedStandardCompare:)];
    self.manifestsToCreateArrayController.sortDescriptors = @[sortByFileName];
    [self.window setBackgroundColor:[NSColor whiteColor]];
}

- (void)awakeFromNib
{
    [self.progressSpinner setUsesThreadedAnimation:YES];
}

- (NSURL *)chooseFile
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    openPanel.title = @"Select a CSV file to import";
    openPanel.allowsMultipleSelection = NO;
    openPanel.canChooseDirectories = NO;
    openPanel.canChooseFiles = YES;
    openPanel.resolvesAliases = YES;
    
    if ([openPanel runModal] == NSFileHandlingPanelOKButton)
    {
        return [openPanel URLs][0];
    } else {
        return nil;
    }
}

- (void)updateMappings
{
    MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    NSMutableArray *newManifestsToCreate = [NSMutableArray new];
    for (CHCSVOrderedDictionary *object in self.importedObjects) {
        NSMutableDictionary *newManifestDict = [NSMutableDictionary new];
        
        newManifestDict[@"fileName"] = [object valueForKey:self.fileNameMappingSelectedKeyName];
        
        if (self.displayNameMappingEnabled) {
            newManifestDict[@"displayName"] = [object valueForKey:self.displayNameMappingSelectedKeyName];
        }
        if (self.userNameMappingEnabled) {
            newManifestDict[@"userName"] = [object valueForKey:self.userNameMappingSelectedKeyName];
        }
        if (self.notesMappingEnabled) {
            newManifestDict[@"notes"] = [object valueForKey:self.notesMappingSelectedKeyName];
        }
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:moc]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"title == %@", [object valueForKey:self.fileNameMappingSelectedKeyName]]];
        if ([moc countForFetchRequest:fetchRequest error:nil] > 0) {
            if (self.shouldUpdateExistingManifests) {
                ManifestMO *manifest = [moc executeFetchRequest:fetchRequest error:nil][0];
                newManifestDict[@"fileExists"] = @YES;
                newManifestDict[@"statusString"] = @"No changes";
                
                if (self.displayNameMappingEnabled) {
                    if (![manifest.manifestDisplayName isEqualToString:[object valueForKey:self.displayNameMappingSelectedKeyName]]) {
                        newManifestDict[@"statusString"] = @"Will be updated";
                    }
                }
                if (self.userNameMappingEnabled) {
                    if (![manifest.manifestUserName isEqualToString:[object valueForKey:self.userNameMappingSelectedKeyName]]) {
                        newManifestDict[@"statusString"] = @"Will be updated";
                    }
                }
                if (self.notesMappingEnabled) {
                    if (![manifest.manifestAdminNotes isEqualToString:[object valueForKey:self.notesMappingSelectedKeyName]]) {
                        newManifestDict[@"statusString"] = @"Will be updated";
                    }
                }
            } else {
                newManifestDict[@"fileExists"] = @YES;
                newManifestDict[@"statusString"] = @"Not updating, file exists";
            }
            
        } else {
            newManifestDict[@"fileExists"] = @NO;
            if (self.shouldCreateNewManifests) {
                newManifestDict[@"statusString"] = @"Will be created";
            } else {
                newManifestDict[@"statusString"] = @"Will not be created";
            }
        }
        
        [newManifestsToCreate addObject:newManifestDict];
    }
    DDLogVerbose(@"%@", newManifestsToCreate);
    self.manifestsToCreate = newManifestsToCreate;
}

- (IBAction)changeOptions:(id)sender
{
    [self updateMappings];
}

- (IBAction)okAction:(id)sender
{
    if ([[sender title] isEqualToString:@"Create Manifests"]) {
        self.progressSpinner.hidden = NO;
        [self.progressSpinner startAnimation:self];
        
        MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
        NSManagedObjectContext *moc = [appDelegate managedObjectContext];
        NSInteger numNewManifestsCreated = 0;
        NSInteger numManifestsModified = 0;
        for (NSDictionary *manifestDict in self.manifestsToCreate) {
            
            NSURL *saveURL = [appDelegate.manifestsURL URLByAppendingPathComponent:manifestDict[@"fileName"]];
            
            NSNumber *fileExists = manifestDict[@"fileExists"];
            if (![fileExists boolValue]) {
                if (self.shouldCreateNewManifests) {
                    
                    /*
                     Create a new manifest file
                     */
                    if (self.templateManifest) {
                        DDLogDebug(@"Writing new file for manifest %@ based on %@", saveURL.lastPathComponent, self.templateManifest.title);
                        [[MAMunkiRepositoryManager sharedManager] duplicateManifest:self.templateManifest toURL:saveURL];
                    } else {
                        DDLogDebug(@"Writing new file for manifest %@", saveURL.lastPathComponent);
                        [[MACoreDataManager sharedManager] createManifestWithURL:saveURL inManagedObjectContext:appDelegate.managedObjectContext];
                    }
                    
                    /*
                     Fetch the manifest we just created
                     */
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:moc]];
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"manifestURL == %@", saveURL]];
                    if ([moc countForFetchRequest:fetchRequest error:nil] > 0) {
                        ManifestMO *manifest = [moc executeFetchRequest:fetchRequest error:nil][0];
                        if (manifestDict[@"displayName"]) {
                            manifest.manifestDisplayName = manifestDict[@"displayName"];
                        }
                        if (manifestDict[@"userName"]) {
                            manifest.manifestUserName = manifestDict[@"userName"];
                        }
                        if (manifestDict[@"notes"]) {
                            manifest.manifestAdminNotes = manifestDict[@"notes"];
                        }
                    }
                    numNewManifestsCreated++;
                } else {
                    DDLogDebug(@"Skipped creating new manifest file %@", saveURL.lastPathComponent);
                }
            } else if (self.shouldUpdateExistingManifests) {
                DDLogDebug(@"Updating existing manifest %@", saveURL.lastPathComponent);
                /*
                 Fetch the existing manifest and update values
                 */
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                [fetchRequest setEntity:[NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:moc]];
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"manifestURL == %@", saveURL]];
                BOOL didUpdate = NO;
                if ([moc countForFetchRequest:fetchRequest error:nil] > 0) {
                    
                    ManifestMO *manifest = [moc executeFetchRequest:fetchRequest error:nil][0];
                    if (manifestDict[@"displayName"] && ![manifest.manifestDisplayName isEqualToString:manifestDict[@"displayName"]]) {
                        manifest.manifestDisplayName = manifestDict[@"displayName"];
                        didUpdate = YES;
                    }
                    if (manifestDict[@"userName"] && ![manifest.manifestUserName isEqualToString:manifestDict[@"userName"]]) {
                        manifest.manifestUserName = manifestDict[@"userName"];
                        didUpdate = YES;
                    }
                    if (manifestDict[@"notes"] && ![manifest.manifestAdminNotes isEqualToString:manifestDict[@"notes"]]) {
                        manifest.manifestAdminNotes = manifestDict[@"notes"];
                        didUpdate = YES;
                    }
                }
                if (didUpdate) {
                    numManifestsModified++;
                }
            } else {
                DDLogDebug(@"Skipped modifications to existing manifest %@", saveURL.lastPathComponent);
            }
        }
        
        self.progressSpinner.hidden = YES;
        [self.progressSpinner stopAnimation:self];
        
        [[self window] orderOut:self];
        [NSApp stopModalWithCode:NSModalResponseOK];
        
        NSString *modifiedString, *createdString;
        if (numNewManifestsCreated == 0) {
            createdString = @"No new manifest files were created";
        } else if (numNewManifestsCreated == 1) {
            createdString = @"1 new manifest file was created";
        } else {
            createdString = [NSString stringWithFormat:@"%li new manifest files were created", (long)numNewManifestsCreated];
        }
        if (numManifestsModified == 0) {
            modifiedString = @"No manifests were modified";
        } else if (numManifestsModified == 1) {
            modifiedString = @"1 manifest was modified";
        } else {
            modifiedString = [NSString stringWithFormat:@"%li manifests were modified", (long)numManifestsModified];
        }
        
        NSString *alertText = [NSString stringWithFormat:@"%@. %@.", createdString, modifiedString];
        
        NSAlert *importResultsAlert = [NSAlert alertWithMessageText:@"Done creating manifests"
                                                      defaultButton:@"OK"
                                                    alternateButton:@""
                                                        otherButton:@""
                                          informativeTextWithFormat:@"%@", alertText];
        [importResultsAlert runModal];
    }
}

- (IBAction)cancelAction:(id)sender
{
    [[self window] orderOut:self];
    [NSApp stopModalWithCode:NSModalResponseCancel];
}


- (BOOL)updateImporterStatusWithCSVFile:(NSURL *)fileURL
{
    if (!fileURL) {
        self.fileURLToImport = [self chooseFile];
    } else {
        self.fileURLToImport = fileURL;
    }
    
    if (!self.fileURLToImport) {
        [[self window] orderOut:self];
        [NSApp stopModalWithCode:NSModalResponseCancel];
        return NO;
    }
    
    self.window.representedURL = self.fileURLToImport;
    self.window.title = [NSString stringWithFormat:@"%@", [self.fileURLToImport lastPathComponent]];
    self.progressSpinner.hidden = YES;
    [self.progressSpinner stopAnimation:self];
    
    self.importedObjects = [NSArray arrayWithContentsOfCSVURL:self.fileURLToImport options:(CHCSVParserOptionsUsesFirstLineAsKeys | CHCSVParserOptionsSanitizesFields | CHCSVParserOptionsRecognizesBackslashesAsEscapes)];
    
    NSLog(@"Found %lu items to import", (unsigned long)self.importedObjects.count);
    if (self.importedObjects.count > 0) {
        NSArray *keyNames = [self.importedObjects[0] allKeys];
        
        self.keyNames = [keyNames sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
        //NSLog(@"%@",self.keyNames);
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@", @"Name"];
    NSArray *results = [self.keyNames filteredArrayUsingPredicate:predicate];
    if (results.count > 0) {
        self.displayNameMappingSelectedKeyName = results[0];
    }
    predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"Username"];
    results = [self.keyNames filteredArrayUsingPredicate:predicate];
    if (results.count > 0) {
        self.userNameMappingSelectedKeyName = results[0];
    }
    predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@ OR SELF contains[cd] %@", @"Description", @"Notes"];
    results = [self.keyNames filteredArrayUsingPredicate:predicate];
    if (results.count > 0) {
        self.notesMappingSelectedKeyName = results[0];
    }
    predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"Manifest"];
    results = [self.keyNames filteredArrayUsingPredicate:predicate];
    if (results.count > 0) {
        self.fileNameMappingSelectedKeyName = results[0];
    } else {
        self.fileNameMappingSelectedKeyName = self.keyNames[0];
    }
    
    [self updateMappings];
    
    return YES;
}

@end
