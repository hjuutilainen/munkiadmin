//
//  MALinkedView.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 16.10.2012.
//
//

#import "MALinkedView.h"

@implementation MALinkedView

@synthesize previousView, nextView;

- (void)awakeFromNib
{
    [self setWantsLayer:YES];
    [previousButton setEnabled:(previousView != nil)];
    [nextButton setEnabled:(nextView != nil)];
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
