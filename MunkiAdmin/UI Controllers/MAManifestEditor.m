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
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

@interface MAManifestEditorSection : NSObject
typedef NS_ENUM(NSInteger, MAEditorSectionTag) {
    MAEditorSectionTagGeneral,
    MAEditorSectionTagManagedInstalls,
    MAEditorSectionTagManagedUninstalls,
    MAEditorSectionTagManagedUpdates,
    MAEditorSectionTagOptionalInstalls,
    MAEditorSectionTagIncludedManifests,
    MAEditorSectionTagConditionalItems
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
    
    [self setupSourceList];
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

- (void)processAddItemsAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    for (StringObjectMO *selectedItem in [self.addItemsWindowController selectionAsStringObjects]) {
        [self.manifestToEdit addManagedInstallsFasterObject:selectedItem];
        
    }
    // Need to refresh fetched properties
    [self.manifestToEdit.managedObjectContext refreshObject:self.manifestToEdit mergeChanges:YES];
    
    [NSApp endSheet:[self.addItemsWindowController window]];
    [[self.addItemsWindowController window] close];
}

- (void)addNewManagedInstallSheetDidEnd:(id)sheet returnCode:(int)returnCode object:(id)object
{
    DDLogError(@"%@", NSStringFromSelector(_cmd));
    
    if (returnCode == NSCancelButton) return;
    [self processAddItemsAction:sheet];
}

- (IBAction)addNewItemsAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    /*
     Figure out what kind of items we're adding
     */
    if ([[self.editorSectionsArrayController selectedObjects] count] == 0) {
        return;
    }
    
    MAManifestEditorSection *selected = [self.editorSectionsArrayController selectedObjects][0];
    if (selected.tag == MAEditorSectionTagManagedInstalls) {
        
    }
    
    [NSApp beginSheet:[self.addItemsWindowController window]
       modalForWindow:self.window modalDelegate:self
       didEndSelector:@selector(addNewManagedInstallSheetDidEnd:returnCode:object:) contextInfo:nil];
    
    ManifestMO *selectedManifest = self.manifestToEdit;
    NSMutableArray *tempPredicates = [[NSMutableArray alloc] init];
    
    for (StringObjectMO *aManagedInstall in selectedManifest.managedInstallsFaster) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"munki_name != %@", aManagedInstall.title];
        [tempPredicates addObject:newPredicate];
    }
    
    for (ConditionalItemMO *conditional in selectedManifest.conditionalItems) {
        for (StringObjectMO *aManagedInstall in conditional.managedInstalls) {
            NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"munki_name != %@", aManagedInstall.title];
            [tempPredicates addObject:newPredicate];
        }
    }
    
    NSPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates:tempPredicates];
    [self.addItemsWindowController setHideAddedPredicate:compPred];
    [self.addItemsWindowController updateGroupedSearchPredicate];
    [self.addItemsWindowController updateIndividualSearchPredicate];
}

- (IBAction)removeItemsAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
        
    for (StringObjectMO *aManagedInstall in [self.managedInstallsArrayController selectedObjects]) {
        [self.manifestToEdit.managedObjectContext deleteObject:aManagedInstall];
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
    
    MAManifestEditorSection *generalSection = [MAManifestEditorSection new];
    generalSection.title = @"General";
    generalSection.tag = MAEditorSectionTagGeneral;
    generalSection.icon = [NSImage imageNamed:NSImageNamePreferencesGeneral];
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
    NSURL *installerURL = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.apple.Installer"];
    managedInstallsSection.icon = [[NSWorkspace sharedWorkspace] iconForFile:[installerURL path]];
    [managedInstallsSection bind:@"subtitle" toObject:self withKeyPath:@"manifestToEdit.managedInstallsCountDescription" options:bindOptions];
    managedInstallsSection.view = self.contentItemsListView;
    [newSourceListItems addObject:managedInstallsSection];
    
    
    MAManifestEditorSection *managedUninstallsSection = [MAManifestEditorSection new];
    managedUninstallsSection.title = @"Managed Uninstalls";
    managedUninstallsSection.tag = MAEditorSectionTagManagedUninstalls;
    managedUninstallsSection.icon = [NSImage imageNamed:NSImageNamePreferencesGeneral];
    [managedUninstallsSection bind:@"subtitle" toObject:self withKeyPath:@"manifestToEdit.managedUninstallsCountDescription" options:bindOptions];
    managedUninstallsSection.view = self.contentItemsListView;
    [newSourceListItems addObject:managedUninstallsSection];
    
    MAManifestEditorSection *managedUpdatesSection = [MAManifestEditorSection new];
    managedUpdatesSection.title = @"Managed Updates";
    managedUpdatesSection.tag = MAEditorSectionTagManagedUpdates;
    NSURL *suURL = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.apple.SoftwareUpdate"];
    managedUpdatesSection.icon = [[NSWorkspace sharedWorkspace] iconForFile:[suURL path]];
    [managedUpdatesSection bind:@"subtitle" toObject:self withKeyPath:@"manifestToEdit.managedUpdatesCountDescription" options:bindOptions];
    managedUpdatesSection.view = self.contentItemsListView;
    [newSourceListItems addObject:managedUpdatesSection];
    
    MAManifestEditorSection *optionalInstallsSection = [MAManifestEditorSection new];
    optionalInstallsSection.title = @"Optional Installs";
    optionalInstallsSection.tag = MAEditorSectionTagOptionalInstalls;
    optionalInstallsSection.icon = [[NSWorkspace sharedWorkspace] iconForFileType:@"app"];
    [optionalInstallsSection bind:@"subtitle" toObject:self withKeyPath:@"manifestToEdit.optionalInstallsCountDescription" options:bindOptions];
    optionalInstallsSection.view = self.contentItemsListView;
    [newSourceListItems addObject:optionalInstallsSection];
    
    MAManifestEditorSection *includedManifestsSection = [MAManifestEditorSection new];
    includedManifestsSection.title = @"Included Manifests";
    includedManifestsSection.tag = MAEditorSectionTagIncludedManifests;
    includedManifestsSection.icon = [NSImage imageNamed:NSImageNameFolderSmart];
    [includedManifestsSection bind:@"subtitle" toObject:self withKeyPath:@"manifestToEdit.includedManifestsCountDescription" options:bindOptions];
    [newSourceListItems addObject:includedManifestsSection];
    
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
            }
            
        }
    }
    return view;
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
