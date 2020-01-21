//
//  MAManifestEditor.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 20.3.2015.
//
//

#import "MAManifestEditor.h"
#import "DataModelHeaders.h"
#import "MASelectManifestItemsWindow.h"
#import "MASelectPkginfoItemsWindow.h"
#import "MAPredicateEditor.h"
#import "MAMunkiAdmin_AppDelegate.h"
#import "MAManifestsView.h"
#import "MARequestStringValueController.h"
#import "MAMunkiRepositoryManager.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

NSString *MAConditionalItemType = @"ConditionalItemType";

#pragma mark -
#pragma mark MAManifestEditorSection

@interface MAManifestEditorSection : NSObject
typedef NS_ENUM(NSInteger, MAEditorSectionTag) {
    MAEditorSectionTagGeneral,
    MAEditorSectionTagManagedInstalls,
    MAEditorSectionTagManagedUninstalls,
    MAEditorSectionTagManagedUpdates,
    MAEditorSectionTagOptionalInstalls,
    MAEditorSectionTagFeaturedItems,
    MAEditorSectionTagIncludedManifests,
    MAEditorSectionTagReferencingManifests,
    MAEditorSectionTagConditions
};
@property (strong) NSString *title;
@property (strong) NSString *subtitle;
@property (strong) NSImage *icon;
@property (strong) NSString *identifier;
@property NSInteger tag;
@property (assign) NSView *view;
@end
@implementation MAManifestEditorSection
@end

#pragma mark -
#pragma mark ItemCellView

@interface ItemCellView : NSTableCellView
@property (nonatomic, retain) IBOutlet NSTextField *detailTextField;
@property (nonatomic, retain) IBOutlet NSPopUpButton *popupButton;
@end
@implementation ItemCellView
@synthesize detailTextField = _detailTextField;
@synthesize popupButton = _popupButton;

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
    NSColor *textColor = (backgroundStyle == NSBackgroundStyleDark) ? [NSColor selectedTextColor] : [NSColor secondaryLabelColor];
    self.detailTextField.textColor = textColor;
    [super setBackgroundStyle:backgroundStyle];
}

@end

#pragma mark -
#pragma mark MAManifestEditor

@interface MAManifestEditor ()
@property (assign) NSView *currentDetailView;
@end

@implementation MAManifestEditor


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.adminNotesTextView setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    
    NSSortDescriptor *sortByCatalogTitle = [NSSortDescriptor sortDescriptorWithKey:@"catalog.title" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByIndexInManifest = [NSSortDescriptor sortDescriptorWithKey:@"indexInManifest" ascending:YES selector:@selector(compare:)];
    self.catalogInfosArrayController.sortDescriptors = @[sortByIndexInManifest, sortByCatalogTitle];
    
    NSSortDescriptor *sortByCondition = [NSSortDescriptor sortDescriptorWithKey:@"munki_condition" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByTitleWithParentTitle = [NSSortDescriptor sortDescriptorWithKey:@"titleWithParentTitle" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.conditionalItemsArrayController setSortDescriptors:@[sortByTitleWithParentTitle, sortByCondition]];
    
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    self.managedInstallsArrayController.sortDescriptors = @[sortByTitle];
    self.managedUpdatesArrayController.sortDescriptors = @[sortByTitle];
    self.managedUninstallsArrayController.sortDescriptors = @[sortByTitle];
    self.optionalInstallsArrayController.sortDescriptors = @[sortByTitle];
    self.featuredItemsArrayController.sortDescriptors = @[sortByTitle];
    self.includedManifestsArrayController.sortDescriptors = @[sortByTitle];
    
    NSSortDescriptor *sortByReferenceTitle = [NSSortDescriptor sortDescriptorWithKey:@"manifestReference.title" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByTitleOrDisplayName = [NSSortDescriptor sortDescriptorWithKey:@"manifestReference.titleOrDisplayName" ascending:YES selector:@selector(localizedStandardCompare:)];
    self.referencingManifestsArrayController.sortDescriptors = @[sortByTitleOrDisplayName, sortByReferenceTitle];
    self.referencingManifestsTableView.target = self;
    self.referencingManifestsTableView.doubleAction = @selector(referencingManifestDoubleClick:);
    
    self.includedManifestsTableView.target = self;
    self.includedManifestsTableView.doubleAction = @selector(includedManifestDoubleClick:);
    
    NSManagedObjectContext *moc = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ConditionalItem" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:nil];
    self.conditionalItemsAllArrayController.content = fetchResults;
    [self.conditionalItemsAllArrayController setSortDescriptors:@[sortByTitleWithParentTitle, sortByCondition]];
    [self.conditionsTreeController setSortDescriptors:@[sortByTitleWithParentTitle, sortByCondition]];
    [self.conditionsOutlineView expandItem:nil expandChildren:YES];
    self.conditionsOutlineView.target = self;
    self.conditionsOutlineView.doubleAction = @selector(editConditionalItemAction:);
    
    [self setupSourceList];
}

- (void)includedManifestDoubleClick:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    for (StringObjectMO *clickedObject in self.includedManifestsArrayController.selectedObjects) {
        ManifestMO *manifest;
        if (clickedObject.originalManifest) {
            //DDLogError(@"Double clicked: %@", [clickedObject.originalManifest description]);
            manifest = clickedObject.originalManifest;
            MAManifestEditor *editor = [self.delegate editorForManifest:manifest];
            [editor showWindow:nil];
        } else {
            DDLogError(@"Double clicked object has no originalManifest reference");
            DDLogError(@"%@", [clickedObject description]);
        }
    }
}

- (void)referencingManifestDoubleClick:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    for (StringObjectMO *clickedObject in self.referencingManifestsArrayController.selectedObjects) {
        ManifestMO *manifest;
        if (clickedObject.manifestReference) {
            //DDLogError(@"Double clicked: %@", [clickedObject.manifestReference description]);
            manifest = clickedObject.manifestReference;
        } else {
            //DDLogError(@"Double clicked: %@", [clickedObject.includedManifestConditionalReference.manifest description]);
            manifest = clickedObject.includedManifestConditionalReference.manifest;
        }
        MAManifestEditor *editor = [self.delegate editorForManifest:manifest];
        [editor showWindow:nil];
    }
}

