//
//  AddItemsWindow.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 19.10.2011.
//

#import <Cocoa/Cocoa.h>
#import "PackageArrayController.h"
#import "ApplicationsArrayController.h"
#import "GradientBackgroundView.h"

@interface AddItemsWindow : NSWindowController {
    PackageArrayController *individualPkgsArrayController;
    ApplicationsArrayController *groupedPkgsArrayController;
    NSTabView *tabView;
    NSInteger currentMode;
    NSTextField *customValueTextField;
    GradientBackgroundView *indSearchBgView;
    GradientBackgroundView *groupSearchBgView;
    GradientBackgroundView *customBgView;
}

@property (assign) IBOutlet PackageArrayController *individualPkgsArrayController;
@property (assign) IBOutlet ApplicationsArrayController *groupedPkgsArrayController;
@property (assign) IBOutlet NSTabView *tabView;
@property NSInteger currentMode;
@property (assign) IBOutlet NSTextField *customValueTextField;
@property (assign) IBOutlet GradientBackgroundView *indSearchBgView;
@property (assign) IBOutlet GradientBackgroundView *groupSearchBgView;
@property (assign) IBOutlet GradientBackgroundView *customBgView;

@end
