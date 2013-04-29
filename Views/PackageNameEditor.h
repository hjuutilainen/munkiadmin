//
//  PackageNameEditor.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 28.10.2011.
//

#import <Cocoa/Cocoa.h>

@class PackageMO;

@interface PackageNameEditor : NSWindowController {
    BOOL shouldRenameAll;
    NSString *oldName;
    NSString *changedName;
    NSArray *changeDescriptions;
    NSArrayController *changeDescriptionsArrayController;
    NSUndoManager *undoManager;
    PackageMO *packageToRename;
    
}

+ (void)editSheetForWindow:(id)window delegate:(id)delegate endSelector:(SEL)selector entity:(PackageMO *)object;

- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@property (assign) PackageMO *packageToRename;
@property BOOL shouldRenameAll;
@property (retain) NSString *changedName;
@property (retain) NSString *oldName;
@property (retain) NSArray *changeDescriptions;
@property (assign) IBOutlet NSArrayController *changeDescriptionsArrayController;

@end
