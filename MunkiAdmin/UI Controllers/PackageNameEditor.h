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
    NSArrayController *__weak changeDescriptionsArrayController;
    NSUndoManager *undoManager;
    PackageMO *__weak packageToRename;
    
}

+ (void)editSheetForWindow:(id)window delegate:(id)delegate endSelector:(SEL)selector entity:(PackageMO *)object;

- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@property (weak) PackageMO *packageToRename;
@property BOOL shouldRenameAll;
@property (strong) NSString *changedName;
@property (strong) NSString *oldName;
@property (strong) NSArray *changeDescriptions;
@property (weak) IBOutlet NSArrayController *changeDescriptionsArrayController;

@end
