//
//  PreferencesController.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 1.6.2010.
//  Copyright 2010. All rights reserved.
//

#import "MAPreferences.h"
#import "MACoreDataManager.h"
#import "MAMunkiAdmin_AppDelegate.h"


@implementation MAPreferences

- (void)awakeFromNib
{
    items = [[NSMutableDictionary alloc] init];
    
	NSToolbarItem *generalItem;
    generalItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"General"];
    [generalItem setPaletteLabel:@"General"];
    [generalItem setLabel:@"General"];
    [generalItem setToolTip:@"General preference options."];
    [generalItem setImage:[NSImage imageNamed:NSImageNamePreferencesGeneral]];
    [generalItem setTarget:self];
    [generalItem setAction:@selector(switchViews:)];
    [items setObject:generalItem forKey:@"General"];
	
	
	NSToolbarItem *munkiItem;
	munkiItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"Munki"];
    [munkiItem setPaletteLabel:@"Munki"];
    [munkiItem setLabel:@"Munki"];
    [munkiItem setToolTip:@"Munki preference options."];
    [munkiItem setImage:[NSImage imageNamed:@"MunkiAdminIcon_32x32"]];
    [munkiItem setTarget:self];
    [munkiItem setAction:@selector(switchViews:)];
    [items setObject:munkiItem forKey:@"Munki"];
    
    
    NSToolbarItem *importOptionsItem;
	importOptionsItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"Import Options"];
    [importOptionsItem setPaletteLabel:@"Import Options"];
    [importOptionsItem setLabel:@"Import Options"];
    [importOptionsItem setToolTip:@"Import Options"];
    [importOptionsItem setImage:[NSImage imageNamed:@"packageGroupIcon_32x32"]];
    [importOptionsItem setTarget:self];
    [importOptionsItem setAction:@selector(switchViews:)];
    [items setObject:importOptionsItem forKey:@"Import Options"];
    
    
    NSToolbarItem *advancedItem;
	advancedItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"Advanced"];
    [advancedItem setPaletteLabel:@"Advanced"];
    [advancedItem setLabel:@"Advanced"];
    [advancedItem setToolTip:@"Advanced options."];
    [advancedItem setImage:[NSImage imageNamed:NSImageNameAdvanced]];
    [advancedItem setTarget:self];
    [advancedItem setAction:@selector(switchViews:)];
    [items setObject:advancedItem forKey:@"Advanced"];
    
    NSToolbarItem *appearanceItem;
	appearanceItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"Appearance"];
    [appearanceItem setPaletteLabel:@"Appearance"];
    [appearanceItem setLabel:@"Appearance"];
    [appearanceItem setToolTip:@"Appearance options."];
    [appearanceItem setImage:[NSImage imageNamed:NSImageNameColorPanel]];
    [appearanceItem setTarget:self];
    [appearanceItem setAction:@selector(switchViews:)];
    [items setObject:appearanceItem forKey:@"Appearance"];
	
    //any other items you want to add, do so here.
    //after you are done, just do all the toolbar stuff.
    //myWindow is an outlet pointing to the Preferences Window you made to hold all these custom views.
	
    toolbar = [[NSToolbar alloc] initWithIdentifier:@"preferencePanes"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setAutosavesConfiguration:NO];
    [self.preferencesWindow setToolbar:toolbar];
	[self.preferencesWindow setShowsResizeIndicator:NO];
	[self.preferencesWindow setShowsToolbarButton:NO];
    [self.preferencesWindow center];
	[self.preferencesWindow makeKeyAndOrderFront:self];
    [self switchViews:nil];
    
    /*
     Add observers for the sidebar related defaults keys.
     We need to update the sidebar when these change.
     */
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                              forKeyPath:@"values.sidebarInstallerTypesVisible"
                                                                 options:NSKeyValueObservingOptionNew
                                                                 context:NULL];
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                              forKeyPath:@"values.sidebarCategoriesVisible"
                                                                 options:NSKeyValueObservingOptionNew
                                                                 context:NULL];
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                              forKeyPath:@"values.sidebarDevelopersVisible"
                                                                 options:NSKeyValueObservingOptionNew
                                                                 context:NULL];
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                              forKeyPath:@"values.sidebarDirectoriesVisible"
                                                                 options:NSKeyValueObservingOptionNew
                                                                 context:NULL];
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                              forKeyPath:@"values.sidebarDeveloperMinimumNumberOfPackageNames"
                                                                 options:NSKeyValueObservingOptionNew
                                                                 context:NULL];
}

