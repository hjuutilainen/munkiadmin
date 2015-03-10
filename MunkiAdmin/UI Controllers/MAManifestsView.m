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
#import "MAMunkiAdmin_AppDelegate.h"
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
    
    [self updateSourceListData];
}

- (void)awakeFromNib
{
    //[self.sourceList registerForDraggedTypes:@[draggingType]];
    
}

- (void)updateSourceListData
{
    [self configureSourceList];
    [self configureSplitView];
    self.sourceListItems = [[NSMutableArray alloc] init];
    
    [self setUpDataModel];
    self.manifestsArrayController.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)]];
    
    [self.sourceList reloadData];
    //[self.sourceList layout];
    [self.sourceList expandItem:nil expandChildren:YES];
    [self.sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
    
}

- (void)configureSourceList
{
    [self.sourceList sizeLastColumnToFit];
    [self.sourceList setFloatsGroupRows:NO];
    [self.sourceList setRowSizeStyle:NSTableViewRowSizeStyleDefault];
    [self.sourceList setIndentationMarkerFollowsCell:YES];
    [self.sourceList setIndentationPerLevel:14];
}

- (void)configureSplitView
{
    [self.mainSplitView setDividerStyle:NSSplitViewDividerStyleThin];
}

# pragma mark - 
# pragma mark Data Model

