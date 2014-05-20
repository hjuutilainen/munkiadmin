//
//  PreferencesController.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 1.6.2010.
//  Copyright 2010. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MAPreferences : NSWindowController <NSToolbarDelegate> {
	
	NSMutableDictionary *items;
	NSToolbar *toolbar;

}

@property (weak) IBOutlet NSWindow *preferencesWindow;
@property (weak) IBOutlet NSView *generalView;
@property (weak) IBOutlet NSView *munkiView;
@property (weak) IBOutlet NSView *advancedView;
@property (weak) IBOutlet NSView *importOptionsView;
@property (weak) IBOutlet NSView *appearanceView;

- (void)switchViews:(NSToolbarItem *)item;

@end
