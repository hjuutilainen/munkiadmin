//
//  PreferencesController.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 1.6.2010.
//  Copyright 2010. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PreferencesController : NSWindowController <NSToolbarDelegate> {
	
	NSMutableDictionary *items;
	NSToolbar *toolbar;
	
	IBOutlet NSWindow *myWindow;
	IBOutlet NSView *generalView;
	IBOutlet NSView *munkiView;
    IBOutlet NSView *advancedView;
    IBOutlet NSView *importOptionsView;

}

- (void)switchViews:(NSToolbarItem *)item;

@end
