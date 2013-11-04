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
    InstallsItemMO *__weak itemToEdit;
    NSUndoManager *undoManager;
    NSArray *versionComparisonKeys;
    NSTableView *__weak customItemsTableView;
    NSArrayController *__weak customItemsArrayController;
    NSTextField *__weak textFieldPath;
    NSTextField *__weak textFieldType;
    NSTextField *__weak textFieldCFBundleIdentifier;
    NSTextField *__weak textFieldCFBundleName;
    NSTextField *__weak textFieldCFBundleShortVersionString;
    NSTextField *__weak textFieldCFBundleVersion;
    NSTextField *__weak textFieldMD5Checksum;
    NSTextField *__weak textFieldMinOSVersion;
    NSPopUpButton *__weak versionComparisonKeyPopup;
}

+ (void)editSheetForWindow:(id)window delegate:(id)delegate endSelector:(SEL)selector entity:(InstallsItemMO *)object;

# pragma mark -
# pragma mark Properties
@property (weak) InstallsItemMO *itemToEdit;
@property (readonly, strong) NSArray *versionComparisonKeys;

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
