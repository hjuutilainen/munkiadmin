//
//  SelectManifestItemsWindow.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 21.10.2011.
//

#import <Cocoa/Cocoa.h>

@interface MASelectManifestItemsWindow : NSWindowController <NSTextFieldDelegate> {
    NSPredicate *originalPredicate;
}

@property (strong) NSPredicate *originalPredicate;
@property (weak) IBOutlet NSView *existingSearchBgView;
@property (weak) IBOutlet NSView *customValueBgView;
@property (weak) IBOutlet NSTextField *customValueTextField;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSArrayController *manifestsArrayController;
@property (weak) IBOutlet NSSearchField *existingSearchField;
@property (weak) IBOutlet NSTableView *manifestsTableView;

- (void)updateSearchPredicate;
- (NSArray *)selectionAsStringObjects;

@end
