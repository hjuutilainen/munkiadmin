//
//  MAManifestsView.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 6.3.2015.
//
//

#import <Cocoa/Cocoa.h>
#import "PXSourceList.h"

@class MAManifestEditor;
@class ManifestMO;
@class MARequestStringValueController;

@interface MAManifestsView : NSViewController <PXSourceListDelegate, PXSourceListDataSource, NSTableViewDataSource, NSTableViewDelegate, NSSplitViewDelegate, NSMenuDelegate>

@property (weak) IBOutlet PXSourceList *sourceList;
@property (weak) IBOutlet NSSplitView *mainSplitView;
@property (weak) IBOutlet NSSplitView *manifestsListSplitView;
@property (weak) IBOutlet NSView *manifestsListView;
@property (weak) IBOutlet NSMenu *manifestsListMenu;
@property (weak) IBOutlet NSMenu *catalogsSubMenu;
@property (weak) IBOutlet NSMenuItem *includedManifestsSubMenuItem;
@property (weak) IBOutlet NSMenu *includedManifestsSubMenu;
@property (weak) IBOutlet NSMenuItem *referencingManifestsSubMenuItem;
@property (weak) IBOutlet NSMenu *referencingManifestsSubMenu;
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

- (NSUInteger)sourceList:(PXSourceList*)sourceList numberOfChildrenOfItem:(id)item;
- (id)sourceList:(PXSourceList*)aSourceList child:(NSUInteger)index ofItem:(id)item;
- (BOOL)sourceList:(PXSourceList*)aSourceList isItemExpandable:(id)item;
- (NSView *)sourceList:(PXSourceList *)aSourceList viewForItem:(id)item;
- (void)updateSourceListData;
- (void)toggleManifestsFindView;
- (void)showFindViewWithPredicate:(NSPredicate *)predicate;
- (MAManifestEditor *)editorForManifest:(ManifestMO *)manifest;
- (void)openEditorForAllSelectedManifests;

@end
