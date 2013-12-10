//
//  InstallsItemEditor.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 30.4.2013.
//
//

#import <Cocoa/Cocoa.h>

@class InstallsItemMO;

@interface InstallsItemEditor : NSWindowController <NSTableViewDelegate> {
    NSUndoManager *undoManager;
}

- (void)updateVersionComparisonKeys;

# pragma mark -
# pragma mark Properties
@property (assign) InstallsItemMO *itemToEdit;
@property (readonly, strong) NSArray *versionComparisonKeys;
@property NSModalSession modalSession;
@property (strong) NSManagedObjectContext *privateContext;

# pragma mark -
# pragma mark IBOutlets
@property (assign) IBOutlet NSTableView *customItemsTableView;
@property (assign) IBOutlet NSArrayController *customItemsArrayController;
@property (assign) IBOutlet NSTextField *textFieldPath;
@property (assign) IBOutlet NSTextField *textFieldType;
@property (assign) IBOutlet NSTextField *textFieldCFBundleIdentifier;
@property (assign) IBOutlet NSTextField *textFieldCFBundleName;
@property (assign) IBOutlet NSTextField *textFieldCFBundleShortVersionString;
@property (assign) IBOutlet NSTextField *textFieldCFBundleVersion;
@property (assign) IBOutlet NSTextField *textFieldMD5Checksum;
@property (assign) IBOutlet NSTextField *textFieldMinOSVersion;
@property (assign) IBOutlet NSPopUpButton *versionComparisonKeyPopup;

@end
