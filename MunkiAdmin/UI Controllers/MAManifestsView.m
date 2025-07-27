//
//  MAManifestsView.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 6.3.2015.
//
//

#import "MAManifestsView.h"
#import "DataModelHeaders.h"
#import "MAMunkiAdmin_AppDelegate.h"
#import "MAMunkiRepositoryManager.h"
#import "MACoreDataManager.h"
#import "MARequestStringValueController.h"
#import "CocoaLumberjack.h"
#import "MAManifestEditor.h"
#import "MAManifestImporter.h"

DDLogLevel ddLogLevel;

#define kMinSplitViewWidth      200.0f
#define kMaxSplitViewWidth      400.0f
#define kDefaultSplitViewWidth  300.0f
#define kMinSplitViewHeight     80.0f
#define kMaxSplitViewHeight     400.0f

#define DEFAULT_PREDICATE @"titleOrDisplayName contains[cd] ''"

@interface MAManifestsView ()
@end

@implementation MAManifestsView

- (NSArray *)defaultSortDescriptors
{
    return @[[NSSortDescriptor sortDescriptorWithKey:@"titleOrDisplayName" ascending:YES selector:@selector(localizedStandardCompare:)]];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
        _predicateEditorHidden = YES;
        _openedManifestEditors = [NSMutableDictionary new];
    }
    
    return self;
}

- (MAManifestEditor *)editorForManifest:(ManifestMO *)manifest
{
    MAManifestEditor *existingEditor = [self.openedManifestEditors objectForKey:manifest.objectID.description];
    if (!existingEditor) {
        MAManifestEditor *newEditor = [[MAManifestEditor alloc] initWithWindowNibName:@"MAManifestEditor"];
        newEditor.manifestToEdit = manifest;
        newEditor.delegate = self;
        [self.openedManifestEditors setObject:newEditor forKey:manifest.objectID.description];
        
        return newEditor;
    } else {
        return existingEditor;
    }
}

- (void)openEditorForManifest:(ManifestMO *)manifest
{
    MAManifestEditor *editor = [self editorForManifest:manifest];
    [editor showWindow:nil];
}

- (void)didDoubleClickManifest:(id)sender
{
    [self openEditorForAllSelectedManifests];
}

- (void)openEditorForAllSelectedManifests
{
    for (ManifestMO *manifest in [self.manifestsArrayController selectedObjects]) {
        DDLogVerbose(@"%@: %@", NSStringFromSelector(_cmd), manifest.title);
        [self openEditorForManifest:manifest];
    }
}

- (void)rowsChanged:(NSNotification *)aNotification
{
    [self uncollapseFindView];
    [self updateSearchPredicateFromEditor];
}

- (void)searchUpdated:(NSNotification *)aNotification
{
    [self updateSearchPredicateFromEditor];
}

- (void)updateSearchPredicateFromEditor
{
    DDLogVerbose(@"%@", [[self.manifestsListPredicateEditor predicate] description]);
    if ([[self.manifestsListPredicateEditor predicate] isEqualTo:[NSCompoundPredicate andPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:DEFAULT_PREDICATE]]]]) {
        self.searchFieldPredicate = [NSPredicate predicateWithValue:YES];
    } else {
        self.searchFieldPredicate = [self.manifestsListPredicateEditor predicate];
    }
}

- (void)resetSearch
{
    self.previousPredicateEditorPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:DEFAULT_PREDICATE]]];
    self.manifestsListPredicateEditor.objectValue = self.previousPredicateEditorPredicate;
    
    [self searchUpdated:nil];
    
    [self.view.window makeFirstResponder:self.manifestsListPredicateEditor];
    [self.view.window selectKeyViewFollowingView:self.manifestsListPredicateEditor];
    [self.view.window recalculateKeyViewLoop];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    /*
     Update the mainCompoundPredicate everytime the subcomponents are updated
     */
    if ([key isEqualToString:@"mainCompoundPredicate"])
    {
        NSSet *affectingKeys = [NSSet setWithObjects:@"selectedSourceListFilterPredicate", @"searchFieldPredicate", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }
    
    return keyPaths;
}


- (NSPredicate *)mainCompoundPredicate
{
    /*
     Combine the selected source list item predicate and the possible search predicate
     */
    return [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:self.selectedSourceListFilterPredicate, self.searchFieldPredicate, nil]];
}

