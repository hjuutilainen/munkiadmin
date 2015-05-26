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
#import "MAMunkiAdmin_AppDelegate.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

#pragma mark -
#pragma mark MAManifestEditorSection

@interface MAManifestEditorSection : NSObject
typedef NS_ENUM(NSInteger, MAEditorSectionTag) {
    MAEditorSectionTagGeneral,
    MAEditorSectionTagManagedInstalls,
    MAEditorSectionTagManagedUninstalls,
    MAEditorSectionTagManagedUpdates,
    MAEditorSectionTagOptionalInstalls,
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
    NSColor *textColor = (backgroundStyle == NSBackgroundStyleDark) ? [NSColor windowBackgroundColor] : [NSColor controlShadowColor];
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
    
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"catalog.title" ascending:YES selector:@selector(localizedStandardCompare:)];
    self.catalogInfosArrayController.sortDescriptors = @[sorter];
    
    NSSortDescriptor *sortByCondition = [NSSortDescriptor sortDescriptorWithKey:@"munki_condition" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByTitleWithParentTitle = [NSSortDescriptor sortDescriptorWithKey:@"titleWithParentTitle" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.conditionalItemsArrayController setSortDescriptors:@[sortByTitleWithParentTitle, sortByCondition]];
    
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    self.managedInstallsArrayController.sortDescriptors = @[sortByTitle];
    self.managedUpdatesArrayController.sortDescriptors = @[sortByTitle];
    self.managedUninstallsArrayController.sortDescriptors = @[sortByTitle];
    self.optionalInstallsArrayController.sortDescriptors = @[sortByTitle];
    self.includedManifestsArrayController.sortDescriptors = @[sortByTitle];
    
    NSSortDescriptor *sortByReferenceTitle = [NSSortDescriptor sortDescriptorWithKey:@"manifestReference.title" ascending:YES selector:@selector(localizedStandardCompare:)];
    self.referencingManifestsArrayController.sortDescriptors = @[sortByReferenceTitle];
    //self.referencingManifestsTableView.target = self;
    //self.referencingManifestsTableView.doubleAction = @selector(referencingManifestDoubleClick:);
    
    NSManagedObjectContext *moc = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ConditionalItem" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:nil];
    self.conditionalItemsAllArrayController.content = fetchResults;
    [self.conditionalItemsAllArrayController setSortDescriptors:@[sortByTitleWithParentTitle, sortByCondition]];
    
    [self setupSourceList];
}

- (void)referencingManifestDoubleClick:(id)sender
{
    
}

- (void)awakeFromNib
{
    /*
     Setup the main window
     */
    [self.window setBackgroundColor:[NSColor whiteColor]];
    [self.window bind:@"title" toObject:self withKeyPath:@"manifestToEdit.title" options:nil];
    
    self.currentDetailView = self.generalView;
    
    
    
    self.addItemsWindowController = [[MASelectPkginfoItemsWindow alloc] initWithWindowNibName:@"MASelectPkginfoItemsWindow"];
    self.selectManifestsWindowController = [[MASelectManifestItemsWindow alloc] initWithWindowNibName:@"MASelectManifestItemsWindow"];
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
        [NSApp beginSheet:[self.selectManifestsWindowController window]
           modalForWindow:self.window modalDelegate:self
           didEndSelector:@selector(addNewItemSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
    }
    
    ManifestMO *selectedManifest = self.manifestToEdit;
    NSMutableArray *tempPredicates = [[NSMutableArray alloc] init];
    
    for (StringObjectMO *referencingManifest in selectedManifest.referencingManifests) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"title != %@", referencingManifest.manifestReference.title];
        [tempPredicates addObject:newPredicate];
    }
    
    for (ConditionalItemMO *conditional in selectedManifest.conditionalItems) {
        for (StringObjectMO *referencingManifest in conditional.referencingManifests) {
            NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"title != %@", referencingManifest.manifestReference.title];
            [tempPredicates addObject:newPredicate];
        }
    }
    
    NSPredicate *denySelfPred = [NSPredicate predicateWithFormat:@"title != %@", selectedManifest.title];
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
        [NSApp beginSheet:[self.selectManifestsWindowController window]
           modalForWindow:self.window modalDelegate:self
           didEndSelector:@selector(addNewItemSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
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
        
        case MAEditorSectionTagIncludedManifests:
            for (StringObjectMO *selectedItem in [self.selectManifestsWindowController selectionAsStringObjects]) {
                [self.manifestToEdit addIncludedManifestsFasterObject:selectedItem];
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
        [self.manifestToEdit.managedObjectContext deleteObject:anIncludedManifest];
    }
    [self.manifestToEdit.managedObjectContext refreshObject:selectedManifest mergeChanges:YES];
}

- (void)addNewItemSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
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
        [NSApp beginSheet:[self.addItemsWindowController window]
           modalForWindow:self.window modalDelegate:self
           didEndSelector:@selector(addNewItemSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
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
            
        case MAEditorSectionTagReferencingManifests:
            for (StringObjectMO *selectedItem in [self.referencingManifestsArrayController selectedObjects]) {
                
                [self.manifestToEdit.managedObjectContext deleteObject:selectedItem];
            }
            break;
            
        default:
            DDLogError(@"removeItemsAction: tag %ld not handled...", (long)selected.tag);
            break;
    }
    
    [self.manifestToEdit.managedObjectContext refreshObject:self.manifestToEdit mergeChanges:YES];
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
    conditionsSection.view = self.includedManifestsListView;
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
    id view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
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
            if (current.manifestReference) {
                [tableCellView.textField bind:NSValueBinding toObject:tableCellView withKeyPath:@"objectValue.manifestReference.title" options:nil];
            } else {
                [tableCellView.textField bind:NSValueBinding toObject:tableCellView withKeyPath:@"objectValue.includedManifestConditionalReference.manifest.title" options:nil];
            }
        }
    }
    return view;
}

- (void)menuWillOpen:(NSMenu *)menu
{
    
}


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
