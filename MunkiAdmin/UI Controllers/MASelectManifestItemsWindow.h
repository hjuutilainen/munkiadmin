//
//  SelectManifestItemsWindow.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 21.10.2011.
//

#import <Cocoa/Cocoa.h>
#import "MAGradientBackgroundView.h"

@interface MASelectManifestItemsWindow : NSWindowController <NSTextFieldDelegate> {
    NSPredicate *originalPredicate;
}

@property (strong) NSPredicate *originalPredicate;
@property (weak) IBOutlet MAGradientBackgroundView *existingSearchBgView;
@property (weak) IBOutlet MAGradientBackgroundView *customValueBgView;
@property (weak) IBOutlet NSTextField *customValueTextField;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSArrayController *manifestsArrayController;
@property (weak) IBOutlet NSSearchField *existingSearchField;
@property (weak) IBOutlet NSTableView *manifestsTableView;

- (void)updateSearchPredicate;
- (NSArray *)selectionAsStringObjects;

@end