- (void)setupFindView
{
    
    self.searchFieldPredicate = [NSPredicate predicateWithValue:YES];
    self.selectedSourceListFilterPredicate = [NSPredicate predicateWithValue:YES];
    self.previousPredicateEditorPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:DEFAULT_PREDICATE]]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchUpdated:) name:NSControlTextDidChangeNotification object:self.manifestsListPredicateEditor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rowsChanged:) name:NSRuleEditorRowsDidChangeNotification object:self.manifestsListPredicateEditor];
    
    NSMutableArray *rowTemplates = [[self.manifestsListPredicateEditor rowTemplates] mutableCopy];
    
    /*
     Add the Any, All and None options
     */
    [rowTemplates addObject:[[NSPredicateEditorRowTemplate alloc] initWithCompoundTypes:@[@(NSAndPredicateType), @(NSOrPredicateType), @(NSNotPredicateType)]]];
    
    /*
     Simple strings that do not need a modifier
     */
    NSArray *simpleLeftExpressions = @[
                                       [NSExpression expressionForKeyPath:@"titleOrDisplayName"],
                                       [NSExpression expressionForKeyPath:@"fileName"],
                                       [NSExpression expressionForKeyPath:@"manifestUserName"],
                                       [NSExpression expressionForKeyPath:@"manifestDisplayName"],
                                       [NSExpression expressionForKeyPath:@"manifestAdminNotes"]];
    NSArray *simpleOperators = @[
                                 @(NSContainsPredicateOperatorType),
                                 @(NSBeginsWithPredicateOperatorType),
                                 @(NSEndsWithPredicateOperatorType),
                                 @(NSEqualToPredicateOperatorType),
                                 @(NSNotEqualToPredicateOperatorType)
                                 ];
    NSPredicateEditorRowTemplate *simpleStringsRowTemplate = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:simpleLeftExpressions
                                                                                              rightExpressionAttributeType:NSStringAttributeType
                                                                                                                  modifier:NSDirectPredicateModifier
                                                                                                                 operators:simpleOperators
                                                                                                                   options:(NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption)];
    [rowTemplates addObject:simpleStringsRowTemplate];
    
    /*
     Numeric
     */
    NSArray *numericLeftExpressions = @[
                                        [NSExpression expressionForKeyPath:@"managedInstallsCount"],
                                        [NSExpression expressionForKeyPath:@"managedUninstallsCount"],
                                        [NSExpression expressionForKeyPath:@"managedUpdatesCount"],
                                        [NSExpression expressionForKeyPath:@"optionalInstallsCount"],
                                        [NSExpression expressionForKeyPath:@"defaultInstallsCount"],
                                        [NSExpression expressionForKeyPath:@"featuredItemsCount"],
                                        [NSExpression expressionForKeyPath:@"includedManifestsCount"],
                                        [NSExpression expressionForKeyPath:@"referencingManifestsCount"],
                                        [NSExpression expressionForKeyPath:@"conditionsCount"]];
    NSArray *numericOperators = @[
                                 @(NSGreaterThanPredicateOperatorType),
                                 @(NSGreaterThanOrEqualToPredicateOperatorType),
                                 @(NSLessThanPredicateOperatorType),
                                 @(NSLessThanOrEqualToPredicateOperatorType),
                                 @(NSEqualToPredicateOperatorType),
                                 @(NSNotEqualToPredicateOperatorType)
                                 ];
    NSPredicateEditorRowTemplate *numericRowTemplate = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:numericLeftExpressions
                                                                                              rightExpressionAttributeType:NSInteger64AttributeType
                                                                                                                  modifier:NSDirectPredicateModifier
                                                                                                                 operators:numericOperators
                                                                                                                   options:0];
    [rowTemplates addObject:numericRowTemplate];
    
    /*
     Strings that need the ANY modifier
     */
    NSArray *containsOperator = @[
                                  @(NSContainsPredicateOperatorType),
                                  @(NSBeginsWithPredicateOperatorType),
                                  @(NSEndsWithPredicateOperatorType)
                                  ];
    NSArray *leftExpressions = @[
                                 [NSExpression expressionForKeyPath:@"allPackageStrings"],
                                 [NSExpression expressionForKeyPath:@"catalogStrings"],
                                 [NSExpression expressionForKeyPath:@"managedInstallsStrings"],
                                 [NSExpression expressionForKeyPath:@"managedUninstallsStrings"],
                                 [NSExpression expressionForKeyPath:@"managedUpdatesStrings"],
                                 [NSExpression expressionForKeyPath:@"optionalInstallsStrings"],
                                 [NSExpression expressionForKeyPath:@"defaultInstallsStrings"],
                                 [NSExpression expressionForKeyPath:@"featuredItemsStrings"],
                                 [NSExpression expressionForKeyPath:@"includedManifestsStrings"],
                                 [NSExpression expressionForKeyPath:@"referencingManifestsStrings"],
                                 [NSExpression expressionForKeyPath:@"conditionalItemsStrings"],
                                 ];
    NSPredicateEditorRowTemplate *catalogsTemplate = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:leftExpressions
                                                                                      rightExpressionAttributeType:NSStringAttributeType
                                                                                                          modifier:NSAnyPredicateModifier
                                                                                                         operators:containsOperator
                                                                                                           options:(NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption)];
    [rowTemplates addObject:catalogsTemplate];
    
    /*
     Add the row templates to the predicate editor
     */
    [self.manifestsListPredicateEditor setRowTemplates:rowTemplates];
    
    NSDictionary *formatting = @{
                                 @"%[titleOrDisplayName]@ %[is, is not, contains, begins with, ends with]@ %@" : @"%[Name]@ %[is, is not, contains, begins with, ends with]@ %@",
                                 @"%[fileName]@ %[is, is not, contains, begins with, ends with]@ %@" : @"%[Filename]@ %[is, is not, contains, begins with, ends with]@ %@",
                                 @"%[manifestUserName]@ %[is, is not, contains, begins with, ends with]@ %@" : @"%[Username]@ %[is, is not, contains, begins with, ends with]@ %@",
                                 @"%[manifestDisplayName]@ %[is, is not, contains, begins with, ends with]@ %@" : @"%[Display name]@ %[is, is not, contains, begins with, ends with]@ %@",
                                 @"%[manifestAdminNotes]@ %[is, is not, contains, begins with, ends with]@ %@" : @"%[Notes]@ %[is, is not, contains, begins with, ends with]@ %@",
                                 @"%[managedInstallsCount]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@" :
                                     @"%[Number of managed installs]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@",
                                 @"%[managedUninstallsCount]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@" :
                                     @"%[Number of managed uninstalls]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@",
                                 @"%[managedUpdatesCount]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@" :
                                     @"%[Number of managed updates]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@",
                                 @"%[optionalInstallsCount]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@" :
                                     @"%[Number of optional installs]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@",
                                 @"%[defaultInstallsCount]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@" :
                                     @"%[Number of default installs]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@",
                                 @"%[featuredItemsCount]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@" :
                                     @"%[Number of featured items]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@",
                                 @"%[includedManifestsCount]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@" :
                                     @"%[Number of included manifests]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@",
                                 @"%[referencingManifestsCount]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@" :
                                     @"%[Number of referencing manifests]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@",
                                 @"%[conditionsCount]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@" :
                                     @"%[Number of conditions]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@",
                                 @"%[allPackageStrings]@ %[contains, begins with, ends with]@ %@" : @"%[Any installs item]@ %[contains, begins with, ends with]@ %@",
                                 @"%[catalogStrings]@ %[contains, begins with, ends with]@ %@" : @"%[Any catalog]@ %[contains, begins with, ends with]@ %@",
                                 @"%[managedInstallsStrings]@ %[contains, begins with, ends with]@ %@" : @"%[Any managed installs item]@ %[contains, begins with, ends with]@ %@",
                                 @"%[managedUninstallsStrings]@ %[contains, begins with, ends with]@ %@" : @"%[Any managed uninstalls item]@ %[contains, begins with, ends with]@ %@",
                                 @"%[managedUpdatesStrings]@ %[contains, begins with, ends with]@ %@" : @"%[Any managed updates item]@ %[contains, begins with, ends with]@ %@",
                                 @"%[optionalInstallsStrings]@ %[contains, begins with, ends with]@ %@" : @"%[Any optional installs item]@ %[contains, begins with, ends with]@ %@",
                                 @"%[defaultInstallsStrings]@ %[contains, begins with, ends with]@ %@" : @"%[Any default installs item]@ %[contains, begins with, ends with]@ %@",
                                 @"%[featuredItemsStrings]@ %[contains, begins with, ends with]@ %@" : @"%[Any featured item]@ %[contains, begins with, ends with]@ %@",
                                 @"%[includedManifestsStrings]@ %[contains, begins with, ends with]@ %@" : @"%[Any included manifest]@ %[contains, begins with, ends with]@ %@",
                                 @"%[referencingManifestsStrings]@ %[contains, begins with, ends with]@ %@" : @"%[Any referencing manifest]@ %[contains, begins with, ends with]@ %@",
                                 @"%[conditionalItemsStrings]@ %[contains, begins with, ends with]@ %@" : @"%[Any condition predicate string]@ %[contains, begins with, ends with]@ %@",
                                 };
    [self.manifestsListPredicateEditor setFormattingDictionary:formatting];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
}

