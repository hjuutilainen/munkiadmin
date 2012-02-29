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


/*
 Overridden to change selection when user right-clicks the table
 */
- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
	NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	int row = [self rowAtPoint:mousePoint];
	if ([selectedRowIndexes containsIndex:row] == NO)
	{
		[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
	}
	return [super menuForEvent:theEvent];
}

@end
