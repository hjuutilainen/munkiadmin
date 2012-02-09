//
//  PredicateEditor.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 9.2.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PredicateEditor.h"

#define DEFAULT_PREDICATE @"os_vers == '10.7'"

@implementation PredicateEditor
@synthesize predEditor;
@synthesize predicate;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        self.predicate = [NSPredicate predicateWithFormat:DEFAULT_PREDICATE];
    }
    
    return self;
}

- (void)awakeFromNib
{
    
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
    [[self window] orderOut:sender];
    [NSApp endSheet:[self window] returnCode:NSCancelButton];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