- (void)awakeFromNib
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    //[self.sourceList registerForDraggedTypes:@[draggingType]];
    
    // The basic recipe for a sidebar. Note that the selectionHighlightStyle is set to NSTableViewSelectionHighlightStyleSourceList in the nib
    [self.sourceList sizeLastColumnToFit];
    [self.sourceList setFloatsGroupRows:NO];
    
    // NSTableViewRowSizeStyleDefault should be used, unless the user has picked an explicit size. In that case, it should be stored out and re-used.
    [self.sourceList setRowSizeStyle:NSTableViewRowSizeStyleDefault];
    
    [self.manifestsListTableView setDelegate:self];
    [self.manifestsListTableView setDataSource:self];
    [self.manifestsListTableView registerForDraggedTypes:@[NSURLPboardType]];
    [self.manifestsListTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    
    [self.sourceList setDelegate:self];
    [self.sourceList setDataSource:self];
    [self.sourceList registerForDraggedTypes:@[NSURLPboardType]];
    [self.sourceList setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    
    self.requestStringValue = [[MARequestStringValueController alloc] initWithWindowNibName:@"MARequestStringValueController"];
    
    self.manifestImporter = [[MAManifestImporter alloc] initWithWindowNibName:@"MAManifestImporter"];
    
    [self setupFindView];
    
    [self configureSplitView];
    [self configureSourceList];
    
    // Add observer for sidebar tree controller content changes
    [self.manifestSourceListTreeController addObserver:self
                                             forKeyPath:@"arrangedObjects"
                                                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                                context:NULL];
    
    /*
     Configure sorting
     */
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
    [self.manifestSourceListTreeController setSortDescriptors:@[sortByIndex, sortByTitle]];
    
    
    
    [self.manifestsListTableView setTarget:self];
    [self.manifestsListTableView setDoubleAction:@selector(didDoubleClickManifest:)];
    [self.manifestsListTableView setMenu:self.manifestsListMenu];
    
    self.predicateEditorHidden = YES;

    [self setDetailView:self.manifestsListView];
    
    /*
     Create a contextual menu for customizing table columns
     */
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    for (NSTableColumn *column in self.manifestsListTableView.tableColumns) {
        NSMenuItem *menuItem = nil;
        if ([[column identifier] isEqualToString:@"manifestsTableColumnIcon"]) {
            menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Icon", @"")
                                            action:@selector(toggleColumn:)
                                     keyEquivalent:@""];
        } else if ([[column identifier] isEqualToString:@"manifestsTableColumnManagedInstallsCount"]) {
            menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Number of Managed Installs", @"")
                                                  action:@selector(toggleColumn:)
                                           keyEquivalent:@""];
        } else if ([[column identifier] isEqualToString:@"manifestsTableColumnManagedUpdatesCount"]) {
            menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Number of Managed Updates", @"")
                                                  action:@selector(toggleColumn:)
                                           keyEquivalent:@""];
        } else if ([[column identifier] isEqualToString:@"manifestsTableColumnManagedUninstallsCount"]) {
            menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Number of Managed Uninstalls", @"")
                                                  action:@selector(toggleColumn:)
                                           keyEquivalent:@""];
        } else if ([[column identifier] isEqualToString:@"manifestsTableColumnOptionalInstallsCount"]) {
            menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Number of Optional Installs", @"")
                                                  action:@selector(toggleColumn:)
                                           keyEquivalent:@""];
        } else if ([[column identifier] isEqualToString:@"manifestsTableColumnDefaultInstallsCount"]) {
            menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Number of Default Installs", @"")
                                                  action:@selector(toggleColumn:)
                                           keyEquivalent:@""];
        } else if ([[column identifier] isEqualToString:@"manifestsTableColumnFeaturedItemsCount"]) {
            menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Number of Featured Items", @"")
                                                  action:@selector(toggleColumn:)
                                           keyEquivalent:@""];
        } else if ([[column identifier] isEqualToString:@"manifestsTableColumnIncludedManifestsCount"]) {
            menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Number of Included Manifests", @"")
                                                  action:@selector(toggleColumn:)
                                           keyEquivalent:@""];
        } else if ([[column identifier] isEqualToString:@"manifestsTableColumnReferencingManifestsCount"]) {
            menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Number of Referencing Manifests", @"")
                                                  action:@selector(toggleColumn:)
                                           keyEquivalent:@""];
        } else {
            menuItem = [[NSMenuItem alloc] initWithTitle:[column.headerCell stringValue]
                                            action:@selector(toggleColumn:)
                                     keyEquivalent:@""];
        }
        menuItem.target = self;
        menuItem.representedObject = column;
        [menu addItem:menuItem];
    }
    menu.delegate = self;
    self.manifestsListTableView.headerView.menu = menu;
    
    // Hide scripts menu if there are no custom scripts
    MAMunkiRepositoryManager *repoManager = [MAMunkiRepositoryManager sharedManager];
    [repoManager updateRepositoryScriptStatus];
    if (![repoManager repositoryHasManifestCustomScripts]) {
        self.scriptsSubMenuItem.hidden = YES;
    }
}

- (void)toggleColumn:(id)sender
{
    NSTableColumn *col = [sender representedObject];
    [col setHidden:![col isHidden]];
}

- (void)updateSourceListData
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    NSManagedObjectContext *moc = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
    [[MACoreDataManager sharedManager] configureManifestSourceListItems:moc];
    
    self.manifestsArrayController.sortDescriptors = self.defaultSortDescriptors;
    
    [self.manifestSourceListTreeController rearrangeObjects];
    
    
}

- (void)configureSourceList
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    [self.sourceList sizeLastColumnToFit];
    [self.sourceList setFloatsGroupRows:NO];
    [self.sourceList setRowSizeStyle:NSTableViewRowSizeStyleDefault];
    [self.sourceList setIndentationMarkerFollowsCell:YES];
    [self.sourceList setIndentationPerLevel:14];
}

- (void)configureSplitView
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    [self.mainSplitView setDividerStyle:NSSplitViewDividerStyleThin];
}

# pragma mark -
# pragma mark IBActions

- (IBAction)resetSearchAction:(id)sender
{
    [self resetSearch];
}

# pragma mark - 
# pragma mark Data Model

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

