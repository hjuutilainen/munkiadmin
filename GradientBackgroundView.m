//
//  GradientBackgroundView.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 21.1.2010.
//

#import "GradientBackgroundView.h"


@implementation GradientBackgroundView

@synthesize drawBottomLine;
@synthesize fillGradient;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		self.drawBottomLine = YES;
		self.fillGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.714 green:0.753 blue:0.812 alpha:1.0] 
													  endingColor:[NSColor colorWithCalibratedRed:0.796 green:0.824 blue:0.867 alpha:1.0]] autorelease];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	
	NSRect wholeRect = [self bounds];
	
	[fillGradient drawInRect:wholeRect angle:90.0];
	
	if (self.drawBottomLine) {
	NSBezierPath *bottomLine = [NSBezierPath bezierPath];
	[bottomLine moveToPoint:NSMakePoint(0, 0)];
	[bottomLine lineToPoint:NSMakePoint(wholeRect.size.width, 0)];
	[[NSColor darkGrayColor] set];
	[bottomLine setLineWidth:1];
	[bottomLine stroke];
	}
}


@end
