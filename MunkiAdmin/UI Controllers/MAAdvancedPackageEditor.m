//
//  AdvancedPackageEditor.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 19.12.2011.
//

#import "MAAdvancedPackageEditor.h"
#import "DataModelHeaders.h"
#import "MAMunkiAdmin_AppDelegate.h"
#import "MAMunkiRepositoryManager.h"
#import "MAMunkiOperation.h"
#import "MASelectPkginfoItemsWindow.h"
#import "MAPackageNameEditor.h"
#import "MAInstallsItemEditor.h"
#import "MACoreDataManager.h"
#import "MARequestStringValueController.h"
#import "MAIconEditor.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

#define kMinSplitViewWidth      300.0f

@implementation MAAdvancedPackageEditor

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
    
    [self updateDatePickerTimeZone];
    
    [self setDefaultValuesFromPackage:self.pkginfoToEdit];
    
    self.modalSession = [NSApp beginModalSessionForWindow:self.window];
    [NSApp runModalSession:self.modalSession];
    return self.modalSession;
}

- (void)packageNameEditorDidFinish:(id)sender returnCode:(NSModalResponse)returnCode object:(id)object
{
    NSManagedObjectContext *mainContext = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
    [[mainContext undoManager] endUndoGrouping];
    if (returnCode == NSModalResponseOK) return;
    [[mainContext undoManager] undoNestedGroup];
}


- (void)renameCurrentPackage
{
    NSManagedObjectContext *mainContext = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
    [[mainContext undoManager] beginUndoGrouping];
    self.packageNameEditor.packageToRename = self.pkginfoToEdit;
    [self.packageNameEditor configureRenameOperation];
    [self.window beginSheet:[self.packageNameEditor window] completionHandler:^(NSModalResponse returnCode) {
        [self packageNameEditorDidFinish:self.packageNameEditor returnCode:returnCode object:nil];
    }];
}

- (IBAction)renameCurrentPackageAction:(id)sender
{
    [self renameCurrentPackage];
}

- (void)addRequiresItemSheetDidEnd:(id)sheet returnCode:(NSModalResponse)returnCode object:(id)object
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    if (returnCode == NSModalResponseCancel) return;
    
    for (StringObjectMO *selectedItem in [pkginfoSelector selectionAsStringObjects]) {
        selectedItem.typeString = @"package";
        [self.pkginfoToEdit addRequirementsObject:selectedItem];
    }
}

- (IBAction)addRequiresItemAction:(id)sender
{
    [self.window beginSheet:pkginfoSelector.window completionHandler:^(NSModalResponse returnCode) {
        [self addRequiresItemSheetDidEnd:self->pkginfoSelector returnCode:returnCode object:nil];
    }];
}

- (void)addUpdateForItemSheetDidEnd:(id)sheet returnCode:(NSModalResponse)returnCode object:(id)object
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    if (returnCode == NSModalResponseCancel) return;
    
    for (StringObjectMO *selectedItem in [pkginfoSelector selectionAsStringObjects]) {
        selectedItem.typeString = @"package";
        [self.pkginfoToEdit addUpdateForObject:selectedItem];
    }
}

- (IBAction)addUpdateForItem:(id)sender
{
    [self.window beginSheet:pkginfoSelector.window completionHandler:^(NSModalResponse returnCode) {
        [self addUpdateForItemSheetDidEnd:self->pkginfoSelector returnCode:returnCode object:nil];
    }];
}

