//
//  PredicateEditor.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 9.2.2012.
//

#import "MAPredicateEditor.h"
#import "ConditionalItemMO.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

#define DEFAULT_PREDICATE @"os_vers == '' AND arch == ''"

@implementation MAPredicateEditor

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
    self.customPredicateString = DEFAULT_PREDICATE;
}

- (void)saveAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    if ([NSWindow instancesRespondToSelector:@selector(endSheet:returnCode:)]) {
        // 10.9 or later
        [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
        [self.window orderOut:sender];
    } else {
        // 10.8 or earlier
        [self.window orderOut:sender];
        [NSApp endSheet:self.window returnCode:NSOKButton];
    }
}

- (void)cancelAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    if ([NSWindow instancesRespondToSelector:@selector(endSheet:returnCode:)]) {
        // 10.9 or later
        [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
        [self.window orderOut:sender];
    } else {
        // 10.8 or earlier
        [self.window orderOut:sender];
        [NSApp endSheet:self.window returnCode:NSCancelButton];
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

@end
