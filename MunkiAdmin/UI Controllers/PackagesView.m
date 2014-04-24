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
#import "MACoreDataManager.h"
#import "MunkiAdmin_AppDelegate.h"
#import "MARequestStringValueController.h"

#define kMinSplitViewWidth      200.0f
#define kMaxSplitViewWidth      400.0f
#define kDefaultSplitViewWidth  300.0f
#define kMinSplitViewHeight     80.0f
#define kMaxSplitViewHeight     400.0f

@interface PackagesView ()

@end

@implementation PackagesView


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
    /*
     Update the mainCompoundPredicate everytime the subcomponents are updated
     */
    if ([key isEqualToString:@"mainCompoundPredicate"])
    {
        NSSet *affectingKeys = [NSSet setWithObjects:@"packagesMainFilterPredicate", @"searchFieldPredicate", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }
	
    return keyPaths;
}


- (NSPredicate *)mainCompoundPredicate
{
    /*
     Combine the selected source list item predicate and the possible search field predicate
     */
    return [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:self.packagesMainFilterPredicate, self.searchFieldPredicate, nil]];
}


- (void)awakeFromNib
{
    self.createNewCategoryController = [[MARequestStringValueController alloc] initWithWindowNibName:@"MARequestStringValueController"];
    self.createNewDeveloperController = [[MARequestStringValueController alloc] initWithWindowNibName:@"MARequestStringValueController"];
    
    [self.packagesTableView setTarget:[NSApp delegate]];
    [self.packagesTableView setDoubleAction:@selector(getInfoAction:)];
    
    [self.packagesTableView setDelegate:self];
    [self.packagesTableView setDataSource:self];
    [self.packagesTableView registerForDraggedTypes:[NSArray arrayWithObject:NSURLPboardType]];
	[self.packagesTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    
    [self.directoriesOutlineView registerForDraggedTypes:[NSArray arrayWithObject:NSURLPboardType]];
    [self.directoriesOutlineView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    [self.directoriesOutlineView setDelegate:self];
    
    // The basic recipe for a sidebar. Note that the selectionHighlightStyle is set to NSTableViewSelectionHighlightStyleSourceList in the nib
    [self.directoriesOutlineView sizeLastColumnToFit];
    //[self.directoriesOutlineView reloadData];
    [self.directoriesOutlineView setFloatsGroupRows:NO];
    
    // NSTableViewRowSizeStyleDefault should be used, unless the user has picked an explicit size. In that case, it should be stored out and re-used.
    [self.directoriesOutlineView setRowSizeStyle:NSTableViewRowSizeStyleDefault];
    
    /*
     Configure sorting
     */
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
    NSSortDescriptor *sortByMunkiName = [NSSortDescriptor sortDescriptorWithKey:@"munki_name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByMunkiVersion = [NSSortDescriptor sortDescriptorWithKey:@"munki_version" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.directoriesTreeController setSortDescriptors:@[sortByIndex, sortByTitle]];
    [self.packagesArrayController setSortDescriptors:@[sortByMunkiName, sortByMunkiVersion]];
    self.defaultSortDescriptors = @[sortByMunkiName, sortByMunkiVersion];
    
    self.rightPlaceHolder.fillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] 
                                                                        endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]];
    
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
        NSMenuItem *mi = nil;
        if ([[col identifier] isEqualToString:@"packagesTableColumnIcon"]) {
            mi = [[NSMenuItem alloc] initWithTitle:@"Icon"
                                            action:@selector(toggleColumn:)
                                     keyEquivalent:@""];
        } else {
            mi = [[NSMenuItem alloc] initWithTitle:[col.headerCell stringValue]
                                            action:@selector(toggleColumn:)
                                     keyEquivalent:@""];
        }
        mi.target = self;
        mi.representedObject = col;
        [menu addItem:mi];
    }
    menu.delegate = self;
    self.packagesTableView.headerView.menu = menu;
    
    /*
     Create menu for the source list
     */
    NSMenu *sourceListMenu = [[NSMenu alloc] initWithTitle:@""];
    NSMenuItem *newCategoryMenuItem = [[NSMenuItem alloc] initWithTitle:@"New Category..."
                                                                 action:@selector(createNewCategory)
                                                          keyEquivalent:@""];
    newCategoryMenuItem.target = self;
    [sourceListMenu addItem:newCategoryMenuItem];
    
    NSMenuItem *renameCategoryMenuItem = [[NSMenuItem alloc] initWithTitle:@"Rename Category..."
                                                                 action:@selector(renameCategory)
                                                          keyEquivalent:@""];
    renameCategoryMenuItem.target = self;
    [sourceListMenu addItem:renameCategoryMenuItem];
    
    NSMenuItem *newDeveloperMenuItem = [[NSMenuItem alloc] initWithTitle:@"New Developer..."
                                                                    action:@selector(createNewDeveloper)
                                                             keyEquivalent:@""];
    newDeveloperMenuItem.target = self;
    [sourceListMenu addItem:newDeveloperMenuItem];
    
    NSMenuItem *renameDeveloperMenuItem = [[NSMenuItem alloc] initWithTitle:@"Rename Developer..."
                                                                  action:@selector(renameDeveloper)
                                                           keyEquivalent:@""];
    renameDeveloperMenuItem.target = self;
    [sourceListMenu addItem:renameDeveloperMenuItem];
    
    sourceListMenu.delegate = self;
    sourceListMenu.autoenablesItems = NO;
    self.directoriesOutlineView.menu = sourceListMenu;
    
    /*
     Set the target and action for path controls (pkginfo and installer item)
     */
    [self.packageInfoPathControl setTarget:self];
    [self.packageInfoPathControl setAction:@selector(didSelectPathControlItem:)];
    [self.installerItemPathControl setTarget:self];
    [self.installerItemPathControl setAction:@selector(didSelectPathControlItem:)];
}

