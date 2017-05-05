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
    
    
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"titleOrDisplayName" ascending:YES selector:@selector(localizedStandardCompare:)];
    self.manifestsArrayController.sortDescriptors = @[sortByTitle];
    
    NSSortDescriptor *sortByFileName = [NSSortDescriptor sortDescriptorWithKey:@"fileName" ascending:YES selector:@selector(localizedStandardCompare:)];
    self.manifestsToCreateArrayController.sortDescriptors = @[sortByFileName];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
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
        
        [newManifestsToCreate addObject:newManifestDict];
    }
    NSLog(@"%@", newManifestsToCreate);
    self.manifestsToCreate = newManifestsToCreate;
}

- (IBAction)changeOptions:(id)sender
{
    [self updateMappings];
}

- (IBAction)okAction:(id)sender
{
    if ([[sender title] isEqualToString:@"Create Manifests"]) {
        MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
        for (NSDictionary *manifestDict in self.manifestsToCreate) {
            NSURL *saveURL = [appDelegate.manifestsURL URLByAppendingPathComponent:manifestDict[@"fileName"]];
            [[MAMunkiRepositoryManager sharedManager] duplicateManifest:self.templateManifest toURL:saveURL];
        }
        
        [[self window] orderOut:self];
        [NSApp stopModalWithCode:NSModalResponseOK];
        
    }
}

- (IBAction)cancelAction:(id)sender
{
    [[self window] orderOut:self];
    [NSApp stopModalWithCode:NSModalResponseCancel];
}


- (void)resetImporterStatus
{
    
    
    self.displayNameMappingEnabled = YES;
    self.userNameMappingEnabled = YES;
    
    self.fileURLToImport = [self chooseFile];
    
    self.importedObjects = [NSArray arrayWithContentsOfCSVURL:self.fileURLToImport options:(CHCSVParserOptionsUsesFirstLineAsKeys | CHCSVParserOptionsSanitizesFields | CHCSVParserOptionsRecognizesBackslashesAsEscapes)];
    
    NSLog(@"Found %lu items to import", (unsigned long)self.importedObjects.count);
    if (self.importedObjects.count > 0) {
        NSArray *keyNames = [self.importedObjects[0] allKeys];
        
        self.keyNames = [keyNames sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
        //NSLog(@"%@",self.keyNames);
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"Name"];
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
}

@end