- (void)awakeFromNib
{
    /*
     Setup the main window
     */
    //[self.window setBackgroundColor:[NSColor whiteColor]];
    [self.window bind:@"title" toObject:self withKeyPath:@"manifestToEdit.title" options:nil];
    
    self.currentDetailView = self.generalView;
    
    [self.catalogInfosTableView registerForDraggedTypes:@[NSURLPboardType]];
    [self.catalogInfosTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    
    [self.conditionsOutlineView registerForDraggedTypes:@[MAConditionalItemType]];
    [self.conditionsOutlineView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:YES];
    
    self.addItemsWindowController = [[MASelectPkginfoItemsWindow alloc] initWithWindowNibName:@"MASelectPkginfoItemsWindow"];
    self.selectManifestsWindowController = [[MASelectManifestItemsWindow alloc] initWithWindowNibName:@"MASelectManifestItemsWindow"];
    self.predicateEditor = [[MAPredicateEditor alloc] initWithWindowNibName:@"MAPredicateEditor"];
    self.requestStringValue = [[MARequestStringValueController alloc] initWithWindowNibName:@"MARequestStringValueController"];
}

- (IBAction)addNewReferencingManifestAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    if ([NSWindow instancesRespondToSelector:@selector(beginSheet:completionHandler:)]) {
        [self.window beginSheet:[self.selectManifestsWindowController window] completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSModalResponseOK) {
                [self processAddItemsAction];
            }
        }];
    } else {
        [self.window beginSheet:[self.selectManifestsWindowController window] completionHandler:^(NSModalResponse returnCode) {
            [self addNewItemSheetDidEnd:[self.selectManifestsWindowController window] returnCode:returnCode contextInfo:nil];
        }];
    }
    
    NSMutableArray *tempPredicates = [[NSMutableArray alloc] init];
    
    for (StringObjectMO *referencingManifest in self.manifestToEdit.referencingManifests) {
        NSPredicate *newPredicate;
        if (referencingManifest.manifestReference) {
            newPredicate = [NSPredicate predicateWithFormat:@"title != %@", referencingManifest.manifestReference.title];
        } else {
            newPredicate = [NSPredicate predicateWithFormat:@"title != %@", referencingManifest.includedManifestConditionalReference.manifest.title];
        }
        [tempPredicates addObject:newPredicate];
    }
    
    NSPredicate *denySelfPred = [NSPredicate predicateWithFormat:@"title != %@", self.manifestToEdit.title];
    [tempPredicates addObject:denySelfPred];
    NSPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates:tempPredicates];
    [self.selectManifestsWindowController setOriginalPredicate:compPred];
    [self.selectManifestsWindowController updateSearchPredicate];
}

- (IBAction)addNewIncludedManifestAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    if ([NSWindow instancesRespondToSelector:@selector(beginSheet:completionHandler:)]) {
        [self.window beginSheet:[self.selectManifestsWindowController window] completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSModalResponseOK) {
                [self processAddItemsAction];
            }
        }];
    } else {
        [self.window beginSheet:[self.selectManifestsWindowController window] completionHandler:^(NSModalResponse returnCode) {
            [self addNewItemSheetDidEnd:[self.selectManifestsWindowController window] returnCode:returnCode contextInfo:nil];
        }];
    }
    
    ManifestMO *selectedManifest = self.manifestToEdit;
    NSMutableArray *tempPredicates = [[NSMutableArray alloc] init];
    
    for (StringObjectMO *aNestedManifest in selectedManifest.includedManifestsFaster) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"title != %@", aNestedManifest.title];
        [tempPredicates addObject:newPredicate];
    }
    
    for (ConditionalItemMO *conditional in selectedManifest.conditionalItems) {
        for (StringObjectMO *aNestedManifest in conditional.includedManifests) {
            NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"title != %@", aNestedManifest.title];
            [tempPredicates addObject:newPredicate];
        }
    }
    
    NSPredicate *denySelfPred = [NSPredicate predicateWithFormat:@"title != %@", selectedManifest.title];
    [tempPredicates addObject:denySelfPred];
    NSPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates:tempPredicates];
    [self.selectManifestsWindowController setOriginalPredicate:compPred];
    [self.selectManifestsWindowController updateSearchPredicate];
}

- (void)processAddItemsAction
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    NSArray *selectedItems = [self.addItemsWindowController selectionAsStringObjects];
    
    
    MAManifestEditorSection *selected = [self.editorSectionsArrayController selectedObjects][0];
    switch (selected.tag) {
        case MAEditorSectionTagManagedInstalls:
            for (StringObjectMO *selectedItem in selectedItems) {
                [self.manifestToEdit addManagedInstallsFasterObject:selectedItem];
            }
            break;
            
        case MAEditorSectionTagManagedUninstalls:
            for (StringObjectMO *selectedItem in selectedItems) {
                [self.manifestToEdit addManagedUninstallsFasterObject:selectedItem];
            }
            break;
            
        case MAEditorSectionTagManagedUpdates:
            for (StringObjectMO *selectedItem in selectedItems) {
                [self.manifestToEdit addManagedUpdatesFasterObject:selectedItem];
            }
            break;
            
        case MAEditorSectionTagOptionalInstalls:
            for (StringObjectMO *selectedItem in selectedItems) {
                [self.manifestToEdit addOptionalInstallsFasterObject:selectedItem];
            }
            break;
        
        case MAEditorSectionTagFeaturedItems:
            for (StringObjectMO *selectedItem in selectedItems) {
                [self.manifestToEdit addFeaturedItemsObject:selectedItem];
            }
            break;
        
        case MAEditorSectionTagIncludedManifests:
            for (ManifestMO *manifestToAdd in [self.selectManifestsWindowController.manifestsArrayController selectedObjects]) {
                StringObjectMO *manifestToAddAsStringObject = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:manifestToAdd.managedObjectContext];
                manifestToAddAsStringObject.title = manifestToAdd.title;
                manifestToAddAsStringObject.typeString = @"includedManifest";
                manifestToAddAsStringObject.originalIndex = [NSNumber numberWithUnsignedInteger:999];
                manifestToAddAsStringObject.indexInNestedManifest = [NSNumber numberWithUnsignedInteger:999];
                manifestToAddAsStringObject.originalManifest = manifestToAdd;
                [self.manifestToEdit addIncludedManifestsFasterObject:manifestToAddAsStringObject];
                [self.manifestToEdit.managedObjectContext refreshObject:manifestToAdd mergeChanges:YES];
            }
            
            break;
        
        case MAEditorSectionTagReferencingManifests:
            for (ManifestMO *aManifest in [self.selectManifestsWindowController.manifestsArrayController selectedObjects]) {
                StringObjectMO *manifestToEditAsStringObject = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:aManifest.managedObjectContext];
                manifestToEditAsStringObject.title = self.manifestToEdit.title;
                manifestToEditAsStringObject.typeString = @"includedManifest";
                manifestToEditAsStringObject.originalIndex = [NSNumber numberWithUnsignedInteger:999];
                manifestToEditAsStringObject.indexInNestedManifest = [NSNumber numberWithUnsignedInteger:999];
                manifestToEditAsStringObject.originalManifest = self.manifestToEdit;
                [aManifest addIncludedManifestsFasterObject:manifestToEditAsStringObject];
                [self.manifestToEdit.managedObjectContext refreshObject:aManifest mergeChanges:YES];
            }
            break;
            
        default:
            DDLogError(@"processAddItemsAction: tag %ld not handled...", (long)selected.tag);
            break;
    }
    
    // Need to refresh fetched properties
    [self.manifestToEdit.managedObjectContext refreshObject:self.manifestToEdit mergeChanges:YES];
    
}