- (void)toggleColumn:(id)sender
{
	NSTableColumn *col = [sender representedObject];
	[col setHidden:![col isHidden]];
}

- (void)menuWillOpen:(NSMenu *)menu
{
    /*
     The column header menu
     */
    if (menu == self.packagesTableView.headerView.menu) {
        for (NSMenuItem *mi in menu.itemArray) {
            NSTableColumn *col = [mi representedObject];
            [mi setState:col.isHidden ? NSOffState : NSOnState];
        }
    }
    
    /*
     The source list menu
     */
    else if (menu == self.directoriesOutlineView.menu) {
        NSInteger clickedRow = [self.directoriesOutlineView clickedRow];
        id clickedObject = [[self.directoriesOutlineView itemAtRow:clickedRow] representedObject];
        for (NSMenuItem *menuItem in menu.itemArray) {
            [menuItem setEnabled:NO];
        }
        if ([clickedObject isKindOfClass:[CategorySourceListItemMO class]]) {
            /*
             Clicked on category objects
             */
            for (NSMenuItem *menuItem in menu.itemArray) {
                if ([[clickedObject title] isEqualToString:@"Uncategorized"] && [menuItem.title isEqualToString:@"Rename Category..."]) {
                    [menuItem setEnabled:NO];
                } else if ([menuItem.title isEqualToString:@"New Category..."] || [menuItem.title isEqualToString:@"Rename Category..."]) {
                    [menuItem setEnabled:YES];
                } else {
                    [menuItem setEnabled:NO];
                }
            }
        } else if ([clickedObject isKindOfClass:[DeveloperSourceListItemMO class]]) {
            /*
             Clicked on developer objects
             */
            for (NSMenuItem *menuItem in menu.itemArray) {
                if ([[clickedObject title] isEqualToString:@"Unknown"] && [menuItem.title isEqualToString:@"Rename Developer..."]) {
                    [menuItem setEnabled:NO];
                } else if ([menuItem.title isEqualToString:@"New Developer..."] || [menuItem.title isEqualToString:@"Rename Developer..."]) {
                    [menuItem setEnabled:YES];
                } else {
                    [menuItem setEnabled:NO];
                }
            }
        } else {
            for (NSMenuItem *menuItem in menu.itemArray) {
                [menuItem setEnabled:NO];
            }
        }
    }
}

