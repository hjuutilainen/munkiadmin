//
//  SelectManifestItemsWindow.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 21.10.2011.
//

#import <Cocoa/Cocoa.h>
#import "GradientBackgroundView.h"

@interface SelectManifestItemsWindow : NSWindowController <NSTextFieldDelegate> {
    GradientBackgroundView *existingSearchBgView;
    GradientBackgroundView *customValueBgView;
    NSTextField *customValueTextField;
    NSTabView *tabView;
    NSArrayController *manifestsArrayController;
    NSSearchField *existingSearchField;
    NSPredicate *originalPredicate;
}

@property (copy) NSPredicate *originalPredicate;
@property (assign) IBOutlet GradientBackgroundView *existingSearchBgView;
@property (assign) IBOutlet GradientBackgroundView *customValueBgView;
@property (assign) IBOutlet NSTextField *customValueTextField;
@property (assign) IBOutlet NSTabView *tabView;
@property (assign) IBOutlet NSArrayController *manifestsArrayController;
@property (assign) IBOutlet NSSearchField *existingSearchField;

- (void)updateSearchPredicate;

@end
