//
//  ManifestItemTableView.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 16.12.2010.
//

#import "MAManifestItemTableView.h"


@implementation MAManifestItemTableView

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	// get the current selections for the outline view. 
	NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
	
	// select the row that was clicked before showing the menu for the event
	NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	int row = [self rowAtPoint:mousePoint];
	
	// figure out if the row that was just clicked on is currently selected
	if ([selectedRowIndexes containsIndex:row] == NO)
	{
		[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
	}
	
	return [super menuForEvent:theEvent];
}

@end
