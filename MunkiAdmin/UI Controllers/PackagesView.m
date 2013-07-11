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
#import "MunkiRepositoryManager.h"
#import "MunkiAdmin_AppDelegate.h"

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
    
    [self.packagesTableView setDelegate:self];
    [self.packagesTableView setDataSource:self];
    [self.packagesTableView registerForDraggedTypes:[NSArray arrayWithObject:NSURLPboardType]];
	[self.packagesTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    
    [self.directoriesOutlineView registerForDraggedTypes:[NSArray arrayWithObject:NSURLPboardType]];
    [self.directoriesOutlineView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    
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


- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
{
    /*
     At the moment we don't support dragging the source list items
     */
    return NO;
}

- (BOOL)shouldMoveInstallerItemWithPkginfo
{
    BOOL shouldMove = NO;
    
    NSString *moveDefaultsKey = @"MoveInstallerItemsWithPkginfos";
    NSString *moveConfirmationSuppressed = @"MoveInstallerItemsWithPkginfosSuppressed";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:moveConfirmationSuppressed]) {
        shouldMove = [defaults boolForKey:moveDefaultsKey];
    } else {
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Move"];
        [alert addButtonWithTitle:@"Skip"];
        [alert setMessageText:@"Move installer item?"];
        [alert setInformativeText:NSLocalizedString(@"MunkiAdmin can move the installer item to a corresponding subdirectory under the pkgs directory. Any missing directories will be created.", @"")];
        [alert setShowsSuppressionButton:YES];
        
        // Display the dialog and act accordingly
        NSInteger result = [alert runModal];
        if (result == NSAlertFirstButtonReturn) {
            shouldMove = YES;
        } else if ( result == NSAlertSecondButtonReturn ) {
            shouldMove = NO;
        }
        
        if ([[alert suppressionButton] state] == NSOnState) {
            // Suppress this alert from now on.
            [defaults setBool:YES forKey:moveConfirmationSuppressed];
            [defaults setBool:shouldMove forKey:moveDefaultsKey];
        }
        [alert release];
    }
    
    return shouldMove;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)proposedParentItem childIndex:(NSInteger)index
{
    if (outlineView == self.directoriesOutlineView) {
        NSArray *dragTypes = [[info draggingPasteboard] types];
        if ([dragTypes containsObject:NSURLPboardType]) {
            
            DirectoryMO *targetDir = [proposedParentItem representedObject];
                        
            NSPasteboard *pasteboard = [info draggingPasteboard];
            NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
            NSDictionary *options = [NSDictionary dictionaryWithObject:
                                     [NSNumber numberWithBool:NO] forKey:NSPasteboardURLReadingFileURLsOnlyKey];
            NSArray *urls = [pasteboard readObjectsForClasses:classes options:options];
            for (NSURL *uri in urls) {
                NSManagedObjectContext *moc = [self.packagesArrayController managedObjectContext];
                NSManagedObjectID *objectID = [[moc persistentStoreCoordinator] managedObjectIDForURIRepresentation:uri];
                PackageMO *droppedPackage = (PackageMO *)[moc objectRegisteredForID:objectID];
                NSString *currentFileName = [[droppedPackage packageInfoURL] lastPathComponent];
                NSURL *targetURL = [targetDir.originalURL URLByAppendingPathComponent:currentFileName];
                
                /*
                 Ask permission to move the installer item as well
                 */
                BOOL allowMove = [self shouldMoveInstallerItemWithPkginfo];
                [[MunkiRepositoryManager sharedManager] movePackage:droppedPackage toURL:targetURL moveInstaller:allowMove];
            }
        }
        return YES;
    }
    else {
        return NO;
    }
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
    
    // Deny drag and drop reordering
    if (index != -1) {
        return NSDragOperationNone;
    }
    
    if (outlineView == self.directoriesOutlineView) {
        
        /*
         Only allow dropping on regular folders
         */
        DirectoryMO *targetDir = [item representedObject];
        if (![targetDir.type isEqualToString:@"regular"]) {
            return NSDragOperationNone;
        }
        
        /*
         Check if we even have a supported type in pasteboard
         */
        NSArray *dragTypes = [[info draggingPasteboard] types];
        if (![dragTypes containsObject:NSURLPboardType]) {
            return NSDragOperationNone;
        }
        
        /*
         Only accept "x-coredata" URLs which resolve to an actual object
         */
        NSPasteboard *pasteboard = [info draggingPasteboard];
        NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:NSPasteboardURLReadingFileURLsOnlyKey];
        NSArray *urls = [pasteboard readObjectsForClasses:classes options:options];
        for (NSURL *uri in urls) {
            if ([[uri scheme] isEqualToString:@"x-coredata"]) {
                NSManagedObjectContext *moc = [self.packagesArrayController managedObjectContext];
                NSManagedObjectID *objectID = [[moc persistentStoreCoordinator] managedObjectIDForURIRepresentation:uri];
                if (!objectID) {
                    return NSDragOperationNone;
                }
            } else {
                return NSDragOperationNone;
            }
        }
        return NSDragOperationMove;
        
    } else {
        return NSDragOperationNone;
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


# pragma mark -
# pragma mark NSTableView delegates

- (BOOL)tableView:(NSTableView *)theTableView writeRowsWithIndexes:(NSIndexSet *)theRowIndexes toPasteboard:(NSPasteboard*)thePasteboard
{
    if (theTableView == self.packagesTableView) {
        [thePasteboard declareTypes:[NSArray arrayWithObject:NSURLPboardType] owner:self];
        NSMutableArray *urls = [NSMutableArray array];
        [theRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            PackageMO *package = [[self.packagesArrayController arrangedObjects] objectAtIndex:idx];
            [urls addObject:[[package objectID] URIRepresentation]];
        }];
        return [thePasteboard writeObjects:urls];
    } 
    
    else {
        return FALSE;
    }
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
	int result = NSDragOperationNone;
    
    /*
     Packages table view validations
     */
    if (aTableView == self.packagesTableView) {
        /*
         Check if we have regular files
         */
        NSArray *dragTypes = [[info draggingPasteboard] types];
        if ([dragTypes containsObject:NSFilenamesPboardType]) {
            
            NSPasteboard *pasteboard = [info draggingPasteboard];
            NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
            NSDictionary *options = [NSDictionary dictionaryWithObject:
                                     [NSNumber numberWithBool:YES] forKey:NSPasteboardURLReadingFileURLsOnlyKey];
            NSArray *urls = [pasteboard readObjectsForClasses:classes options:options];
            
            for (NSURL *uri in urls) {
                BOOL canImport = [[MunkiRepositoryManager sharedManager] canImportURL:uri error:nil];
                if (canImport) {
                    [aTableView setDropRow:-1 dropOperation:NSTableViewDropOn];
                    result = NSDragOperationCopy;
                } else {
                    result = NSDragOperationNone;
                }
            }
            
        } else {
            result = NSDragOperationNone;
        }
    }
    
    return (result);
}