- (void)renameCategory
{
    /*
     Get the category item that was right-clicked
     */
    NSInteger clickedRow = [self.directoriesOutlineView clickedRow];
    CategorySourceListItemMO *clickedObject = [[self.directoriesOutlineView itemAtRow:clickedRow] representedObject];
    CategoryMO *clickedCategory = clickedObject.categoryReference;
    
    /*
     Ask for a new title
     */
    [self.createNewCategoryController setDefaultValues];
    self.createNewCategoryController.windowTitleText = @"Rename Category";
    self.createNewCategoryController.titleText = @"Rename Category";
    self.createNewCategoryController.okButtonTitle = @"Rename";
    self.createNewCategoryController.labelText = @"New Name:";
    self.createNewCategoryController.descriptionText = [NSString stringWithFormat:@"Enter new name for the \"%@\" category. The category will be renamed in all referencing pkginfo files.", clickedObject.title];
    self.createNewCategoryController.stringValue = clickedObject.title;
    NSWindow *window = [self.createNewCategoryController window];
    NSInteger result = [NSApp runModalForWindow:window];
    
    /*
     Perform the actual rename
     */
    if (result == NSModalResponseOK) {
        [[MACoreDataManager sharedManager] renameCategory:clickedCategory
                                                 newTitle:self.createNewCategoryController.stringValue
                                   inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
        [[NSApp delegate] configureSourceListCategoriesSection];
        [self.directoriesTreeController rearrangeObjects];
    }
}


- (void)createNewCategory
{
    [self.createNewCategoryController setDefaultValues];
    self.createNewCategoryController.windowTitleText = @"New Category";
    self.createNewCategoryController.titleText = @"New Category";
    self.createNewCategoryController.okButtonTitle = @"Create";
    self.createNewCategoryController.labelText = @"Name:";
    self.createNewCategoryController.descriptionText = @"Enter name for new category. The category is written in to the pkginfo files and empty categories will not be saved when MunkiAdmin quits.";
    NSWindow *window = [self.createNewCategoryController window];
    NSInteger result = [NSApp runModalForWindow:window];
    
    if (result == NSModalResponseOK) {
        [[MACoreDataManager sharedManager] createCategoryWithTitle:self.createNewCategoryController.stringValue
                                            inManagedObjectContext:nil];
        [[NSApp delegate] configureSourceListCategoriesSection];
        [self.directoriesTreeController rearrangeObjects];
        
    }
    [self.createNewCategoryController setDefaultValues];
}


- (void)renameDeveloper
{
    /*
     Get the category item that was right-clicked
     */
    NSInteger clickedRow = [self.directoriesOutlineView clickedRow];
    DeveloperSourceListItemMO *clickedObject = [[self.directoriesOutlineView itemAtRow:clickedRow] representedObject];
    DeveloperMO *clickedDeveloper = clickedObject.developerReference;
    
    /*
     Ask for a new title
     */
    [self.createNewDeveloperController setDefaultValues];
    self.createNewDeveloperController.windowTitleText = @"Rename Developer";
    self.createNewDeveloperController.titleText = @"Rename Developer";
    self.createNewDeveloperController.okButtonTitle = @"Rename";
    self.createNewDeveloperController.labelText = @"New Name:";
    self.createNewDeveloperController.descriptionText = [NSString stringWithFormat:@"Enter new name for the \"%@\" developer. The developer will be renamed in all referencing pkginfo files.", clickedObject.title];
    self.createNewDeveloperController.stringValue = clickedObject.title;
    NSWindow *window = [self.createNewDeveloperController window];
    NSInteger result = [NSApp runModalForWindow:window];
    
    /*
     Perform the actual rename
     */
    if (result == NSModalResponseOK) {
        [[MACoreDataManager sharedManager] renameDeveloper:clickedDeveloper
                                                 newTitle:self.createNewDeveloperController.stringValue
                                   inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
        [[NSApp delegate] configureSourceListDevelopersSection];
        [self.directoriesTreeController rearrangeObjects];
    }
    [self.createNewDeveloperController setDefaultValues];
}


- (void)createNewDeveloper
{
    [self.createNewDeveloperController setDefaultValues];
    self.createNewDeveloperController.windowTitleText = @"New Developer";
    self.createNewDeveloperController.titleText = @"New Developer";
    self.createNewDeveloperController.okButtonTitle = @"Create";
    self.createNewDeveloperController.labelText = @"Name:";
    self.createNewDeveloperController.descriptionText = @"Enter name for new developer. The developer is written in to the pkginfo files and empty developers will not be saved when MunkiAdmin quits.";
    NSWindow *window = [self.createNewDeveloperController window];
    NSInteger result = [NSApp runModalForWindow:window];
    
    if (result == NSModalResponseOK) {
        [[MACoreDataManager sharedManager] createDeveloperWithTitle:self.createNewDeveloperController.stringValue inManagedObjectContext:nil];
        [[NSApp delegate] configureSourceListDevelopersSection];
        [self.directoriesTreeController rearrangeObjects];
        
    }
    [self.createNewDeveloperController setDefaultValues];
}

- (IBAction)createNewCategoryAction:(id)sender
{
    [self createNewCategory];
}


#pragma mark -
#pragma mark NSOutlineView view delegates

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    /*
     Source list selection changed, update the package list filter predicate
     */
    NSArray *selectedSourceListItems = [self.directoriesTreeController selectedObjects];
    if ([selectedSourceListItems count] > 0) {
        id selectedItem = [selectedSourceListItems objectAtIndex:0];
        NSPredicate *productFilter = [selectedItem filterPredicate];
        NSSortDescriptor *productSort = [selectedItem sortDescriptor];
        [self setPackagesMainFilterPredicate:productFilter];
        if (productSort != nil) {
            [self.packagesArrayController setSortDescriptors:@[productSort]];
        } else {
            [self.packagesArrayController setSortDescriptors:self.defaultSortDescriptors];
        }
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    if ([[item representedObject] isGroupItemValue]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSView *)outlineView:(NSOutlineView *)ov viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    NSTableCellView *view = nil;
    
    if ([[item representedObject] isGroupItemValue]) {
        view = [ov makeViewWithIdentifier:@"HeaderCell" owner:self];
    } else {
        view = [ov makeViewWithIdentifier:@"DataCell" owner:self];
    }
    
    return view;
}

/*
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
 */

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
    }
    
    return shouldMove;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)proposedParentItem childIndex:(NSInteger)index
{
    if (outlineView == self.directoriesOutlineView) {
        NSArray *dragTypes = [[info draggingPasteboard] types];
        if ([dragTypes containsObject:NSURLPboardType]) {
            
            if ([[proposedParentItem representedObject] isKindOfClass:[DirectoryMO class]]) {
            
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
            } else if ([[proposedParentItem representedObject] isKindOfClass:[CategorySourceListItemMO class]]) {
                CategorySourceListItemMO *targetCategorySourceList = [proposedParentItem representedObject];
                
                NSPasteboard *pasteboard = [info draggingPasteboard];
                NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
                NSDictionary *options = [NSDictionary dictionaryWithObject:
                                         [NSNumber numberWithBool:NO] forKey:NSPasteboardURLReadingFileURLsOnlyKey];
                NSArray *urls = [pasteboard readObjectsForClasses:classes options:options];
                for (NSURL *uri in urls) {
                    NSManagedObjectContext *moc = [self.packagesArrayController managedObjectContext];
                    NSManagedObjectID *objectID = [[moc persistentStoreCoordinator] managedObjectIDForURIRepresentation:uri];
                    PackageMO *droppedPackage = (PackageMO *)[moc objectRegisteredForID:objectID];
                    
                    if (targetCategorySourceList.categoryReference != nil) {
                        //NSLog(@"Existing category: %@, New category: %@", droppedPackage.category.title, targetCategorySourceList.title);
                        droppedPackage.category = targetCategorySourceList.categoryReference;
                    } else {
                        //NSLog(@"Existing category: %@, New category: None", droppedPackage.category.title);
                        droppedPackage.category = nil;
                    }
                }
            } else if ([[proposedParentItem representedObject] isKindOfClass:[DeveloperSourceListItemMO class]]) {
                DeveloperSourceListItemMO *targetCategorySourceList = [proposedParentItem representedObject];
                
                NSPasteboard *pasteboard = [info draggingPasteboard];
                NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
                NSDictionary *options = [NSDictionary dictionaryWithObject:
                                         [NSNumber numberWithBool:NO] forKey:NSPasteboardURLReadingFileURLsOnlyKey];
                NSArray *urls = [pasteboard readObjectsForClasses:classes options:options];
                for (NSURL *uri in urls) {
                    NSManagedObjectContext *moc = [self.packagesArrayController managedObjectContext];
                    NSManagedObjectID *objectID = [[moc persistentStoreCoordinator] managedObjectIDForURIRepresentation:uri];
                    PackageMO *droppedPackage = (PackageMO *)[moc objectRegisteredForID:objectID];
                    
                    if (targetCategorySourceList.developerReference != nil) {
                        droppedPackage.developer = targetCategorySourceList.developerReference;
                    } else {
                        droppedPackage.developer = nil;
                    }
                }
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
        if (([[item representedObject] isKindOfClass:[CategorySourceListItemMO class]])) {
            return NSDragOperationMove;
        }
        else if (![targetDir.type isEqualToString:@"regular"]) {
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
            
            NSMutableArray *temporarySupportedURLs = [[NSMutableArray alloc] init];
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
