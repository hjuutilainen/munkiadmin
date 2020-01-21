//
//  PackagesView.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 27.2.2012.
//
// This class contains code provided by Agile Monks, LLC.
// http://cocoa.agilemonks.com/2011/09/25/add-a-contextual-menu-to-hideshow-columns-in-an-nstableview/


#import "MAPackagesView.h"
#import "DataModelHeaders.h"
#import "MAMunkiRepositoryManager.h"
#import "MACoreDataManager.h"
#import "MAMunkiAdmin_AppDelegate.h"
#import "MARequestStringValueController.h"
#import "MAIconEditor.h"
#import "MAIconChooser.h"
#import "MAIconBatchExtractor.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

#define kMinSplitViewWidth      200.0f
#define kMaxSplitViewWidth      400.0f
#define kDefaultSplitViewWidth  300.0f
#define kMinSplitViewHeight     80.0f
#define kMaxSplitViewHeight     400.0f

@interface MAPackagesView ()

@end

@implementation MAPackagesView


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
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    self.createNewCategoryController = [[MARequestStringValueController alloc] initWithWindowNibName:@"MARequestStringValueController"];
    self.createNewDeveloperController = [[MARequestStringValueController alloc] initWithWindowNibName:@"MARequestStringValueController"];
    self.iconEditor = [[MAIconEditor alloc] initWithWindowNibName:@"MAIconEditor"];
    self.iconChooser = [[MAIconChooser alloc] initWithWindowNibName:@"MAIconChooser"];
    self.iconBatchExtractor = [[MAIconBatchExtractor alloc] initWithWindowNibName:@"MAIconBatchExtractor"];
    
    [self.packagesTableView setTarget:(MAMunkiAdmin_AppDelegate *)[NSApp delegate]];
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
    NSSortDescriptor *sortByMunkiDisplayName = [NSSortDescriptor sortDescriptorWithKey:@"munki_display_name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByMunkiVersion = [NSSortDescriptor sortDescriptorWithKey:@"munki_version" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.directoriesTreeController setSortDescriptors:@[sortByIndex, sortByTitle]];
    self.defaultSortDescriptors = @[sortByMunkiName, sortByMunkiVersion, sortByMunkiDisplayName];
    
    self.nameColumn.sortDescriptorPrototype = sortByMunkiName;
    self.versionColumn.sortDescriptorPrototype = sortByMunkiVersion;
    self.displayNameColumn.sortDescriptorPrototype = sortByMunkiDisplayName;
    self.descriptionColumn.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:@"munki_description" ascending:YES selector:@selector(localizedStandardCompare:)];
    self.adminNotesColumn.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:@"munki_notes" ascending:YES selector:@selector(localizedStandardCompare:)];
    self.minOSColumn.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:@"munki_minimum_os_version" ascending:YES selector:@selector(localizedStandardCompare:)];
    self.maxOSColumn.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:@"munki_maximum_os_version" ascending:YES selector:@selector(localizedStandardCompare:)];
    self.catalogsColumn.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:@"catalogsDescriptionString" ascending:YES selector:@selector(localizedStandardCompare:)];
    self.sizeColumn.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:@"munki_installer_item_size" ascending:YES selector:@selector(compare:)];
    self.modifiedDateColumn.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:@"packageInfoDateModified" ascending:YES];
    self.createdDateColumn.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:@"packageInfoDateCreated" ascending:YES];
    
    [self.descriptionTextView setFont:[NSFont systemFontOfSize:11.0]];
    [self.notesTextView setFont:[NSFont systemFontOfSize:11.0]];
    
    /*
     Configure the main triple split view (sourcelist | packagelist | info)
     */
    float rightFrameWidth = kDefaultSplitViewWidth;
	CGFloat dividerThickness = [self.tripleSplitView dividerThickness];
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
    
    self.categoriesSubMenu.delegate = self;
    self.developersSubMenu.delegate = self;
    self.iconSubMenu.delegate = self;
    self.iconSubMenu.autoenablesItems = NO;
    self.catalogsSubMenu.delegate = self;
    self.catalogsSubMenu.autoenablesItems = NO;
    
    /*
     Create a contextual menu for customizing table columns
     */
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    NSSortDescriptor *sortByHeaderString = [NSSortDescriptor sortDescriptorWithKey:@"headerCell.stringValue" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray *tableColumnsSorted = [self.packagesTableView.tableColumns sortedArrayUsingDescriptors:@[sortByHeaderString]];
    for (NSTableColumn *col in tableColumnsSorted) {
        NSMenuItem *mi = nil;
        if ([[col identifier] isEqualToString:@"packagesTableColumnIcon"]) {
            mi = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Icon", @"")
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

- (IBAction)editIconAction:(id)sender
{
    PackageMO *firstPackage = self.packagesArrayController.selectedObjects[0];
    self.iconEditor.packagesToEdit = self.packagesArrayController.selectedObjects;
    self.iconEditor.currentImage = firstPackage.iconImage.imageRepresentation;
    
    NSWindow *window = [self.iconEditor window];
    NSInteger result = [NSApp runModalForWindow:window];
    
    if (result == NSModalResponseOK) {
        
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
    self.createNewCategoryController.windowTitleText = @"";
    self.createNewCategoryController.titleText = [NSString stringWithFormat:@"Rename \"%@\"?", clickedObject.title];;
    self.createNewCategoryController.okButtonTitle = @"Rename";
    self.createNewCategoryController.labelText = @"New Name:";
    self.createNewCategoryController.descriptionText = [NSString stringWithFormat:@"Enter new name for the category \"%@\". The category will be renamed in all referencing pkginfo files.", clickedObject.title];
    self.createNewCategoryController.stringValue = clickedObject.title;
    NSWindow *window = [self.createNewCategoryController window];
    NSInteger result = [NSApp runModalForWindow:window];
    
    /*
     Perform the actual rename
     */
    if (result == NSModalResponseOK) {
        MACoreDataManager *coreDataManager = [MACoreDataManager sharedManager];
        NSManagedObjectContext *mainContext = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
        [coreDataManager renameCategory:clickedCategory
                               newTitle:self.createNewCategoryController.stringValue
                 inManagedObjectContext:mainContext];
        [coreDataManager configureSourceListCategoriesSection:mainContext];
        [self.directoriesTreeController rearrangeObjects];
    }
}


- (void)deleteCategory
{
    /*
     Get the category item that was right-clicked
     */
    NSInteger clickedRow = [self.directoriesOutlineView clickedRow];
    CategorySourceListItemMO *clickedObject = [[self.directoriesOutlineView itemAtRow:clickedRow] representedObject];
    CategoryMO *clickedCategory = clickedObject.categoryReference;
    
    NSAlert *alert = [[NSAlert alloc] init];
    NSString * _Nonnull messageText = [NSString stringWithFormat:NSLocalizedString(@"Delete \"%@\"?", @""), clickedObject.title];
    alert.messageText = messageText;
    NSString * _Nonnull informativeText = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to delete the category \"%@\"? Category reference will be removed from any packages using it.", @""), clickedObject.title];
    alert.informativeText = informativeText;
    [alert addButtonWithTitle:NSLocalizedString(@"Delete", @"")];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    NSInteger result = [alert runModal];
    
    /*
     Perform the actual deletion
     */
    if (result == NSAlertFirstButtonReturn) {
        MACoreDataManager *coreDataManager = [MACoreDataManager sharedManager];
        NSManagedObjectContext *mainContext = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
        [coreDataManager deleteCategory:clickedCategory inManagedObjectContext:mainContext];
        [coreDataManager configureSourceListCategoriesSection:mainContext];
        [self.directoriesTreeController rearrangeObjects];
    } else {
        // User cancelled
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
        MACoreDataManager *cdManager = [MACoreDataManager sharedManager];
        NSManagedObjectContext *mainContext = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
        [cdManager createCategoryWithTitle:self.createNewCategoryController.stringValue inManagedObjectContext:mainContext];
        [cdManager configureSourceListCategoriesSection:mainContext];
        [self.directoriesTreeController rearrangeObjects];
        
    }
    [self.createNewCategoryController setDefaultValues];
}

- (void)createNewCategoryAndAddSelectedPackages
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
        MACoreDataManager *cdManager = [MACoreDataManager sharedManager];
        NSManagedObjectContext *mainContext = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
        CategoryMO *newCategory = [cdManager createCategoryWithTitle:self.createNewCategoryController.stringValue
                                                                      inManagedObjectContext:mainContext];
        for (PackageMO *package in self.packagesArrayController.selectedObjects) {
            package.category = newCategory;
            package.hasUnstagedChangesValue = YES;
        }
        [cdManager configureSourceListCategoriesSection:mainContext];
        [self.directoriesTreeController rearrangeObjects];
        
    }
    [self.createNewCategoryController setDefaultValues];
}

