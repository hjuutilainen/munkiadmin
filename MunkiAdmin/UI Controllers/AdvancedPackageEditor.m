//
//  AdvancedPackageEditor.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 19.12.2011.
//

#import "AdvancedPackageEditor.h"
#import "DataModelHeaders.h"
#import "MAMunkiAdmin_AppDelegate.h"
#import "MAMunkiRepositoryManager.h"
#import "MAMunkiOperation.h"
#import "SelectPkginfoItemsWindow.h"
#import "PackageNameEditor.h"
#import "InstallsItemEditor.h"
#import "MACoreDataManager.h"
#import "MARequestStringValueController.h"
#import "MAIconEditor.h"

#define kMinSplitViewWidth      300.0f

@implementation AdvancedPackageEditor

NSString *installsPboardType = @"installsPboardType";
NSString *itemsToCopyPboardType = @"itemsToCopyPboardType";
NSString *receiptsPboardType = @"receiptsPboardType";
NSString *installerChoicesXMLPboardType = @"installerChoicesXMLPboardType";
NSString *installerEnvironmentPboardType = @"installerEnvironmentPboardType";
NSString *stringObjectPboardType = @"stringObjectPboardType";


- (NSUndoManager*)windowWillReturnUndoManager:(NSWindow*)window
{
    if (!undoManager) {
        undoManager = [[NSUndoManager alloc] init];
    }
    return undoManager;
}


- (NSModalSession)beginEditSessionWithObject:(PackageMO *)aPackage delegate:(id)modalDelegate
{
    self.pkginfoToEdit = aPackage;
    self.delegate = modalDelegate;
    [self.mainTabView selectTabViewItemAtIndex:0];
    
    // Set the force_install_after_date date picker to use UTC
    NSTimeZone *timeZoneUTC = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setTimeZone:timeZoneUTC];
    [self.forceInstallDatePicker setCalendar:gregorian];
    [self.forceInstallDatePicker setTimeZone:timeZoneUTC];
    
    [self setDefaultValuesFromPackage:self.pkginfoToEdit];
    
    self.modalSession = [NSApp beginModalSessionForWindow:self.window];
    [NSApp runModalSession:self.modalSession];
    return self.modalSession;
}

- (void)packageNameEditorDidFinish:(id)sender returnCode:(int)returnCode object:(id)object
{
    [[[[NSApp delegate] managedObjectContext] undoManager] endUndoGrouping];
    if (returnCode == NSOKButton) return;
    [[[[NSApp delegate] managedObjectContext] undoManager] undoNestedGroup];
}


- (void)renameCurrentPackage
{
    [[[[NSApp delegate] managedObjectContext] undoManager] beginUndoGrouping];
    self.packageNameEditor.packageToRename = self.pkginfoToEdit;
    [self.packageNameEditor configureRenameOperation];
    SEL endSelector = @selector(packageNameEditorDidFinish:returnCode:object:);
    [NSApp beginSheet:[self.packageNameEditor window]
	   modalForWindow:[self window] modalDelegate:self
	   didEndSelector:endSelector contextInfo:nil];
}

- (IBAction)renameCurrentPackageAction:(id)sender
{
    [self renameCurrentPackage];
}

- (void)addRequiresItemSheetDidEnd:(id)sheet returnCode:(int)returnCode object:(id)object
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    if (returnCode == NSCancelButton) return;
    
    for (StringObjectMO *selectedItem in [pkginfoSelector selectionAsStringObjects]) {
        selectedItem.typeString = @"package";
        [self.pkginfoToEdit addRequirementsObject:selectedItem];
    }
}

- (IBAction)addRequiresItemAction:(id)sender
{
    [NSApp beginSheet:[pkginfoSelector window]
	   modalForWindow:[self window] modalDelegate:self 
	   didEndSelector:@selector(addRequiresItemSheetDidEnd:returnCode:object:) contextInfo:nil];
}

- (void)addUpdateForItemSheetDidEnd:(id)sheet returnCode:(int)returnCode object:(id)object
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    if (returnCode == NSCancelButton) return;
    
    for (StringObjectMO *selectedItem in [pkginfoSelector selectionAsStringObjects]) {
        selectedItem.typeString = @"package";
        [self.pkginfoToEdit addUpdateForObject:selectedItem];
    }
}

- (IBAction)addUpdateForItem:(id)sender
{
    [NSApp beginSheet:[pkginfoSelector window]
	   modalForWindow:[self window] modalDelegate:self 
	   didEndSelector:@selector(addUpdateForItemSheetDidEnd:returnCode:object:) contextInfo:nil];
}

- (void)installsItemEditorDidFinish:(id)sender returnCode:(int)returnCode object:(id)object
{
    [[[[NSApp delegate] managedObjectContext] undoManager] endUndoGrouping];
    if (returnCode == NSOKButton) return;
    [[[[NSApp delegate] managedObjectContext] undoManager] undoNestedGroup];
}