- (void)setUpDataModel
{
    /*
     Predicates
     */
    NSPredicate *noReferencingManifests     = [NSPredicate predicateWithFormat:@"referencingStringObjects.@count == 0"];
    NSPredicate *hasReferencingManifests    = [NSPredicate predicateWithFormat:@"referencingStringObjects.@count > 0"];
    NSPredicate *hasIncludedManifests       = [NSPredicate predicateWithFormat:@"allIncludedManifests.@count > 0"];
    NSPredicate *noIncludedManifests        = [NSPredicate predicateWithFormat:@"allIncludedManifests.@count == 0"];
    //NSPredicate *noManagedInstalls        = [NSPredicate predicateWithFormat:@"allManagedInstalls.@count == 0"];
    NSPredicate *hasManagedInstalls         = [NSPredicate predicateWithFormat:@"allManagedInstalls.@count > 0"];
    //NSPredicate *noManagedUninstalls      = [NSPredicate predicateWithFormat:@"allManagedUninstalls.@count == 0"];
    NSPredicate *hasManagedUninstalls       = [NSPredicate predicateWithFormat:@"allManagedUninstalls.@count > 0"];
    //NSPredicate *noOptionalInstalls       = [NSPredicate predicateWithFormat:@"allOptionalInstalls.@count == 0"];
    NSPredicate *hasOptionalInstalls        = [NSPredicate predicateWithFormat:@"allOptionalInstalls.@count > 0"];
    //NSPredicate *noManagedUpdates         = [NSPredicate predicateWithFormat:@"allManagedUpdates.@count == 0"];
    NSPredicate *hasManagedUpdates          = [NSPredicate predicateWithFormat:@"allManagedUpdates.@count > 0"];
    
    /*
     All Manifests item
     */
    MAManifestsViewSourceListItem *allManifestsItem = [MAManifestsViewSourceListItem collectionWithTitle:@"All Manifests" identifier:@"allManifests" type:ManifestSourceItemTypeFolder];
    allManifestsItem.filterPredicate = [NSPredicate predicateWithValue:TRUE];
    
    /*
     Recently modified item
     */
    MAManifestsViewSourceListItem *recentlyModifiedItem = [MAManifestsViewSourceListItem collectionWithTitle:@"Recently Modified" identifier:@"recentlyModified" type:ManifestSourceItemTypeFolder];
    NSDate *now = [NSDate date];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = -7;
    NSDate *sevenDaysAgo = [[NSCalendar currentCalendar] dateByAddingComponents:dayComponent toDate:now options:0];
    NSPredicate *recentlyModifiedPredicate = [NSPredicate predicateWithFormat:@"manifestDateModified >= %@", sevenDaysAgo];
    recentlyModifiedItem.filterPredicate = recentlyModifiedPredicate;
    
    /*
     Machine manifests item
     */
    MAManifestsViewSourceListItem *machineManifestsItem = [MAManifestsViewSourceListItem collectionWithTitle:@"Machine Manifests" identifier:@"machineManifests" type:ManifestSourceItemTypeFolder];
    machineManifestsItem.filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[noReferencingManifests, hasIncludedManifests]];
    
    /*
     Group manifests item
     */
    MAManifestsViewSourceListItem *groupManifestsItem = [MAManifestsViewSourceListItem collectionWithTitle:@"Group Manifests" identifier:@"groupManifests" type:ManifestSourceItemTypeFolder];
    groupManifestsItem.filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[hasReferencingManifests, hasIncludedManifests]];
    
    /*
     Profile manifests item
     */
    MAManifestsViewSourceListItem *profileManifestsItem = [MAManifestsViewSourceListItem collectionWithTitle:@"Profile Manifests" identifier:@"profileManifests" type:ManifestSourceItemTypeFolder];
    profileManifestsItem.filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                [NSCompoundPredicate andPredicateWithSubpredicates:@[hasReferencingManifests, noIncludedManifests]],
                                                [NSCompoundPredicate orPredicateWithSubpredicates:@[hasManagedInstalls, hasManagedUninstalls, hasManagedUpdates, hasOptionalInstalls]]
                                                ]];
    
    /*
     Self-contained manifests item
     */
    /*
    MAManifestsViewSourceListItem *selfContainedManifestsItem = [MAManifestsViewSourceListItem collectionWithTitle:@"Self-contained Manifests" identifier:@"selfContainedManifests" type:ManifestSourceItemTypeFolder];
    selfContainedManifestsItem.filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[noReferencingManifests, noIncludedManifests]];
     */
    
    // Icon images we're going to use in the Source List.
    
    NSImage *notepad = [NSImage imageNamed:@"book"];
    [notepad setTemplate:YES];
    
    NSImage *inbox = [NSImage imageNamed:@"inbox"];
    [inbox setTemplate:YES];
    
    NSImage *calendar = [NSImage imageNamed:@"calendar_ok"];
    [calendar setTemplate:YES];
    
    NSImage *folder = [NSImage imageNamed:@"folder"];
    [folder setTemplate:YES];
    
    NSImage *document = [NSImage imageNamed:@"document"];
    [document setTemplate:YES];
    
    NSImage *documents = [NSImage imageNamed:@"documents"];
    [documents setTemplate:YES];
    
    NSImage *documentDownload = [NSImage imageNamed:@"document_download"];
    [documentDownload setTemplate:YES];
    
    /*
     Catalog items
     */
    NSManagedObjectContext *moc = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Catalog" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)]]];
    NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:nil];
    NSMutableArray *catalogItems = [NSMutableArray new];
    NSMutableArray *catalogSourceListItems = [NSMutableArray new];
    for (CatalogMO *catalog in fetchResults) {
        MAManifestsViewSourceListItem *item = [MAManifestsViewSourceListItem collectionWithTitle:catalog.title identifier:catalog.title type:ManifestSourceItemTypeFolder];
        item.filterPredicate = [NSPredicate predicateWithFormat:@"ANY catalogStrings == %@", catalog.title];
        [catalogSourceListItems addObject:item];
        [catalogItems addObject:[PXSourceListItem itemWithRepresentedObject:item icon:notepad]];
    }
    
    // Store all of the model objects in an array because each source list item only holds a weak reference to them.
    self.modelObjects = [@[allManifestsItem, recentlyModifiedItem, machineManifestsItem, groupManifestsItem, profileManifestsItem] mutableCopy];
    [self.modelObjects addObjectsFromArray:catalogSourceListItems];
    
    
    
    // Set up our Source List data model used in the Source List data source methods.
    PXSourceListItem *libraryItem = [PXSourceListItem itemWithTitle:[self uppercaseOrCapitalizedHeaderString:@"Repository"] identifier:nil];
    libraryItem.children = @[[PXSourceListItem itemWithRepresentedObject:allManifestsItem icon:inbox],
                             [PXSourceListItem itemWithRepresentedObject:recentlyModifiedItem icon:calendar]];
    
    PXSourceListItem *manifestTypesItem = [PXSourceListItem itemWithTitle:[self uppercaseOrCapitalizedHeaderString:@"Manifest Types"] identifier:nil];
    manifestTypesItem.children = @[[PXSourceListItem itemWithRepresentedObject:machineManifestsItem icon:document],
                                   [PXSourceListItem itemWithRepresentedObject:groupManifestsItem icon:documents],
                                   [PXSourceListItem itemWithRepresentedObject:profileManifestsItem icon:documentDownload],
                                   ];
    
    PXSourceListItem *catalogsItem = [PXSourceListItem itemWithTitle:[self uppercaseOrCapitalizedHeaderString:@"Catalogs"] identifier:nil];
    catalogsItem.children = [NSArray arrayWithArray:catalogItems];
    
    PXSourceListItem *directoriesItem = [self directoriesItem];
    
    [self.sourceListItems addObject:libraryItem];
    [self.sourceListItems addObject:manifestTypesItem];
    [self.sourceListItems addObject:catalogsItem];
    [self.sourceListItems addObject:directoriesItem];
}

- (NSString *)uppercaseOrCapitalizedHeaderString:(NSString *)headerTitle
{
    if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_9) {
        /* On a 10.9 - 10.9.x system */
        return [headerTitle uppercaseString];
    } else {
        /* 10.10 or later system */
        return [headerTitle capitalizedString];
    }
}

