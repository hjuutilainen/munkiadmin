//
//  MAManifestsView.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 6.3.2015.
//
//

#import "MAManifestsView.h"
#import "MAManifestsViewSourceListItem.h"
#import "DataModelHeaders.h"
#import "MAMunkiRepositoryManager.h"
#import "MACoreDataManager.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

#define kMinSplitViewWidth      200.0f
#define kMaxSplitViewWidth      400.0f
#define kDefaultSplitViewWidth  300.0f
#define kMinSplitViewHeight     80.0f
#define kMaxSplitViewHeight     400.0f

@interface MAManifestsView ()
@property (strong, nonatomic) NSMutableArray *modelObjects;
@property (strong, nonatomic) NSMutableArray *sourceListItems;
@end

@implementation MAManifestsView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.sourceList registerForDraggedTypes:@[draggingType]];
    self.sourceListItems = [[NSMutableArray alloc] init];
    [self configureSplitView];
    [self setUpDataModel];
    [self.sourceList setFloatsGroupRows:NO];
    self.manifestsArrayController.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)]];
    [self.sourceList reloadData];
}

- (void)configureSplitView
{
    [self.mainSplitView setDividerStyle:NSSplitViewDividerStyleThin];
}

# pragma mark - 
# pragma mark Data Model

- (void)setUpDataModel
{
    MAManifestsViewSourceListItem *allManifestsItem = [MAManifestsViewSourceListItem collectionWithTitle:@"All Manifests" identifier:@"allManifests" type:ManifestSourceItemTypeFolder];
    allManifestsItem.filterPredicate = [NSPredicate predicateWithValue:TRUE];
    
    MAManifestsViewSourceListItem *recentlyModifiedItem = [MAManifestsViewSourceListItem collectionWithTitle:@"Recently Modified" identifier:@"recentlyModified" type:ManifestSourceItemTypeFolder];
    NSDate *now = [NSDate date];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = -30;
    NSDate *thirtyDaysAgo = [[NSCalendar currentCalendar] dateByAddingComponents:dayComponent toDate:now options:0];
    NSPredicate *thirtyDaysAgoPredicate = [NSPredicate predicateWithFormat:@"packageInfoDateCreated >= %@", thirtyDaysAgo];
    //recentlyModifiedItem.filterPredicate = thirtyDaysAgoPredicate;
    
    MAManifestsViewSourceListItem *machineManifestsItem = [MAManifestsViewSourceListItem collectionWithTitle:@"Machine Manifests" identifier:@"machineManifests" type:ManifestSourceItemTypeFolder];
    NSPredicate *noReferencingManifests = [NSPredicate predicateWithFormat:@"referencingStringObjects.@count == 0 AND allIncludedManifests.@count > 0"];
    machineManifestsItem.filterPredicate = noReferencingManifests;
    
    MAManifestsViewSourceListItem *groupManifestsItem = [MAManifestsViewSourceListItem collectionWithTitle:@"Group Manifests" identifier:@"groupManifests" type:ManifestSourceItemTypeFolder];
    NSPredicate *hasReferencingManifests = [NSPredicate predicateWithFormat:@"referencingStringObjects.@count > 0 AND allIncludedManifests.@count > 0"];
    groupManifestsItem.filterPredicate = hasReferencingManifests;
    
    MAManifestsViewSourceListItem *profileManifestsItem = [MAManifestsViewSourceListItem collectionWithTitle:@"Profile Manifests" identifier:@"profileManifests" type:ManifestSourceItemTypeFolder];
    NSPredicate *profileManifestsPredicate = [NSPredicate predicateWithFormat:@"(referencingStringObjects.@count > 0 AND allIncludedManifests.@count == 0) AND ((allOptionalInstalls.@count > 0) OR (allManagedUpdates.@count > 0) OR (allManagedInstalls.@count > 0) OR (allManagedUninstalls.@count > 0))"];
    profileManifestsItem.filterPredicate = profileManifestsPredicate;
    
    MAManifestsViewSourceListItem *selfContainedManifestsItem = [MAManifestsViewSourceListItem collectionWithTitle:@"Self-contained Manifests" identifier:@"selfContainedManifests" type:ManifestSourceItemTypeFolder];
    NSPredicate *selfContainedManifestsItemPredicate = [NSPredicate predicateWithFormat:@"(referencingStringObjects.@count == 0 AND allIncludedManifests.@count == 0)"];
    selfContainedManifestsItem.filterPredicate = selfContainedManifestsItemPredicate;
    
    // Store all of the model objects in an array because each source list item only holds a weak reference to them.
    self.modelObjects = [@[allManifestsItem, recentlyModifiedItem, machineManifestsItem, groupManifestsItem, profileManifestsItem, selfContainedManifestsItem] mutableCopy];
    
    // Icon images we're going to use in the Source List.
    NSImage *smartFolder = [NSImage imageNamed:NSImageNameFolderSmart];
    [smartFolder setTemplate:NO];
    
    // Set up our Source List data model used in the Source List data source methods.
    NSString *libraryItemTitle = @"Repository";
    NSString *manifestTypesItemTitle = @"Manifest Types";
    NSString *directoriesItemTitle = @"Directories";
    
    for (__strong NSString *aString in @[libraryItemTitle, manifestTypesItemTitle, directoriesItemTitle]) {
        if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_9) {
            /* On a 10.9 - 10.9.x system */
            aString = [aString uppercaseString];
        } else {
            /* 10.10 or later system */
            aString = [aString capitalizedString];
        }
    }
    
    PXSourceListItem *libraryItem = [PXSourceListItem itemWithTitle:libraryItemTitle identifier:nil];
    libraryItem.children = @[[PXSourceListItem itemWithRepresentedObject:allManifestsItem icon:smartFolder],
                             [PXSourceListItem itemWithRepresentedObject:recentlyModifiedItem icon:smartFolder]];
    
    PXSourceListItem *manifestTypesItem = [PXSourceListItem itemWithTitle:manifestTypesItemTitle identifier:nil];
    manifestTypesItem.children = @[[PXSourceListItem itemWithRepresentedObject:machineManifestsItem icon:smartFolder],
                                   [PXSourceListItem itemWithRepresentedObject:groupManifestsItem icon:smartFolder],
                                   [PXSourceListItem itemWithRepresentedObject:profileManifestsItem icon:smartFolder],
                                   [PXSourceListItem itemWithRepresentedObject:selfContainedManifestsItem icon:smartFolder]];
    
    PXSourceListItem *directoriesItem = [PXSourceListItem itemWithTitle:directoriesItemTitle identifier:nil];
    
    [self.sourceListItems addObject:libraryItem];
    [self.sourceListItems addObject:manifestTypesItem];
    [self.sourceListItems addObject:directoriesItem];
}





