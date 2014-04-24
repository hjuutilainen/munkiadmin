//
//  MACreateNewCategoryController.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 22.4.2014.
//
//

#import "MARequestStringValueController.h"

@interface MARequestStringValueController ()

@end

@implementation MARequestStringValueController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        [self setDefaultValues];
    }
    return self;
}

- (void)setDefaultValues
{
    self.okButtonTitle = NSLocalizedString(@"OK", @"OK button default value");
    self.cancelButtonTitle = NSLocalizedString(@"Cancel", @"Cancel button default value");
    self.stringValue = nil;
    self.titleText = @"";
    self.labelText = NSLocalizedString(@"Title:", @"Label text default value");;
    self.windowTitleText = @"Window";
    self.descriptionText = @"";
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (IBAction)okAction:(id)sender;
{
    [[self window] orderOut:sender];
    [NSApp stopModalWithCode:NSModalResponseOK];
}

- (IBAction)cancelAction:(id)sender;
{
    [[self window] orderOut:sender];
    [NSApp stopModalWithCode:NSModalResponseCancel];
}

@end