- (void)removeDetailViewSubviews
{
    NSArray *detailSubViews = [self.detailViewPlaceHolder subviews];
    if ([detailSubViews count] > 0)
    {
        [detailSubViews[0] removeFromSuperview];
    }
}

#pragma mark -
#pragma mark Manifest list right-click menu actions

- (void)importManifestsFromFile
{
    if ([self.manifestImporter updateImporterStatusWithCSVFile:nil]) {
        NSWindow *window = [self.manifestImporter window];
        NSInteger result = [NSApp runModalForWindow:window];
        if (result == NSModalResponseOK) {
            
        }
    }
}

- (IBAction)importManifestsFromFileAction:(id)sender
{
    [self importManifestsFromFile];
}

- (void)renameSelectedManifest
{
    /*
     Get the manifest item that was right-clicked
     */
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    NSUInteger clickedRow = (NSUInteger)[self.manifestsListTableView clickedRow];
    ManifestMO *clickedManifest = [[self.manifestsArrayController arrangedObjects] objectAtIndex:clickedRow];
    
    NSString *originalFilename = [clickedManifest.manifestURL lastPathComponent];
    
    /*
     Ask for a new title
     */
    [self.requestStringValue setDefaultValues];
    self.requestStringValue.windowTitleText = @"";
    self.requestStringValue.titleText = [NSString stringWithFormat:@"Rename \"%@\"?", originalFilename];
    self.requestStringValue.okButtonTitle = @"Rename";
    self.requestStringValue.labelText = @"New Name:";
    self.requestStringValue.descriptionText = [NSString stringWithFormat:@"Enter a new name for the manifest \"%@\".", originalFilename];
    self.requestStringValue.stringValue = originalFilename;
    NSWindow *window = [self.requestStringValue window];
    NSInteger result = [NSApp runModalForWindow:window];
    
    /*
     Perform the actual rename
     */
    if (result == NSModalResponseOK) {
        MAMunkiRepositoryManager *repoManager = [MAMunkiRepositoryManager sharedManager];
        NSString *newTitle = self.requestStringValue.stringValue;
        
        if (![originalFilename isEqualToString:newTitle]) {
            NSURL *newURL = [clickedManifest.manifestParentDirectoryURL URLByAppendingPathComponent:newTitle];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:[newURL path]]) {
                DDLogDebug(@"Can't rename. File already exists at path %@", [newURL path]);
                NSAlert *fileExistsAlert = [[NSAlert alloc] init];
                NSString *messageText = NSLocalizedString(@"File already exists", @"");
                fileExistsAlert.messageText = messageText;
                NSString * _Nonnull informativeText = [NSString stringWithFormat:NSLocalizedString(@"MunkiAdmin failed to rename \"%@\" to \"%@\" because a file with that name already exists.", @""), originalFilename, newTitle];
                fileExistsAlert.informativeText = informativeText;
                [fileExistsAlert addButtonWithTitle:NSLocalizedString(@"OK", @"")];
                [fileExistsAlert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {}];
            }
            
            [repoManager moveManifest:clickedManifest toURL:newURL cascade:YES];
        } else {
            DDLogError(@"Old name and new name are the same. Skipping rename...");
        }
    }
    
    [self.requestStringValue setDefaultValues];
}

- (IBAction)renameManifestAction:(id)sender
{
    [self renameSelectedManifest];
}

- (void)deleteSelectedManifests
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    NSInteger clickedRow = [self.manifestsListTableView clickedRow];
    if (clickedRow == -1) {
        return;
    }
    
    ManifestMO *clickedManifest = [[self.manifestsArrayController arrangedObjects] objectAtIndex:(NSUInteger)clickedRow];
    
    NSMutableArray *selectedManifests = [NSMutableArray new];
    [selectedManifests addObjectsFromArray:[self.manifestsArrayController selectedObjects]];
    
    if (![selectedManifests containsObject:clickedManifest]) {
        /*
         User right-clicked outside the selection, add it to the items to remove
         */
        [selectedManifests addObject:clickedManifest];
    }
    
    // Configure the dialog
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:NSLocalizedString(@"Delete", @"")];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    
    NSString *messageText;
    NSString *informativeText;
    if ([selectedManifests count] > 1) {
        messageText = NSLocalizedString(@"Delete manifests", @"");
        informativeText = [NSString stringWithFormat:
                           NSLocalizedString(@"Are you sure you want to delete %lu manifests? MunkiAdmin will move the selected manifest files to trash and remove all references to them in other manifests.", @""),
                           (unsigned long)[selectedManifests count]];
    } else if ([selectedManifests count] == 1) {
        messageText = [NSString stringWithFormat:NSLocalizedString(@"Delete manifest \"%@\"", @""), [selectedManifests[0] title]];
        informativeText = [NSString stringWithFormat:
                           NSLocalizedString(@"Are you sure you want to delete manifest \"%@\"? MunkiAdmin will move the manifest file to trash and remove all references to it in other manifests.", @""),
                           [selectedManifests[0] title]];
    } else {
        DDLogError(@"No manifests selected, can't delete anything...");
        return;
    }
    [alert setMessageText:messageText];
    [alert setInformativeText:informativeText];
    [alert setAlertStyle:NSAlertStyleInformational];
    [alert setShowsSuppressionButton:NO];
    
    NSInteger result = [alert runModal];
    if (result == NSAlertFirstButtonReturn) {
        for (ManifestMO *aManifest in selectedManifests) {
            [[MAMunkiRepositoryManager sharedManager] removeManifest:aManifest withReferences:YES];
        }
    }
}

- (IBAction)deleteSelectedManifestsAction:sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    [self deleteSelectedManifests];
}

- (void)createNewManifest
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    NSString *newFilename = NSLocalizedString(@"new-manifest", nil);
    NSString *message = NSLocalizedString(@"Choose a location and name for the new manifest. Location should be within your manifests directory.", nil);
    
    NSURL *newURL;
    MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.nameFieldStringValue = newFilename;
    savePanel.directoryURL = appDelegate.manifestsURL;
    savePanel.message = message;
    NSString *title = NSLocalizedString(@"Create manifest", @"");
    savePanel.title = title;
    if ([savePanel runModal] == NSModalResponseOK)
    {
        newURL = [savePanel URL];
    } else {
        return;
    }
    
    if (!newURL) {
        DDLogError(@"User cancelled new manifest creation");
        return;
    }
    
    /*
     Let URLByResolvingSymlinksInPath work on directory since file is not created yet
     */
    newURL = [[[newURL URLByDeletingLastPathComponent] URLByResolvingSymlinksInPath] URLByAppendingPathComponent:[newURL lastPathComponent]];
    
    ManifestMO *newManifest = [[MACoreDataManager sharedManager] createManifestWithURL:[newURL URLByResolvingSymlinksInPath] inManagedObjectContext:appDelegate.managedObjectContext];
    if (!newManifest) {
        DDLogError(@"Failed to create manifest");
    }
    
}

