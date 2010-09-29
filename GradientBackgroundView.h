//
//  GradientBackgroundView.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 21.1.2010.
//

#import <Cocoa/Cocoa.h>


@interface GradientBackgroundView : NSView {

	NSGradient *fillGradient;
	BOOL drawBottomLine;
}

@property BOOL drawBottomLine;
@property (retain) NSGradient *fillGradient;

@end