- (void)editInstallsItem
{
    if ([[self.installsItemsController selectedObjects] count] == 0) {
        return;
    }
    InstallsItemMO *selected = [[self.installsItemsController selectedObjects] objectAtIndex:0];
    if (!selected) {
        return;
    }
    [[[[NSApp delegate] managedObjectContext] undoManager] beginUndoGrouping];
    self.installsItemEditor.itemToEdit = selected;
    [NSApp beginSheet:[self.installsItemEditor window]
	   modalForWindow:[self window] modalDelegate:self
	   didEndSelector:@selector(installsItemEditorDidFinish:returnCode:object:) contextInfo:nil];
    [self.installsItemEditor updateVersionComparisonKeys];
    
    
}

- (void)installsItemDidFinish:(NSDictionary *)pkginfoPlist
{
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	NSDictionary *installsItemProps = [[pkginfoPlist objectForKey:@"installs"] objectAtIndex:0];
	if (installsItemProps != nil) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Got new dictionary from makepkginfo");
        InstallsItemMO *newInstallsItem = [[MACoreDataManager sharedManager] createInstallsItemFromDictionary:installsItemProps inManagedObjectContext:moc];
        [self.pkginfoToEdit addInstallsItemsObject:newInstallsItem];
	} else {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Error. Got nil from makepkginfo");
	}
    
}

- (IBAction)addInstallsItemFromDiskAction:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	if ([[NSApp delegate] makepkginfoInstalled]) {
		NSArray *filesToAdd = [[NSApp delegate] chooseFiles];
		if (filesToAdd) {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Adding %lu installs items", (unsigned long)[filesToAdd count]);
			for (NSURL *fileToAdd in filesToAdd) {
				if (fileToAdd != nil) {
					MAMunkiOperation *theOp = [MAMunkiOperation installsItemFromURL:fileToAdd];
					theOp.delegate = self;
					[[[NSApp delegate] operationQueue] addOperation:theOp];
				}
			}
		}
	} else {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Can't find %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"makepkginfoPath"]);
	}
}


- (void)createNewCategory
{
    [self.createNewCategoryController setDefaultValues];
    self.createNewCategoryController.windowTitleText = @"New Category";
    self.createNewCategoryController.titleText = @"New Category";
    self.createNewCategoryController.okButtonTitle = @"Create";
    self.createNewCategoryController.labelText = @"Name:";
    self.createNewCategoryController.descriptionText = @"Enter name for new category. The category is written in to the pkginfo files and empty categories will not be saved when MunkiAdmin quits.";
    NSWindow *window = [self.createNewCategoryController window];
    NSInteger result = [NSApp runModalForWindow:window];
    
    if (result == NSModalResponseOK) {
        CategoryMO *newCategory = [[MACoreDataManager sharedManager] createCategoryWithTitle:self.createNewCategoryController.stringValue
                                                                      inManagedObjectContext:nil];
        [self.categoriesArrayController prepareContent];
        
        if (newCategory != nil) {
            self.pkginfoToEdit.category = newCategory;
            self.pkginfoToEdit.hasUnstagedChangesValue = YES;
        }
        
        [[MACoreDataManager sharedManager] configureSourceListCategoriesSection:[[NSApp delegate] managedObjectContext]];
        [[NSApp delegate] updateSourceList];
        
    }
    [self.createNewCategoryController setDefaultValues];
}

- (IBAction)createNewCategoryAction:(id)sender
{
    [self createNewCategory];
}


- (void)createNewDeveloper
{
    [self.createNewDeveloperController setDefaultValues];
    self.createNewDeveloperController.windowTitleText = @"New Developer";
    self.createNewDeveloperController.titleText = @"New Developer";
    self.createNewDeveloperController.okButtonTitle = @"Create";
    self.createNewDeveloperController.labelText = @"Name:";
    self.createNewDeveloperController.descriptionText = @"Enter name for new developer. The developer is written in to the pkginfo files and empty developers will not be saved when MunkiAdmin quits.";
    NSWindow *window = [self.createNewDeveloperController window];
    NSInteger result = [NSApp runModalForWindow:window];
    
    if (result == NSModalResponseOK) {
        DeveloperMO *newDeveloper = [[MACoreDataManager sharedManager] createDeveloperWithTitle:self.createNewDeveloperController.stringValue
                                                                         inManagedObjectContext:nil];
        [self.developersArrayController prepareContent];
        
        if (newDeveloper != nil) {
            self.pkginfoToEdit.developer = newDeveloper;
            self.pkginfoToEdit.hasUnstagedChangesValue = YES;
        }
        [[MACoreDataManager sharedManager] configureSourceListDevelopersSection:[[NSApp delegate] managedObjectContext]];
        [[NSApp delegate] updateSourceList];
    }
    
    [self.createNewDeveloperController setDefaultValues];
}

- (IBAction)createNewDeveloperAction:(id)sender
{
    [self createNewDeveloper];
}


