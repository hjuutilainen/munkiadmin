//
//  MAManifestImporter.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 4.5.2017.
//
//

#import <Cocoa/Cocoa.h>

@class ManifestMO;

@interface MAManifestImporter : NSWindowController

@property (weak) IBOutlet NSArrayController *manifestsArrayController;
@property (weak) IBOutlet NSArrayController *manifestsToCreateArrayController;
@property (weak) IBOutlet NSTableView *previewTableView;
@property (weak) IBOutlet NSTableColumn *fileNameColumn;
@property (weak) IBOutlet NSTableColumn *displayNameColumn;
@property (weak) IBOutlet NSTableColumn *userNameColumn;
@property (weak) IBOutlet NSTableColumn *notesColumn;
@property (weak) IBOutlet NSTableColumn *actionColumn;
@property (weak) IBOutlet NSProgressIndicator *progressSpinner;

@property (strong) ManifestMO *templateManifest;
@property (strong) NSURL *fileURLToImport;
@property (strong) NSArray *importedObjects;
@property (strong) NSArray *keyNames;
@property (strong) NSArray *manifestsToCreate;
@property BOOL shouldCreateNewManifests;
@property BOOL shouldUpdateExistingManifests;
@property (strong) NSString *fileNameMappingSelectedKeyName;

@property BOOL displayNameMappingEnabled;
@property (strong) NSString *displayNameMappingSelectedKeyName;
@property BOOL userNameMappingEnabled;
@property (strong) NSString *userNameMappingSelectedKeyName;
@property BOOL notesMappingEnabled;
@property (strong) NSString *notesMappingSelectedKeyName;

- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)changeOptions:(id)sender;
- (BOOL)updateImporterStatusWithCSVFile:(NSURL *)fileURL;

@end
