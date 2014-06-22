//
//  MATableView.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 29.2.2012.
//

#import "MATableView.h"

@implementation MATableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

- (NSImage *)badgeImageWithText:(NSString *)text
{
    
    NSMutableParagraphStyle * aParagraphStyle = [[NSMutableParagraphStyle alloc] init];
	[aParagraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [aParagraphStyle setAlignment:NSCenterTextAlignment];
	NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSColor whiteColor], NSForegroundColorAttributeName,
                                        [NSFont systemFontOfSize:10], NSFontAttributeName,
                                        aParagraphStyle, NSParagraphStyleAttributeName,
                                        nil];
    
    // Figure out the required sizes based on the input string
    // and the above attributes
    NSSize textSize = [text sizeWithAttributes:attributes];
    NSRect textRect = NSMakeRect(0, 0, textSize.width + 5, textSize.height);
    NSRect badgeRect = NSInsetRect(textRect, 0, 0);
    
    // Create the image and start drawing
    NSImage *returnImage = [[NSImage alloc] initWithSize:badgeRect.size];
    [returnImage lockFocus];
    
    // Create a small rounded rect
    NSBezierPath *roundedRect = [NSBezierPath bezierPathWithRoundedRect:badgeRect xRadius:2.0 yRadius:2.0];
    [[NSColor redColor] set];
    [roundedRect fill];
    
    // Draw the text
    [text drawInRect:textRect withAttributes:attributes];
    
    [returnImage unlockFocus];
    return returnImage;
}

- (NSImage *)dragImageForRowsWithIndexes:(NSIndexSet *)dragRows tableColumns:(NSArray *)tableColumns event:(NSEvent *)dragEvent offset:(NSPointPointer)dragImageOffset
{
    /*
     Dragging multiple items
     */
    if ([dragRows count] > 1) {
        
        // Get image references
        NSImage *iconImage = [NSImage imageNamed:@"packageGroupIcon_32x32"];
        NSImage *dragImage = [[NSImage alloc] initWithSize:NSMakeSize(iconImage.size.width + 8, iconImage.size.height)];
        
        // Start drawing
        [dragImage lockFocus];
        
        // First draw the package group icon
        NSRect iconRect = NSMakeRect(0, 0, iconImage.size.width, iconImage.size.height);
        [iconImage drawInRect:iconRect
                     fromRect:NSZeroRect
                    operation:NSCompositeSourceOver
                     fraction:1.0];
        
        // Create a custom badge
        NSString *text = [NSString stringWithFormat:@"%lu", (unsigned long)[dragRows count]];
        NSImage *badgeImage = [self badgeImageWithText:text];
        
        // Figure out where the top right corner of our image is and draw
        NSRect badgeRect = NSMakeRect(dragImage.size.width - badgeImage.size.width,
                                      dragImage.size.height - badgeImage.size.height,
                                      badgeImage.size.width,
                                      badgeImage.size.height);
        
        [badgeImage drawInRect:badgeRect
                      fromRect:NSZeroRect
                     operation:NSCompositeSourceOver
                      fraction:1.0];
        
        // Done drawing
        [dragImage unlockFocus];
        return dragImage;
    }
    
    /*
     Dragging a single pkginfo
     */
    else {
        return [NSImage imageNamed:@"packageIcon_32x32"];
    }
    
    return nil;
}



/*
 Overridden to change selection when user right-clicks the table
 */
- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
	NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSUInteger row = (NSUInteger)[self rowAtPoint:mousePoint];
	if ([selectedRowIndexes containsIndex:row] == NO)
	{
		[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
	}
	return [super menuForEvent:theEvent];
}


- (void)textDidEndEditing:(NSNotification *)notification
{
    if ([[self delegate] respondsToSelector:@selector(tableViewDidEndAllEditing:)]) {
        [[self delegate] performSelector:@selector(tableViewDidEndAllEditing:) withObject:self];
    }
    [super textDidEndEditing:notification];
}

@end
