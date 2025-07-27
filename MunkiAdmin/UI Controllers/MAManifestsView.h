//
//  MAManifestsView.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 6.3.2015.
//
//

#import <Cocoa/Cocoa.h>

@class MAManifestEditor;
@class MAManifestImporter;
@class ManifestMO;
@class MARequestStringValueController;

@interface MAManifestsView : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource, NSTableViewDataSource, NSTableViewDelegate, NSSplitViewDelegate, NSMenuDelegate>

@property (weak) IBOutlet NSOutlineView *sourceList;
@property (weak) IBOutlet NSTreeController *manifestSourceListTreeController;
@property (weak) IBOutlet NSSplitView *mainSplitView;
@property (weak) IBOutlet NSSplitView *manifestsListSplitView;
@property (weak) IBOutlet NSView *manifestsListView;
@property (weak) IBOutlet NSMenu *manifestsListMenu;
@property (weak) IBOutlet NSMenu *catalogsSubMenu;
@property (weak) IBOutlet NSMenuItem *includedManifestsSubMenuItem;
@property (weak) IBOutlet NSMenu *includedManifestsSubMenu;
@property (weak) IBOutlet NSMenuItem *referencingManifestsSubMenuItem;
@property (weak) IBOutlet NSMenu *referencingManifestsSubMenu;
@property (weak) IBOutlet NSMenuItem *scriptsSubMenuItem;
@property (weak) IBOutlet NSMenu *scriptsSubMenu;
@property (weak) IBOutlet NSPredicateEditor *manifestsListPredicateEditor;
@property (weak) IBOutlet NSTableView *manifestsListTableView;
@property BOOL predicateEditorHidden;
@property (weak) IBOutlet NSView *detailViewPlaceHolder;
@property (weak) IBOutlet NSArrayController *manifestsArrayController;
@property (strong) NSPredicate *selectedSourceListFilterPredicate;
@property (readonly, strong) NSPredicate *mainCompoundPredicate;
@property (strong) NSPredicate *searchFieldPredicate;
@property (strong) NSPredicate *previousPredicateEditorPredicate;
@property (readonly) NSArray *defaultSortDescriptors;
@property (strong) MAManifestEditor *manifestEditor;
@property (strong) NSMutableDictionary *openedManifestEditors;
@property (strong) MARequestStringValueController *requestStringValue;
@property (strong) MAManifestImporter *manifestImporter;

- (void)updateSourceListData;
- (void)toggleManifestsFindView;
- (void)showFindViewWithPredicate:(NSPredicate *)predicate;
- (MAManifestEditor *)editorForManifest:(ManifestMO *)manifest;
- (void)openEditorForAllSelectedManifests;

- (void)importManifestsFromFile;
- (IBAction)importManifestsFromFileAction:(id)sender;

@end