- (void)addSelectedPackagesToCategory:(CategoryMO *)category
{
    for (PackageMO *package in self.packagesArrayController.selectedObjects) {
        package.category = category;
        package.hasUnstagedChangesValue = YES;
    }
}

- (void)addSelectedPackagesToCategoryAction:(id)sender
{
    CategoryMO *category = [sender representedObject];
    [self addSelectedPackagesToCategory:category];
}


- (void)addSelectedPackagesToCatalogAction:(id)sender
{
    CatalogMO *catalog = [sender representedObject];
    for (PackageMO *package in self.packagesArrayController.selectedObjects) {
        for (PackageInfoMO *packageInfo in package.packageInfos) {
            if (packageInfo.catalog == catalog) {
                packageInfo.isEnabledForCatalogValue = YES;
            }
        }
        package.hasUnstagedChangesValue = YES;
    }
}

- (void)removeSelectedPackagesFromCatalogAction:(id)sender
{
    CatalogMO *catalog = [sender representedObject];
    for (PackageMO *package in self.packagesArrayController.selectedObjects) {
        for (PackageInfoMO *packageInfo in package.packageInfos) {
            if (packageInfo.catalog == catalog) {
                packageInfo.isEnabledForCatalogValue = NO;
            }
        }
        package.hasUnstagedChangesValue = YES;
    }
}

- (void)enableAllCatalogsAction:(id)sender
{
    for (PackageMO *package in self.packagesArrayController.selectedObjects) {
        for (PackageInfoMO *packageInfo in package.packageInfos) {
            packageInfo.isEnabledForCatalogValue = YES;
        }
        package.hasUnstagedChangesValue = YES;
    }
}

- (void)disableAllCatalogsAction:(id)sender
{
    for (PackageMO *package in self.packagesArrayController.selectedObjects) {
        for (PackageInfoMO *packageInfo in package.packageInfos) {
            packageInfo.isEnabledForCatalogValue = NO;
        }
        package.hasUnstagedChangesValue = YES;
    }
}

