//
//  ImageAndTitleCell.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 27.2.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageAndTitleCell.h"

@implementation ImageAndTitleCell

@synthesize aTitleAttributes;
@synthesize aSubtitleAttributes;

- (void)awakeFromNib
{
	// Make attributes for our strings
	NSMutableParagraphStyle * aParagraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[aParagraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	
	// Title attributes: system font, 11pt, black, truncate tail
	self.aTitleAttributes = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                              [NSColor blackColor],NSForegroundColorAttributeName,
                              [NSFont systemFontOfSize:[NSFont smallSystemFontSize]],NSFontAttributeName,
                              aParagraphStyle, NSParagraphStyleAttributeName,
                              nil] autorelease];
	
	// Subtitle attributes: system font, 11pt, gray, truncate tail
	self.aSubtitleAttributes = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 [NSColor grayColor],NSForegroundColorAttributeName,
                                 [NSFont systemFontOfSize:[NSFont smallSystemFontSize]],NSFontAttributeName,
                                 aParagraphStyle, NSParagraphStyleAttributeName,
                                 nil] autorelease];
}

- (NSRect)expansionFrameWithFrame:(NSRect)cellFrame inView:(NSView *)view
{
    return NSZeroRect;
}

- (void)drawInteriorWithFrame:(NSRect)theCellFrame inView:(NSView *)theControlView
{
    if ([[self objectValue] isKindOfClass:[NSDictionary class]]) {
        // Inset the cell frame to give everything a little horizontal padding
        NSRect		anInsetRect = NSInsetRect(theCellFrame,10,0);
        
        // Make the icon
        NSImage *anIcon = [[self objectValue] valueForKey:@"icon"];
        
        // Flip the icon because the entire cell has a flipped coordinate system
        [anIcon setFlipped:YES];
        
        // get the size of the icon for layout
        NSSize		anIconSize = NSMakeSize(16, 16);
        
        // Make the strings and get their sizes
        
        // Make a Title string
        NSString *aTitle = [[self objectValue] valueForKey:@"title"];
        // get the size of the string for layout
        NSSize		aTitleSize = [aTitle sizeWithAttributes:self.aTitleAttributes];
        
        
        // Make the layout boxes for all of our elements - remember that we're in a flipped coordinate system when setting the y-values
        
        // Vertical padding between the lines of text
        //float		aVerticalPadding = 2.0;
        
        // Horizontal padding between icon and text
        float		aHorizontalPadding = 5.0;
        
        // Icon box: center the icon vertically inside of the inset rect
        NSRect		anIconBox = NSMakeRect(anInsetRect.origin.x,
                                           anInsetRect.origin.y + anInsetRect.size.height*.5 - anIconSize.height*.5,
                                           anIconSize.width,
                                           anIconSize.height);
        
        // Make a box for our text
        // Place it next to the icon with horizontal padding
        // Size it horizontally to fill out the rest of the inset rect
        // Center it vertically inside of the inset rect
        //float		aCombinedHeight = aTitleSize.height + aVerticalPadding;
        
        NSRect		aTextBox = NSMakeRect(anIconBox.origin.x + anIconBox.size.width + aHorizontalPadding,
                                          anInsetRect.origin.y + anInsetRect.size.height*.5 - aTitleSize.height*.5,
                                          anInsetRect.size.width - anIconSize.width - aHorizontalPadding,
                                          aTitleSize.height);
        
        // Now split the text box in half and put the title box in the top half and subtitle box in bottom half
        NSRect		aTitleBox = NSMakeRect(aTextBox.origin.x, 
                                           aTextBox.origin.y + aTextBox.size.height*0.5 - aTitleSize.height*0.5,
                                           aTextBox.size.width,
                                           aTitleSize.height);	
        
        if(	[self isHighlighted])
        {
            // if the cell is highlighted, draw the text white
            [aTitleAttributes setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
        }
        else
        {
            // if the cell is not highlighted, draw the title black and the subtile gray
            [aTitleAttributes setValue:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
        }
        
        
        // Draw the icon
        [anIcon drawInRect:anIconBox fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        
        // Draw the text
        [aTitle drawInRect:aTitleBox withAttributes:aTitleAttributes];
    }
    else {
        [super drawInteriorWithFrame:theCellFrame inView:theControlView];
    }
}


@end