- (PXSourceListItem *)directoriesItem
{
    NSURL *mainManifestsURL = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] manifestsURL];
    PXSourceListItem *directoriesItem = [PXSourceListItem itemWithTitle:[self uppercaseOrCapitalizedHeaderString:@"Directories"] identifier:nil];
    NSMutableArray *newChildren = [NSMutableArray new];
    NSMutableArray *newRepresentedObjects = [NSMutableArray new];
    
    NSImage *folderImage = [NSImage imageNamed:@"folder"];
    
    NSString *newTitle;
    [mainManifestsURL getResourceValue:&newTitle forKey:NSURLNameKey error:nil];
    MAManifestsViewSourceListItem *item = [MAManifestsViewSourceListItem collectionWithTitle:newTitle identifier:newTitle type:ManifestSourceItemTypeFolder];
    item.filterPredicate = [NSPredicate predicateWithFormat:@"manifestParentDirectoryURL == %@", mainManifestsURL];
    item.representedFileURL = mainManifestsURL;
    [newChildren addObject:[PXSourceListItem itemWithRepresentedObject:item icon:folderImage]];
    [newRepresentedObjects addObject:item];
    
    NSArray *keysToget = [NSArray arrayWithObjects:NSURLNameKey, NSURLLocalizedNameKey, NSURLIsDirectoryKey, nil];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *pkgsInfoDirEnum = [fm enumeratorAtURL:[(MAMunkiAdmin_AppDelegate *)[NSApp delegate] manifestsURL] includingPropertiesForKeys:keysToget options:(NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:nil];
    for (NSURL *anURL in pkgsInfoDirEnum)
    {
        NSNumber *isDir;
        [anURL getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
        if ([isDir boolValue]) {
            
            
            NSString *newTitle;
            [anURL getResourceValue:&newTitle forKey:NSURLNameKey error:nil];
            MAManifestsViewSourceListItem *item = [MAManifestsViewSourceListItem collectionWithTitle:newTitle identifier:newTitle type:ManifestSourceItemTypeFolder];
            item.filterPredicate = [NSPredicate predicateWithFormat:@"manifestParentDirectoryURL == %@", anURL];
            item.representedFileURL = anURL;
            
            NSURL *parentDirectory = [anURL URLByDeletingLastPathComponent];
            
            NSArray *parentURLs = [newChildren filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"representedObject.representedFileURL == %@", parentDirectory]];
            if ([parentURLs count] > 0) {
                PXSourceListItem *parent = parentURLs[0];
                [parent addChildItem:[PXSourceListItem itemWithRepresentedObject:item icon:folderImage]];
            }
            [newRepresentedObjects addObject:item];
        }
    }
    directoriesItem.children = [NSArray arrayWithArray:newChildren];
    [self.modelObjects addObjectsFromArray:newRepresentedObjects];
    return directoriesItem;
}

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


- (void)sourceListSelectionDidChange:(NSNotification *)notification
{
    if ([self.sourceList selectedRow] >= 0) {
        id selectedItem = [self.sourceList itemAtRow:[self.sourceList selectedRow]];
        NSPredicate *productFilter = [(MAManifestsViewSourceListItem *)[selectedItem representedObject] filterPredicate];
        self.manifestsArrayController.filterPredicate = productFilter;
        
        [self setDetailView:self.manifestsListView];
        
        NSArray *productSortDescriptors = [(MAManifestsViewSourceListItem *)[selectedItem representedObject] sortDescriptors];
        
        if (productSortDescriptors != nil) {
            [self.manifestsArrayController setSortDescriptors:productSortDescriptors];
        } else {
            //[self.manifestsArrayController setSortDescriptors:self.defaultSortDescriptors];
        }
    }
}

- (BOOL)sourceList:(PXSourceList *)aSourceList isGroupAlwaysExpanded:(id)group
{
    return NO;
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
    
    // Only allow us to edit the user created items.
    BOOL isTitleEditable = [collection isKindOfClass:[MAManifestsViewSourceListItem class]] && collection.type == ManifestSourceItemTypeUserCreated;
    cellView.textField.editable = isTitleEditable;
    cellView.textField.selectable = isTitleEditable;
    
    cellView.textField.stringValue = sourceListItem.title ? sourceListItem.title : [sourceListItem.representedObject title];
    cellView.imageView.image = [item icon];
    cellView.badgeView.hidden = YES;
    //cellView.badgeView.badgeValue = ...;
    
    return cellView;
}

-(BOOL)sourceList:(PXSourceList *)aSourceList shouldShowOutlineCellForItem:(id)item
{
    /*
     Don't show disclosure triangle for subitems
     */
    if ([aSourceList levelForItem:item] == 0) {
        return YES;
    } else {
        return NO;
    }
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
     Resize only the right side of the splitview
     */
    if (sender == self.mainSplitView) {
        
        NSView *left = [sender subviews][0];
        NSView *right = [sender subviews][1];
        CGFloat dividerThickness = [sender dividerThickness];
        NSRect newFrame = [sender frame];
        NSRect leftFrame = [left frame];
        NSRect rightFrame = [right frame];
        
        rightFrame.size.height = newFrame.size.height;
        rightFrame.size.width = newFrame.size.width - leftFrame.size.width - dividerThickness;
        rightFrame.origin = NSMakePoint(leftFrame.size.width + dividerThickness, 0);
        
        leftFrame.size.height = newFrame.size.height;
        leftFrame.origin.x = 0;
        
        [left setFrame:leftFrame];
        [right setFrame:rightFrame];
    }
    
}


@end
