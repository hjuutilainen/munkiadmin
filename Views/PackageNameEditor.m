//
//  PackageNameEditor.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 28.10.2011.
//

#import "PackageNameEditor.h"
#import "MunkiRepositoryManager.h"
#import "DataModelHeaders.h"

@implementation PackageNameEditor

@synthesize shouldRenameAll;
@synthesize changedName;
@synthesize changeDescriptions;
@synthesize changeDescriptionsArrayController;

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
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.changeDescriptionsArrayController setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
}

@end
