//
//  PackagesView.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 27.2.2012.
//

#import <Cocoa/Cocoa.h>
#import "MAGradientBackgroundView.h"

@class MARequestStringValueController;
@class MAIconEditor;
@class MAIconChooser;
@class MAIconBatchExtractor;

@interface MAPackagesView : NSViewController <NSMenuDelegate, NSTableViewDataSource, NSTableViewDelegate, NSOutlineViewDelegate> {
    
}

@property (weak) IBOutlet NSSplitView *tripleSplitView;
@property (weak) IBOutlet NSView *leftPlaceHolder;
@property (weak) IBOutlet NSView *middlePlaceHolder;
@property (weak) IBOutlet MAGradientBackgroundView *rightPlaceHolder;
@property (weak) IBOutlet NSTableView *packagesTableView;
@property (weak) IBOutlet NSTableColumn *nameColumn;
@property (weak) IBOutlet NSTableColumn *displayNameColumn;
@property (weak) IBOutlet NSTableColumn *versionColumn;
@property (weak) IBOutlet NSTableColumn *catalogsColumn;
@property (weak) IBOutlet NSTableColumn *descriptionColumn;
@property (weak) IBOutlet NSTableColumn *adminNotesColumn;
@property (weak) IBOutlet NSTableColumn *minOSColumn;
@property (weak) IBOutlet NSTableColumn *maxOSColumn;
@property (weak) IBOutlet NSTableColumn *sizeColumn;
@property (weak) IBOutlet NSTableColumn *modifiedDateColumn;
@property (weak) IBOutlet NSTableColumn *createdDateColumn;
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
@property (weak) IBOutlet NSMenu *catalogsSubMenu;
@property (weak) IBOutlet NSPathControl *packageInfoPathControl;
@property (weak) IBOutlet NSPathControl *installerItemPathControl;
@property (weak) IBOutlet NSSearchField *packagesSearchField;

@property (strong) NSPredicate *packagesMainFilterPredicate;
@property (readonly, strong) NSPredicate *mainCompoundPredicate;
@property (strong) NSPredicate *searchFieldPredicate;
@property (strong) NSArray *defaultSortDescriptors;
@property (strong) MARequestStringValueController *createNewCategoryController;
@property (strong) MARequestStringValueController *createNewDeveloperController;
@property (strong) MAIconEditor *iconEditor;
@property (strong) MAIconChooser *iconChooser;
@property (strong) MAIconBatchExtractor *iconBatchExtractor;

- (void)batchExtractIcons;

@end
