//
//  SelectManifestItemsWindow.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 21.10.2011.
//

#import <Cocoa/Cocoa.h>
#import "GradientBackgroundView.h"

@interface SelectManifestItemsWindow : NSWindowController <NSTextFieldDelegate> {
    GradientBackgroundView *__weak existingSearchBgView;
    GradientBackgroundView *__weak customValueBgView;
    NSTextField *__weak customValueTextField;
    NSTabView *__weak tabView;
    NSArrayController *__weak manifestsArrayController;
    NSSearchField *__weak existingSearchField;
    NSPredicate *originalPredicate;
}

@property (copy) NSPredicate *originalPredicate;
@property (weak) IBOutlet GradientBackgroundView *existingSearchBgView;
@property (weak) IBOutlet GradientBackgroundView *customValueBgView;
@property (weak) IBOutlet NSTextField *customValueTextField;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSArrayController *manifestsArrayController;
@property (weak) IBOutlet NSSearchField *existingSearchField;

- (void)updateSearchPredicate;

@end