- (void)commitChangesToCurrentPackage
{
    // Empty blocking_applications array
    if (self.temp_blocking_applications_include_empty) {
        for (StringObjectMO *blockApp in self.pkginfoToEdit.blockingApplications) {
            [self.pkginfoToEdit removeBlockingApplicationsObject:blockApp];
        }
        self.pkginfoToEdit.hasEmptyBlockingApplicationsValue = YES;
    } else {
        self.pkginfoToEdit.hasEmptyBlockingApplicationsValue = NO;
    }
    
    // Scripts
    if (self.temp_preinstall_script_enabled) {
        if (self.temp_preinstall_script) {
            self.pkginfoToEdit.munki_preinstall_script = self.temp_preinstall_script;
        } else {
            self.pkginfoToEdit.munki_preinstall_script = @"";
        }
    } else {
        self.pkginfoToEdit.munki_preinstall_script = nil;
    }
    
    if (self.temp_postinstall_script_enabled) {
        if (self.temp_postinstall_script) {
            self.pkginfoToEdit.munki_postinstall_script = self.temp_postinstall_script;
        } else {
            self.pkginfoToEdit.munki_postinstall_script = @"";
        }
    } else {
        self.pkginfoToEdit.munki_postinstall_script = nil;
    }
    
    if (self.temp_postuninstall_script_enabled) {
        if (self.temp_postuninstall_script) {
            self.pkginfoToEdit.munki_postuninstall_script = self.temp_postuninstall_script;
        } else {
            self.pkginfoToEdit.munki_postuninstall_script = @"";
        }
    } else {
        self.pkginfoToEdit.munki_postuninstall_script = nil;
    }
    
    if (self.temp_preuninstall_script_enabled) {
        if (self.temp_preuninstall_script) {
            self.pkginfoToEdit.munki_preuninstall_script = self.temp_preuninstall_script;
        } else {
            self.pkginfoToEdit.munki_preuninstall_script = @"";
        }
    } else {
        self.pkginfoToEdit.munki_preuninstall_script = nil;
    }
    
    if (self.temp_uninstall_script_enabled) {
        if (self.temp_uninstall_script) {
            self.pkginfoToEdit.munki_uninstall_script = self.temp_uninstall_script;
        } else {
            self.pkginfoToEdit.munki_uninstall_script = @"";
        }
    } else {
        self.pkginfoToEdit.munki_uninstall_script = nil;
    }
    
    if (self.temp_installcheck_script_enabled) {
        if (self.temp_installcheck_script) {
            self.pkginfoToEdit.munki_installcheck_script = self.temp_installcheck_script;
        } else {
            self.pkginfoToEdit.munki_installcheck_script = @"";
        }
    } else {
        self.pkginfoToEdit.munki_installcheck_script = nil;
    }
    
    if (self.temp_uninstallcheck_script_enabled) {
        if (self.temp_uninstallcheck_script) {
            self.pkginfoToEdit.munki_uninstallcheck_script = self.temp_uninstallcheck_script;
        } else {
            self.pkginfoToEdit.munki_uninstallcheck_script = @"";
        }
    } else {
        self.pkginfoToEdit.munki_uninstallcheck_script = nil;
    }
    
    
    if (self.temp_force_install_after_date_enabled) {
        self.pkginfoToEdit.munki_force_install_after_date = self.temp_force_install_after_date;
    } else {
        self.pkginfoToEdit.munki_force_install_after_date = nil;
    }
}

- (void)saveAction:(id)sender;
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    
    [self commitChangesToCurrentPackage];
        
    [[self window] orderOut:sender];
    [NSApp endModalSession:self.modalSession];
    [NSApp stopModal];
    
    if ([self.delegate respondsToSelector:@selector(packageEditorDidFinish:returnCode:object:)]) {
        [self.delegate packageEditorDidFinish:self returnCode:NSOKButton object:nil];
    }
}

- (void)cancelAction:(id)sender;
{    
    [[self window] orderOut:sender];
    [NSApp endModalSession:self.modalSession];
    [NSApp stopModal];
    
    if ([self.delegate respondsToSelector:@selector(packageEditorDidFinish:returnCode:object:)]) {
        [self.delegate packageEditorDidFinish:self returnCode:NSCancelButton object:nil];
    }
}

- (id)initWithWindow:(NSWindow *)window
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSArray *)getItemsOfTypeFromPasteboard:(NSString *)pboardType
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    
    // Get the archived custom data from pasteboard
    NSData *archivedItems = [pb dataForType:pboardType];
    
    // Unarchive
    NSArray *itemsFromPasteboard = [NSKeyedUnarchiver unarchiveObjectWithData:archivedItems];
    return itemsFromPasteboard;
}

- (void)copyItems:(NSArray *)items forType:(NSString *)pboardType
{
    // Copy the data to pasteboard
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSArray *pb_types = [NSArray arrayWithObjects:pboardType, NSStringPboardType, nil];
    [pb declareTypes:pb_types owner:nil];
    [pb setData:[NSKeyedArchiver archivedDataWithRootObject:items] forType:pboardType];
    
    // As a convenience, copy the data as a string too
    NSData *data;
    NSString *error;
    data = [NSPropertyListSerialization dataFromPropertyList:items
                                                      format:NSPropertyListXMLFormat_v1_0
                                            errorDescription:&error];
    if (data) {
        NSString *str = [NSString stringWithUTF8String:[data bytes]];
        [pb setString:str forType:NSStringPboardType];
    }
}


