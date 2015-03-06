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
@property (assign) IBOutlet NSView *manifestsListView;
@property (assign) IBOutlet NSView *detailViewPlaceHolder;
@property (assign) IBOutlet NSArrayController *manifestsArrayController;

- (NSUInteger)sourceList:(PXSourceList*)sourceList numberOfChildrenOfItem:(id)item;
- (id)sourceList:(PXSourceList*)aSourceList child:(NSUInteger)index ofItem:(id)item;
- (BOOL)sourceList:(PXSourceList*)aSourceList isItemExpandable:(id)item;
- (NSView *)sourceList:(PXSourceList *)aSourceList viewForItem:(id)item;

@end