- (void)assignSelectedPackagesToDeveloper:(DeveloperMO *)developer
{
    for (PackageMO *package in self.packagesArrayController.selectedObjects) {
        package.developer = developer;
        package.hasUnstagedChangesValue = YES;
    }
}

- (void)assignSelectedPackagesToDeveloperAction:(id)sender
{
    DeveloperMO *developer = [sender representedObject];
    [self assignSelectedPackagesToDeveloper:developer];
}

- (void)createNewDeveloperAndAssignSelectedPackages
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
        MACoreDataManager *cdManager = [MACoreDataManager sharedManager];
        NSManagedObjectContext *mainContext = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
        DeveloperMO *newDeveloper = [cdManager createDeveloperWithTitle:self.createNewDeveloperController.stringValue inManagedObjectContext:mainContext];
        for (PackageMO *package in self.packagesArrayController.selectedObjects) {
            package.developer = newDeveloper;
            package.hasUnstagedChangesValue = YES;
        }
        [cdManager configureSourceListDevelopersSection:mainContext];
        [self.directoriesTreeController rearrangeObjects];
        
    }
    [self.createNewDeveloperController setDefaultValues];
}


- (void)renameDeveloper
{
    /*
     Get the developer item that was right-clicked
     */
    NSInteger clickedRow = [self.directoriesOutlineView clickedRow];
    DeveloperSourceListItemMO *clickedObject = [[self.directoriesOutlineView itemAtRow:clickedRow] representedObject];
    DeveloperMO *clickedDeveloper = clickedObject.developerReference;
    
    /*
     Ask for a new title
     */
    [self.createNewDeveloperController setDefaultValues];
    self.createNewDeveloperController.windowTitleText = @"";
    self.createNewDeveloperController.titleText = [NSString stringWithFormat:@"Rename \"%@\"?", clickedObject.title];
    self.createNewDeveloperController.okButtonTitle = @"Rename";
    self.createNewDeveloperController.labelText = @"New Name:";
    self.createNewDeveloperController.descriptionText = [NSString stringWithFormat:@"Enter new name for the developer \"%@\". The developer will be renamed in all referencing pkginfo files.", clickedObject.title];
    self.createNewDeveloperController.stringValue = clickedObject.title;
    NSWindow *window = [self.createNewDeveloperController window];
    NSInteger result = [NSApp runModalForWindow:window];
    
    /*
     Perform the actual rename
     */
    if (result == NSModalResponseOK) {
        MACoreDataManager *cdManager = [MACoreDataManager sharedManager];
        NSManagedObjectContext *mainContext = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
        [cdManager renameDeveloper:clickedDeveloper newTitle:self.createNewDeveloperController.stringValue inManagedObjectContext:mainContext];
        [cdManager configureSourceListDevelopersSection:mainContext];
        [self.directoriesTreeController rearrangeObjects];
    }
    [self.createNewDeveloperController setDefaultValues];
}


- (void)deleteDeveloper
{
    /*
     Get the developer item that was right-clicked
     */
    NSInteger clickedRow = [self.directoriesOutlineView clickedRow];
    DeveloperSourceListItemMO *clickedObject = [[self.directoriesOutlineView itemAtRow:clickedRow] representedObject];
    DeveloperMO *clickedDeveloper = clickedObject.developerReference;
    
    NSAlert *alert = [[NSAlert alloc] init];
    NSString * _Nonnull messageText = [NSString stringWithFormat:NSLocalizedString(@"Delete \"%@\"?", @""), clickedObject.title];
    alert.messageText = messageText;
    NSString * _Nonnull informativeText = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to delete the developer \"%@\"? The developer will be removed from all referencing pkginfo files.", @""), clickedObject.title];
    alert.informativeText = informativeText;
    [alert addButtonWithTitle:NSLocalizedString(@"Delete", @"")];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    NSInteger result = [alert runModal];
    
    /*
     Perform the actual deletion
     */
    if (result == NSAlertFirstButtonReturn) {
        MACoreDataManager *cdManager = [MACoreDataManager sharedManager];
        NSManagedObjectContext *mainContext = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
        [cdManager deleteDeveloper:clickedDeveloper
                                   inManagedObjectContext:mainContext];
        [cdManager configureSourceListDevelopersSection:mainContext];
        [self.directoriesTreeController rearrangeObjects];
    } else {
        // User cancelled
    }
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
        MACoreDataManager *cdManager = [MACoreDataManager sharedManager];
        NSManagedObjectContext *mainContext = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
        [cdManager createDeveloperWithTitle:self.createNewDeveloperController.stringValue inManagedObjectContext:mainContext];
        [cdManager configureSourceListDevelopersSection:mainContext];
        [self.directoriesTreeController rearrangeObjects];
        
    }
    [self.createNewDeveloperController setDefaultValues];
}

- (IBAction)createNewCategoryAction:(id)sender
{
    [self createNewCategory];
}


- (IBAction)clearCustomIconAction:(id)sender
{
    MAMunkiRepositoryManager *repoManager = [MAMunkiRepositoryManager sharedManager];
    [self.packagesArrayController.selectedObjects enumerateObjectsUsingBlock:^(PackageMO *obj, NSUInteger idx, BOOL *stop) {
        [repoManager clearCustomIconForPackage:obj];
    }];
}