# pragma mark -
# pragma mark PXSourceList Data Source methods

- (NSUInteger)sourceList:(PXSourceList*)sourceList numberOfChildrenOfItem:(id)item
{
    if (!item)
        return self.sourceListItems.count;
    
    return [[item children] count];
}

- (id)sourceList:(PXSourceList*)aSourceList child:(NSUInteger)index ofItem:(id)item
{
    if (!item)
        return self.sourceListItems[index];
    
    return [[item children] objectAtIndex:index];
}

- (BOOL)sourceList:(PXSourceList*)aSourceList isItemExpandable:(id)item
{
    return [item hasChildren];
}

# pragma mark -
# pragma mark PXSourceList Delegate

- (void)removeDetailViewSubviews
{
    NSArray *detailSubViews = [self.detailViewPlaceHolder subviews];
    if ([detailSubViews count] > 0)
    {
        [detailSubViews[0] removeFromSuperview];
    }
}

- (void)setDetailView:(NSView *)newDetailView
{
    [self.detailViewPlaceHolder addSubview:newDetailView];
    
    [newDetailView setFrame:[self.detailViewPlaceHolder frame]];
    
    // make sure our added subview is placed and resizes correctly
    [newDetailView setFrameOrigin:NSMakePoint(0,0)];
    [newDetailView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
}

- (void)sourceListSelectionDidChange:(NSNotification *)notification
{
    if ([self.sourceList selectedRow] >= 0) {
        id selectedItem = [self.sourceList itemAtRow:[self.sourceList selectedRow]];
        NSPredicate *productFilter = [(MAManifestsViewSourceListItem *)[selectedItem representedObject] filterPredicate];
        self.manifestsArrayController.filterPredicate = productFilter;
        
        [self setDetailView:self.manifestsListView];
        
        //NSArray *productSortDescriptors = [selectedItem sortDescriptors];
        /*
        [self setPackagesMainFilterPredicate:productFilter];
        if (productSortDescriptors != nil) {
            [self.packagesArrayController setSortDescriptors:productSortDescriptors];
        } else {
            [self.packagesArrayController setSortDescriptors:self.defaultSortDescriptors];
        }
         */
    }
}

- (BOOL)sourceList:(PXSourceList *)aSourceList isGroupAlwaysExpanded:(id)group
{
    return YES;
}

- (NSView *)sourceList:(PXSourceList *)aSourceList viewForItem:(id)item
{
    PXSourceListTableCellView *cellView = nil;
    if ([aSourceList levelForItem:item] == 0)
        cellView = [aSourceList makeViewWithIdentifier:@"HeaderCell" owner:nil];
    else
        cellView = [aSourceList makeViewWithIdentifier:@"MainCell" owner:nil];
    
    PXSourceListItem *sourceListItem = item;
    MAManifestsViewSourceListItem *collection = sourceListItem.representedObject;
    
    // Only allow us to edit the user created photo collection titles.
    BOOL isTitleEditable = [collection isKindOfClass:[MAManifestsViewSourceListItem class]] && collection.type == ManifestSourceItemTypeUserCreated;
    cellView.textField.editable = isTitleEditable;
    cellView.textField.selectable = isTitleEditable;
    
    cellView.textField.stringValue = sourceListItem.title ? sourceListItem.title : [sourceListItem.representedObject title];
    cellView.imageView.image = [item icon];
    //cellView.badgeView.hidden = collection.photos.count == 0;
    //cellView.badgeView.badgeValue = collection.photos.count;
    
    return cellView;
}


# pragma mark -
# pragma mark NSSplitView delegates

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
    if (splitView == self.mainSplitView) return NO;
    else return NO;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex
{
    if (splitView == self.mainSplitView) return NO;
    else return NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
    if (splitView == self.mainSplitView) {
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
    if (splitView == self.mainSplitView) {
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
            return [self.mainSplitView frame].size.width - kMinSplitViewWidth;
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
    if (sender == self.mainSplitView) {
        
        NSView *left = [[sender subviews] objectAtIndex:0];
        NSView *center = [[sender subviews] objectAtIndex:1];
        NSView *right = [[sender subviews] objectAtIndex:2];
        
        CGFloat dividerThickness = [sender dividerThickness];
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
    
}


@end
