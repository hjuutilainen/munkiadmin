//
//  SelectManifestItemsWindow.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 21.10.2011.
//

#import "SelectManifestItemsWindow.h"

@implementation SelectManifestItemsWindow
@synthesize existingSearchBgView;
@synthesize customValueBgView;
@synthesize customValueTextField;
@synthesize tabView;
@synthesize manifestsArrayController;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
	[self.manifestsArrayController setSortDescriptors:[NSArray arrayWithObjects:sortByTitle, nil]];
    
    self.existingSearchBgView.fillGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] 
                                                                       endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]] autorelease];
    
    self.customValueBgView.fillGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] 
                                                                    endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]] autorelease];
    self.customValueBgView.drawBottomLine = YES;
    self.customValueBgView.lineColor = [NSColor grayColor];
}

@end
