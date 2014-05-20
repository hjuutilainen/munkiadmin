//
//  PackageNameEditor.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 28.10.2011.
//

#import <Cocoa/Cocoa.h>

@class PackageMO;

@interface MAPackageNameEditor : NSWindowController {
    NSUndoManager *undoManager;
}

- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (void)configureRenameOperation;

@property (weak) PackageMO *packageToRename;
@property BOOL shouldRenameAll;
@property (strong) NSString *changedName;
@property (strong) NSString *oldName;
@property (strong) NSArray *changeDescriptions;
@property (weak) IBOutlet NSArrayController *changeDescriptionsArrayController;

@end