- (IBAction)updateIconHashAction:(id)sender
{
    MAMunkiRepositoryManager *repoManager = [MAMunkiRepositoryManager sharedManager];
    [self.packagesArrayController.selectedObjects enumerateObjectsUsingBlock:^(PackageMO *obj, NSUInteger idx, BOOL *stop) {
        [repoManager updateIconHashForPackage:obj];
    }];
}

- (IBAction)deleteIconHashAction:(id)sender
{
    MAMunkiRepositoryManager *repoManager = [MAMunkiRepositoryManager sharedManager];
    [self.packagesArrayController.selectedObjects enumerateObjectsUsingBlock:^(PackageMO *obj, NSUInteger idx, BOOL *stop) {
        [repoManager deleteIconHashForPackage:obj];
    }];
}

- (IBAction)chooseIconForNameAction:(id)sender
{
    self.iconChooser.packagesToEdit = self.packagesArrayController.selectedObjects;
    self.iconChooser.useInSiblingPackages = YES;
    
    NSWindow *window = [self.iconChooser window];
    NSInteger result = [NSApp runModalForWindow:window];
    
    if (result == NSModalResponseOK) {
        
    }
}

- (IBAction)chooseIconForPackageAction:(id)sender
{
    self.iconChooser.packagesToEdit = self.packagesArrayController.selectedObjects;
    self.iconChooser.useInSiblingPackages = NO;
    
    NSWindow *window = [self.iconChooser window];
    NSInteger result = [NSApp runModalForWindow:window];
    
    if (result == NSModalResponseOK) {
        
    }
}

- (void)batchExtractIcons
{
    NSWindow *window = [self.iconBatchExtractor window];
    [self.iconBatchExtractor resetExtractorStatus];
    NSInteger result = [NSApp runModalForWindow:window];
    if (result == NSModalResponseOK) {
        
    }
}

- (IBAction)batchExtractIconsAction:(id)sender
{
    [self batchExtractIcons];
}

- (IBAction)createIconForNameAction:(id)sender
{
    NSWindow *window = [self.iconEditor window];
    self.iconEditor.packagesToEdit = self.packagesArrayController.selectedObjects;
    self.iconEditor.useInSiblingPackages = YES;
    
    /*
     If all selected packages are using the same icon, show the icon in the image view
     */
    NSArray *iconImages = [self.iconEditor.packagesToEdit valueForKeyPath:@"@distinctUnionOfObjects.iconImage"];
    if ([iconImages count] == 1) {
        IconImageMO *iconImage = iconImages[0];
        [self.iconEditor.imageView setImage:iconImage.imageRepresentation];
    } else {
        [self.iconEditor.imageView setImage:nil];
    }
    
    NSInteger result = [NSApp runModalForWindow:window];
    if (result == NSModalResponseOK) {
        
    }
}

- (IBAction)createIconForPackageAction:(id)sender
{
    NSWindow *window = [self.iconEditor window];
    self.iconEditor.packagesToEdit = self.packagesArrayController.selectedObjects;
    self.iconEditor.useInSiblingPackages = NO;
    
    /*
     If all selected packages are using the same icon, show the icon in the image view
     */
    NSArray *iconImages = [self.iconEditor.packagesToEdit valueForKeyPath:@"@distinctUnionOfObjects.iconImage"];
    if ([iconImages count] == 1) {
        IconImageMO *iconImage = iconImages[0];
        [self.iconEditor.imageView setImage:iconImage.imageRepresentation];
    } else {
        [self.iconEditor.imageView setImage:nil];
    }
    
    NSInteger result = [NSApp runModalForWindow:window];
    if (result == NSModalResponseOK) {
        
    }
}


#pragma mark -
#pragma mark NSMenu delegates


- (void)toggleColumn:(id)sender
{
	NSTableColumn *col = [sender representedObject];
	[col setHidden:![col isHidden]];
}

- (void)developerSubMenuWillOpen:(NSMenu *)menu
{
    [menu removeAllItems];
    
    /*
     Get the developer names for selected packages
     */
    NSArray *selectedPackageDevelopers = [self.packagesArrayController.selectedObjects valueForKeyPath:@"@distinctUnionOfObjects.developer.title"];
    
    /*
     Get selected packages whose developer is nil
     */
    NSPredicate *nilDeveloperPred = [NSPredicate predicateWithFormat:@"developer == %@", [NSNull null]];
    NSArray *nilDeveloperPackages = [self.packagesArrayController.selectedObjects filteredArrayUsingPredicate:nilDeveloperPred];
    
    /*
     Create the first menu items
     */
    NSMenuItem *createAndAddMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"New Developer...", @"")
                                                                  action:@selector(createNewDeveloperAndAssignSelectedPackages)
                                                           keyEquivalent:@""];
    createAndAddMenuItem.target = self;
    [menu addItem:createAndAddMenuItem];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *unknownDeveloperItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Unknown", @"")
                                                                   action:@selector(assignSelectedPackagesToDeveloperAction:)
                                                            keyEquivalent:@""];
    if ([nilDeveloperPackages count] > 0 && [selectedPackageDevelopers count] == 0) {
        unknownDeveloperItem.state = NSOnState;
    } else if ([nilDeveloperPackages count] > 0 && [selectedPackageDevelopers count] > 0) {
        unknownDeveloperItem.state = NSMixedState;
    } else {
        unknownDeveloperItem.state = NSOffState;
    }
    
    unknownDeveloperItem.target = self;
    [menu addItem:unknownDeveloperItem];
    
    /*
     Create a menu item for each developer object
     */
    NSManagedObjectContext *moc = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Developer" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)]]];
    NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:nil];
    for (DeveloperMO *developer in fetchResults) {
        NSMenuItem *developerItem = [[NSMenuItem alloc] initWithTitle:developer.title
                                                              action:@selector(assignSelectedPackagesToDeveloperAction:)
                                                       keyEquivalent:@""];
        developerItem.representedObject = developer;
        if ([selectedPackageDevelopers count] == 1 && [developer.title isEqualToString:selectedPackageDevelopers[0]]) {
            if ([nilDeveloperPackages count] > 0) {
                developerItem.state = NSMixedState;
            } else {
                developerItem.state = NSOnState;
            }
        } else if ([selectedPackageDevelopers count] > 1 && [selectedPackageDevelopers containsObject:developer.title]) {
            developerItem.state = NSMixedState;
        } else {
            developerItem.state = NSOffState;
        }
        
        developerItem.target = self;
        [menu addItem:developerItem];
    }
}