- (IBAction)paste:(id)sender
{    
    // Get the destination table view
    NSResponder *firstResponder;
    firstResponder = [[self window] firstResponder];
    
    MACoreDataManager *coreDataManager = [MACoreDataManager sharedManager];
    NSManagedObjectContext *mainMoc = [[NSApp delegate] managedObjectContext];
    
    // Create new objects based on the destination and pasteboard contents
    if (firstResponder == self.installsTableView) {
        for (NSDictionary *item in [self getItemsOfTypeFromPasteboard:installsPboardType]) {
            InstallsItemMO *newInstallsItem = [coreDataManager createInstallsItemFromDictionary:item inManagedObjectContext:mainMoc];
            [self.pkginfoToEdit addInstallsItemsObject:newInstallsItem];
        }
    } else if (firstResponder == self.receiptsTableView) {
        for (NSDictionary *item in [self getItemsOfTypeFromPasteboard:receiptsPboardType]) {
            ReceiptMO *newReceipt = [NSEntityDescription insertNewObjectForEntityForName:@"Receipt" inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
            newReceipt.munki_filename = [item objectForKey:@"filename"];
            newReceipt.munki_installed_size = [item objectForKey:@"installed_size"];
            newReceipt.munki_name = [item objectForKey:@"name"];
            newReceipt.munki_optional = [item objectForKey:@"optional"];
            newReceipt.munki_packageid = [item objectForKey:@"packageid"];
            newReceipt.munki_version = [item objectForKey:@"version"];
            [self.pkginfoToEdit addReceiptsObject:newReceipt];
        }
    } else if (firstResponder == self.itemsToCopyTableView) {
        for (NSDictionary *item in [self getItemsOfTypeFromPasteboard:itemsToCopyPboardType]) {
            ItemToCopyMO *newItemToCopy = [NSEntityDescription insertNewObjectForEntityForName:@"ItemToCopy" inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
            newItemToCopy.munki_destination_item = [item objectForKey:@"destination_item"];
            newItemToCopy.munki_destination_path = [item objectForKey:@"destination_path"];
            newItemToCopy.munki_group = [item objectForKey:@"group"];
            newItemToCopy.munki_mode = [item objectForKey:@"mode"];
            newItemToCopy.munki_source_item = [item objectForKey:@"source_item"];
            newItemToCopy.munki_user = [item objectForKey:@"user"];
            [self.pkginfoToEdit addItemsToCopyObject:newItemToCopy];
        }
    } else if (firstResponder == self.installerChoicesXMLTableView) {
        for (NSDictionary *item in [self getItemsOfTypeFromPasteboard:installerChoicesXMLPboardType]) {
            InstallerChoicesItemMO *newInstallerChoicesItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallerChoicesItem" inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
            newInstallerChoicesItem.munki_attributeSetting = [item objectForKey:@"attributeSetting"];
            newInstallerChoicesItem.munki_choiceAttribute = [item objectForKey:@"choiceAttribute"];
            newInstallerChoicesItem.munki_choiceIdentifier = [item objectForKey:@"choiceIdentifier"];
            [self.pkginfoToEdit addInstallerChoicesItemsObject:newInstallerChoicesItem];
        }
    } else if (firstResponder == self.blockingApplicationsTableView) {
        for (NSString *item in [self getItemsOfTypeFromPasteboard:stringObjectPboardType]) {
            StringObjectMO *newStringObject = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
            newStringObject.title = item;
            newStringObject.typeString = @"package";
            [self.pkginfoToEdit addBlockingApplicationsObject:newStringObject];
        }
    } else if (firstResponder == self.supportedArchitecturesTableView) {
        for (NSString *item in [self getItemsOfTypeFromPasteboard:stringObjectPboardType]) {
            StringObjectMO *newStringObject = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
            newStringObject.title = item;
            newStringObject.typeString = @"package";
            [self.pkginfoToEdit addSupportedArchitecturesObject:newStringObject];
        }
    }
}

- (IBAction)copy:(id)sender
{
    // Get the sending table view
    NSResponder *firstResponder;
    firstResponder = [[self window] firstResponder];
    
    if (firstResponder == self.installsTableView) {
        NSArray *selectedObjects = [[self.installsItemsController selectedObjects] valueForKeyPath:@"dictValueForSave"];
        [self copyItems:selectedObjects forType:installsPboardType];
    } else if (firstResponder == self.receiptsTableView) {
        NSArray *selectedObjects = [[self.receiptsArrayController selectedObjects] valueForKeyPath:@"dictValueForSave"];
        [self copyItems:selectedObjects forType:receiptsPboardType];
    } else if (firstResponder == self.itemsToCopyTableView) {
        NSArray *selectedObjects = [[self.itemsToCopyArrayController selectedObjects] valueForKeyPath:@"dictValueForSave"];
        [self copyItems:selectedObjects forType:itemsToCopyPboardType];
    } else if (firstResponder == self.installerChoicesXMLTableView) {
        NSArray *selectedObjects = [[self.installerChoicesArrayController selectedObjects] valueForKeyPath:@"dictValueForSave"];
        [self copyItems:selectedObjects forType:installerChoicesXMLPboardType];
    } else if (firstResponder == self.blockingApplicationsTableView) {
        NSArray *selectedObjects = [[self.blockingApplicationsArrayController selectedObjects] valueForKeyPath:@"title"];
        [self copyItems:selectedObjects forType:stringObjectPboardType];
    } else if (firstResponder == self.supportedArchitecturesTableView) {
        NSArray *selectedObjects = [[self.supportedArchitecturesArrayController selectedObjects] valueForKeyPath:@"title"];
        [self copyItems:selectedObjects forType:stringObjectPboardType];
    }
}

- (IBAction)cut:(id)sender
{
    // Get the sending table view
    NSResponder *firstResponder;
    firstResponder = [[self window] firstResponder];
    
    if (firstResponder == self.installsTableView) {
        NSArray *selectedObjects = [self.installsItemsController selectedObjects];
        NSArray *selectedObjectDicts = [[self.installsItemsController selectedObjects] valueForKeyPath:@"dictValueForSave"];
        [self copyItems:selectedObjectDicts forType:installsPboardType];
        for (InstallsItemMO *installsItem in selectedObjects) {
            [self.pkginfoToEdit removeInstallsItemsObject:installsItem];
        }
    } else if (firstResponder == self.receiptsTableView) {
        NSArray *selectedObjects = [self.receiptsArrayController selectedObjects];
        NSArray *selectedObjectDicts = [[self.receiptsArrayController selectedObjects] valueForKeyPath:@"dictValueForSave"];
        [self copyItems:selectedObjectDicts forType:receiptsPboardType];
        for (ReceiptMO *receipt in selectedObjects) {
            [self.pkginfoToEdit removeReceiptsObject:receipt];
        }
    } else if (firstResponder == self.itemsToCopyTableView) {
        NSArray *selectedObjects = [self.itemsToCopyArrayController selectedObjects];
        NSArray *selectedObjectDicts = [[self.itemsToCopyArrayController selectedObjects] valueForKeyPath:@"dictValueForSave"];
        [self copyItems:selectedObjectDicts forType:itemsToCopyPboardType];
        for (ItemToCopyMO *item in selectedObjects) {
            [self.pkginfoToEdit removeItemsToCopyObject:item];
        }
    } else if (firstResponder == self.installerChoicesXMLTableView) {        
        NSArray *selectedObjects = [self.installerChoicesArrayController selectedObjects];
        NSArray *selectedObjectDicts = [[self.installerChoicesArrayController selectedObjects] valueForKeyPath:@"dictValueForSave"];
        [self copyItems:selectedObjectDicts forType:installerChoicesXMLPboardType];
        for (InstallerChoicesItemMO *item in selectedObjects) {
            [self.pkginfoToEdit removeInstallerChoicesItemsObject:item];
        }
    } else if (firstResponder == self.blockingApplicationsTableView) {        
        NSArray *selectedObjects = [self.blockingApplicationsArrayController selectedObjects];
        NSArray *selectedObjectTitles = [[self.blockingApplicationsArrayController selectedObjects] valueForKeyPath:@"title"];
        [self copyItems:selectedObjectTitles forType:stringObjectPboardType];
        for (StringObjectMO *object in selectedObjects) {
            [self.pkginfoToEdit removeBlockingApplicationsObject:object];
        }
    } else if (firstResponder == self.supportedArchitecturesTableView) {        
        NSArray *selectedObjects = [self.supportedArchitecturesArrayController selectedObjects];
        NSArray *selectedObjectTitles = [[self.supportedArchitecturesArrayController selectedObjects] valueForKeyPath:@"title"];
        [self copyItems:selectedObjectTitles forType:stringObjectPboardType];
        for (StringObjectMO *architecture in selectedObjects) {
            [self.pkginfoToEdit removeSupportedArchitecturesObject:architecture];
        }
    }
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
    if (aTableView == self.installsTableView) {
        NSArray *selectedObjects = [[self.installsItemsController selectedObjects] valueForKeyPath:@"dictValueForSave"];
        [self copyItems:selectedObjects forType:installsPboardType];
        return YES;
    }
    return NO;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard *pasteboard = [info draggingPasteboard];
    
    if (aTableView == self.installsTableView) {
        NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSPasteboardURLReadingFileURLsOnlyKey];
        NSArray *fileURLs = [pasteboard readObjectsForClasses:classes options:options];
        for (NSURL *url in fileURLs) {
            MAMunkiOperation *theOp = [MAMunkiOperation installsItemFromURL:url];
            theOp.delegate = self;
            [[[NSApp delegate] operationQueue] addOperation:theOp];
        }
        return YES;
    }
    return NO;
}


- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard *pasteboard = [info draggingPasteboard];
    
    if (aTableView == self.installsTableView) {
        if ([[pasteboard types] containsObject:NSURLPboardType]) {
            // The drop should always target the whole table view
            [aTableView setDropRow:-1 dropOperation:NSTableViewDropOn];
            return NSDragOperationCopy;
        }
    }
    
    return NSDragOperationNone;
}

