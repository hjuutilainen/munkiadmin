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
    InstallsItemMO *itemToEdit;
    NSUndoManager *undoManager;
    NSArray *versionComparisonKeys;
    NSTableView *customItemsTableView;
    NSArrayController *customItemsArrayController;
    NSTextField *textFieldPath;
    NSTextField *textFieldType;
    NSTextField *textFieldCFBundleIdentifier;
    NSTextField *textFieldCFBundleName;
    NSTextField *textFieldCFBundleShortVersionString;
    NSTextField *textFieldCFBundleVersion;
    NSTextField *textFieldMD5Checksum;
    NSTextField *textFieldMinOSVersion;
    NSPopUpButton *versionComparisonKeyPopup;
}

+ (void)editSheetForWindow:(id)window delegate:(id)delegate endSelector:(SEL)selector entity:(InstallsItemMO *)object;

# pragma mark -
# pragma mark Properties
@property (assign) InstallsItemMO *itemToEdit;
@property (readonly, retain) NSArray *versionComparisonKeys;

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
