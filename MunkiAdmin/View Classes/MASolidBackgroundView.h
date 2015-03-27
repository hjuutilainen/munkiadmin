//
//  MASolidBackgroundView.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 27.3.2015.
//
//

#import <Cocoa/Cocoa.h>

@interface MASolidBackgroundView : NSView

@property BOOL drawBottomLine;
@property BOOL drawTopLine;
@property BOOL drawLeftLine;
@property BOOL drawRightLine;
@property (nonatomic, copy) NSColor *fillColor;
@property (nonatomic, copy) NSColor *lineColor;

@end
