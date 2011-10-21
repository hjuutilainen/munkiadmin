//
//  SelectManifestItemsWindow.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 21.10.2011.
//

#import <Cocoa/Cocoa.h>
#import "GradientBackgroundView.h"

@interface SelectManifestItemsWindow : NSWindowController {
    GradientBackgroundView *existingSearchBgView;
    GradientBackgroundView *customValueBgView;
    NSTextField *customValueTextField;
    NSTabView *tabView;
    NSArrayController *manifestsArrayController;
}

@property (assign) IBOutlet GradientBackgroundView *existingSearchBgView;
@property (assign) IBOutlet GradientBackgroundView *customValueBgView;
@property (assign) IBOutlet NSTextField *customValueTextField;
@property (assign) IBOutlet NSTabView *tabView;
@property (assign) IBOutlet NSArrayController *manifestsArrayController;

@end
