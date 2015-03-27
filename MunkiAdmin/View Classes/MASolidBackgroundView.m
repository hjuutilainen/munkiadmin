//
//  MASolidBackgroundView.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 27.3.2015.
//
//

#import "MASolidBackgroundView.h"

@implementation MASolidBackgroundView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _drawBottomLine = YES;
        _drawTopLine = YES;
        _drawLeftLine = YES;
        _drawRightLine = YES;
        _lineColor = [NSColor grayColor];
        _fillColor = [NSColor whiteColor];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect wholeRect = [self bounds];
    
    [self.fillColor set];
    NSRectFill(wholeRect);
    
    if (self.drawBottomLine) {
        NSBezierPath *bottomLine = [NSBezierPath bezierPath];
        [bottomLine moveToPoint:NSMakePoint(0, 0)];
        [bottomLine lineToPoint:NSMakePoint(wholeRect.size.width, 0)];
        [self.lineColor set];
        [bottomLine setLineWidth:1];
        [bottomLine stroke];
    }
    
    if (self.drawTopLine) {
        NSBezierPath *topLine = [NSBezierPath bezierPath];
        [topLine moveToPoint:NSMakePoint(0, wholeRect.size.height)];
        [topLine lineToPoint:NSMakePoint(wholeRect.size.width, wholeRect.size.height)];
        [self.lineColor set];
        [topLine setLineWidth:1];
        [topLine stroke];
    }
    
    if (self.drawLeftLine) {
        NSBezierPath *leftLine = [NSBezierPath bezierPath];
        [leftLine moveToPoint:NSMakePoint(0, 0)];
        [leftLine lineToPoint:NSMakePoint(0, wholeRect.size.height)];
        [self.lineColor set];
        [leftLine setLineWidth:1];
        [leftLine stroke];
    }
    
    if (self.drawRightLine) {
        NSBezierPath *rightLine = [NSBezierPath bezierPath];
        [rightLine moveToPoint:NSMakePoint(wholeRect.size.width, 0)];
        [rightLine lineToPoint:NSMakePoint(wholeRect.size.width, wholeRect.size.height)];
        [self.lineColor set];
        [rightLine setLineWidth:1];
        [rightLine stroke];
    }
}

@end
