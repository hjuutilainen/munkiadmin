//
//  MAManifestsView.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 6.3.2015.
//
//

#import <Cocoa/Cocoa.h>
#import "PXSourceList.h"

@interface MAManifestsView : NSViewController <PXSourceListDelegate, PXSourceListDataSource, NSSplitViewDelegate>

@property (assign) IBOutlet PXSourceList *sourceList;
@property (assign) IBOutlet NSSplitView *mainSplitView;
@property (assign) IBOutlet NSSplitView *manifestsListSplitView;
@property (assign) IBOutlet NSView *manifestsListView;
@property (assign) IBOutlet NSPredicateEditor *manifestsListPredicateEditor;
@property (assign) IBOutlet NSTableView *manifestsListTableView;
@property BOOL predicateEditorHidden;
@property (assign) IBOutlet NSView *detailViewPlaceHolder;
@property (assign) IBOutlet NSArrayController *manifestsArrayController;
@property (strong) NSPredicate *selectedSourceListFilterPredicate;
@property (readonly, strong) NSPredicate *mainCompoundPredicate;
@property (strong) NSPredicate *searchFieldPredicate;
@property (strong) NSPredicate *previousPredicateEditorPredicate;
@property (strong) NSArray *defaultSortDescriptors;

- (NSUInteger)sourceList:(PXSourceList*)sourceList numberOfChildrenOfItem:(id)item;
- (id)sourceList:(PXSourceList*)aSourceList child:(NSUInteger)index ofItem:(id)item;
- (BOOL)sourceList:(PXSourceList*)aSourceList isItemExpandable:(id)item;
- (NSView *)sourceList:(PXSourceList *)aSourceList viewForItem:(id)item;
- (void)updateSourceListData;
- (void)toggleManifestsFindView;

@end