- (void)switchViews:(NSToolbarItem *)item
{
    NSString *sender;
    if (item == nil) {
        sender = @"General";
        [toolbar setSelectedItemIdentifier:sender];
    } else {
        sender = [item label];
    }
	
    NSView *prefsView;
    [self.preferencesWindow setTitle:sender];
	
    if ([sender isEqualToString:@"General"]) {
        prefsView = self.generalView;
    } else if ([sender isEqualToString:@"Munki"]) {
        prefsView = self.munkiView;
    } else if ([sender isEqualToString:@"Import Options"]) {
        prefsView = self.importOptionsView;
    } else if ([sender isEqualToString:@"Advanced"]) {
        prefsView = self.advancedView;
    } else if ([sender isEqualToString:@"Appearance"]) {
        prefsView = self.appearanceView;
    } else {
        prefsView = self.munkiView;
    }
	
    NSView *tempView = [[NSView alloc] initWithFrame:[[self.preferencesWindow contentView] frame]];
    [self.preferencesWindow setContentView:tempView];
    
    NSRect newFrame = [self.preferencesWindow frame];
    newFrame.size.height = [prefsView frame].size.height + ([self.preferencesWindow frame].size.height - [[self.preferencesWindow contentView] frame].size.height);
    newFrame.size.width = [prefsView frame].size.width;
    newFrame.origin.y += ([[self.preferencesWindow contentView] frame].size.height - [prefsView frame].size.height);
    
    [self.preferencesWindow setShowsResizeIndicator:YES];
    [self.preferencesWindow setFrame:newFrame display:YES animate:YES];
    [self.preferencesWindow setContentView:prefsView];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    /*
     Reconfigure the package view sidebar if related defaults change
     */
    if ([keyPath isEqualToString:@"values.sidebarInstallerTypesVisible"]) {
        [[MACoreDataManager sharedManager] configureSourceListInstallerTypesSection:[[NSApp delegate] managedObjectContext]];
    } else if ([keyPath isEqualToString:@"values.sidebarCategoriesVisible"]) {
        [[MACoreDataManager sharedManager] configureSourceListCategoriesSection:[[NSApp delegate] managedObjectContext]];
    } else if ([keyPath isEqualToString:@"values.sidebarDevelopersVisible"]) {
        [[MACoreDataManager sharedManager] configureSourceListDevelopersSection:[[NSApp delegate] managedObjectContext]];
    } else if ([keyPath isEqualToString:@"values.sidebarDeveloperMinimumNumberOfPackageNames"]) {
        [[MACoreDataManager sharedManager] configureSourceListDevelopersSection:[[NSApp delegate] managedObjectContext]];
    } else if ([keyPath isEqualToString:@"values.sidebarDirectoriesVisible"]) {
        [[MACoreDataManager sharedManager] configureSourceListDirectoriesSection:[[NSApp delegate] managedObjectContext]];
    }
    [[NSApp delegate] updateSourceList];
}

# pragma mark -
# pragma mark NSToolbar delegate methods

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    return [items objectForKey:itemIdentifier];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)theToolbar
{
    return [self toolbarDefaultItemIdentifiers:theToolbar];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)theToolbar
{
    return [NSArray arrayWithObjects:@"General", @"Appearance", @"Munki", @"Import Options", @"Advanced", nil];
}

- (NSArray *)toolbarSelectableItemIdentifiers: (NSToolbar *)toolbar
{
    return [items allKeys];
}

@end
