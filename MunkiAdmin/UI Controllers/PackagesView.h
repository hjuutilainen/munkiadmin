//
//  PackagesView.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 27.2.2012.
//

#import <Cocoa/Cocoa.h>
#import "GradientBackgroundView.h"

@class MARequestStringValueController;
@class MAIconEditor;

@interface PackagesView : NSViewController <NSMenuDelegate, NSTableViewDataSource, NSTableViewDelegate, NSOutlineViewDelegate> {
    
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
@property (weak) IBOutlet NSMenu *categoriesSubMenu;
@property (weak) IBOutlet NSMenu *developersSubMenu;
@property (weak) IBOutlet NSMenu *iconSubMenu;
@property (weak) IBOutlet NSPathControl *packageInfoPathControl;
@property (weak) IBOutlet NSPathControl *installerItemPathControl;

@property (strong) NSPredicate *packagesMainFilterPredicate;
@property (readonly, strong) NSPredicate *mainCompoundPredicate;
@property (strong) NSPredicate *searchFieldPredicate;
@property (strong) NSArray *defaultSortDescriptors;
@property (strong) MARequestStringValueController *createNewCategoryController;
@property (strong) MARequestStringValueController *createNewDeveloperController;
@property (strong) MAIconEditor *iconEditor;

@end
