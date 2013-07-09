// Thanks to Cathy Shive, http://katidev.com/blog/2008/02/22/styling-an-nstableview-dttah/
// Modified by Hannes Juutilainen

#import "MyCell.h"

@implementation MyCell

@synthesize aTitleAttributes;
@synthesize aSubtitleAttributes;

- (void)awakeFromNib
{
	// Make attributes for our strings
	NSMutableParagraphStyle * aParagraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[aParagraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	
	// Title attributes: system font, 14pt, black, truncate tail
	self.aTitleAttributes = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
											   [NSColor blackColor],NSForegroundColorAttributeName,
											   [NSFont systemFontOfSize:13.0],NSFontAttributeName,
											   aParagraphStyle, NSParagraphStyleAttributeName,
											   nil] autorelease];
	
	// Subtitle attributes: system font, 12pt, gray, truncate tail
	self.aSubtitleAttributes = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
												  [NSColor grayColor],NSForegroundColorAttributeName,
												  [NSFont systemFontOfSize:12.0],NSFontAttributeName,
												  aParagraphStyle, NSParagraphStyleAttributeName,
												  nil] autorelease];
}

- (NSImage *)theIcon
{
	NSImage *img = nil;
	NSWorkspace *wp = [NSWorkspace sharedWorkspace];
	NSString *type = [[self objectValue] valueForKey:@"type"];
	
	if ([type isEqualToString:@"application"]) {
		//NSString *appPath = [wp fullPathForApplication:[[self objectValue] valueForKey:@"title"]];
		//if (appPath != nil) img = [wp iconForFile:appPath];
		//else img = [wp iconForFileType:NSFileTypeForHFSTypeCode(kGenericApplicationIcon)];
		img = [NSImage imageNamed:@"packageIcon_32x32"];
	
	} else if ([type isEqualToString:@"applications"]) {
		img = [NSImage imageNamed:@"packageGroupIcon_32x32"];
		
	} else if ([type isEqualToString:@"catalog"]) {
		img = [NSImage imageNamed:@"catalogIcon_32x32"];
		
	} else if ([type isEqualToString:@"cataloginfo"]) {
		img = [wp iconForFileType:NSFileTypeForHFSTypeCode(kGenericDocumentIcon)];
		
	} else if ([type isEqualToString:@"package"]) {
		img = [NSImage imageNamed:@"packageIcon_32x32"];
		
	} else if ([type isEqualToString:@"requires"]) {
		img = [NSImage imageNamed:@"packageIcon_32x32"];
		
	} else if ([type isEqualToString:@"updateFor"]) {
		img = [NSImage imageNamed:@"packageIcon_32x32"];
		
	} else if ([type isEqualToString:@"packageinfo"]) {
		img = [wp iconForFileType:@"dmg"];
		
	} else if ([type isEqualToString:@"manifest"]) {
		img = [NSImage imageNamed:@"manifestIcon_32x32"];
	
	} else if ([type isEqualToString:@"includedManifest"]) {
		img = [NSImage imageNamed:@"manifestIcon_32x32"];
        
	} else if ([type isEqualToString:@"installsitem"]) {
		img = [wp iconForFile:[[self objectValue] valueForKey:@"title"]];
	
	} else if ([type isEqualToString:@"receipt"]) {
		img = [wp iconForFileType:@"pkg"];
	
	} else if ([type isEqualToString:@"requirement"]) {
		img = [wp iconForFileType:@"packageIcon_32x32"];
        
	} else if ([type isEqualToString:@"itemtocopy"]) {
		img = [wp iconForFileType:NSFileTypeForHFSTypeCode(kGenericDocumentIcon)];
	
    } else if ([type isEqualToString:@"managedInstall"]) {
		img = [NSImage imageNamed:@"packageIcon_32x32"];
	
    } else if ([type isEqualToString:@"managedUninstall"]) {
		img = [NSImage imageNamed:@"packageIcon_32x32"];
	
    } else if ([type isEqualToString:@"managedUpdate"]) {
		img = [NSImage imageNamed:@"packageIcon_32x32"];
	
    } else if ([type isEqualToString:@"optionalInstall"]) {
		img = [NSImage imageNamed:@"packageIcon_32x32"];
	}
	
	return img;
}