- (IBAction)removeIncludedManifestAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    ManifestMO *selectedManifest = self.manifestToEdit;
    
    for (StringObjectMO *anIncludedManifest in [self.includedManifestsArrayController selectedObjects]) {
        ManifestMO *originalManifest = anIncludedManifest.originalManifest;
        [self.manifestToEdit.managedObjectContext deleteObject:anIncludedManifest];
        [self.manifestToEdit.managedObjectContext refreshObject:originalManifest mergeChanges:YES];
    }
    [self.manifestToEdit.managedObjectContext refreshObject:selectedManifest mergeChanges:YES];
}

- (void)addNewItemSheetDidEnd:(NSWindow *)sheet returnCode:(NSModalResponse)returnCode contextInfo:(void *)contextInfo
{
    DDLogError(@"%@", NSStringFromSelector(_cmd));
    
    if (returnCode == NSModalResponseCancel) return;
    [self processAddItemsAction];
}

- (IBAction)addNewItemsAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    if ([[self.editorSectionsArrayController selectedObjects] count] == 0) {
        return;
    }
    
    /*
     Figure out what kind of items we're adding
     */
    MAManifestEditorSection *selected = [self.editorSectionsArrayController selectedObjects][0];
    NSSet *existingObjects = nil;
    NSSet *conditionalObjects = nil;
    switch (selected.tag) {
        case MAEditorSectionTagManagedInstalls:
            existingObjects = self.manifestToEdit.managedInstallsFaster;
            conditionalObjects = [self.manifestToEdit.conditionalItems valueForKeyPath:@"@distinctUnionOfSets.managedInstalls"];
            break;
            
        case MAEditorSectionTagManagedUninstalls:
            existingObjects = self.manifestToEdit.managedUninstallsFaster;
            conditionalObjects = [self.manifestToEdit.conditionalItems valueForKeyPath:@"@distinctUnionOfSets.managedUninstalls"];
            break;
        
        case MAEditorSectionTagManagedUpdates:
            existingObjects = self.manifestToEdit.managedUpdatesFaster;
            conditionalObjects = [self.manifestToEdit.conditionalItems valueForKeyPath:@"@distinctUnionOfSets.managedUpdates"];
            break;
            
        case MAEditorSectionTagOptionalInstalls:
            existingObjects = self.manifestToEdit.optionalInstallsFaster;
            conditionalObjects = [self.manifestToEdit.conditionalItems valueForKeyPath:@"@distinctUnionOfSets.optionalInstalls"];
            break;
        
        case MAEditorSectionTagFeaturedItems:
            existingObjects = self.manifestToEdit.featuredItems;
            conditionalObjects = [self.manifestToEdit.conditionalItems valueForKeyPath:@"@distinctUnionOfSets.featuredItems"];
            break;
            
        default:
            DDLogError(@"addNewItemsAction: tag %ld not handled...", (long)selected.tag);
            break;
    }
    
    NSMutableArray *tempPredicates = [[NSMutableArray alloc] init];
    
    for (StringObjectMO *object in existingObjects) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"munki_name != %@", object.title];
        [tempPredicates addObject:newPredicate];
    }
    for (StringObjectMO *object in conditionalObjects) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"munki_name != %@", object.title];
        [tempPredicates addObject:newPredicate];
    }
    
    NSPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates:tempPredicates];
    [self.addItemsWindowController setHideAddedPredicate:compPred];
    [self.addItemsWindowController updateGroupedSearchPredicate];
    [self.addItemsWindowController updateIndividualSearchPredicate];
    
    if ([NSWindow instancesRespondToSelector:@selector(beginSheet:completionHandler:)]) {
        [self.window beginSheet:[self.addItemsWindowController window] completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSModalResponseOK) {
                [self processAddItemsAction];
            }
        }];
    } else {
        [self.window beginSheet:[self.addItemsWindowController window] completionHandler:^(NSModalResponse returnCode) {
            [self addNewItemSheetDidEnd:[self.addItemsWindowController window] returnCode:returnCode contextInfo:nil];
        }];
    }
}

- (IBAction)removeItemsAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    MAManifestEditorSection *selected = [self.editorSectionsArrayController selectedObjects][0];
    switch (selected.tag) {
        case MAEditorSectionTagManagedInstalls:
            for (StringObjectMO *selectedItem in [self.managedInstallsArrayController selectedObjects]) {
                [self.manifestToEdit.managedObjectContext deleteObject:selectedItem];
            }
            break;
            
        case MAEditorSectionTagManagedUninstalls:
            for (StringObjectMO *selectedItem in [self.managedUninstallsArrayController selectedObjects]) {
                [self.manifestToEdit.managedObjectContext deleteObject:selectedItem];
            }
            break;
            
        case MAEditorSectionTagManagedUpdates:
            for (StringObjectMO *selectedItem in [self.managedUpdatesArrayController selectedObjects]) {
                [self.manifestToEdit.managedObjectContext deleteObject:selectedItem];
            }
            break;
            
        case MAEditorSectionTagOptionalInstalls:
            for (StringObjectMO *selectedItem in [self.optionalInstallsArrayController selectedObjects]) {
                [self.manifestToEdit.managedObjectContext deleteObject:selectedItem];
            }
            break;
        
        case MAEditorSectionTagFeaturedItems:
            for (StringObjectMO *selectedItem in [self.featuredItemsArrayController selectedObjects]) {
                [self.manifestToEdit.managedObjectContext deleteObject:selectedItem];
            }
            break;
            
        case MAEditorSectionTagReferencingManifests:
            for (StringObjectMO *selectedItem in [self.referencingManifestsArrayController selectedObjects]) {
                ManifestMO *originalManifest;
                if (selectedItem.manifestReference) {
                    originalManifest = selectedItem.manifestReference;
                } else {
                    originalManifest = selectedItem.includedManifestConditionalReference.manifest;
                }
                [self.manifestToEdit.managedObjectContext deleteObject:selectedItem];
                [self.manifestToEdit.managedObjectContext refreshObject:originalManifest mergeChanges:YES];
            }
            break;
            
        default:
            DDLogError(@"removeItemsAction: tag %ld not handled...", (long)selected.tag);
            break;
    }
    
    [self.manifestToEdit.managedObjectContext refreshObject:self.manifestToEdit mergeChanges:YES];
}