- (void)installsItemEditorDidFinish:(id)sender returnCode:(NSModalResponse)returnCode object:(id)object
{
    NSManagedObjectContext *mainContext = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
    [[mainContext undoManager] endUndoGrouping];
    if (returnCode == NSModalResponseOK) return;
    [[mainContext undoManager] undoNestedGroup];
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
    [[[(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext] undoManager] beginUndoGrouping];
    self.installsItemEditor.itemToEdit = selected;
    [self.window beginSheet:[self.installsItemEditor window] completionHandler:^(NSModalResponse returnCode) {
        [self installsItemEditorDidFinish:self.installsItemEditor returnCode:returnCode object:nil];
    }];
    [self.installsItemEditor updateVersionComparisonKeys];
    
    
}

- (void)installsItemDidFinish:(NSDictionary *)pkginfoPlist
{
    NSManagedObjectContext *moc = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
	NSDictionary *installsItemProps = [[pkginfoPlist objectForKey:@"installs"] objectAtIndex:0];
	if (installsItemProps != nil) {
		DDLogDebug(@"Got new dictionary from makepkginfo");
        InstallsItemMO *newInstallsItem = [[MACoreDataManager sharedManager] createInstallsItemFromDictionary:installsItemProps inManagedObjectContext:moc];
        [self.pkginfoToEdit addInstallsItemsObject:newInstallsItem];
	} else {
		DDLogError(@"Error. Got nil from makepkginfo");
	}
    
}

- (IBAction)addInstallsItemFromDiskAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
	if ([[MAMunkiRepositoryManager sharedManager] makepkginfoInstalled]) {
        MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
		NSArray *filesToAdd = [appDelegate chooseFiles];
		if (filesToAdd) {
			DDLogDebug(@"Adding %lu installs items", (unsigned long)[filesToAdd count]);
			for (NSURL *fileToAdd in filesToAdd) {
				if (fileToAdd != nil) {
					MAMunkiOperation *theOp = [MAMunkiOperation installsItemFromURL:fileToAdd];
					theOp.delegate = self;
					[[appDelegate operationQueue] addOperation:theOp];
				}
			}
		}
	} else {
		DDLogError(@"Can't find %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"makepkginfoPath"]);
	}
}

- (IBAction)createNewInstallsItem:(id)sender
{
    NSManagedObjectContext *moc = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
    InstallsItemMO *newInstallsItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallsItem" inManagedObjectContext:moc];
    newInstallsItem.munki_path = @"/Applications/Application.app";
    newInstallsItem.munki_type = @"application";
    newInstallsItem.munki_CFBundleIdentifier = @"com.example.application";
    newInstallsItem.munki_CFBundleName = @"Application.app";
    newInstallsItem.munki_CFBundleShortVersionString = @"1.0";
    newInstallsItem.munki_CFBundleVersion = @"1001";
    newInstallsItem.munki_version_comparison_key = @"CFBundleShortVersionString";
    [self.pkginfoToEdit addInstallsItemsObject:newInstallsItem];
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
        MACoreDataManager *cdManager = [MACoreDataManager sharedManager];
        MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
        NSManagedObjectContext *mainContext = [appDelegate managedObjectContext];
        CategoryMO *newCategory = [cdManager createCategoryWithTitle:self.createNewCategoryController.stringValue
                                                                      inManagedObjectContext:mainContext];
        [self.categoriesArrayController prepareContent];
        
        if (newCategory != nil) {
            self.pkginfoToEdit.category = newCategory;
            self.pkginfoToEdit.hasUnstagedChangesValue = YES;
        }
        
        [cdManager configureSourceListCategoriesSection:mainContext];
        [appDelegate updateSourceList];
        
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
        MACoreDataManager *cdManager = [MACoreDataManager sharedManager];
        MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
        NSManagedObjectContext *mainContext = [appDelegate managedObjectContext];
        DeveloperMO *newDeveloper = [cdManager createDeveloperWithTitle:self.createNewDeveloperController.stringValue
                                                                         inManagedObjectContext:mainContext];
        [self.developersArrayController prepareContent];
        
        if (newDeveloper != nil) {
            self.pkginfoToEdit.developer = newDeveloper;
            self.pkginfoToEdit.hasUnstagedChangesValue = YES;
        }
        [cdManager configureSourceListDevelopersSection:mainContext];
        [appDelegate updateSourceList];
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

- (void)endEditingInWindow
{
    /*
     From https://red-sweater.com/blog/229/stay-responsive
     
     Gracefully end all editing in our window (from Erik Buck).
     This will cause the user's changes to be committed.
     */
    
    id oldFirstResponder = [self.window firstResponder];
    if ((oldFirstResponder != nil) && [oldFirstResponder isKindOfClass:[NSTextView class]] && [(NSTextView *)oldFirstResponder isFieldEditor]) {
        // A field editor's delegate is the view we're editing
        oldFirstResponder = [oldFirstResponder delegate];
        if ([oldFirstResponder isKindOfClass:[NSResponder class]] == NO) {
            // Eh ... we'd better back off if
            // this thing isn't a responder at all
            oldFirstResponder = nil;
        }
    }
    
    if ([self.window makeFirstResponder:self.window]) {
        // All editing is now ended and delegate messages sent etc.
    } else {
        // For some reason the text object being edited will
        // not resign first responder status so force an
        /// end to editing anyway
        [self.window endEditingFor:nil];
    }
    
    // If we had a first responder before, restore it
    if (oldFirstResponder != nil) {
        [self.window makeFirstResponder:oldFirstResponder];
    }
}

- (void)saveAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    [self endEditingInWindow];
    
    [self commitChangesToCurrentPackage];
    
    [[self window] orderOut:sender];
    [NSApp endModalSession:self.modalSession];
    [NSApp stopModal];
    
    if ([self.delegate respondsToSelector:@selector(packageEditorDidFinish:returnCode:object:)]) {
        [self.delegate packageEditorDidFinish:self returnCode:NSModalResponseOK object:nil];
    }
}

- (void)cancelAction:(id)sender
{
    [self endEditingInWindow];
    
    [[self window] orderOut:sender];
    [NSApp endModalSession:self.modalSession];
    [NSApp stopModal];
    
    if ([self.delegate respondsToSelector:@selector(packageEditorDidFinish:returnCode:object:)]) {
        [self.delegate packageEditorDidFinish:self returnCode:NSModalResponseCancel object:nil];
    }
}

- (id)initWithWindow:(NSWindow *)window
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
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
    /*
    NSString *error;
    data = [NSPropertyListSerialization dataFromPropertyList:items
                                                      format:NSPropertyListXMLFormat_v1_0
                                            errorDescription:&error];
     */
    NSError *error = nil;
    data = [NSPropertyListSerialization dataWithPropertyList:items format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
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
    NSManagedObjectContext *mainMoc = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
    
    // Create new objects based on the destination and pasteboard contents
    if (firstResponder == self.installsTableView) {
        for (NSDictionary *item in [self getItemsOfTypeFromPasteboard:installsPboardType]) {
            InstallsItemMO *newInstallsItem = [coreDataManager createInstallsItemFromDictionary:item inManagedObjectContext:mainMoc];
            [self.pkginfoToEdit addInstallsItemsObject:newInstallsItem];
        }
    } else if (firstResponder == self.receiptsTableView) {
        for (NSDictionary *item in [self getItemsOfTypeFromPasteboard:receiptsPboardType]) {
            ReceiptMO *newReceipt = [NSEntityDescription insertNewObjectForEntityForName:@"Receipt" inManagedObjectContext:mainMoc];
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
            ItemToCopyMO *newItemToCopy = [NSEntityDescription insertNewObjectForEntityForName:@"ItemToCopy" inManagedObjectContext:mainMoc];
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
            InstallerChoicesItemMO *newInstallerChoicesItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallerChoicesItem" inManagedObjectContext:mainMoc];
            newInstallerChoicesItem.munki_attributeSetting = [item objectForKey:@"attributeSetting"];
            newInstallerChoicesItem.munki_choiceAttribute = [item objectForKey:@"choiceAttribute"];
            newInstallerChoicesItem.munki_choiceIdentifier = [item objectForKey:@"choiceIdentifier"];
            [self.pkginfoToEdit addInstallerChoicesItemsObject:newInstallerChoicesItem];
        }
    } else if (firstResponder == self.blockingApplicationsTableView) {
        for (NSString *item in [self getItemsOfTypeFromPasteboard:stringObjectPboardType]) {
            StringObjectMO *newStringObject = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:mainMoc];
            newStringObject.title = item;
            newStringObject.typeString = @"package";
            [self.pkginfoToEdit addBlockingApplicationsObject:newStringObject];
        }
    } else if (firstResponder == self.supportedArchitecturesTableView) {
        for (NSString *item in [self getItemsOfTypeFromPasteboard:stringObjectPboardType]) {
            StringObjectMO *newStringObject = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:mainMoc];
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
            [[(MAMunkiAdmin_AppDelegate *)[NSApp delegate] operationQueue] addOperation:theOp];
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
            menuItemTitle = NSLocalizedString(@"Icon", @"");
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
            menuItemTitle = NSLocalizedString(@"Icon", @"");
        } else if ([menuItemTitle isEqualToString:@"Opt."]) {
            // Optional check box column
            menuItemTitle = NSLocalizedString(@"Optional", @"");
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

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    [[MAMunkiRepositoryManager sharedManager] updateIconForPackage:self.pkginfoToEdit];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    if ([self.iconNameComboBox objectValueOfSelectedItem]) {
        self.iconNameComboBox.stringValue = [self.iconNameComboBox objectValueOfSelectedItem];
        self.pkginfoToEdit.munki_icon_name = [self.iconNameComboBox objectValueOfSelectedItem];
        [[MAMunkiRepositoryManager sharedManager] updateIconForPackage:self.pkginfoToEdit];
    }
    
}

- (void)updateIconNameComboBoxAutoCompleteList
{
    /*
     Get all available icon names for the combo box autocomplete list
     */
    MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IconImage" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"originalURL != %@", [NSNull null]]];
    NSURL *mainIconsURL = [appDelegate iconsURL];
    NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:nil];
    NSMutableArray *newIconNameSuggestions = [NSMutableArray new];
    if (self.pkginfoToEdit.munki_icon_name) {
        [newIconNameSuggestions addObject:self.pkginfoToEdit.munki_icon_name];
    }
    for (IconImageMO *image in fetchResults) {
        NSString *relativePath = [[MAMunkiRepositoryManager sharedManager] relativePathToChildURL:image.originalURL parentURL:mainIconsURL];
        if (![newIconNameSuggestions containsObject:relativePath]) {
            [newIconNameSuggestions addObject:relativePath];
        }
    }
    [newIconNameSuggestions sortUsingSelector:@selector(localizedStandardCompare:)];
    self.iconNameSuggestions = newIconNameSuggestions;
}

