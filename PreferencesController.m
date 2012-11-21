//
//  PreferencesController.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 1.6.2010.
//  Copyright 2010. All rights reserved.
//

#import "PreferencesController.h"


@implementation PreferencesController

- (void)awakeFromNib
{
    items = [[NSMutableDictionary alloc] init];
    
	NSToolbarItem *generalItem;
    generalItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"General"];
    [generalItem setPaletteLabel:@"General"];
    [generalItem setLabel:@"General"];
    [generalItem setToolTip:@"General preference options."];
    [generalItem setImage:[NSImage imageNamed:@"NSPreferencesGeneral"]];
    [generalItem setTarget:self];
    [generalItem setAction:@selector(switchViews:)];
    [items setObject:generalItem forKey:@"General"];
    [generalItem release];
	
	
	NSToolbarItem *munkiItem;
	munkiItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"Munki"];
    [munkiItem setPaletteLabel:@"Munki"];
    [munkiItem setLabel:@"Munki"];
    [munkiItem setToolTip:@"Munki preference options."];
    [munkiItem setImage:[NSImage imageNamed:@"NSColorPanel"]];
    [munkiItem setTarget:self];
    [munkiItem setAction:@selector(switchViews:)];
    [items setObject:munkiItem forKey:@"Munki"];
    [munkiItem release];
    
    
    NSToolbarItem *importOptionsItem;
	importOptionsItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"Import Options"];
    [importOptionsItem setPaletteLabel:@"Import Options"];
    [importOptionsItem setLabel:@"Import Options"];
    [importOptionsItem setToolTip:@"Import Options"];
    [importOptionsItem setImage:[NSImage imageNamed:@"NSAdvanced"]];
    [importOptionsItem setTarget:self];
    [importOptionsItem setAction:@selector(switchViews:)];
    [items setObject:importOptionsItem forKey:@"Import Options"];
    [importOptionsItem release];
    
    
    NSToolbarItem *advancedItem;
	advancedItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"Advanced"];
    [advancedItem setPaletteLabel:@"Advanced"];
    [advancedItem setLabel:@"Advanced"];
    [advancedItem setToolTip:@"Advanced options."];
    [advancedItem setImage:[NSImage imageNamed:@"NSAdvanced"]];
    [advancedItem setTarget:self];
    [advancedItem setAction:@selector(switchViews:)];
    [items setObject:advancedItem forKey:@"Advanced"];
    [advancedItem release];
	
    //any other items you want to add, do so here.
    //after you are done, just do all the toolbar stuff.
    //myWindow is an outlet pointing to the Preferences Window you made to hold all these custom views.
	
    toolbar = [[[NSToolbar alloc] initWithIdentifier:@"preferencePanes"] autorelease];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setAutosavesConfiguration:NO];
    [myWindow setToolbar:toolbar];
	[myWindow setShowsResizeIndicator:NO];
	[myWindow setShowsToolbarButton:NO];
    [myWindow center];
	[myWindow makeKeyAndOrderFront:self];
    [self switchViews:nil];
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
    [myWindow setTitle:sender];
	
    if ([sender isEqualToString:@"General"]) {
        prefsView = generalView;
    } else if ([sender isEqualToString:@"Munki"]) {
        prefsView = munkiView;
    } else if ([sender isEqualToString:@"Import Options"]) {
        prefsView = importOptionsView;
    } else if ([sender isEqualToString:@"Advanced"]) {
        prefsView = advancedView;
    } else {
        prefsView = munkiView;
    }
	
    NSView *tempView = [[NSView alloc] initWithFrame:[[myWindow contentView] frame]];
    [myWindow setContentView:tempView];
    [tempView release];
    
    NSRect newFrame = [myWindow frame];
    newFrame.size.height = [prefsView frame].size.height + ([myWindow frame].size.height - [[myWindow contentView] frame].size.height);
    newFrame.size.width = [prefsView frame].size.width;
    newFrame.origin.y += ([[myWindow contentView] frame].size.height - [prefsView frame].size.height);
    
    [myWindow setShowsResizeIndicator:YES];
    [myWindow setFrame:newFrame display:YES animate:YES];
    [myWindow setContentView:prefsView];
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
    return [NSArray arrayWithObjects:@"General", @"Munki", @"Import Options", @"Advanced", nil];
}

- (NSArray *)toolbarSelectableItemIdentifiers: (NSToolbar *)toolbar
{
    return [items allKeys];
}

@end