- (void)newPredicateSheetDidEnd:(id)sheet returnCode:(NSModalResponse)returnCode object:(id)object
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    if (returnCode == NSModalResponseCancel) return;
    
    NSString *thePredicateString = nil;
    if ([self.predicateEditor.tabView selectedTabViewItem] == self.predicateEditor.predicateEditorTabViewItem) {
        thePredicateString = [self.predicateEditor.predicateEditor.objectValue description];
    } else {
        thePredicateString = [self.predicateEditor.customTextField stringValue];
    }
    
    NSArray *selectedConditionalItems = [self.conditionsTreeController selectedObjects];
    ManifestMO *selectedManifest = self.manifestToEdit;
    NSManagedObjectContext *moc = self.manifestToEdit.managedObjectContext;
    
    
    if ([selectedConditionalItems count] == 0) {
        ConditionalItemMO *newConditionalItem = [NSEntityDescription insertNewObjectForEntityForName:@"ConditionalItem" inManagedObjectContext:moc];
        newConditionalItem.munki_condition = thePredicateString;
        [self.manifestToEdit addConditionalItemsObject:newConditionalItem];
    } else {
        for (id selectedConditionalItem in selectedConditionalItems) {
            ConditionalItemMO *newConditionalItem = [NSEntityDescription insertNewObjectForEntityForName:@"ConditionalItem" inManagedObjectContext:moc];
            newConditionalItem.munki_condition = thePredicateString;
            [self.manifestToEdit addConditionalItemsObject:newConditionalItem];
            newConditionalItem.parent = selectedConditionalItem;
        }
    }
    
    [moc refreshObject:selectedManifest mergeChanges:YES];
}

- (void)editPredicateSheetDidEnd:(id)sheet returnCode:(NSModalResponse)returnCode object:(id)object
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    if (returnCode == NSModalResponseCancel) return;
    
    NSString *thePredicateString = nil;
    if ([self.predicateEditor.tabView selectedTabViewItem] == self.predicateEditor.predicateEditorTabViewItem) {
        thePredicateString = [self.predicateEditor.predicateEditor.objectValue description];
    } else {
        thePredicateString = [self.predicateEditor.customTextField stringValue];
    }
    
    NSManagedObjectContext *moc = self.manifestToEdit.managedObjectContext;
    self.predicateEditor.conditionToEdit.munki_condition = thePredicateString;
    [moc refreshObject:self.manifestToEdit mergeChanges:YES];
}

- (IBAction)addNewConditionalItemAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    [self.window beginSheet:[self.predicateEditor window] completionHandler:^(NSModalResponse returnCode) {
        [self newPredicateSheetDidEnd:self.predicateEditor returnCode:returnCode object:nil];
    }];
    
    self.predicateEditor.conditionToEdit = nil;
    [self.predicateEditor resetPredicateToDefault];
}

- (IBAction)editConditionalItemAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    ConditionalItemMO *selectedCondition = [[self.conditionsTreeController selectedObjects] lastObject];
    
    @try {
        NSPredicate *predicateToEdit = [NSPredicate predicateWithFormat:selectedCondition.munki_condition];
        if (predicateToEdit != nil) {
            [self.window beginSheet:[self.predicateEditor window] completionHandler:^(NSModalResponse returnCode) {
                [self editPredicateSheetDidEnd:self.predicateEditor returnCode:returnCode object:nil];
            }];
            
            self.predicateEditor.conditionToEdit = selectedCondition;
            self.predicateEditor.customPredicateString = selectedCondition.munki_condition;
            self.predicateEditor.predicateEditor.objectValue = [NSPredicate predicateWithFormat:selectedCondition.munki_condition];
        }
    }
    @catch (NSException *exception) {
        DDLogError(@"Caught exception while trying to open predicate editor. This usually means that the predicate is valid but the editor can not edit it. Showing the text field editor instead...");
        [self.window beginSheet:[self.predicateEditor window] completionHandler:^(NSModalResponse returnCode) {
            [self editPredicateSheetDidEnd:self.predicateEditor returnCode:returnCode object:nil];
        }];
        
        [self.predicateEditor resetPredicateToDefault];
        self.predicateEditor.conditionToEdit = selectedCondition;
        self.predicateEditor.customPredicateString = selectedCondition.munki_condition;
        [self.predicateEditor.tabView selectTabViewItemAtIndex:1];
    }
    @finally {
        
    }
    
}

- (IBAction)removeConditionalItemAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    ManifestMO *selectedManifest = self.manifestToEdit;
    
    for (ConditionalItemMO *aConditionalItem in [self.conditionsTreeController selectedObjects]) {
        [self.manifestToEdit.managedObjectContext deleteObject:aConditionalItem];
    }
    [self.manifestToEdit.managedObjectContext refreshObject:selectedManifest mergeChanges:YES];
}


