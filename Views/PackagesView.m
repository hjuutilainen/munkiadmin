//
//  PackagesView.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 27.2.2012.
//
// This class contains code provided by Agile Monks, LLC.
// http://cocoa.agilemonks.com/2011/09/25/add-a-contextual-menu-to-hideshow-columns-in-an-nstableview/


#import "PackagesView.h"
#import "ImageAndTitleCell.h"
#import "DataModelHeaders.h"

#define kMinSplitViewWidth      200.0f
#define kMaxSplitViewWidth      400.0f
#define kDefaultSplitViewWidth  300.0f
#define kMinSplitViewHeight     80.0f
#define kMaxSplitViewHeight     400.0f

@interface PackagesView ()

@end

@implementation PackagesView
@synthesize tripleSplitView;
@synthesize leftPlaceHolder;
@synthesize middlePlaceHolder;
@synthesize rightPlaceHolder;
@synthesize packagesTableView;
@synthesize packagesArrayController;
@synthesize directoriesTreeController;
@synthesize directoriesOutlineView;
@synthesize descriptionTextView;
@synthesize notesTextView;
@synthesize notesDescriptionSplitView;
@synthesize packagesTableViewMenu;
@synthesize packageInfoPathControl;
@synthesize installerItemPathControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self.packagesTableView setTarget:[NSApp delegate]];
    [self.packagesTableView setDoubleAction:@selector(getInfoAction:)];
    
    /*
     Configure sorting
     */
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
    NSSortDescriptor *sortByMunkiName = [NSSortDescriptor sortDescriptorWithKey:@"munki_name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByMunkiVersion = [NSSortDescriptor sortDescriptorWithKey:@"munki_version" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.directoriesTreeController setSortDescriptors:[NSArray arrayWithObjects:sortByIndex,sortByTitle, nil]];
    [self.packagesArrayController setSortDescriptors:[NSArray arrayWithObjects:sortByMunkiName, sortByMunkiVersion, nil]];
    
    self.rightPlaceHolder.fillGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] 
                                                                        endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]] autorelease];
    
    [self.descriptionTextView setFont:[NSFont systemFontOfSize:11.0]];
    [self.notesTextView setFont:[NSFont systemFontOfSize:11.0]];
    
    /*
     Configure the main triple split view (sourcelist | packagelist | info)
     */
    float rightFrameWidth = kDefaultSplitViewWidth;
	float dividerThickness = [self.tripleSplitView dividerThickness];
	NSRect newFrame = [self.tripleSplitView frame];
	NSRect leftFrame = [self.leftPlaceHolder frame];
    NSRect centerFrame = [self.middlePlaceHolder frame];
	NSRect rightFrame = [self.rightPlaceHolder frame];
	
    rightFrame.size.height = newFrame.size.height;
    rightFrame.origin = NSMakePoint([self.tripleSplitView frame].size.width - rightFrameWidth, 0);
    rightFrame.size.width = rightFrameWidth;
    
	leftFrame.size.height = newFrame.size.height;
	leftFrame.origin.x = 0;
    
    centerFrame.size.height = newFrame.size.height;
	centerFrame.size.width = newFrame.size.width - leftFrame.size.width - dividerThickness - rightFrame.size.width - dividerThickness;
	centerFrame.origin = NSMakePoint(leftFrame.size.width + dividerThickness, 0);
	
	[self.leftPlaceHolder setFrame:leftFrame];
	[self.middlePlaceHolder setFrame:centerFrame];
    [self.rightPlaceHolder setFrame:rightFrame];
    
    
    /*
     Create a contextual menu for customizing table columns
     */
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    NSSortDescriptor *sortByHeaderString = [NSSortDescriptor sortDescriptorWithKey:@"headerCell.stringValue" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray *tableColumnsSorted = [self.packagesTableView.tableColumns sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByHeaderString]];
    for (NSTableColumn *col in tableColumnsSorted) {
        NSMenuItem *mi = [[[NSMenuItem alloc] initWithTitle:[col.headerCell stringValue]
                                                    action:@selector(toggleColumn:)
                                             keyEquivalent:@""] autorelease];
        mi.target = self;
        mi.representedObject = col;
        [menu addItem:mi];
    }
    menu.delegate = self;
    self.packagesTableView.headerView.menu = menu;
    [menu release];
    
    /*
     Set the target and action for path controls (pkginfo and installer item)
     */
    [self.packageInfoPathControl setTarget:self];
    [self.packageInfoPathControl setAction:@selector(didSelectPathControlItem:)];
    [self.installerItemPathControl setTarget:self];
    [self.installerItemPathControl setAction:@selector(didSelectPathControlItem:)];
}

-(void)toggleColumn:(id)sender
{
	NSTableColumn *col = [sender representedObject];
	[col setHidden:![col isHidden]];
}

-(void)menuWillOpen:(NSMenu *)menu
{
	for (NSMenuItem *mi in menu.itemArray) {
		NSTableColumn *col = [mi representedObject];
		[mi setState:col.isHidden ? NSOffState : NSOnState];
	}
}


