//
//  PackageNameEditor.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 28.10.2011.
//

#import <Cocoa/Cocoa.h>

@class PackageMO;

@interface PackageNameEditor : NSWindowController {
    NSUndoManager *undoManager;
}

- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (void)configureRenameOperation;

@property (assign) PackageMO *packageToRename;
@property BOOL shouldRenameAll;
@property (strong) NSString *changedName;
@property (strong) NSString *oldName;
@property (strong) NSArray *changeDescriptions;
@property (assign) IBOutlet NSArrayController *changeDescriptionsArrayController;

@end