- (BOOL)tableView:(NSTableView *)theTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    
    if (theTableView == self.packagesTableView) {
        /*
         Check if we have regular files
         */
        NSArray *dragTypes = [[info draggingPasteboard] types];
        if ([dragTypes containsObject:NSFilenamesPboardType]) {
            
            NSPasteboard *pasteboard = [info draggingPasteboard];
            NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
            NSDictionary *options = [NSDictionary dictionaryWithObject:
                                     [NSNumber numberWithBool:YES] forKey:NSPasteboardURLReadingFileURLsOnlyKey];
            NSArray *urls = [pasteboard readObjectsForClasses:classes options:options];
            
            NSMutableArray *temporarySupportedURLs = [[[NSMutableArray alloc] init] autorelease];
            for (NSURL *uri in urls) {
                BOOL canImport = [[MunkiRepositoryManager sharedManager] canImportURL:uri error:nil];
                if (canImport) {
                    [temporarySupportedURLs addObject:uri];
                }
            }
            NSArray *supportedURLs = [NSArray arrayWithArray:temporarySupportedURLs];
            [[NSApp delegate] addNewPackagesFromFileURLs:supportedURLs];
            return YES;
            
        } else {
            return NO;
        }
    }
    
    else {
        return NO;
    }
    return NO;
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
