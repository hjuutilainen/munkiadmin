//
//  SelectManifestItemsWindow.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 21.10.2011.
//

#import "MASelectManifestItemsWindow.h"
#import "MAMunkiAdmin_AppDelegate.h"

@implementation MASelectManifestItemsWindow

@dynamic originalPredicate;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (void)updateSearchPredicate
{
    if ([[self.existingSearchField stringValue] isEqualToString:@""]) {
        [self.manifestsArrayController setFilterPredicate:self.originalPredicate];
    } else {
        NSPredicate *new = [NSPredicate predicateWithFormat:@"title contains[cd] %@", [self.existingSearchField stringValue]];
        NSPredicate *merged = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:new, self.originalPredicate, nil]];
        [self.manifestsArrayController setFilterPredicate:merged];
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
	[self.manifestsArrayController setSortDescriptors:[NSArray arrayWithObjects:sortByTitle, nil]];
    
    self.existingSearchBgView.fillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] 
                                                                       endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]];
    
    self.customValueBgView.fillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] 
                                                                    endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]];
    self.customValueBgView.drawBottomLine = YES;
    self.customValueBgView.lineColor = [NSColor grayColor];
    
    /*
     Allow double-clicking items in tableviews
     */
    self.manifestsTableView.target = self;
    self.manifestsTableView.doubleAction = @selector(addSelectedAction:);
    
    [self updateSearchPredicate];
}


- (NSPredicate *)originalPredicate
{
    return originalPredicate;
}

- (void)setOriginalPredicate:(NSPredicate *)newPredicate {
    if (originalPredicate != newPredicate) {
        originalPredicate = [newPredicate copy];
        [self.manifestsArrayController setFilterPredicate:originalPredicate];
    }
}


- (void)controlTextDidBeginEditing:(NSNotification *)aNotification
{
    //NSLog(@"controlTextDidBeginEditing");
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    [self updateSearchPredicate];
}

- (NSArray *)selectionAsStringObjects
{
    NSManagedObjectContext *mainContext = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSString *selectedTabViewLabel = [[[self tabView] selectedTabViewItem] label];
    if ([selectedTabViewLabel isEqualToString:@"Existing"]) {
        for (ManifestMO *aManifest in [self.manifestsArrayController selectedObjects]) {
            StringObjectMO *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:mainContext];
            newItem.title = aManifest.title;
            newItem.typeString = @"includedManifest";
            newItem.manifestReference = aManifest;
            [items addObject:newItem];
        }
    } else if ([selectedTabViewLabel isEqualToString:@"Custom"]) {
        StringObjectMO *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:mainContext];
        NSString *newTitle = [self.customValueTextField stringValue];
        newItem.title = newTitle;
        newItem.typeString = @"includedManifest";
        [items addObject:newItem];
    }
    return [NSArray arrayWithArray:items];
}


- (IBAction)cancelAction:(id)sender
{
    if ([NSWindow instancesRespondToSelector:@selector(endSheet:returnCode:)]) {
        // 10.9 or later
        [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
        [self.window orderOut:sender];
    } else {
        // 10.8
        [self.window orderOut:sender];
        [NSApp endSheet:self.window returnCode:NSCancelButton];
    }
}

- (IBAction)addSelectedAction:(id)sender
{
    if ([NSWindow instancesRespondToSelector:@selector(endSheet:returnCode:)]) {
        // 10.9 or later
        [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
        [self.window orderOut:sender];
    } else {
        // 10.8
        [self.window orderOut:sender];
        [NSApp endSheet:self.window returnCode:NSOKButton];
    }
}


@end
