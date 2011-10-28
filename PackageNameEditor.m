//
//  PackageNameEditor.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 28.10.2011.
//

#import "PackageNameEditor.h"

@implementation PackageNameEditor

@synthesize shouldRenameAll;
@synthesize changedName;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        self.shouldRenameAll = YES;
        self.changedName = @"";
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
