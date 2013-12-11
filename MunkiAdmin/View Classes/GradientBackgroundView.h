//
//  GradientBackgroundView.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 21.1.2010.
//

#import <Cocoa/Cocoa.h>


@interface GradientBackgroundView : NSView {
    
}

@property BOOL drawBottomLine;
@property BOOL drawTopLine;
@property BOOL drawLeftLine;
@property BOOL drawRightLine;
@property (nonatomic, copy) NSGradient *fillGradient;
@property (nonatomic, copy) NSColor *lineColor;

@end
