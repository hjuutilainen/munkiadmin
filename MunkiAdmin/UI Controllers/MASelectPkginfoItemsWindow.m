//
//  AddItemsWindow.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 19.10.2011.
//

#import "MASelectPkginfoItemsWindow.h"
#import "DataModelHeaders.h"
#import "MAMunkiAdmin_AppDelegate.h"

@implementation MASelectPkginfoItemsWindow

@dynamic shouldHideAddedItems;

- (void)updateGroupedSearchPredicate
{
    if (self.shouldHideAddedItems) {
        if ([[self.groupedSearchField stringValue] isEqualToString:@""]) {
            NSPredicate *merged = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:self.hideAddedPredicate, self.hideGroupedAppleUpdatesPredicate, nil]];
            [self.groupedPkgsArrayController setFilterPredicate:merged];
        } else {
            NSPredicate *new = [NSPredicate predicateWithFormat:@"munki_name contains[cd] %@", [self.groupedSearchField stringValue]];
            NSPredicate *merged = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:new, self.hideAddedPredicate, self.hideGroupedAppleUpdatesPredicate, nil]];
            [self.groupedPkgsArrayController setFilterPredicate:merged];
        }
    } else {
        if ([[self.groupedSearchField stringValue] isEqualToString:@""]) {
            [self.groupedPkgsArrayController setFilterPredicate:self.hideGroupedAppleUpdatesPredicate];
        } else {
            NSPredicate *new = [NSPredicate predicateWithFormat:@"munki_name contains[cd] %@", [self.groupedSearchField stringValue]];
            NSPredicate *merged = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:new, self.hideGroupedAppleUpdatesPredicate, nil]];
            [self.groupedPkgsArrayController setFilterPredicate:merged];
        }
    }
}

- (void)updateIndividualSearchPredicate
{
    if (self.shouldHideAddedItems) {
        if ([[self.individualSearchField stringValue] isEqualToString:@""]) {
            NSPredicate *merged = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:self.hideAddedPredicate, self.hideIndividualAppleUpdatesPredicate, nil]];
            [self.individualPkgsArrayController setFilterPredicate:merged];
        } else {
            NSPredicate *new = [NSPredicate predicateWithFormat:@"munki_name contains[cd] %@", [self.individualSearchField stringValue]];
            NSPredicate *merged = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:new, self.hideAddedPredicate, self.hideIndividualAppleUpdatesPredicate, nil]];
            [self.individualPkgsArrayController setFilterPredicate:merged];
        }
    } else {
        if ([[self.individualSearchField stringValue] isEqualToString:@""]) {
            [self.individualPkgsArrayController setFilterPredicate:self.hideIndividualAppleUpdatesPredicate];
        } else {
            NSPredicate *new = [NSPredicate predicateWithFormat:@"munki_name contains[cd] %@", [self.individualSearchField stringValue]];
            NSPredicate *merged = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:new, self.hideIndividualAppleUpdatesPredicate, nil]];
            [self.individualPkgsArrayController setFilterPredicate:merged];
        }
    }
}

- (void)setShouldHideAddedItems:(BOOL)newHideAddedItems
{
    shouldHideAddedItems = newHideAddedItems;
    [self updateGroupedSearchPredicate];
}

- (BOOL)shouldHideAddedItems
{
    return shouldHideAddedItems;
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    NSString *selectedTabViewLabel = [[[self tabView] selectedTabViewItem] label];
    if ([selectedTabViewLabel isEqualToString:@"Grouped"]) {
        [self updateGroupedSearchPredicate];
    } else if ([selectedTabViewLabel isEqualToString:@"Individual"]) {
        [self updateIndividualSearchPredicate];
    }
}

- (void)beginSelectSession:(id)delegate
{
    
}

- (NSArray *)selectionAsStringObjects
{
    NSManagedObjectContext *mainContext = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSString *selectedTabViewLabel = [[[self tabView] selectedTabViewItem] label];
    if ([selectedTabViewLabel isEqualToString:@"Grouped"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Adding in Grouped mode");
        for (ApplicationMO *anApp in [[self groupedPkgsArrayController] selectedObjects]) {
            StringObjectMO *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:mainContext];
            newItem.title = anApp.munki_name;
            newItem.originalApplication = anApp;
            [items addObject:newItem];
        }
    } else if ([selectedTabViewLabel isEqualToString:@"Individual"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Adding in Individual mode");
        for (PackageMO *aPackage in [[self individualPkgsArrayController] selectedObjects]) {
            StringObjectMO *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:mainContext];
            NSString *newTitle = [NSString stringWithFormat:@"%@-%@", aPackage.munki_name, aPackage.munki_version];
            newItem.title = newTitle;
            newItem.originalPackage = aPackage;
            [items addObject:newItem];
        }
    } else if ([selectedTabViewLabel isEqualToString:@"Custom"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Adding in Custom mode");
        StringObjectMO *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:mainContext];
        NSString *newTitle = [[self customValueTextField] stringValue];
        newItem.title = newTitle;
        [items addObject:newItem];
    }
    return [NSArray arrayWithArray:items];
}

- (IBAction)cancelAction:(id)sender
{
    [[self window] orderOut:sender];
    [NSApp endSheet:[self window] returnCode:NSCancelButton];
}

- (IBAction)addSelectedAction:(id)sender
{
    [[self window] orderOut:sender];
    [NSApp endSheet:[self window] returnCode:NSOKButton];
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // 0 = nothing
        // 1 = groups
        // 2 = individual
        // 3 = ...
        self.currentMode = 0;
        
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.indSearchBgView.fillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] 
                                                                       endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]];
    
    self.groupSearchBgView.fillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] 
                                                                         endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]];
    
    self.customBgView.fillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] 
                                                                    endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]];
    self.customBgView.drawBottomLine = YES;
    self.customBgView.lineColor = [NSColor grayColor];
    
    /*
     Allow double-clicking items in tableviews
     */
    self.groupedTableView.doubleAction = @selector(addSelectedAction:);
    self.individualTableView.doubleAction = @selector(addSelectedAction:);
    
    /*
     Create predicates to hide "apple_update_metadata" style packages since they should not be added to any manifest.
     These will be used in a compound predicate later when the search field is updated.
     */
    NSString *keyName = @"apple_update_metadata";
    self.hideGroupedAppleUpdatesPredicate = [NSPredicate predicateWithFormat:@"SUBQUERY(packages, $package, $package.munki_installer_type == %@).@count == 0", keyName];
    self.hideIndividualAppleUpdatesPredicate = [NSPredicate predicateWithFormat:@"munki_installer_type != %@", keyName];
    
    [self updateGroupedSearchPredicate];
}

@end
