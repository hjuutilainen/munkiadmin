//
//  AddItemsWindow.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 19.10.2011.
//

#import "SelectPkginfoItemsWindow.h"

@implementation SelectPkginfoItemsWindow

@synthesize individualPkgsArrayController;
@synthesize groupedPkgsArrayController;
@synthesize tabView;
@synthesize currentMode;
@synthesize customValueTextField;
@synthesize indSearchBgView;
@synthesize groupSearchBgView;
@synthesize customBgView;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // 0 = nothing
        // 1 = groups
        // 2 = individual
        // 3 = ...
        self.currentMode = 0;
        
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.indSearchBgView.fillGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] 
                                                                       endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]] autorelease];
    
    self.groupSearchBgView.fillGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] 
                                                                         endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]] autorelease];
    
    self.customBgView.fillGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] 
                                                                    endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]] autorelease];
    self.customBgView.drawBottomLine = YES;
    self.customBgView.lineColor = [NSColor grayColor];
}

@end
