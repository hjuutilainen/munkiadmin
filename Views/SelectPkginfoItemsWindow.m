//
//  AddItemsWindow.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 19.10.2011.
//

#import "SelectPkginfoItemsWindow.h"
#import "ApplicationMO.h"
#import "PackageMO.h"
#import "StringObjectMO.h"

@implementation SelectPkginfoItemsWindow

@synthesize individualPkgsArrayController;
@synthesize groupedPkgsArrayController;
@synthesize tabView;
@synthesize currentMode;
@synthesize customValueTextField;
@synthesize indSearchBgView;
@synthesize groupSearchBgView;
@synthesize customBgView;

- (void)beginSelectSession:(id)delegate
{
    
}

- (NSArray *)selectionAsStringObjects
{
    NSMutableArray *items = [[[NSMutableArray alloc] init] autorelease];
    NSString *selectedTabViewLabel = [[[self tabView] selectedTabViewItem] label];
    if ([selectedTabViewLabel isEqualToString:@"Grouped"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Adding in Grouped mode");
        for (ApplicationMO *anApp in [[self groupedPkgsArrayController] selectedObjects]) {
            StringObjectMO *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
            newItem.title = anApp.munki_name;
            newItem.originalApplication = anApp;
            [items addObject:newItem];
        }
    } else if ([selectedTabViewLabel isEqualToString:@"Individual"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Adding in Individual mode");
        for (PackageMO *aPackage in [[self individualPkgsArrayController] selectedObjects]) {
            StringObjectMO *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
            NSString *newTitle = [NSString stringWithFormat:@"%@-%@", aPackage.munki_name, aPackage.munki_version];
            newItem.title = newTitle;
            newItem.originalPackage = aPackage;
            [items addObject:newItem];
        }
    } else if ([selectedTabViewLabel isEqualToString:@"Custom"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Adding in Custom mode");
        StringObjectMO *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
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
    
    self.indSearchBgView.fillGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] 
                                                                       endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]] autorelease];
    
    self.groupSearchBgView.fillGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] 
                                                                         endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]] autorelease];
    
    self.customBgView.fillGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] 
                                                                    endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]] autorelease];
    self.customBgView.drawBottomLine = YES;
    self.customBgView.lineColor = [NSColor grayColor];
}

@end