- (void)updateDatePickerTimeZone
{
    // Set the force_install_after_date date picker to use UTC (don't try to display it in some other time zone)
    NSTimeZone *timeZoneUTC = [NSTimeZone timeZoneWithName:@"UTC"];
    [NSTimeZone setDefaultTimeZone:timeZoneUTC];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setTimeZone:timeZoneUTC];
    [self.forceInstallDatePicker setCalendar:gregorian];
    [self.forceInstallDatePicker setTimeZone:timeZoneUTC];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.installsItemEditor = [[MAInstallsItemEditor alloc] initWithWindowNibName:@"MAInstallsItemEditor"];
    self.packageNameEditor = [[MAPackageNameEditor alloc] initWithWindowNibName:@"MAPackageNameEditor"];
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
    self.preinstallScriptTextView.automaticDashSubstitutionEnabled = NO;
    
    [self.postinstallScriptTextView setFont:scriptFont];
    self.postinstallScriptTextView.automaticQuoteSubstitutionEnabled = NO;
    self.postinstallScriptTextView.automaticDashSubstitutionEnabled = NO;
    
    [self.uninstallScriptTextView setFont:scriptFont];
    self.uninstallScriptTextView.automaticQuoteSubstitutionEnabled = NO;
    self.uninstallScriptTextView.automaticDashSubstitutionEnabled = NO;
    
    [self.preuninstallScriptTextView setFont:scriptFont];
    self.preuninstallScriptTextView.automaticQuoteSubstitutionEnabled = NO;
    self.preuninstallScriptTextView.automaticDashSubstitutionEnabled = NO;
    
    [self.postuninstallScriptTextView setFont:scriptFont];
    self.postuninstallScriptTextView.automaticQuoteSubstitutionEnabled = NO;
    self.postuninstallScriptTextView.automaticDashSubstitutionEnabled = NO;
    
    [self.installCheckScriptTextView setFont:scriptFont];
    self.installCheckScriptTextView.automaticQuoteSubstitutionEnabled = NO;
    self.installCheckScriptTextView.automaticDashSubstitutionEnabled = NO;
    
    [self.uninstallCheckScriptTextView setFont:scriptFont];
    self.uninstallCheckScriptTextView.automaticQuoteSubstitutionEnabled = NO;
    self.uninstallCheckScriptTextView.automaticDashSubstitutionEnabled = NO;
    
    
    pkginfoSelector = [[MASelectPkginfoItemsWindow alloc] initWithWindowNibName:@"MASelectPkginfoItemsWindow"];
    
    NSSortDescriptor *osVersionSorter = [NSSortDescriptor sortDescriptorWithKey:nil
                                                                     ascending:NO 
                                                                      selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *installerTypeSorter = [NSSortDescriptor sortDescriptorWithKey:nil
                                                                      ascending:YES
                                                                       selector:@selector(localizedStandardCompare:)];
    
    NSArray *newOsVersions = @[@"10.5", @"10.5.8", @"10.5.99",
                               @"10.6", @"10.6.8", @"10.6.99",
                               @"10.7", @"10.7.5", @"10.7.99",
                               @"10.8", @"10.8.5", @"10.8.99",
                               @"10.9", @"10.9.5", @"10.9.99",
                               @"10.10", @"10.10.5", @"10.10.99",
                               @"10.11", @"10.11.6", @"10.11.99",
                               @"10.12", @"10.12.6", @"10.12.99",
                               @"10.13", @"10.13.6", @"10.13.99",
                               @"10.14", @"10.14.99"];
    self.osVersions = [newOsVersions sortedArrayUsingDescriptors:@[osVersionSorter]];
    
    NSArray *newInstallerTypes = @[@"copy_from_dmg",
                                   @"apple_update_metadata",
                                   @"nopkg",
                                   @"profile",
                                   @"startosinstall",
                                   @"AdobeSetup",
                                   @"AdobeUberInstaller",
                                   @"AdobeAcrobatUpdater",
                                   @"AdobeCS5AAMEEPackage",
                                   @"AdobeCS5PatchInstaller"];
    self.installerTypes = [newInstallerTypes sortedArrayUsingDescriptors:@[installerTypeSorter]];
    
    [[MAMunkiRepositoryManager sharedManager] scanIconsDirectoryForImages];
    [self updateIconNameComboBoxAutoCompleteList];
    [self.iconNameComboBox setDelegate:self];
    
    [self updateDatePickerTimeZone];
    
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
    // Mark the package as edited
    aPackage.hasUnstagedChangesValue = YES;
    
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
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *dateComponents = [gregorian components:( NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:now];
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
    
    [self updateIconNameComboBoxAutoCompleteList];
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