- (IBAction)renameManifestAction:(id)sender
{
    /*
     Get the manifest item that was right-clicked
     */
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    ManifestMO *selectedManifest = self.manifestToEdit;
    
    NSString *originalFilename = [selectedManifest.manifestURL lastPathComponent];
    
    /*
     Ask for a new title
     */
    [self.requestStringValue setDefaultValues];
    self.requestStringValue.windowTitleText = @"";
    self.requestStringValue.titleText = [NSString stringWithFormat:@"Rename \"%@\"?", originalFilename];
    self.requestStringValue.okButtonTitle = @"Rename";
    self.requestStringValue.labelText = @"New Name:";
    self.requestStringValue.descriptionText = [NSString stringWithFormat:@"Enter a new name for the manifest \"%@\".", originalFilename];
    self.requestStringValue.stringValue = originalFilename;
    NSWindow *window = [self.requestStringValue window];
    NSInteger result = [NSApp runModalForWindow:window];
    
    /*
     Perform the actual rename
     */
    if (result == NSModalResponseOK) {
        MAMunkiRepositoryManager *repoManager = [MAMunkiRepositoryManager sharedManager];
        NSString *newTitle = self.requestStringValue.stringValue;
        
        if (![originalFilename isEqualToString:newTitle]) {
            NSURL *newURL = [selectedManifest.manifestParentDirectoryURL URLByAppendingPathComponent:newTitle];
            [repoManager moveManifest:selectedManifest toURL:newURL cascade:YES];
        } else {
            DDLogError(@"Old name and new name are the same. Skipping rename...");
        }
    }
    
    [self.manifestToEdit.managedObjectContext refreshObject:selectedManifest mergeChanges:YES];
    [self.requestStringValue setDefaultValues];
}


- (void)setupSourceList
{
    NSView *sourceListView = self.sourceListView;
    [sourceListView setIdentifier:@"sourceListView"];
    //[sourceListView setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
    [sourceListView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [sourceListView setAutoresizesSubviews:YES];
    [self.sourceListPlaceHolder addSubview:sourceListView];
    NSDictionary *views = NSDictionaryOfVariableBindings(sourceListView);
    [self.sourceListPlaceHolder addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sourceListView(>=100)]|" options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
    [self.sourceListPlaceHolder addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sourceListView(>=100)]|" options:NSLayoutFormatAlignAllLeading metrics:nil views:views]];
    
    
    /*
     Create source list items
     */
    NSDictionary *bindOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSContinuouslyUpdatesValueBindingOption, nil];
    NSMutableArray *newSourceListItems = [NSMutableArray new];
    
    NSImage *generalIcon = [NSImage imageNamed:@"manifestGeneralTemplate.pdf"];
    NSImage *managedInstallsIcon = [NSImage imageNamed:@"manifestManagedInstallsTemplate.pdf"];
    NSImage *managedUninstallsIcon = [NSImage imageNamed:@"manifestManagedUninstallsTemplate.pdf"];
    NSImage *managedUpdatesIcon = [NSImage imageNamed:@"manifestManagedUpdatesTemplate.pdf"];
    NSImage *optionalInstallsIcon = [NSImage imageNamed:@"manifestOptionalInstallsTemplate.pdf"];
    NSImage *featuredItemsIcon = [NSImage imageNamed:@"manifestFeaturedItemsTemplate.pdf"];
    NSImage *includedManifestsIcon = [NSImage imageNamed:@"manifestIncludedManifestsTemplate.pdf"];
    NSImage *referencingManifestsIcon = [NSImage imageNamed:@"manifestReferencedManifestsTemplate.pdf"];
    NSImage *conditionsIcon = [NSImage imageNamed:@"manifestConditionsTemplate.pdf"];
    
    MAManifestEditorSection *generalSection = [MAManifestEditorSection new];
    generalSection.title = @"General";
    generalSection.tag = MAEditorSectionTagGeneral;
    generalSection.icon = generalIcon;
    [generalSection bind:@"subtitle" toObject:self withKeyPath:@"manifestToEdit.catalogsCountDescriptionString" options:bindOptions];
    generalSection.view = self.generalView;
    [newSourceListItems addObject:generalSection];
    
    /*
    MAManifestEditorSection *combinedSection = [MAManifestEditorSection new];
    combinedSection.title = @"Combined";
    combinedSection.icon = [NSImage imageNamed:NSImageNamePreferencesGeneral];
    [newSourceListItems addObject:combinedSection];
    */
    
    MAManifestEditorSection *managedInstallsSection = [MAManifestEditorSection new];
    managedInstallsSection.title = @"Managed Installs";
    managedInstallsSection.tag = MAEditorSectionTagManagedInstalls;
    managedInstallsSection.icon = managedInstallsIcon;
    [managedInstallsSection bind:@"subtitle" toObject:self withKeyPath:@"manifestToEdit.managedInstallsCountDescription" options:bindOptions];
    managedInstallsSection.view = self.contentItemsListView;
    [newSourceListItems addObject:managedInstallsSection];
    
    
    MAManifestEditorSection *managedUninstallsSection = [MAManifestEditorSection new];
    managedUninstallsSection.title = @"Managed Uninstalls";
    managedUninstallsSection.tag = MAEditorSectionTagManagedUninstalls;
    managedUninstallsSection.icon = managedUninstallsIcon;
    [managedUninstallsSection bind:@"subtitle" toObject:self withKeyPath:@"manifestToEdit.managedUninstallsCountDescription" options:bindOptions];
    managedUninstallsSection.view = self.contentItemsListView;
    [newSourceListItems addObject:managedUninstallsSection];
    
    MAManifestEditorSection *managedUpdatesSection = [MAManifestEditorSection new];
    managedUpdatesSection.title = @"Managed Updates";
    managedUpdatesSection.tag = MAEditorSectionTagManagedUpdates;
    managedUpdatesSection.icon = managedUpdatesIcon;
    [managedUpdatesSection bind:@"subtitle" toObject:self withKeyPath:@"manifestToEdit.managedUpdatesCountDescription" options:bindOptions];
    managedUpdatesSection.view = self.contentItemsListView;
    [newSourceListItems addObject:managedUpdatesSection];
    
    MAManifestEditorSection *optionalInstallsSection = [MAManifestEditorSection new];
    optionalInstallsSection.title = @"Optional Installs";
    optionalInstallsSection.tag = MAEditorSectionTagOptionalInstalls;
    optionalInstallsSection.icon = optionalInstallsIcon;
    [optionalInstallsSection bind:@"subtitle" toObject:self withKeyPath:@"manifestToEdit.optionalInstallsCountDescription" options:bindOptions];
    optionalInstallsSection.view = self.contentItemsListView;
    [newSourceListItems addObject:optionalInstallsSection];
    
    MAManifestEditorSection *featuredItemsSection = [MAManifestEditorSection new];
    featuredItemsSection.title = @"Featured Items";
    featuredItemsSection.tag = MAEditorSectionTagFeaturedItems;
    featuredItemsSection.icon = featuredItemsIcon;
    [featuredItemsSection bind:@"subtitle" toObject:self withKeyPath:@"manifestToEdit.featuredItemsCountDescription" options:bindOptions];
    featuredItemsSection.view = self.contentItemsListView;
    [newSourceListItems addObject:featuredItemsSection];
    
    MAManifestEditorSection *includedManifestsSection = [MAManifestEditorSection new];
    includedManifestsSection.title = @"Included Manifests";
    includedManifestsSection.tag = MAEditorSectionTagIncludedManifests;
    includedManifestsSection.icon = includedManifestsIcon;
    [includedManifestsSection bind:@"subtitle" toObject:self withKeyPath:@"manifestToEdit.includedManifestsCountDescription" options:bindOptions];
    includedManifestsSection.view = self.includedManifestsListView;
    [newSourceListItems addObject:includedManifestsSection];
    
    MAManifestEditorSection *referencingManifestsSection = [MAManifestEditorSection new];
    referencingManifestsSection.title = @"Referencing Manifests";
    referencingManifestsSection.tag = MAEditorSectionTagReferencingManifests;
    referencingManifestsSection.icon = referencingManifestsIcon;
    [referencingManifestsSection bind:@"subtitle" toObject:self withKeyPath:@"manifestToEdit.referencingManifestsCountDescription" options:bindOptions];
    referencingManifestsSection.view = self.referencingManifestsListView;
    [newSourceListItems addObject:referencingManifestsSection];
    
    MAManifestEditorSection *conditionsSection = [MAManifestEditorSection new];
    conditionsSection.title = @"Conditions";
    conditionsSection.tag = MAEditorSectionTagConditions;
    conditionsSection.icon = conditionsIcon;
    [conditionsSection bind:@"subtitle" toObject:self withKeyPath:@"manifestToEdit.conditionsCountDescription" options:bindOptions];
    conditionsSection.view = self.conditionalsListView;
    [newSourceListItems addObject:conditionsSection];
    
    
    self.sourceListItems = [NSArray arrayWithArray:newSourceListItems];
}


