//
//  InstallsItemEditor.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 30.4.2013.
//
//

#import <Cocoa/Cocoa.h>

@class InstallsItemMO;

@interface InstallsItemEditor : NSWindowController <NSTableViewDelegate> {
    InstallsItemMO *itemToEdit;
    NSUndoManager *undoManager;
    NSArray *versionComparisonKeys;
    NSTableView *customItemsTableView;
    NSArrayController *customItemsArrayController;
}

+ (void)editSheetForWindow:(id)window delegate:(id)delegate endSelector:(SEL)selector entity:(InstallsItemMO *)object;

@property (assign) InstallsItemMO *itemToEdit;
@property (readonly, retain) NSArray *versionComparisonKeys;
@property (assign) IBOutlet NSTableView *customItemsTableView;
@property (assign) IBOutlet NSArrayController *customItemsArrayController;

@end