- (IBAction)duplicateManifestAction:(id)sender
{
    NSUInteger clickedRow = (NSUInteger)[self.manifestsListTableView clickedRow];
    ManifestMO *clickedManifest = [[self.manifestsArrayController arrangedObjects] objectAtIndex:clickedRow];
    [[MAMunkiRepositoryManager sharedManager] duplicateManifest:clickedManifest];
}

- (IBAction)newManifestAction:(id)sender
{
    [self createNewManifest];
}


- (IBAction)propertiesAction:(id)sender
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    NSUInteger clickedRow = (NSUInteger)[self.manifestsListTableView clickedRow];
    ManifestMO *clickedManifest = [[self.manifestsArrayController arrangedObjects] objectAtIndex:clickedRow];
    if ([[self.manifestsArrayController selectedObjects] count] > 0) {
        if ([[self.manifestsArrayController selectionIndexes] containsIndex:clickedRow]) {
            for (ManifestMO *manifest in [self.manifestsArrayController selectedObjects]) {
                MAManifestEditor *editor = [self editorForManifest:manifest];
                [editor showWindow:nil];
            }
        } else {
            MAManifestEditor *editor = [self editorForManifest:clickedManifest];
            [editor showWindow:nil];
        }
    } else {
        MAManifestEditor *editor = [self editorForManifest:clickedManifest];
        [editor showWindow:nil];
    }
}