- (NSTextField *)addTextFieldWithidentifier:(NSString *)identifier superView:(NSView *)superview
{
    NSTextField *textField = [[NSTextField alloc] init];
    [textField setIdentifier:identifier];
    [[textField cell] setControlSize:NSRegularControlSize];
    [textField setBordered:NO];
    [textField setBezeled:NO];
    [textField setSelectable:YES];
    [textField setEditable:NO];
    [textField setFont:[NSFont systemFontOfSize:13.0]];
    [textField setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [superview addSubview:textField];
    return textField;
}

- (NSTextField *)addLabelFieldWithTitle:(NSString *)title identifier:(NSString *)identifier superView:(NSView *)superview
{
    NSTextField *textField = [[NSTextField alloc] init];
    [textField setIdentifier:identifier];
    [textField setStringValue:title];
    [[textField cell] setControlSize:NSRegularControlSize];
    [textField setAlignment:NSRightTextAlignment];
    [textField setBordered:NO];
    [textField setBezeled:NO];
    [textField setSelectable:NO];
    [textField setEditable:NO];
    [textField setDrawsBackground:NO];
    [textField setFont:[NSFont boldSystemFontOfSize:13.0]];
    [textField setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [superview addSubview:textField];
    return textField;
}



- (void)setupProductInfoView:(NSView *)parentView
{
    
}


#pragma mark -
#pragma mark NSTableView Delegate

- (id<NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row
{
    if (tableView == self.catalogInfosTableView) {
        CatalogInfoMO *aCatalogInfo = [[self.catalogInfosArrayController arrangedObjects] objectAtIndex:(NSUInteger)row];
        NSURL *objectURL = [[aCatalogInfo objectID] URIRepresentation];
        return objectURL;
    } else {
        return nil;
    }
}

- (NSDragOperation)tableView:(NSTableView*)theTableView validateDrop:(id <NSDraggingInfo>)theDraggingInfo proposedRow:(NSInteger)theRow proposedDropOperation:(NSTableViewDropOperation)theDropOperation
{
    NSDragOperation result = NSDragOperationNone;
    if (theTableView == self.catalogInfosTableView) {
        if (theDropOperation == NSTableViewDropAbove) {
            result = NSDragOperationMove;
        }
    }
    
    return result;
}

- (void)makeRoomForCatalogsAtIndex:(NSInteger)index
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"indexInManifest >= %@", [NSNumber numberWithInteger:index]];
    for (CatalogInfoMO *catalogInfo in [self.manifestToEdit.catalogInfos filteredSetUsingPredicate:predicate]) {
        NSInteger currentIndex = [catalogInfo.indexInManifest integerValue];
        catalogInfo.indexInManifest = [NSNumber numberWithInteger:currentIndex + 1];
    }
}

- (void)renumberCatalogItems
{
    NSInteger index = 0;
    for (CatalogInfoMO *aCatalogInfo in [self.catalogInfosArrayController arrangedObjects]) {
        aCatalogInfo.indexInManifest = [NSNumber numberWithInteger:index];
        index++;
    }
}

- (BOOL)tableView:(NSTableView *)theTableView acceptDrop:(id <NSDraggingInfo>)draggingInfo row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard *draggingPasteboard = [draggingInfo draggingPasteboard];
    if (theTableView == self.catalogInfosTableView) {
        NSArray *dragTypes = [draggingPasteboard types];
        if ([dragTypes containsObject:NSURLPboardType]) {
            
            NSPasteboard *pasteboard = draggingPasteboard;
            NSArray *classes = @[[NSURL class]];
            NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey : @NO};
            NSArray *urls = [pasteboard readObjectsForClasses:classes options:options];
            for (NSURL *uri in urls) {
                NSManagedObjectContext *moc = self.manifestToEdit.managedObjectContext;
                NSManagedObjectID *objectID = [[moc persistentStoreCoordinator] managedObjectIDForURIRepresentation:uri];
                CatalogInfoMO *mo = (CatalogInfoMO *)[moc objectRegisteredForID:objectID];
                [self makeRoomForCatalogsAtIndex:row];
                mo.indexInManifest = @(row);
                
            }
        }
        
        [self renumberCatalogItems];
        
        return YES;
    }
    
    else {
        return NO;
    }
}


