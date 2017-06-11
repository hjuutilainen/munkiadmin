//
//  MAManifestEditor.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 20.3.2015.
//
//

#import <Cocoa/Cocoa.h>

@class ManifestMO;
@class MASelectPkginfoItemsWindow;
@class MASelectManifestItemsWindow;
@class MAPredicateEditor;
@class MAManifestsView;
@class MARequestStringValueController;

@interface MAManifestEditor : NSWindowController <NSSplitViewDelegate, NSTableViewDelegate, NSTableViewDataSource, NSMenuDelegate>

@property (weak) MAManifestsView *delegate;
@property (weak) IBOutlet NSSplitView *mainSplitView;
@property (weak) IBOutlet NSView *sourceListPlaceHolder;
@property (weak) IBOutlet NSView *contentViewPlaceHolder;
@property (weak) IBOutlet NSView *generalView;
@property (weak) IBOutlet NSView *contentItemsListView;
@property (weak) IBOutlet NSView *includedManifestsListView;
@property (weak) IBOutlet NSView *referencingManifestsListView;
@property (weak) IBOutlet NSView *conditionalsListView;
@property (weak) IBOutlet NSTableView *catalogInfosTableView;
@property (weak) IBOutlet NSTableView *sourceListTableView;
@property (weak) IBOutlet NSTableView *contentItemsTableView;
@property (weak) IBOutlet NSTableView *includedManifestsTableView;
@property (weak) IBOutlet NSTableView *referencingManifestsTableView;
@property (weak) IBOutlet NSArrayController *editorSectionsArrayController;
@property (weak) IBOutlet NSArrayController *catalogInfosArrayController;
@property (weak) IBOutlet NSArrayController *conditionalItemsArrayController;
@property (weak) IBOutlet NSArrayController *conditionalItemsAllArrayController;
@property (weak) IBOutlet NSArrayController *managedInstallsArrayController;
@property (weak) IBOutlet NSArrayController *managedUninstallsArrayController;
@property (weak) IBOutlet NSArrayController *managedUpdatesArrayController;
@property (weak) IBOutlet NSArrayController *optionalInstallsArrayController;
@property (weak) IBOutlet NSArrayController *featuredItemsArrayController;
@property (weak) IBOutlet NSArrayController *includedManifestsArrayController;
@property (weak) IBOutlet NSArrayController *referencingManifestsArrayController;
@property (weak) IBOutlet NSMenu *referencingManifestsConditionMenu;
@property (weak) IBOutlet NSTableCellView *conditionalsTableCellView;
@property (weak) IBOutlet NSPopUpButton *conditionalsPopupButton;
@property (weak) IBOutlet NSOutlineView *conditionsOutlineView;
@property (weak) IBOutlet NSTreeController *conditionsTreeController;
@property (strong) IBOutlet NSScrollView *sourceListView;
@property (strong) NSArray *sourceListItems;
@property (strong) ManifestMO *manifestToEdit;
@property (strong) MASelectPkginfoItemsWindow *addItemsWindowController;
@property (strong) MASelectManifestItemsWindow *selectManifestsWindowController;
@property (strong) MAPredicateEditor *predicateEditor;
@property (strong) MARequestStringValueController *requestStringValue;


@end