- (void)categoriesSubMenuWillOpen:(NSMenu *)menu
{
    [menu removeAllItems];
    
    /*
     Get the category titles for selected packages
     */
    NSArray *selectedPackageCategories = [self.packagesArrayController.selectedObjects valueForKeyPath:@"@distinctUnionOfObjects.category.title"];
    
    /*
     Get selected packages whose category is nil
     */
    NSPredicate *nilCategoryPred = [NSPredicate predicateWithFormat:@"category == %@", [NSNull null]];
    NSArray *nilCategoryPackages = [self.packagesArrayController.selectedObjects filteredArrayUsingPredicate:nilCategoryPred];
    
    /*
     Create the first menu items
     */
    NSMenuItem *createAndAddMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"New Category...", @"")
                                                                  action:@selector(createNewCategoryAndAddSelectedPackages)
                                                           keyEquivalent:@""];
    createAndAddMenuItem.target = self;
    [menu addItem:createAndAddMenuItem];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *uncategorizedMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Uncategorized", @"")
                                                                   action:@selector(addSelectedPackagesToCategoryAction:)
                                                            keyEquivalent:@""];
    if ([nilCategoryPackages count] > 0 && [selectedPackageCategories count] == 0) {
        uncategorizedMenuItem.state = NSOnState;
    } else if ([nilCategoryPackages count] > 0 && [selectedPackageCategories count] > 0) {
        uncategorizedMenuItem.state = NSMixedState;
    } else {
        uncategorizedMenuItem.state = NSOffState;
    }
    
    uncategorizedMenuItem.target = self;
    [menu addItem:uncategorizedMenuItem];
    
    /*
     Create a menu item for each category object
     */
    NSManagedObjectContext *moc = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)]]];
    NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:nil];
    for (CategoryMO *category in fetchResults) {
        NSMenuItem *categoryItem = [[NSMenuItem alloc] initWithTitle:category.title
                                                              action:@selector(addSelectedPackagesToCategoryAction:)
                                                       keyEquivalent:@""];
        categoryItem.representedObject = category;
        if ([selectedPackageCategories count] == 1 && [category.title isEqualToString:selectedPackageCategories[0]]) {
            if ([nilCategoryPackages count] > 0) {
                categoryItem.state = NSMixedState;
            } else {
                categoryItem.state = NSOnState;
            }
        } else if ([selectedPackageCategories count] > 1 && [selectedPackageCategories containsObject:category.title]) {
            categoryItem.state = NSMixedState;
        } else {
            categoryItem.state = NSOffState;
        }
        
        categoryItem.target = self;
        [menu addItem:categoryItem];
    }
}

- (void)catalogsSubMenuWillOpen:(NSMenu *)menu
{
    [menu removeAllItems];
    
    NSMenuItem *enableAllCatalogsMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Enable All Catalogs", @"")
                                                                       action:@selector(enableAllCatalogsAction:)
                                                                keyEquivalent:@""];
    [enableAllCatalogsMenuItem setEnabled:YES];
    enableAllCatalogsMenuItem.target = self;
    [menu addItem:enableAllCatalogsMenuItem];
    
    
    NSMenuItem *disableAllCatalogsMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Disable All Catalogs", @"")
                                                                 action:@selector(disableAllCatalogsAction:)
                                                          keyEquivalent:@""];
    
    [disableAllCatalogsMenuItem setEnabled:YES];
    disableAllCatalogsMenuItem.target = self;
    [menu addItem:disableAllCatalogsMenuItem];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    
    /*
     Create a menu item for each catalog object
     */
    NSManagedObjectContext *moc = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Catalog" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)]]];
    NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:nil];
    for (CatalogMO *catalog in fetchResults) {
        
        NSMenuItem *catalogItem = [[NSMenuItem alloc] initWithTitle:catalog.title
                                                              action:nil
                                                       keyEquivalent:@""];
        catalogItem.representedObject = catalog;
        catalogItem.target = self;
        [menu addItem:catalogItem];
        
        
        /*
         Set the state of the menu item
         */
        int numEnabled = 0;
        int numDisabled = 0;
        NSMutableArray *enabledPackageNames = [NSMutableArray new];
        NSMutableArray *disabledPackageNames = [NSMutableArray new];
        for (PackageMO *package in self.packagesArrayController.selectedObjects) {
            if ([[package catalogStrings] containsObject:catalog.title]) {
                [enabledPackageNames addObject:package.titleWithVersion];
                numEnabled++;
            } else {
                [disabledPackageNames addObject:package.titleWithVersion];
                numDisabled++;
            }
        }
        
        if (numDisabled == 0) {
            /*
             All of the selected packages are in this catalog.
             Selecting this menu item should remove packages from catalog.
             */
            catalogItem.action = @selector(removeSelectedPackagesFromCatalogAction:);
            catalogItem.state = NSOnState;
        
        } else if (numEnabled == 0) {
            /*
             None of the selected packages are in this catalog.
             Selecting this menu item should add packages to this catalog.
             */
            catalogItem.action = @selector(addSelectedPackagesToCatalogAction:);
            catalogItem.state = NSOffState;
        
        } else {
            /*
             Some of the selected packages are in this catalog.
             Selecting this menu item should add the missing packages to this catalog.
             
             Additionally create a tooltip to show which packages are enabled/disable.
             */
            NSString *toolTip;
            if (numEnabled > numDisabled) {
                toolTip = [NSString stringWithFormat:@"Packages not in catalog \"%@\":\n- %@",
                           catalog.title,
                           [disabledPackageNames componentsJoinedByString:@"\n- "]];
            } else {
                toolTip = [NSString stringWithFormat:@"Packages in catalog \"%@\":\n- %@",
                           catalog.title,
                           [enabledPackageNames componentsJoinedByString:@"\n- "]];
            }
            catalogItem.toolTip = toolTip;
            
            catalogItem.action = @selector(addSelectedPackagesToCatalogAction:);
            catalogItem.state = NSMixedState;
        }
    }
}

