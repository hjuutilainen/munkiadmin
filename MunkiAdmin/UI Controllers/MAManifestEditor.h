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

@interface MAManifestEditor : NSWindowController <NSSplitViewDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSSplitView *mainSplitView;
@property (weak) IBOutlet NSView *sourceListPlaceHolder;
@property (weak) IBOutlet NSView *contentViewPlaceHolder;
@property (weak) IBOutlet NSView *generalView;
@property (weak) IBOutlet NSView *managedInstallsView;
@property (weak) IBOutlet NSTableView *sourceListTableView;
@property (weak) IBOutlet NSTableView *managedInstallsTableView;
@property (weak) IBOutlet NSArrayController *editorSectionsArrayController;
@property (weak) IBOutlet NSArrayController *catalogInfosArrayController;
@property (weak) IBOutlet NSArrayController *conditionalItemsArrayController;
@property (strong) IBOutlet NSScrollView *sourceListView;
@property (strong) NSArray *sourceListItems;
@property (assign) ManifestMO *manifestToEdit;
@property (strong) MASelectPkginfoItemsWindow *addItemsWindowController;
@property (strong) MASelectManifestItemsWindow *selectManifestsWindowController;

@end