-(void)toggleColumn:(id)sender
{
	NSTableColumn *col = [sender representedObject];
	[col setHidden:![col isHidden]];
}

-(void)menuWillOpen:(NSMenu *)menu
{
	for (NSMenuItem *mi in menu.itemArray) {
		NSTableColumn *col = [mi representedObject];
		[mi setState:col.isHidden ? NSOffState : NSOnState];
	}
}

- (void)configureTableViews
{
    /*
     Create a contextual menu for customizing the installs item table columns
     */
    NSMenu *installsItemsHeaderMenu = [[NSMenu alloc] initWithTitle:@""];
    NSSortDescriptor *sortByHeaderString = [NSSortDescriptor sortDescriptorWithKey:@"headerCell.stringValue" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray *tableColumnsSorted = [self.installsTableView.tableColumns sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByHeaderString]];
    for (NSTableColumn *aColumn in tableColumnsSorted) {
        NSString *menuItemTitle = [aColumn.headerCell stringValue];
        if ([menuItemTitle isEqualToString:@""]) {
            // Title is empty so this is the icon column
            menuItemTitle = @"Icon";
        }
        NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:menuItemTitle
                                                              action:@selector(toggleColumn:)
                                                       keyEquivalent:@""];
        newMenuItem.target = self;
        newMenuItem.representedObject = aColumn;
        [installsItemsHeaderMenu addItem:newMenuItem];
    }
    installsItemsHeaderMenu.delegate = self;
    self.installsTableView.headerView.menu = installsItemsHeaderMenu;
    
    [self.installsTableView registerForDraggedTypes:[NSArray arrayWithObjects:NSURLPboardType, nil]];
    [self.installsTableView setDelegate:self];
    [self.installsTableView setDataSource:self];
    
    
    /*
     Create a contextual menu for customizing the receipt items table columns
     */
    NSMenu *receiptsHeaderMenu = [[NSMenu alloc] initWithTitle:@""];
    NSArray *receiptsTableColumnsSorted = [self.receiptsTableView.tableColumns sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByHeaderString]];
    for (NSTableColumn *aColumn in receiptsTableColumnsSorted) {
        NSString *menuItemTitle = [aColumn.headerCell stringValue];
        if ([menuItemTitle isEqualToString:@""]) {
            // Title is empty so this is the icon column
            menuItemTitle = @"Icon";
        } else if ([menuItemTitle isEqualToString:@"Opt."]) {
            // Optional check box column
            menuItemTitle = @"Optional";
        }
        NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:menuItemTitle
                                                              action:@selector(toggleColumn:)
                                                       keyEquivalent:@""];
        newMenuItem.target = self;
        newMenuItem.representedObject = aColumn;
        [receiptsHeaderMenu addItem:newMenuItem];
    }
    receiptsHeaderMenu.delegate = self;
    self.receiptsTableView.headerView.menu = receiptsHeaderMenu;
    
    [self.receiptsTableView setDelegate:self];
    [self.receiptsTableView setDataSource:self];
    
    [self.itemsToCopyTableView setDelegate:self];
    [self.itemsToCopyTableView setDataSource:self];
    
    [self.installerChoicesXMLTableView setDelegate:self];
    [self.installerChoicesXMLTableView setDataSource:self];
    
    [self.blockingApplicationsTableView setDelegate:self];
    [self.blockingApplicationsTableView setDataSource:self];
    
    [self.supportedArchitecturesTableView setDelegate:self];
    [self.supportedArchitecturesTableView setDataSource:self];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.installsItemEditor = [[InstallsItemEditor alloc] initWithWindowNibName:@"InstallsItemEditor"];
    self.packageNameEditor = [[PackageNameEditor alloc] initWithWindowNibName:@"PackageNameEditor"];
    self.createNewCategoryController = [[MARequestStringValueController alloc] initWithWindowNibName:@"MARequestStringValueController"];
    self.createNewDeveloperController = [[MARequestStringValueController alloc] initWithWindowNibName:@"MARequestStringValueController"];
    self.iconEditor = [[MAIconEditor alloc] initWithWindowNibName:@"MAIconEditor"];
    
    [self configureTableViews];
    
    /*
     Set a code-friendly font for the script views.
     If the size is 0 or negative, this uses the fixed-pitch font at the default size.
     */
    NSFont *scriptFont = [NSFont userFixedPitchFontOfSize:0.0];
    
    // Configure the script text views
    [self.preinstallScriptTextView setFont:scriptFont];
    self.preinstallScriptTextView.automaticQuoteSubstitutionEnabled = NO;
    
    [self.postinstallScriptTextView setFont:scriptFont];
    self.postinstallScriptTextView.automaticQuoteSubstitutionEnabled = NO;
    
    [self.uninstallScriptTextView setFont:scriptFont];
    self.uninstallScriptTextView.automaticQuoteSubstitutionEnabled = NO;
    
    [self.preuninstallScriptTextView setFont:scriptFont];
    self.preuninstallScriptTextView.automaticQuoteSubstitutionEnabled = NO;
    
    [self.postuninstallScriptTextView setFont:scriptFont];
    self.postuninstallScriptTextView.automaticQuoteSubstitutionEnabled = NO;
    
    [self.installCheckScriptTextView setFont:scriptFont];
    self.installCheckScriptTextView.automaticQuoteSubstitutionEnabled = NO;
    
    [self.uninstallCheckScriptTextView setFont:scriptFont];
    self.uninstallCheckScriptTextView.automaticQuoteSubstitutionEnabled = NO;
    
    
    pkginfoSelector = [[SelectPkginfoItemsWindow alloc] initWithWindowNibName:@"SelectPkginfoItemsWindow"];
    
    NSSortDescriptor *osVersionSorter = [NSSortDescriptor sortDescriptorWithKey:nil
                                                                     ascending:NO 
                                                                      selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *installerTypeSorter = [NSSortDescriptor sortDescriptorWithKey:nil
                                                                      ascending:YES
                                                                       selector:@selector(localizedStandardCompare:)];
    
    self.osVersions = [[NSArray arrayWithObjects:
                        @"10.5",
                        @"10.5.8",
                        @"10.5.99",
                        @"10.6",
                        @"10.6.8", 
                        @"10.6.99", 
                        @"10.7",
                        @"10.7.5",
                        @"10.7.99",
                        @"10.8",
                        @"10.8.5",
                        @"10.8.99",
                        @"10.9",
                        @"10.9.2",
                        @"10.9.99",
                        nil] 
                       sortedArrayUsingDescriptors:[NSArray arrayWithObject:osVersionSorter]];
    
    self.installerTypes = [[NSArray arrayWithObjects:
                            @"copy_from_dmg",
                            @"apple_update_metadata",
                            @"nopkg",
                            @"AdobeSetup",
                            @"AdobeUberInstaller",
                            @"AdobeAcrobatUpdater",
                            @"AdobeCS5AAMEEPackage",
                            @"AdobeCS5PatchInstaller",
                            nil]
                           sortedArrayUsingDescriptors:[NSArray arrayWithObject:installerTypeSorter]];
    
    // Set the force_install_after_date date picker to use UTC
    NSTimeZone *timeZoneUTC = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setTimeZone:timeZoneUTC];
    [self.forceInstallDatePicker setCalendar:gregorian];
    [self.forceInstallDatePicker setTimeZone:timeZoneUTC];
    
    [self setDefaultValuesFromPackage:self.pkginfoToEdit];
    
    [self.mainTabView selectTabViewItemAtIndex:0];
    
    NSSortDescriptor *sortInstallsItems = [NSSortDescriptor sortDescriptorWithKey:@"munki_path" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.installsItemsController setSortDescriptors:[NSArray arrayWithObject:sortInstallsItems]];
    [self.installsTableView setDoubleAction:@selector(editInstallsItem)];
    
    NSSortDescriptor *sortItemsToCopyByDestPath = [NSSortDescriptor sortDescriptorWithKey:@"munki_destination_path" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortItemsToCopyBySource = [NSSortDescriptor sortDescriptorWithKey:@"munki_source_item" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.itemsToCopyArrayController setSortDescriptors:[NSArray arrayWithObjects:sortItemsToCopyByDestPath, sortItemsToCopyBySource, nil]];
    
    NSSortDescriptor *sortReceiptsByPackageID = [NSSortDescriptor sortDescriptorWithKey:@"munki_packageid" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortReceiptsByName = [NSSortDescriptor sortDescriptorWithKey:@"munki_name" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.receiptsArrayController setSortDescriptors:[NSArray arrayWithObjects:sortReceiptsByPackageID, sortReceiptsByName, nil]];
    
    NSSortDescriptor *sortStringObjectsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.updateForArrayController setSortDescriptors:[NSArray arrayWithObject:sortStringObjectsByTitle]];
    [self.requiresArrayController setSortDescriptors:[NSArray arrayWithObject:sortStringObjectsByTitle]];
    [self.blockingApplicationsArrayController setSortDescriptors:[NSArray arrayWithObject:sortStringObjectsByTitle]];
    [self.supportedArchitecturesArrayController setSortDescriptors:[NSArray arrayWithObject:sortStringObjectsByTitle]];
    
    [self.categoriesArrayController setSortDescriptors:@[sortStringObjectsByTitle]];
    [self.developersArrayController setSortDescriptors:@[sortStringObjectsByTitle]];
    
    NSSortDescriptor *sortByChoiceIdentifier = [NSSortDescriptor sortDescriptorWithKey:@"munki_choiceIdentifier" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByChoiceAttribute = [NSSortDescriptor sortDescriptorWithKey:@"munki_choiceAttribute" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.installerChoicesArrayController setSortDescriptors:[NSArray arrayWithObjects:sortByChoiceIdentifier, sortByChoiceAttribute, nil]];
    
    NSSortDescriptor *sortByCatalogTitle = [NSSortDescriptor sortDescriptorWithKey:@"catalog.title" ascending:YES];
    [self.catalogInfosArrayController setSortDescriptors:[NSArray arrayWithObject:sortByCatalogTitle]];
    
    NSSortDescriptor *sortByVariableName = [NSSortDescriptor sortDescriptorWithKey:@"munki_installer_environment_key" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.installerEnvironmentVariablesArrayController setSortDescriptors:[NSArray arrayWithObjects:sortByVariableName, nil]];
}

- (void)setDefaultValuesFromPackage:(PackageMO *)aPackage
{
    if (aPackage.munki_postinstall_script == nil) {
        self.temp_postinstall_script_enabled = NO;
        self.temp_postinstall_script = @"";
    } else {
        self.temp_postinstall_script_enabled = YES;
        self.temp_postinstall_script = aPackage.munki_postinstall_script;
    }
    
    if (aPackage.munki_postuninstall_script == nil) {
        self.temp_postuninstall_script_enabled = NO;
        self.temp_postuninstall_script = @"";
    } else {
        self.temp_postuninstall_script_enabled = YES;
        self.temp_postuninstall_script = aPackage.munki_postuninstall_script;
    }
    
    if (aPackage.munki_preinstall_script == nil) {
        self.temp_preinstall_script_enabled = NO;
        self.temp_preinstall_script = @"";
    } else {
        self.temp_preinstall_script_enabled = YES;
        self.temp_preinstall_script = aPackage.munki_preinstall_script;
    }
    
    if (aPackage.munki_preuninstall_script == nil) {
        self.temp_preuninstall_script_enabled = NO;
        self.temp_preuninstall_script = @"";
    } else {
        self.temp_preuninstall_script_enabled = YES;
        self.temp_preuninstall_script = aPackage.munki_preuninstall_script;
    }
    
    if (aPackage.munki_uninstall_script == nil) {
        self.temp_uninstall_script_enabled = NO;
        self.temp_uninstall_script = @"";
    } else {
        self.temp_uninstall_script_enabled = YES;
        self.temp_uninstall_script = aPackage.munki_uninstall_script;
    }
    
    if (aPackage.munki_installcheck_script == nil) {
        self.temp_installcheck_script_enabled = NO;
        self.temp_installcheck_script = @"";
    } else {
        self.temp_installcheck_script_enabled = YES;
        self.temp_installcheck_script = aPackage.munki_installcheck_script;
    }
    
    if (aPackage.munki_uninstallcheck_script == nil) {
        self.temp_uninstallcheck_script_enabled = NO;
        self.temp_uninstallcheck_script = @"";
    } else {
        self.temp_uninstallcheck_script_enabled = YES;
        self.temp_uninstallcheck_script = aPackage.munki_uninstallcheck_script;
    }
    
    if (aPackage.munki_force_install_after_date == nil) {
        
        /*
         Package doesn't have a forced date.
         Set the default date to something meaningful (now + 7 days)
         in case the user decides to enable it
         */
        
        NSDate *now = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *dateComponents = [gregorian components:( NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:now];
        [dateComponents setMinute:0];
        [dateComponents setSecond:0];
        NSDate *normalizedDate = [gregorian dateFromComponents:dateComponents];
        
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setDay:7];
        NSDate *newDate = [gregorian dateByAddingComponents:offsetComponents toDate:normalizedDate options:0];
        
        self.temp_force_install_after_date = newDate;
        self.temp_force_install_after_date_enabled = NO;
        
    } else {
        self.temp_force_install_after_date_enabled = YES;
        self.temp_force_install_after_date = aPackage.munki_force_install_after_date;
    }
    
    if (aPackage.hasEmptyBlockingApplicationsValue) {
        self.temp_blocking_applications_include_empty = YES;
    } else {
        self.temp_blocking_applications_include_empty = NO;
    }

}

#pragma mark -
#pragma mark NSSplitView delegates

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
	return NO;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex
{
	return NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
    if ([splitView isVertical] == NO) {
        return proposedMin;
    }
    if (dividerIndex == 0) {
        return kMinSplitViewWidth;
    }
    return proposedMin;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
    if ([splitView isVertical] == NO) {
        return proposedMax;
    }
    if (dividerIndex == 0) {
        return [splitView frame].size.width - kMinSplitViewWidth;
    }
    return proposedMax;
}

/*
- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    
}
*/

@end
