//
//  InstallsItemEditor.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 30.4.2013.
//
//

#import "MAInstallsItemEditor.h"
#import "InstallsItemMO.h"
#import "InstallsItemCustomKeyMO.h"
#import "MAMunkiAdmin_AppDelegate.h"

@interface MAInstallsItemEditor ()

@property (readwrite, strong) NSArray *versionComparisonKeys;

- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)addNewCustomInstallAction:(id)sender;
- (IBAction)removeCustomInstallAction:(id)sender;

@end

@implementation MAInstallsItemEditor

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
    NSMutableArray *newKeyNames = [[NSMutableArray alloc] init];
    [newKeyNames addObjectsFromArray:@[@"CFBundleShortVersionString", @"CFBundleVersion"]];
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
    NSManagedObjectContext *moc = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
    InstallsItemCustomKeyMO *newKey = [NSEntityDescription insertNewObjectForEntityForName:@"InstallsItemCustomKey" inManagedObjectContext:moc];
    newKey.installsItem = self.itemToEdit;
    [moc refreshObject:self.itemToEdit mergeChanges:YES];
    [self updateVersionComparisonKeys];
}

- (IBAction)removeCustomInstallAction:(id)sender
{
    NSManagedObjectContext *moc = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
    [self.customItemsArrayController.selectedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [moc deleteObject:obj];
    }];
    [self updateVersionComparisonKeys];
}

- (IBAction)okAction:(id)sender
{
    NSError *validateError = nil;
    if (![self.itemToEdit validateForUpdate:&validateError]) {
        [NSApp presentError:validateError];
    } else {
        [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
        [self.window orderOut:sender];
    }
}

- (IBAction)cancelAction:(id)sender
{
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
    [self.window orderOut:sender];
}


@end
