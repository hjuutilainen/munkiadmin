//
//  InstallsItemEditor.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 30.4.2013.
//
//

#import "InstallsItemEditor.h"
#import "InstallsItemMO.h"
#import "InstallsItemCustomKeyMO.h"

@interface InstallsItemEditor ()

@property (readwrite, retain) NSArray *versionComparisonKeys;

- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)addNewCustomInstallAction:(id)sender;
- (IBAction)removeCustomInstallAction:(id)sender;

@end

@implementation InstallsItemEditor

@synthesize itemToEdit;
@synthesize versionComparisonKeys;
@synthesize customItemsTableView;
@synthesize customItemsArrayController;
@synthesize textFieldPath;
@synthesize textFieldType;
@synthesize textFieldCFBundleIdentifier;
@synthesize textFieldCFBundleName;
@synthesize textFieldCFBundleShortVersionString;
@synthesize textFieldCFBundleVersion;
@synthesize textFieldMD5Checksum;
@synthesize textFieldMinOSVersion;
@synthesize versionComparisonKeyPopup;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    if (!undoManager) {
        undoManager = [[NSUndoManager alloc] init];
    }
    return undoManager;
}

- (void)updateVersionComparisonKeys
{
    NSMutableArray *newKeyNames = [[[NSMutableArray alloc] init] autorelease];
    [newKeyNames addObjectsFromArray:[NSArray arrayWithObjects:@"CFBundleShortVersionString", @"CFBundleVersion", nil]];
    NSArray *customKeysFromInstallsItem = [[[self.itemToEdit.customKeys allObjects] valueForKeyPath:@"@distinctUnionOfObjects.customKeyName"] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    if (customKeysFromInstallsItem) {
        [newKeyNames addObjectsFromArray:customKeysFromInstallsItem];
    }
    [self setVersionComparisonKeys:[NSArray arrayWithArray:newKeyNames]];
}


- (void)tableViewDidEndAllEditing:(id)sender
{
    [self updateVersionComparisonKeys];
}

- (IBAction)addNewCustomInstallAction:(id)sender
{
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    InstallsItemCustomKeyMO *newKey = [NSEntityDescription insertNewObjectForEntityForName:@"InstallsItemCustomKey" inManagedObjectContext:moc];
    newKey.installsItem = self.itemToEdit;
    [moc refreshObject:self.itemToEdit mergeChanges:YES];
    [self updateVersionComparisonKeys];
}

- (IBAction)removeCustomInstallAction:(id)sender
{
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    [self.customItemsArrayController.selectedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [moc deleteObject:obj];
    }];
    [self updateVersionComparisonKeys];
}

- (IBAction)okAction:(id)sender;
{    
    [[self window] orderOut:sender];
    [NSApp endSheet:[self window] returnCode:NSOKButton];
}

- (IBAction)cancelAction:(id)sender;
{
    [[self window] orderOut:sender];
    [NSApp endSheet:[self window] returnCode:NSCancelButton];
}

+ (void)editSheetForWindow:(id)window delegate:(id)delegate endSelector:(SEL)selector entity:(InstallsItemMO *)object;
{
    InstallsItemEditor *controller;
    controller = [[InstallsItemEditor alloc] initWithWindowNibName:@"InstallsItemEditor"];
    
    controller.itemToEdit = object;
    
    [controller updateVersionComparisonKeys];
    
    [NSApp beginSheet:[controller window]
       modalForWindow:window
        modalDelegate:delegate
       didEndSelector:selector
          contextInfo:object];
}

@end