- (void)iconSubMenuWillOpen:(NSMenu *)menu
{
    [menu removeAllItems];
    
    /*
     Get the category titles for selected packages
     */
    NSArray *selectedPackageNames = [self.packagesArrayController.selectedObjects valueForKeyPath:@"@distinctUnionOfObjects.munki_name"];
    
    /*
     Create the menu items
     */
    NSPredicate *iconNotNilPredicate = [NSPredicate predicateWithFormat:@"munki_icon_name != %@", [NSNull null]];
    NSArray *iconNotNilPackages = [self.packagesArrayController.selectedObjects filteredArrayUsingPredicate:iconNotNilPredicate];
    
    
    
    NSMenuItem *batchCreateCustomMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Batch Extract Icons...", @"")
                                                                 action:@selector(batchExtractIconsAction:)
                                                          keyEquivalent:@""];
    
    [batchCreateCustomMenuItem setEnabled:YES];
    batchCreateCustomMenuItem.target = self;
    [menu addItem:batchCreateCustomMenuItem];
    
    
    NSMenuItem *clearCustomMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Clear Custom Icon", @"")
                                                                 action:@selector(clearCustomIconAction:)
                                                          keyEquivalent:@""];
    
    if ([iconNotNilPackages count] > 0) {
        [clearCustomMenuItem setEnabled:YES];
    } else {
        [clearCustomMenuItem setEnabled:NO];
    }
    clearCustomMenuItem.target = self;
    [menu addItem:clearCustomMenuItem];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    /*
     Items for modifying the icon_hash.
     Only visible if option key is down when opening the menu.
     */
    NSEvent *event = [NSApp currentEvent];
    if (([event modifierFlags] & NSEventModifierFlagOption) != 0) {
        NSMenuItem *updateHashMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Update Icon Hash", @"")
                                                                    action:@selector(updateIconHashAction:)
                                                             keyEquivalent:@""];
        [updateHashMenuItem setEnabled:YES];
        updateHashMenuItem.target = self;
        [menu addItem:updateHashMenuItem];
        
        NSMenuItem *deleteHashMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete Icon Hash", @"")
                                                                    action:@selector(deleteIconHashAction:)
                                                             keyEquivalent:@""];
        [deleteHashMenuItem setEnabled:YES];
        deleteHashMenuItem.target = self;
        [menu addItem:deleteHashMenuItem];
        
        [menu addItem:[NSMenuItem separatorItem]];
    }

    if ([selectedPackageNames count] == 1) {
        PackageMO *selectedPackage = self.packagesArrayController.selectedObjects[0];
        
        NSString * _Nonnull chooseIconForNameTitle = [NSString stringWithFormat:NSLocalizedString(@"Choose Existing Icon for Name \"%@\"...", @""), selectedPackageNames[0]];
        NSMenuItem *chooseIconForNameMenuItem = [[NSMenuItem alloc] initWithTitle:chooseIconForNameTitle
                                                                           action:@selector(chooseIconForNameAction:)
                                                                    keyEquivalent:@""];
        
        chooseIconForNameMenuItem.target = self;
        [menu addItem:chooseIconForNameMenuItem];
        
        NSString *menuItemTitle;
        if ([self.packagesArrayController.selectedObjects count] == 1) {
            menuItemTitle = [NSString stringWithFormat:NSLocalizedString(@"Choose Existing Icon for Package %@ %@...", @""), selectedPackage.munki_name, selectedPackage.munki_version];
        } else {
            menuItemTitle = NSLocalizedString(@"Choose Existing Icon for Selected Packages...", @"");
        }
        NSMenuItem *chooseIconForPackageMenuItem = [[NSMenuItem alloc] initWithTitle:menuItemTitle
                                                                              action:@selector(chooseIconForPackageAction:)
                                                                       keyEquivalent:@""];
        
        chooseIconForPackageMenuItem.target = self;
        [menu addItem:chooseIconForPackageMenuItem];
        
        [menu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *createIconForNameMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Create New Icon for Name \"%@\"...", selectedPackageNames[0]]
                                                                           action:@selector(createIconForNameAction:)
                                                                    keyEquivalent:@""];
        
        createIconForNameMenuItem.target = self;
        [menu addItem:createIconForNameMenuItem];
        
        if ([self.packagesArrayController.selectedObjects count] == 1) {
            menuItemTitle = [NSString stringWithFormat:NSLocalizedString(@"Create New Icon for Package %@ %@...", @""), selectedPackage.munki_name, selectedPackage.munki_version];
        } else {
            menuItemTitle = NSLocalizedString(@"Create New Icon for Selected Packages...", @"");
        }
        NSMenuItem *createIconForPackageMenuItem = [[NSMenuItem alloc] initWithTitle:menuItemTitle
                                                                              action:@selector(createIconForPackageAction:)
                                                                       keyEquivalent:@""];
        
        createIconForPackageMenuItem.target = self;
        [menu addItem:createIconForPackageMenuItem];
    } else {
        NSMenuItem *chooseIconForNameMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Choose Existing Icon for Selected Packages...", @"")
                                                                           action:@selector(chooseIconForPackageAction:)
                                                                    keyEquivalent:@""];
        
        chooseIconForNameMenuItem.target = self;
        [menu addItem:chooseIconForNameMenuItem];
        NSMenuItem *createIconForNameMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Create New Icon for Selected Packages...", @"")
                                                                           action:@selector(createIconForPackageAction:)
                                                                    keyEquivalent:@""];
        
        createIconForNameMenuItem.target = self;
        [menu addItem:createIconForNameMenuItem];
    }
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
        [menu removeAllItems];
        
        NSInteger clickedRow = [self.directoriesOutlineView clickedRow];
        id clickedObject = [[self.directoriesOutlineView itemAtRow:clickedRow] representedObject];
        for (NSMenuItem *menuItem in menu.itemArray) {
            [menuItem setEnabled:NO];
        }
        if ([clickedObject isKindOfClass:[CategorySourceListItemMO class]]) {
            /*
             Clicked on category objects
             */
            NSMenuItem *newCategoryMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"New Category...", @"")
                                                                         action:@selector(createNewCategory)
                                                                  keyEquivalent:@""];
            newCategoryMenuItem.target = self;
            [menu addItem:newCategoryMenuItem];
            
            NSMenuItem *renameCategoryMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Rename Category...", @"")
                                                                            action:@selector(renameCategory)
                                                                     keyEquivalent:@""];
            renameCategoryMenuItem.target = self;
            [menu addItem:renameCategoryMenuItem];
            
            NSMenuItem *deleteCategoryMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete Category...", @"")
                                                                            action:@selector(deleteCategory)
                                                                     keyEquivalent:@""];
            deleteCategoryMenuItem.target = self;
            [menu addItem:deleteCategoryMenuItem];
            
            for (NSMenuItem *menuItem in menu.itemArray) {
                if ([[clickedObject title] isEqualToString:NSLocalizedString(@"Uncategorized", @"")] && [menuItem.title isEqualToString:NSLocalizedString(@"Rename Category...", @"")]) {
                    [menuItem setEnabled:NO];
                } else if ([[clickedObject title] isEqualToString:NSLocalizedString(@"Uncategorized", @"")] && [menuItem.title isEqualToString:NSLocalizedString(@"Delete Category...", @"")]) {
                    [menuItem setEnabled:NO];
                } else if ([menuItem.title isEqualToString:NSLocalizedString(@"New Category...", @"")]
                           || [menuItem.title isEqualToString:NSLocalizedString(@"Rename Category...", @"")]
                           || [menuItem.title isEqualToString:NSLocalizedString(@"Delete Category...", @"")]) {
                    [menuItem setEnabled:YES];
                } else {
                    [menuItem setEnabled:NO];
                }
            }
        } else if ([clickedObject isKindOfClass:[DeveloperSourceListItemMO class]]) {
            /*
             Clicked on developer objects
             */
            NSMenuItem *newDeveloperMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"New Developer...", @"")
                                                                          action:@selector(createNewDeveloper)
                                                                   keyEquivalent:@""];
            newDeveloperMenuItem.target = self;
            [menu addItem:newDeveloperMenuItem];
            
            NSMenuItem *renameDeveloperMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Rename Developer...", @"")
                                                                             action:@selector(renameDeveloper)
                                                                      keyEquivalent:@""];
            renameDeveloperMenuItem.target = self;
            [menu addItem:renameDeveloperMenuItem];
            
            NSMenuItem *deleteDeveloperMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete Developer...", @"")
                                                                            action:@selector(deleteDeveloper)
                                                                     keyEquivalent:@""];
            deleteDeveloperMenuItem.target = self;
            [menu addItem:deleteDeveloperMenuItem];
            
            for (NSMenuItem *menuItem in menu.itemArray) {
                if ([[clickedObject title] isEqualToString:@"Unknown"] && [menuItem.title isEqualToString:NSLocalizedString(@"Rename Developer...", @"")]) {
                    [menuItem setEnabled:NO];
                } else if ([[clickedObject title] isEqualToString:@"Unknown"] && [menuItem.title isEqualToString:NSLocalizedString(@"Delete Developer...", @"")]) {
                    [menuItem setEnabled:NO];
                } else if ([menuItem.title isEqualToString:NSLocalizedString(@"New Developer...", @"")]
                           || [menuItem.title isEqualToString:NSLocalizedString(@"Rename Developer...", @"")]
                           || [menuItem.title isEqualToString:NSLocalizedString(@"Delete Developer...", @"")]) {
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
    
    /*
     Packages table view Category submenu
     */
    else if (menu == self.categoriesSubMenu) {
        [self categoriesSubMenuWillOpen:menu];
    }
    
    /*
     Packages table view Developer submenu
     */
    else if (menu == self.developersSubMenu) {
        [self developerSubMenuWillOpen:menu];
    }
    
    /*
     Packages table view Icon submenu
     */
    else if (menu == self.iconSubMenu) {
        [self iconSubMenuWillOpen:menu];
    }
    
    /*
     Packages table view Catalogs submenu
     */
    else if (menu == self.catalogsSubMenu) {
        [self catalogsSubMenuWillOpen:menu];
    }
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
        NSArray *productSortDescriptors = [selectedItem sortDescriptors];
        [self setPackagesMainFilterPredicate:productFilter];
        if (productSortDescriptors != nil) {
            [self.packagesArrayController setSortDescriptors:productSortDescriptors];
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
        view = [ov makeViewWithIdentifier:@"HeaderCell" owner:nil];
    } else {
        view = [ov makeViewWithIdentifier:@"DataCell" owner:nil];
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
        [alert addButtonWithTitle:NSLocalizedString(@"Move", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"Skip", @"")];
        [alert setMessageText:NSLocalizedString(@"Move installer item?", @"")];
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
                NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey : @NO};
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
                    [[MAMunkiRepositoryManager sharedManager] movePackage:droppedPackage toURL:targetURL moveInstaller:allowMove];
                    droppedPackage.hasUnstagedChanges = @YES;
                }
            } else if ([[proposedParentItem representedObject] isKindOfClass:[CategorySourceListItemMO class]]) {
                CategorySourceListItemMO *targetCategorySourceList = [proposedParentItem representedObject];
                
                NSPasteboard *pasteboard = [info draggingPasteboard];
                NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
                NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey : @NO};
                NSArray *urls = [pasteboard readObjectsForClasses:classes options:options];
                for (NSURL *uri in urls) {
                    NSManagedObjectContext *moc = [self.packagesArrayController managedObjectContext];
                    NSManagedObjectID *objectID = [[moc persistentStoreCoordinator] managedObjectIDForURIRepresentation:uri];
                    PackageMO *droppedPackage = (PackageMO *)[moc objectRegisteredForID:objectID];
                    
                    if (targetCategorySourceList.categoryReference != nil) {
                        //DDLogDebug(@"Existing category: %@, New category: %@", droppedPackage.category.title, targetCategorySourceList.title);
                        droppedPackage.category = targetCategorySourceList.categoryReference;
                    } else {
                        //DDLogDebug(@"Existing category: %@, New category: None", droppedPackage.category.title);
                        droppedPackage.category = nil;
                    }
                    droppedPackage.hasUnstagedChanges = @YES;
                }
            } else if ([[proposedParentItem representedObject] isKindOfClass:[DeveloperSourceListItemMO class]]) {
                DeveloperSourceListItemMO *targetCategorySourceList = [proposedParentItem representedObject];
                
                NSPasteboard *pasteboard = [info draggingPasteboard];
                NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
                NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey : @NO};
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
                    droppedPackage.hasUnstagedChanges = @YES;
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
        else if (([[item representedObject] isKindOfClass:[DeveloperSourceListItemMO class]])) {
            return NSDragOperationMove;
        }
        else if (![targetDir.itemType isEqualToString:@"regular"]) {
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
        NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey : @NO};
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