#pragma mark -
#pragma mark NSOutlineView view delegates

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    if ([[item representedObject] isGroupItemValue]) {
        return YES;
    } else {
        return NO;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    id objectValue = nil;
    
    if ( [[item representedObject] isGroupItemValue] ) 
    {
        objectValue = [[item representedObject] title];
    }
    else 
    {        
        objectValue = [(PackageSourceListItemMO *)[item representedObject] dictValue];
    }
    
    return objectValue;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    if ([[item representedObject] isGroupItemValue]) {
        return NO;
    } else {
        return YES;
    }
}


#pragma mark -
#pragma mark NSPathControl methods

- (void)didSelectPathControlItem:(id)sender
{
    /*
     User selected a path component from one of the path controls, show it in Finder.
     */
    NSPathComponentCell *clickedCell = [(NSPathControl *)sender clickedPathComponentCell];
    NSURL *clickedURL = [clickedCell URL];
    if (clickedURL != nil) {
        [[NSWorkspace sharedWorkspace] selectFile:[clickedURL relativePath] inFileViewerRootedAtPath:@""];
    }
}


#pragma mark -
#pragma mark NSSplitView delegates

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
	if (splitView == self.tripleSplitView) return NO;
    else return NO;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex
{
	if (splitView == self.tripleSplitView) return NO;
    else return NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
    if (splitView == self.notesDescriptionSplitView) {
        if (dividerIndex == 0) {
            return kMinSplitViewHeight;
        }
    } else if (splitView == self.tripleSplitView) {
        /*
         User is dragging the left side divider
         */
        if (dividerIndex == 0) {
            return kMinSplitViewWidth;
        }
        /*
         User is dragging the right side divider
         */
        else if (dividerIndex == 1) {
            return proposedMin;
        }
    }
    return proposedMin;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
    if (splitView == self.notesDescriptionSplitView) {
        if (dividerIndex == 0) {
            return [self.notesDescriptionSplitView frame].size.height - kMinSplitViewHeight;
        }
    } else if (splitView == self.tripleSplitView) {
        /*
         User is dragging the left side divider
         */
        if (dividerIndex == 0) {
            return kMaxSplitViewWidth;
        }
        /*
         User is dragging the right side divider
         */
        else if (dividerIndex == 1) {
            return [self.tripleSplitView frame].size.width - kMinSplitViewWidth;
        }
    }
    return proposedMax;
}

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    /*
     Main split view
     Resize the middle view only
     */
    if (sender == self.tripleSplitView) {
        
        NSView *left = [[sender subviews] objectAtIndex:0];
        NSView *center = [[sender subviews] objectAtIndex:1];
        NSView *right = [[sender subviews] objectAtIndex:2];
        
        float dividerThickness = [sender dividerThickness];
        NSRect newFrame = [sender frame];
        NSRect leftFrame = [left frame];
        NSRect centerFrame = [center frame];
        NSRect rightFrame = [right frame];
        
        leftFrame.size.height = newFrame.size.height;
        leftFrame.origin.x = 0;
        
        centerFrame.size.height = newFrame.size.height;
        centerFrame.size.width = newFrame.size.width - leftFrame.size.width - dividerThickness - rightFrame.size.width - dividerThickness;
        centerFrame.origin = NSMakePoint(leftFrame.size.width + dividerThickness, 0);
        
        rightFrame.size.height = newFrame.size.height;
        rightFrame.origin = NSMakePoint(leftFrame.size.width + dividerThickness + centerFrame.size.width + dividerThickness, 0);
        
        [left setFrame:leftFrame];
        [center setFrame:centerFrame];
        [right setFrame:rightFrame];
    }
    
    /*
     Notes / Description split view
     */
    else if (sender == self.notesDescriptionSplitView) {
        
        NSView *top = [[sender subviews] objectAtIndex:0];
        NSView *bottom = [[sender subviews] objectAtIndex:1];
        float dividerThickness = [sender dividerThickness];
        NSRect newFrame = [sender frame];
        NSRect topFrame = [top frame];
        NSRect bottomFrame = [bottom frame];
        
        topFrame.size.width = newFrame.size.width;
        bottomFrame.size.width = newFrame.size.width;
        
        if ((topFrame.size.height <= kMinSplitViewHeight) && (newFrame.size.height < oldSize.height)) {
            topFrame.size.height = kMinSplitViewHeight;
            bottomFrame.size.height = newFrame.size.height - topFrame.size.height - dividerThickness;
            bottomFrame.origin = NSMakePoint(0, topFrame.size.height + dividerThickness);
        } else {
            topFrame.size.height = newFrame.size.height - bottomFrame.size.height - dividerThickness;
            bottomFrame.origin = NSMakePoint(0, topFrame.size.height + dividerThickness);
        }
        
        [top setFrame:topFrame];
        [bottom setFrame:bottomFrame];
    }
}


@end