- (IBAction)showManifestInFinderAction:(id)sender
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
    NSUInteger clickedRow = (NSUInteger)[self.manifestsListTableView clickedRow];
    ManifestMO *clickedManifest = [[self.manifestsArrayController arrangedObjects] objectAtIndex:clickedRow];
    NSURL *selectedURL;
    if ([[self.manifestsArrayController selectedObjects] count] > 0) {
        if ([[self.manifestsArrayController selectionIndexes] containsIndex:clickedRow]) {
            selectedURL = (NSURL *)[[self.manifestsArrayController selectedObjects][0] manifestURL];
        } else {
            selectedURL = [clickedManifest manifestURL];
        }
    } else {
        selectedURL = [clickedManifest manifestURL];
    }
    
    if (selectedURL != nil) {
        [[NSWorkspace sharedWorkspace] selectFile:[selectedURL relativePath] inFileViewerRootedAtPath:[appDelegate.repoURL relativePath]];
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

- (IBAction)openEditorForManifestMenuItemAction:(id)sender
{
    ManifestMO *manifest = [sender representedObject];
    [self openEditorForManifest:manifest];
}

- (void)addSelectedManifestsToCatalogAction:(id)sender
{
    CatalogMO *catalog = [sender representedObject];
    for (ManifestMO *manifest in self.manifestsArrayController.selectedObjects) {
        for (CatalogInfoMO *catalogInfo in manifest.catalogInfos) {
            if (catalogInfo.catalog == catalog) {
                catalogInfo.isEnabledForManifestValue = YES;
            }
        }
        manifest.hasUnstagedChangesValue = YES;
    }
}

- (void)removeSelectedManifestsFromCatalogAction:(id)sender
{
    CatalogMO *catalog = [sender representedObject];
    for (ManifestMO *manifest in self.manifestsArrayController.selectedObjects) {
        for (CatalogInfoMO *catalogInfo in manifest.catalogInfos) {
            if (catalogInfo.catalog == catalog) {
                catalogInfo.isEnabledForManifestValue = NO;
            }
        }
        manifest.hasUnstagedChangesValue = YES;
    }
}

- (void)enableAllCatalogsAction:(id)sender
{
    for (ManifestMO *manifest in self.manifestsArrayController.selectedObjects) {
        for (CatalogInfoMO *catalogInfo in manifest.catalogInfos) {
            catalogInfo.isEnabledForManifestValue = YES;
        }
        manifest.hasUnstagedChangesValue = YES;
    }
}

- (void)disableAllCatalogsAction:(id)sender
{
    for (ManifestMO *manifest in self.manifestsArrayController.selectedObjects) {
        for (CatalogInfoMO *catalogInfo in manifest.catalogInfos) {
            catalogInfo.isEnabledForManifestValue = NO;
        }
        manifest.hasUnstagedChangesValue = YES;
    }
}

#pragma mark -
#pragma mark NSMenu delegates

- (void)menuWillOpen:(NSMenu *)menu
{
    /*
     The column header menu
     */
    if (menu == self.manifestsListTableView.headerView.menu) {
        for (NSMenuItem *mi in menu.itemArray) {
            NSTableColumn *col = [mi representedObject];
            [mi setState:col.isHidden ? NSOffState : NSOnState];
        }
    } else if (menu == self.manifestsListMenu) {
        [self manifestsListMenuWillOpen:menu];
    } else if (menu == self.catalogsSubMenu) {
        [self catalogsSubMenuWillOpen:menu];
    } else if (menu == self.referencingManifestsSubMenu) {
        [self referencingManifestsSubMenuWillOpen:menu];
    } else if (menu == self.includedManifestsSubMenu) {
        [self includedManifestsSubMenuWillOpen:menu];
    } else if (menu == self.scriptsSubMenu) {
        [self scriptsSubMenuWillOpen:menu];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    DDLogVerbose(@"Validating menu item %@", [menuItem title]);
    return YES;
}

- (void)runManifestCustomScriptMenuItemAction:(id)sender
{
    MAMunkiRepositoryManager *repoManager = [MAMunkiRepositoryManager sharedManager];
    
    NSMutableArray *selectedManifests = [NSMutableArray new];
    for (ManifestMO *manifest in self.manifestsArrayController.selectedObjects) {
        [selectedManifests addObject:manifest];
    }
    
    NSInteger clickedRow = [self.manifestsListTableView clickedRow];
    if (clickedRow != -1) {
        ManifestMO *clickedManifest = [[self.manifestsArrayController arrangedObjects] objectAtIndex:(NSUInteger)clickedRow];
        if (![selectedManifests containsObject:clickedManifest]) {
            [selectedManifests addObject:clickedManifest];
        }
    }
    
    NSString *scriptPath = [sender representedObject];
    [repoManager runManifestCustomScriptAtPath:scriptPath withManifests:[NSArray arrayWithArray:selectedManifests]];
}

- (void)scriptsSubMenuWillOpen:(NSMenu *)menu
{
    [menu removeAllItems];
    
    MAMunkiRepositoryManager *repoManager = [MAMunkiRepositoryManager sharedManager];
    for (NSString *scriptPath in [[repoManager manifestCustomScriptPaths] sortedArrayUsingSelector:@selector(localizedStandardCompare:)]) {
        NSString *fileNameFull = [scriptPath lastPathComponent];
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^manifest-custom[-\\s]*"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];

        NSString *output = [regex stringByReplacingMatchesInString:fileNameFull
                                                        options:0
                                                          range:NSMakeRange(0, [fileNameFull length])
                                                   withTemplate:@""];
        
        NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:output
                                                             action:nil
                                                      keyEquivalent:@""];
        newMenuItem.representedObject = scriptPath;
        newMenuItem.target = self;
        newMenuItem.action = @selector(runManifestCustomScriptMenuItemAction:);
        [menu addItem:newMenuItem];
    }
}


- (void)manifestsListMenuWillOpen:(NSMenu *)menu
{
    NSInteger clickedRow = [self.manifestsListTableView clickedRow];
    if (clickedRow == -1) {
        self.referencingManifestsSubMenuItem.hidden = YES;
        self.includedManifestsSubMenuItem.hidden = YES;
        return;
    }
    
    ManifestMO *clickedManifest = [[self.manifestsArrayController arrangedObjects] objectAtIndex:(NSUInteger)clickedRow];
    
    if ([clickedManifest.allReferencingManifests count] == 0) {
        self.referencingManifestsSubMenuItem.hidden = YES;
    } else {
        self.referencingManifestsSubMenuItem.hidden = NO;
    }
    
    if ([clickedManifest.allIncludedManifests count] == 0) {
        self.includedManifestsSubMenuItem.hidden = YES;
    } else {
        self.includedManifestsSubMenuItem.hidden = NO;
    }
}

- (void)referencingManifestsSubMenuWillOpen:(NSMenu *)menu
{
    [menu removeAllItems];
    
    NSMutableArray *newItems = [NSMutableArray new];
    
    NSUInteger clickedRow = (NSUInteger)[self.manifestsListTableView clickedRow];
    ManifestMO *clickedManifest = [[self.manifestsArrayController arrangedObjects] objectAtIndex:clickedRow];
    for (StringObjectMO *object in clickedManifest.allReferencingManifests) {
        NSString *title;
        id representedObject;
        if (object.manifestReference) {
            title = object.manifestReference.titleOrDisplayName;
            representedObject = object.manifestReference;
        } else {
            title = object.includedManifestConditionalReference.manifest.titleOrDisplayName;
            representedObject = object.includedManifestConditionalReference.manifest;
        }
        [newItems addObject:@{@"title": title, @"representedObject": representedObject}];
    }
    
    NSImage *manifestImage = [NSImage imageNamed:@"manifestIcon_32x32"];
    [manifestImage setSize:NSMakeSize(16.0, 16.0)];
    
    [newItems sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    for (NSDictionary *object in newItems) {
        NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:object[@"title"]
                                                             action:nil
                                                      keyEquivalent:@""];
        ManifestMO *representedManifest = (ManifestMO *)object[@"representedObject"];
        newMenuItem.representedObject = representedManifest;
        newMenuItem.target = self;
        newMenuItem.action = @selector(openEditorForManifestMenuItemAction:);
        newMenuItem.image = manifestImage;
        [menu addItem:newMenuItem];
    }
}

- (void)includedManifestsSubMenuWillOpen:(NSMenu *)menu
{
    [menu removeAllItems];
    
    NSMutableArray *newItems = [NSMutableArray new];
    
    NSUInteger clickedRow = (NSUInteger)[self.manifestsListTableView clickedRow];
    ManifestMO *clickedManifest = [[self.manifestsArrayController arrangedObjects] objectAtIndex:clickedRow];
    
    for (StringObjectMO *object in clickedManifest.allIncludedManifests) {
        NSString *title;
        id representedObject;
        if (object.originalManifest) {
            title = object.originalManifest.titleOrDisplayName;
            representedObject = object.originalManifest;
            [newItems addObject:@{@"title": title, @"representedObject": representedObject}];
        } else {
            DDLogError(@"Error. Included manifest object %@ doesn't have reference to its original manifest.", object.description);
        }
    }
    
    NSImage *manifestImage = [NSImage imageNamed:@"manifestIcon_32x32"];
    [manifestImage setSize:NSMakeSize(16.0, 16.0)];
    
    [newItems sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    for (NSDictionary *object in newItems) {
        NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:object[@"title"]
                                                             action:nil
                                                      keyEquivalent:@""];
        ManifestMO *representedManifest = (ManifestMO *)object[@"representedObject"];
        newMenuItem.representedObject = representedManifest;
        newMenuItem.target = self;
        newMenuItem.action = @selector(openEditorForManifestMenuItemAction:);
        newMenuItem.image = manifestImage;
        [menu addItem:newMenuItem];
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
        
        for (ManifestMO *manifest in self.manifestsArrayController.selectedObjects) {
            if ([[manifest catalogStrings] containsObject:catalog.title]) {
                [enabledPackageNames addObject:manifest.title];
                numEnabled++;
            } else {
                [disabledPackageNames addObject:manifest.title];
                numDisabled++;
            }
        }
        
        NSInteger clickedRow = [self.manifestsListTableView clickedRow];
        if (clickedRow == -1) {
            continue;
        }
        ManifestMO *clickedManifest = [[self.manifestsArrayController arrangedObjects] objectAtIndex:(NSUInteger)clickedRow];
        if ([[clickedManifest catalogStrings] containsObject:catalog.title]) {
            [enabledPackageNames addObject:clickedManifest.title];
            numEnabled++;
        } else {
            [disabledPackageNames addObject:clickedManifest.title];
            numDisabled++;
        }
        
        if (numDisabled == 0) {
            /*
             All of the selected manifests are in this catalog.
             Selecting this menu item should remove manifests from catalog.
             */
            catalogItem.action = @selector(removeSelectedManifestsFromCatalogAction:);
            catalogItem.state = NSOnState;
            
        } else if (numEnabled == 0) {
            /*
             None of the selected manifests are in this catalog.
             Selecting this menu item should add manifests to this catalog.
             */
            catalogItem.action = @selector(addSelectedManifestsToCatalogAction:);
            catalogItem.state = NSOffState;
            
        } else {
            /*
             Some of the selected manifests are in this catalog.
             Selecting this menu item should add the missing manifests to this catalog.
             
             Additionally create a tooltip to show which manifests are enabled/disable.
             */
            NSString *toolTip;
            if (numEnabled > numDisabled) {
                toolTip = [NSString stringWithFormat:@"Manifests not using catalog \"%@\":\n- %@",
                           catalog.title,
                           [disabledPackageNames componentsJoinedByString:@"\n- "]];
            } else {
                toolTip = [NSString stringWithFormat:@"Manifests using catalog \"%@\":\n- %@",
                           catalog.title,
                           [enabledPackageNames componentsJoinedByString:@"\n- "]];
            }
            catalogItem.toolTip = toolTip;
            
            catalogItem.action = @selector(addSelectedManifestsToCatalogAction:);
            catalogItem.state = NSMixedState;
        }
        
    }
}

# pragma mark -
# pragma mark NSTableView delegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *identifier = [tableColumn identifier];
    NSView *cellView = [tableView makeViewWithIdentifier:identifier owner:nil];
    return cellView;
}