- (id<NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row
{
    if (tableView == self.packagesTableView) {
        PackageMO *package = [[self.packagesArrayController arrangedObjects] objectAtIndex:(NSUInteger)row];
        NSURL *objectURL = [[package objectID] URIRepresentation];
        return objectURL;
    } else {
        return nil;
    }
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
	NSDragOperation result = NSDragOperationNone;
    
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
            NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey : @YES};
            NSArray *urls = [pasteboard readObjectsForClasses:classes options:options];
            
            for (NSURL *uri in urls) {
                BOOL canImport = [[MAMunkiRepositoryManager sharedManager] canImportURL:uri error:nil];
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
    
    return result;
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
            NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey : @YES};
            NSArray *urls = [pasteboard readObjectsForClasses:classes options:options];
            
            NSMutableArray *temporarySupportedURLs = [[NSMutableArray alloc] init];
            for (NSURL *uri in urls) {
                BOOL canImport = [[MAMunkiRepositoryManager sharedManager] canImportURL:uri error:nil];
                if (canImport) {
                    [temporarySupportedURLs addObject:uri];
                }
            }
            NSArray *supportedURLs = [NSArray arrayWithArray:temporarySupportedURLs];
            [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] addNewPackagesFromFileURLs:supportedURLs];
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
    
    /*
     Notes / Description split view
     */
    else if (sender == self.notesDescriptionSplitView) {
        
        NSView *top = [[sender subviews] objectAtIndex:0];
        NSView *bottom = [[sender subviews] objectAtIndex:1];
        CGFloat dividerThickness = [sender dividerThickness];
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
