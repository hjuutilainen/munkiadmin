//
//  GradientBackgroundView.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 21.1.2010.
//

#import <Cocoa/Cocoa.h>


@interface GradientBackgroundView : NSView {

	NSGradient *fillGradient;
    NSColor *lineColor;
	BOOL drawBottomLine;
    BOOL drawTopLine;
    BOOL drawLeftLine;
    BOOL drawRightLine;
}

@property BOOL drawBottomLine;
@property BOOL drawTopLine;
@property BOOL drawLeftLine;
@property BOOL drawRightLine;
@property (retain) NSGradient *fillGradient;
@property (retain) NSColor *lineColor;

@end
