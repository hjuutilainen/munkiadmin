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
@property (weak) InstallsItemMO *itemToEdit;
@property (readonly, strong) NSArray *versionComparisonKeys;
@property NSModalSession modalSession;
@property (strong) NSManagedObjectContext *privateContext;

# pragma mark -
# pragma mark IBOutlets
@property (weak) IBOutlet NSTableView *customItemsTableView;
@property (weak) IBOutlet NSArrayController *customItemsArrayController;
@property (weak) IBOutlet NSTextField *textFieldPath;
@property (weak) IBOutlet NSTextField *textFieldType;
@property (weak) IBOutlet NSTextField *textFieldCFBundleIdentifier;
@property (weak) IBOutlet NSTextField *textFieldCFBundleName;
@property (weak) IBOutlet NSTextField *textFieldCFBundleShortVersionString;
@property (weak) IBOutlet NSTextField *textFieldCFBundleVersion;
@property (weak) IBOutlet NSTextField *textFieldMD5Checksum;
@property (weak) IBOutlet NSTextField *textFieldMinOSVersion;
@property (weak) IBOutlet NSPopUpButton *versionComparisonKeyPopup;

@end