- (id<NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row
{
    if (tableView == self.manifestsListTableView) {
        ManifestMO *manifest = [[self.manifestsArrayController arrangedObjects] objectAtIndex:(NSUInteger)row];
        NSURL *objectURL = [[manifest objectID] URIRepresentation];
        return objectURL;
    } else {
        return nil;
    }
}

- (BOOL)canImportURL:(NSURL *)fileURL
{
    NSString *typeIdentifier;
    [fileURL getResourceValue:&typeIdentifier forKey:NSURLTypeIdentifierKey error:nil];
    if ([[NSWorkspace sharedWorkspace] type:typeIdentifier conformsToType:(NSString *)kUTTypePlainText]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    NSDragOperation result = NSDragOperationNone;
    
    /*
     Packages table view validations
     */
    if (aTableView == self.manifestsListTableView) {
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
                BOOL canImport = [self canImportURL:uri];
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
    
    if (theTableView == self.manifestsListTableView) {
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
                BOOL canImport = [self canImportURL:uri];
                if (canImport) {
                    [temporarySupportedURLs addObject:uri];
                }
            }
            NSArray *supportedURLs = [NSArray arrayWithArray:temporarySupportedURLs];
            if ([self.manifestImporter updateImporterStatusWithCSVFile:supportedURLs[0]]) {
                NSWindow *window = [self.manifestImporter window];
                NSInteger result = [NSApp runModalForWindow:window];
                if (result == NSModalResponseOK) {
                    
                }
            }
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


# pragma mark -
# pragma mark NSOutlineView delegate and data source methods


- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSArray *selectedSourceListItems = [self.manifestSourceListTreeController selectedObjects];
    if ([selectedSourceListItems count] > 0) {
        DDLogVerbose(@"Starting to set predicate...");
        ManifestSourceListItemMO *selectedItem = [selectedSourceListItems objectAtIndex:0];
        NSPredicate *productFilter = selectedItem.filterPredicate;
        self.selectedSourceListFilterPredicate = productFilter;
        
        NSArray *productSortDescriptors = selectedItem.sortDescriptors;
        
        if (productSortDescriptors != nil) {
            [self.manifestsArrayController setSortDescriptors:productSortDescriptors];
        } else {
            [self.manifestsArrayController setSortDescriptors:self.defaultSortDescriptors];
        }
        DDLogVerbose(@"Finished setting predicate...");
    }
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if (outlineView == self.sourceList) {
        
        NSTableCellView *view = nil;
        ManifestSourceListItemMO *sourceListItem = [item representedObject];
        
        if (sourceListItem.isGroupItemValue) {
            view = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:nil];
        } else {
            view = [outlineView makeViewWithIdentifier:@"MainCell" owner:nil];
        }
        
        view.textField.stringValue = sourceListItem.title;
        view.imageView.image = sourceListItem.icon;
        
        return view;
    } else {
        return nil;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(nonnull id)item
{
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    ManifestSourceListItemMO *sourceListItem = [item representedObject];
    return !sourceListItem.isGroupItemValue;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    ManifestSourceListItemMO *sourceListItem = [item representedObject];
    return sourceListItem.isGroupItemValue;
}

- (NSDragOperation)outlineView:(NSOutlineView *)sourceList validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
    // Deny drag and drop reordering
    if (index != -1) {
        return NSDragOperationNone;
    }
    
    if (sourceList == self.sourceList) {
        
        /*
         Only allow dropping on directory items
         */
        if ([[item representedObject] isKindOfClass:[ManifestDirectorySourceListItemMO class]]) {
            // Allow dropping on directory items
        } else {
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
                NSManagedObjectContext *moc = [self.manifestsArrayController managedObjectContext];
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

- (BOOL)outlineView:(NSOutlineView *)aSourceList acceptDrop:(nonnull id<NSDraggingInfo>)info item:(nullable id)proposedParentItem childIndex:(NSInteger)index
{
    if (aSourceList == self.sourceList) {
        NSArray *dragTypes = [[info draggingPasteboard] types];
        if ([dragTypes containsObject:NSURLPboardType]) {
            
            if ([[proposedParentItem representedObject] isKindOfClass:[ManifestDirectorySourceListItemMO class]]) {
                
                ManifestDirectorySourceListItemMO *targetDir = (ManifestDirectorySourceListItemMO *)[proposedParentItem representedObject];
                
                NSPasteboard *pasteboard = [info draggingPasteboard];
                NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
                NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey : @NO};
                NSArray *urls = [pasteboard readObjectsForClasses:classes options:options];
                for (NSURL *uri in urls) {
                    NSManagedObjectContext *moc = [self.manifestsArrayController managedObjectContext];
                    NSManagedObjectID *objectID = [[moc persistentStoreCoordinator] managedObjectIDForURIRepresentation:uri];
                    ManifestMO *droppedManifest = (ManifestMO *)[moc objectRegisteredForID:objectID];
                    NSString *currentFileName = [[droppedManifest manifestURL] lastPathComponent];
                    NSURL *targetURL = [targetDir.representedFileURLValue URLByAppendingPathComponent:currentFileName];
                    if ([[droppedManifest manifestURL] isEqualTo:targetURL]) {
                        DDLogError(@"Error. Dropped to same folder %@", [targetURL path]);
                    }
                    
                    if ([[NSFileManager defaultManager] fileExistsAtPath:[targetURL path]]) {
                        DDLogError(@"Error. File already exists %@", [targetURL path]);
                    }
                    
                    [[MAMunkiRepositoryManager sharedManager] moveManifest:droppedManifest toURL:targetURL cascade:YES];
                    
                    droppedManifest.hasUnstagedChanges = @YES;
                }
            }
        }
        return YES;
    }
    else {
        return NO;
    }
}


# pragma mark -
# pragma mark NSSplitView delegates

- (void)showFindViewWithPredicate:(NSPredicate *)predicate
{
    self.manifestsListPredicateEditor.objectValue = predicate;
    self.searchFieldPredicate = predicate;
    [self searchUpdated:nil];
    [self uncollapseFindView];
    
    [self.view.window makeFirstResponder:self.manifestsListPredicateEditor];
    [self.view.window selectKeyViewFollowingView:self.manifestsListPredicateEditor];
    [self.view.window recalculateKeyViewLoop];
}

- (void)toggleManifestsFindView
{
    BOOL findViewCollapsed = [self.manifestsListSplitView isSubviewCollapsed:[self.manifestsListSplitView subviews][0]];
    if (findViewCollapsed) {
        self.manifestsListPredicateEditor.objectValue = self.previousPredicateEditorPredicate;
        self.searchFieldPredicate = self.previousPredicateEditorPredicate;
        [self searchUpdated:nil];
        [self uncollapseFindView];
        
        [self.view.window makeFirstResponder:self.manifestsListPredicateEditor];
        [self.view.window selectKeyViewFollowingView:self.manifestsListPredicateEditor];
        [self.view.window recalculateKeyViewLoop];
        
    } else {
        self.previousPredicateEditorPredicate = self.manifestsListPredicateEditor.objectValue;
        self.searchFieldPredicate = [NSPredicate predicateWithValue:YES];
        [self collapseFindView];
        [self.view.window makeFirstResponder:self.manifestsListTableView];
        [self.manifestsListTableView setNextKeyView:self.sourceList];
        [self.sourceList setNextKeyView:self.manifestsListTableView];
         
    }
}

- (void)collapseFindView
{
    NSView *predicateEditorSubView = [self.manifestsListSplitView subviews][0];
    NSView *manifestsListSubView  = [self.manifestsListSplitView subviews][1];
    NSRect overallFrame = [self.detailViewPlaceHolder frame];
    [predicateEditorSubView setHidden:YES];
    
    [manifestsListSubView setFrameOrigin:NSMakePoint(0, 0)];
    [manifestsListSubView setFrameSize:NSMakeSize(overallFrame.size.width,overallFrame.size.height)];
    
    [self.manifestsListSplitView display];
}

- (void)uncollapseFindView
{
    NSView *predicateEditorSubView = [self.manifestsListSplitView subviews][0];
    NSView *manifestsListSubView  = [self.manifestsListSplitView subviews][1];
    NSRect overallFrame = [self.detailViewPlaceHolder frame];
    
    [predicateEditorSubView setHidden:NO];
    
    NSRect manifestsListFrame = [manifestsListSubView frame];
    NSRect predicateEditorFrame = [predicateEditorSubView frame];
    
    CGFloat predEditorRowHeight = [self.manifestsListPredicateEditor rowHeight];
    NSInteger numRowsInPredEditor = [self.manifestsListPredicateEditor numberOfRows];
    int padding = 32;
    CGFloat desiredHeight = numRowsInPredEditor * predEditorRowHeight + padding;
    CGFloat dividerThickness = [self.manifestsListSplitView dividerThickness];
    predicateEditorFrame.size.height = desiredHeight;
    predicateEditorFrame.size.width = overallFrame.size.width;
    manifestsListFrame.size.height = (overallFrame.size.height - predicateEditorFrame.size.height - dividerThickness);
    manifestsListFrame.size.width = overallFrame.size.width;
    
    manifestsListFrame.origin.y = predicateEditorFrame.size.height + dividerThickness;
    
    [manifestsListSubView setFrame:manifestsListFrame];
    [predicateEditorSubView setFrame:predicateEditorFrame];
    
    [self.manifestsListSplitView display];
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
    if (splitView == self.mainSplitView) {
        return NO;
    } else if ((splitView == self.manifestsListSplitView) && (subview == [self.manifestsListSplitView subviews][0])) {
        return NO;
    } else {
        return NO;
    }
}

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex
{
    if (splitView == self.manifestsListSplitView) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex
{
    if (splitView == self.mainSplitView) {
        return NO;
    } else if (splitView == self.manifestsListSplitView && subview == [self.manifestsListSplitView subviews][0]) {
        return YES;
    } else {
        return NO;
    }
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
    } else if (splitView == self.manifestsListSplitView) {
        if (dividerIndex == 0) {
            return [[self.manifestsListSplitView subviews][0] frame].size.height;
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
    } else if (splitView == self.manifestsListSplitView) {
        if (dividerIndex == 0) {
            return [[self.manifestsListSplitView subviews][0] frame].size.height;
        }
    }
    return proposedMax;
}

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    if (sender == self.mainSplitView) {
        /*
         Main split view
         Resize only the right side of the splitview
         */
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
    } else if (sender == self.manifestsListSplitView) {
        /*
         Manifests list split view should be resized automatically
         if the predicate view (top) is hidden. Otherwise only resize
         the bottom view.
         */
        NSView *topView = [sender subviews][0];
        NSView *bottomView = [sender subviews][1];
        
        CGFloat dividerThickness = [sender dividerThickness];
        NSRect newFrame = [sender frame];
        NSRect topFrame = [topView frame];
        NSRect bottomFrame = [bottomView frame];
         
        if ([sender isSubviewCollapsed:topView]) {
            [sender adjustSubviews];
        } else {
            topFrame.size.width = newFrame.size.width;
            topFrame.origin = NSMakePoint(0, 0);
            
            bottomFrame.size.height = newFrame.size.height - topFrame.size.height - dividerThickness;
            bottomFrame.size.width = newFrame.size.width;
            bottomFrame.origin.y = topFrame.size.height + dividerThickness;
            
            [topView setFrame:topFrame];
            [bottomView setFrame:bottomFrame];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self.manifestSourceListTreeController && [keyPath isEqualToString:@"arrangedObjects"]) {
        DDLogVerbose(@"Sidebar tree controller content changed");
        // React to sidebar content changes here
        // You can access the new/old values through the change dictionary
        // NSArray *newObjects = change[NSKeyValueChangeNewKey];
        // NSArray *oldObjects = change[NSKeyValueChangeOldKey];
        
        // Perform any necessary updates when sidebar content changes
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.sourceList reloadData];
            
            // Auto-expand all groups and select the first data item
            [self.sourceList expandItem:nil expandChildren:YES];
            
            // Select "All Manifests" by default (should be at index 1 after the Repository header)
            NSIndexSet *selectionIndexes = [NSIndexSet indexSetWithIndex:1];
            [self.sourceList selectRowIndexes:selectionIndexes byExtendingSelection:NO];
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc
{
    @try {
        [self.manifestSourceListTreeController removeObserver:self forKeyPath:@"arrangedObjects"];
    } @catch (NSException *exception) {
        DDLogError(@"Exception removing observer: %@", exception.reason);
    }
}


@end
