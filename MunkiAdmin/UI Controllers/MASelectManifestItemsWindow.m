//
//  SelectManifestItemsWindow.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 21.10.2011.
//

#import "MASelectManifestItemsWindow.h"

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
        [self.manifestsArrayController setFilterPredicate:nil];
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
    
    [self.existingSearchField setDelegate:self];
    
    /*
     Allow double-clicking items in tableviews
     */
    self.manifestsTableView.target = nil; // first responder
    self.manifestsTableView.doubleAction = @selector(processAddNestedManifestAction:);
    
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

@end
