//
//  MAManifestEditor.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 20.3.2015.
//
//

#import <Cocoa/Cocoa.h>

@interface MAManifestEditor : NSWindowController <NSSplitViewDelegate>

@property (weak) IBOutlet NSSplitView *mainSplitView;
@property (weak) IBOutlet NSView *sourceListPlaceHolder;
@property (weak) IBOutlet NSView *contentViewPlaceHolder;
@property (strong) IBOutlet NSScrollView *sourceListView;
@property (strong) NSArray *sourceListItems;

@end
