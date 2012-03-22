//
//  PredicateEditor.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 9.2.2012.
//

#import "PredicateEditor.h"
#import "ConditionalItemMO.h"

#define DEFAULT_PREDICATE @"os_vers == '' AND arch == ''"

@implementation PredicateEditor
@synthesize predicateEditor;
@synthesize predicate;
@synthesize tabView;
@synthesize customTextField;
@synthesize predicateEditorTabViewItem;
@synthesize customTabViewItem;
@synthesize conditionToEdit;
@synthesize customPredicateString;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {        
        self.predicate = [NSPredicate predicateWithFormat:DEFAULT_PREDICATE];
    }
    
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)resetPredicateToDefault
{
    self.predicate = [NSPredicate predicateWithFormat:DEFAULT_PREDICATE];
    self.customPredicateString = [NSString stringWithString:DEFAULT_PREDICATE];
}

- (void)saveAction:(id)sender;
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    
    [[self window] orderOut:sender];
    [NSApp endSheet:[self window] returnCode:NSOKButton];
}

- (void)cancelAction:(id)sender;
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    
    [[self window] orderOut:sender];
    [NSApp endSheet:[self window] returnCode:NSCancelButton];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

@end
