//
//  AddItemsWindow.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 19.10.2011.
//

#import <Cocoa/Cocoa.h>
#import "PackageArrayController.h"
#import "MAApplicationsArrayController.h"
#import "MAGradientBackgroundView.h"

@interface MASelectPkginfoItemsWindow : NSWindowController <NSTextFieldDelegate> {
    BOOL shouldHideAddedItems;
}

@property (weak) IBOutlet NSSearchField *groupedSearchField;
@property (weak) IBOutlet NSSearchField *individualSearchField;
@property (weak) IBOutlet NSTableView *individualTableView;
@property (weak) IBOutlet NSTableView *groupedTableView;
@property (strong) NSPredicate *hideAddedPredicate;
@property (strong) NSPredicate *hideGroupedAppleUpdatesPredicate;
@property (strong) NSPredicate *hideIndividualAppleUpdatesPredicate;
@property BOOL shouldHideAddedItems;
@property (weak) IBOutlet PackageArrayController *individualPkgsArrayController;
@property (weak) IBOutlet MAApplicationsArrayController *groupedPkgsArrayController;
@property (weak) IBOutlet NSTabView *tabView;
@property NSInteger currentMode;
@property (weak) IBOutlet NSTextField *customValueTextField;
@property (weak) IBOutlet MAGradientBackgroundView *indSearchBgView;
@property (weak) IBOutlet MAGradientBackgroundView *groupSearchBgView;
@property (weak) IBOutlet MAGradientBackgroundView *customBgView;

- (NSArray *)selectionAsStringObjects;
- (void)updateGroupedSearchPredicate;
- (void)updateIndividualSearchPredicate;

@end
