//
//  SelectManifestItemsWindow.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 21.10.2011.
//

#import "SelectManifestItemsWindow.h"

@implementation SelectManifestItemsWindow

@dynamic originalPredicate;
@synthesize existingSearchBgView;
@synthesize customValueBgView;
@synthesize customValueTextField;
@synthesize tabView;
@synthesize manifestsArrayController;
@synthesize existingSearchField;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [originalPredicate release];
    [manifestsArrayController release];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
	[self.manifestsArrayController setSortDescriptors:[NSArray arrayWithObjects:sortByTitle, nil]];
    
    self.existingSearchBgView.fillGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] 
                                                                       endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]] autorelease];
    
    self.customValueBgView.fillGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] 
                                                                    endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]] autorelease];
    self.customValueBgView.drawBottomLine = YES;
    self.customValueBgView.lineColor = [NSColor grayColor];
    
    [existingSearchField setDelegate:self];
    
    [self.manifestsArrayController setFilterPredicate:self.originalPredicate];
}


- (NSPredicate *)originalPredicate
{
    return originalPredicate;
}

- (void)setOriginalPredicate:(NSPredicate *)newPredicate {
    if (originalPredicate != newPredicate) {
        [originalPredicate release];
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
    if ([[self.existingSearchField stringValue] isEqualToString:@""]) {
        [self.manifestsArrayController setFilterPredicate:self.originalPredicate];
    } else {
        NSPredicate *new = [NSPredicate predicateWithFormat:@"title contains[cd] %@", [self.existingSearchField stringValue]];
        NSPredicate *merged = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:new, self.originalPredicate, nil]];
        [self.manifestsArrayController setFilterPredicate:merged];
    }
}

@end