- (void)setContentView:(NSView *)newContentView
{
    for (id view in [self.contentViewPlaceHolder subviews]) {
        [view removeFromSuperview];
    }
    
    [self.contentViewPlaceHolder addSubview:newContentView];
    
    [newContentView setFrame:[self.contentViewPlaceHolder frame]];
    
    // make sure our added subview is placed and resizes correctly
    [newContentView setFrameOrigin:NSMakePoint(0,0)];
    [newContentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [newContentView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [newContentView setAutoresizesSubviews:NO];
}


- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSTableView *tableView = [aNotification object];
    if (tableView == self.sourceListTableView) {
        if ([[self.editorSectionsArrayController selectedObjects] count] == 0) {
            return;
        }
        
        MAManifestEditorSection *selected = [self.editorSectionsArrayController selectedObjects][0];
        
        if (selected.tag == MAEditorSectionTagManagedInstalls) {
            [self.contentItemsTableView bind:NSContentBinding toObject:self.managedInstallsArrayController withKeyPath:@"arrangedObjects" options:nil];
            [self.contentItemsTableView bind:NSSelectionIndexesBinding toObject:self.managedInstallsArrayController withKeyPath:@"selectionIndexes" options:nil];
        } else if ([selected.title isEqualToString:@"Managed Uninstalls"]) {
            [self.contentItemsTableView bind:NSContentBinding toObject:self.managedUninstallsArrayController withKeyPath:@"arrangedObjects" options:nil];
            [self.contentItemsTableView bind:NSSelectionIndexesBinding toObject:self.managedUninstallsArrayController withKeyPath:@"selectionIndexes" options:nil];
        } else if ([selected.title isEqualToString:@"Managed Updates"]) {
            [self.contentItemsTableView bind:NSContentBinding toObject:self.managedUpdatesArrayController withKeyPath:@"arrangedObjects" options:nil];
            [self.contentItemsTableView bind:NSSelectionIndexesBinding toObject:self.managedUpdatesArrayController withKeyPath:@"selectionIndexes" options:nil];
        } else if ([selected.title isEqualToString:@"Optional Installs"]) {
            [self.contentItemsTableView bind:NSContentBinding toObject:self.optionalInstallsArrayController withKeyPath:@"arrangedObjects" options:nil];
            [self.contentItemsTableView bind:NSSelectionIndexesBinding toObject:self.optionalInstallsArrayController withKeyPath:@"selectionIndexes" options:nil];
        } else if (selected.tag == MAEditorSectionTagFeaturedItems) {
            [self.contentItemsTableView bind:NSContentBinding toObject:self.featuredItemsArrayController withKeyPath:@"arrangedObjects" options:nil];
            [self.contentItemsTableView bind:NSSelectionIndexesBinding toObject:self.featuredItemsArrayController withKeyPath:@"selectionIndexes" options:nil];
        } else if (selected.tag == MAEditorSectionTagIncludedManifests) {
            [self.includedManifestsTableView bind:NSContentBinding toObject:self.includedManifestsArrayController withKeyPath:@"arrangedObjects" options:nil];
            [self.includedManifestsTableView bind:NSSelectionIndexesBinding toObject:self.includedManifestsArrayController withKeyPath:@"selectionIndexes" options:nil];
        } else if (selected.tag == MAEditorSectionTagReferencingManifests) {
            [self.referencingManifestsTableView bind:NSContentBinding toObject:self.referencingManifestsArrayController withKeyPath:@"arrangedObjects" options:nil];
            [self.referencingManifestsTableView bind:NSSelectionIndexesBinding toObject:self.referencingManifestsArrayController withKeyPath:@"selectionIndexes" options:nil];
        }
        [self setContentView:selected.view];
        self.currentDetailView = selected.view;
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    id view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:nil];
    
    if (tableView == self.contentItemsTableView) {
        
        /*
         Create the correct bindings for the condition column
         */
        if ([tableColumn.identifier isEqualToString:@"tableColumnCondition"]) {
            NSDictionary *bindOptions = @{NSInsertsNullPlaceholderBindingOption: @YES,
                                          NSNullPlaceholderBindingOption: @"--"};
            ItemCellView *itemCellView = (ItemCellView *)view;
            [itemCellView.popupButton bind:NSContentBinding toObject:self.conditionalItemsArrayController withKeyPath:@"arrangedObjects" options:bindOptions];
            [itemCellView.popupButton bind:NSContentValuesBinding toObject:self.conditionalItemsArrayController withKeyPath:@"arrangedObjects.titleWithParentTitle" options:bindOptions];
            MAManifestEditorSection *selected = [self.editorSectionsArrayController selectedObjects][0];
            if ([selected.title isEqualToString:@"Managed Installs"]) {
                [itemCellView.popupButton bind:NSSelectedObjectBinding toObject:itemCellView withKeyPath:@"objectValue.managedInstallConditionalReference" options:nil];
            } else if ([selected.title isEqualToString:@"Managed Uninstalls"]) {
                [itemCellView.popupButton bind:NSSelectedObjectBinding toObject:itemCellView withKeyPath:@"objectValue.managedUninstallConditionalReference" options:nil];
            } else if ([selected.title isEqualToString:@"Managed Updates"]) {
                [itemCellView.popupButton bind:NSSelectedObjectBinding toObject:itemCellView withKeyPath:@"objectValue.managedUpdateConditionalReference" options:nil];
            } else if ([selected.title isEqualToString:@"Optional Installs"]) {
                [itemCellView.popupButton bind:NSSelectedObjectBinding toObject:itemCellView withKeyPath:@"objectValue.optionalInstallConditionalReference" options:nil];
            } else if (selected.tag == MAEditorSectionTagFeaturedItems) {
                [itemCellView.popupButton bind:NSSelectedObjectBinding toObject:itemCellView withKeyPath:@"objectValue.featuredItemConditionalReference" options:nil];
            } else if (selected.tag == MAEditorSectionTagIncludedManifests) {
                [itemCellView.popupButton bind:NSSelectedObjectBinding toObject:itemCellView withKeyPath:@"objectValue.includedManifestConditionalReference" options:nil];
            }
            
        }
    } else if (tableView == self.includedManifestsTableView) {
        /*
         Create the correct bindings for the condition column
         */
        if ([tableColumn.identifier isEqualToString:@"tableColumnCondition"]) {
            NSDictionary *bindOptions = @{NSInsertsNullPlaceholderBindingOption: @YES,
                                          NSNullPlaceholderBindingOption: @"--"};
            ItemCellView *itemCellView = (ItemCellView *)view;
            [itemCellView.popupButton bind:NSContentBinding toObject:self.conditionalItemsArrayController withKeyPath:@"arrangedObjects" options:bindOptions];
            [itemCellView.popupButton bind:NSContentValuesBinding toObject:self.conditionalItemsArrayController withKeyPath:@"arrangedObjects.titleWithParentTitle" options:bindOptions];
            MAManifestEditorSection *selected = [self.editorSectionsArrayController selectedObjects][0];
            if (selected.tag == MAEditorSectionTagIncludedManifests) {
                [itemCellView.popupButton bind:NSSelectedObjectBinding toObject:itemCellView withKeyPath:@"objectValue.includedManifestConditionalReference" options:nil];
            } else if (selected.tag == MAEditorSectionTagReferencingManifests) {
                [itemCellView.popupButton bind:NSSelectedObjectBinding toObject:itemCellView withKeyPath:@"objectValue.originalManifestConditionalReference" options:nil];
            }
        } else if ([tableColumn.identifier isEqualToString:@"tableColumnManifestTitle"]) {
            NSTableCellView *tableCellView = (NSTableCellView *)view;
            StringObjectMO *current = [self.includedManifestsArrayController.arrangedObjects objectAtIndex:(NSUInteger)row];
            //[tableCellView.textField bind:NSValueBinding toObject:tableCellView withKeyPath:@"objectValue.manifestTitleOrDisplayName" options:nil];
            if (current.originalManifest) {
                [tableCellView.textField bind:NSValueBinding toObject:tableCellView withKeyPath:@"objectValue.originalManifest.titleOrDisplayName" options:nil];
            } else {
                //
            }
        }
        
    } else if (tableView == self.referencingManifestsTableView) {
        /*
         Create the correct bindings for the condition column
         */
        if ([tableColumn.identifier isEqualToString:@"tableColumnConditionTitle"]) {
            
            NSDictionary *bindOptions = @{NSInsertsNullPlaceholderBindingOption: @YES, NSNullPlaceholderBindingOption: @"--"};
            NSTableCellView *tableCellView = (NSTableCellView *)view;
            [tableCellView.textField bind:NSValueBinding toObject:tableCellView withKeyPath:@"objectValue.includedManifestConditionalReference.munki_condition" options:bindOptions];
        } else if ([tableColumn.identifier isEqualToString:@"tableColumnManifestTitle"]) {
            NSTableCellView *tableCellView = (NSTableCellView *)view;
            StringObjectMO *current = [self.referencingManifestsArrayController.arrangedObjects objectAtIndex:(NSUInteger)row];
            //[tableCellView.textField bind:NSValueBinding toObject:tableCellView withKeyPath:@"objectValue.manifestTitleOrDisplayName" options:nil];
            if (current.manifestReference) {
                [tableCellView.textField bind:NSValueBinding toObject:tableCellView withKeyPath:@"objectValue.manifestReference.titleOrDisplayName" options:nil];
            } else {
                [tableCellView.textField bind:NSValueBinding toObject:tableCellView withKeyPath:@"objectValue.includedManifestConditionalReference.manifest.titleOrDisplayName" options:nil];
            }
        }
    }
    return view;
}

- (void)menuWillOpen:(NSMenu *)menu
{
    
}

# pragma mark - NSOutlineView delegates


- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
{
    [pboard declareTypes:[NSArray arrayWithObject:MAConditionalItemType] owner:self];
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:[items valueForKey:@"indexPath"]] forType:MAConditionalItemType];
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)proposedParentItem childIndex:(NSInteger)index
{
    
    NSArray *droppedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:MAConditionalItemType]];
    
    NSMutableArray *draggedNodes = [NSMutableArray array];
    for (NSIndexPath *indexPath in droppedIndexPaths) {
        id treeRoot = [self.conditionsTreeController arrangedObjects];
        NSTreeNode *node = [treeRoot descendantNodeAtIndexPath:indexPath];
        [draggedNodes addObject:node];
    }
    
    for (NSTreeNode *aNode in draggedNodes) {
        ConditionalItemMO *droppedConditional = [aNode representedObject];
        NSTreeNode *parent = proposedParentItem;
        ConditionalItemMO *parentConditional = [parent representedObject];
        
        if (!proposedParentItem) {
            droppedConditional.parent = nil;
        }
        else {
            droppedConditional.parent = parentConditional;
        }
        
        [[(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext] refreshObject:droppedConditional.manifest mergeChanges:YES];
    }
    
    [self.conditionsTreeController rearrangeObjects];
    [self.conditionalItemsArrayController rearrangeObjects];
    
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
    
    // Deny drag and drop reordering
    if (index != -1) {
        return NSDragOperationNone;
    }
    
    NSArray *draggedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:MAConditionalItemType]];
    for (NSIndexPath *indexPath in draggedIndexPaths) {
        id treeRoot = [self.conditionsTreeController arrangedObjects];
        NSTreeNode *node = [treeRoot descendantNodeAtIndexPath:indexPath];
        ConditionalItemMO *droppedConditional = [node representedObject];
        NSTreeNode *parent = item;
        ConditionalItemMO *parentConditional = [parent representedObject];
        
        // Dragging a 1st level item so deny dropping to root
        if ((droppedConditional.parent == nil) && (parentConditional == nil)) {
            return NSDragOperationNone;
        }
        
        // Can't drop on child items
        while (parent != nil) {
            if (parent == node) {
                return NSDragOperationNone;
            }
            parent = [parent parentNode];
        }
    }
    return NSDragOperationGeneric;
}

# pragma mark - NSSplitView delegates

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    if (sender == self.mainSplitView) {
        /*
         Main split view
         Resize only the right side of the splitview
         */
        NSView *left = [sender subviews][0];
        NSView *right = [sender subviews][1];
        CGFloat dividerThickness = [sender dividerThickness];
        NSRect newFrame = [sender frame];
        NSRect leftFrame = [left frame];
        NSRect rightFrame = [right frame];
        
        rightFrame.size.height = newFrame.size.height;
        rightFrame.size.width = newFrame.size.width - leftFrame.size.width - dividerThickness;
        rightFrame.origin = NSMakePoint(leftFrame.size.width + dividerThickness, 0);
        
        leftFrame.size.height = newFrame.size.height;
        leftFrame.origin.x = 0;
        
        [left setFrame:leftFrame];
        [right setFrame:rightFrame];
    }
}


@end
