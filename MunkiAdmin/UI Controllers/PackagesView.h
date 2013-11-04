//
//  PackagesView.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 27.2.2012.
//

#import <Cocoa/Cocoa.h>
#import "GradientBackgroundView.h"

@interface PackagesView : NSViewController <NSMenuDelegate, NSTableViewDataSource, NSTableViewDelegate> {
    NSSplitView *__weak tripleSplitView;
    NSView *__weak leftPlaceHolder;
    NSView *__weak middlePlaceHolder;
    GradientBackgroundView *__weak rightPlaceHolder;
    NSTableView *__weak packagesTableView;
    NSArrayController *__weak packagesArrayController;
    NSTreeController *__weak directoriesTreeController;
    NSOutlineView *__weak directoriesOutlineView;
    NSTextView *__unsafe_unretained descriptionTextView;
    NSTextView *__unsafe_unretained notesTextView;
    NSSplitView *__weak notesDescriptionSplitView;
    NSMenu *__weak packagesTableViewMenu;
    NSPathControl *__weak packageInfoPathControl;
    NSPathControl *__weak installerItemPathControl;
}

@property (weak) IBOutlet NSSplitView *tripleSplitView;
@property (weak) IBOutlet NSView *leftPlaceHolder;
@property (weak) IBOutlet NSView *middlePlaceHolder;
@property (weak) IBOutlet GradientBackgroundView *rightPlaceHolder;
@property (weak) IBOutlet NSTableView *packagesTableView;
@property (weak) IBOutlet NSArrayController *packagesArrayController;
@property (weak) IBOutlet NSTreeController *directoriesTreeController;
@property (weak) IBOutlet NSOutlineView *directoriesOutlineView;
@property (unsafe_unretained) IBOutlet NSTextView *descriptionTextView;
@property (unsafe_unretained) IBOutlet NSTextView *notesTextView;
@property (weak) IBOutlet NSSplitView *notesDescriptionSplitView;
@property (weak) IBOutlet NSMenu *packagesTableViewMenu;
@property (weak) IBOutlet NSPathControl *packageInfoPathControl;
@property (weak) IBOutlet NSPathControl *installerItemPathControl;

@end