- (void)drawInteriorWithFrame:(NSRect)theCellFrame inView:(NSView *)theControlView
{
	// Inset the cell frame to give everything a little horizontal padding
	NSRect		anInsetRect = NSInsetRect(theCellFrame,10,0);
	
	// Make the icon
	NSImage *anIcon = [self theIcon];
	
	// Flip the icon because the entire cell has a flipped coordinate system
	[anIcon setFlipped:YES];
	
	// get the size of the icon for layout
    NSSize anIconSize;
    if (anInsetRect.size.height <= 20) {
        anIconSize = NSMakeSize(16, 16);
    } else if (anInsetRect.size.height <= 40) {
        anIconSize = NSMakeSize(32, 32);
    } else {
        anIconSize = NSMakeSize(32, 32);
    }
											
	// Make the strings and get their sizes
	
	// Make a Title string
	NSString *aTitle = [[self objectValue] valueForKey:@"title"];
	// get the size of the string for layout
	NSSize		aTitleSize = [aTitle sizeWithAttributes:self.aTitleAttributes];
	
	// Make a Subtitle string
	NSString *aSubtitle = [[self objectValue] valueForKey:@"subtitle"];
	// get the size of the string for layout
	NSSize		aSubtitleSize = [aSubtitle sizeWithAttributes:self.aSubtitleAttributes];
	
	
	// Make the layout boxes for all of our elements - remember that we're in a flipped coordinate system when setting the y-values
	
	// Vertical padding between the lines of text
	float		aVerticalPadding = 5.0;
	
	// Horizontal padding between icon and text
	float		aHorizontalPadding = 10.0;
	
	// Icon box: center the icon vertically inside of the inset rect
	NSRect		anIconBox = NSMakeRect(anInsetRect.origin.x,
									   anInsetRect.origin.y + anInsetRect.size.height*.5 - anIconSize.height*.5,
									   anIconSize.width,
									   anIconSize.height);
	
	// Make a box for our text
	// Place it next to the icon with horizontal padding
	// Size it horizontally to fill out the rest of the inset rect
	// Center it vertically inside of the inset rect
	float		aCombinedHeight = aTitleSize.height + aSubtitleSize.height + aVerticalPadding;
	
	NSRect		aTextBox = NSMakeRect(anIconBox.origin.x + anIconBox.size.width + aHorizontalPadding,
									  anInsetRect.origin.y + anInsetRect.size.height*.5 - aCombinedHeight*.5,
									  anInsetRect.size.width - anIconSize.width - aHorizontalPadding,
									  aCombinedHeight);
	
	// Now split the text box in half and put the title box in the top half and subtitle box in bottom half
	NSRect		aTitleBox = NSMakeRect(aTextBox.origin.x, 
									   aTextBox.origin.y + aTextBox.size.height*.5 - aTitleSize.height,
									   aTextBox.size.width,
									   aTitleSize.height);
											
	NSRect		aSubtitleBox = NSMakeRect(aTextBox.origin.x,
										  aTextBox.origin.y + aTextBox.size.height*.5,
										  aTextBox.size.width,
										  aSubtitleSize.height);
	
	
	if(	[self isHighlighted])
	{
		// if the cell is highlighted, draw the text white
		[aTitleAttributes setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		[aSubtitleAttributes setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	}
	else
	{
		// if the cell is not highlighted, draw the title black and the subtile gray
		[aTitleAttributes setValue:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
		[aSubtitleAttributes setValue:[NSColor grayColor] forKey:NSForegroundColorAttributeName];
	}
	
	
	// Draw the icon
	[anIcon drawInRect:anIconBox fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	// Draw the text
	[aTitle drawInRect:aTitleBox withAttributes:aTitleAttributes];
	[aSubtitle drawInRect:aSubtitleBox withAttributes:aSubtitleAttributes];

}


@end
