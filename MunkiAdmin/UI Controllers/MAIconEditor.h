//
//  IconEditor.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 29.4.2014.
//
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "DataModelHeaders.h"


@interface MAIconEditor : NSWindowController

// Main window
@property (weak) IBOutlet NSImageView *imageView;
@property (strong) NSArray *packagesToEdit;
@property (strong) NSImage *currentImage;
@property (nonatomic, strong) NSString *windowTitle;
@property BOOL resizeOnSave;
@property BOOL useInSiblingPackages;
@property BOOL calculateHash;

// Image browser window
@property (strong) NSSet *imageBrowserItems;
@property (weak) IBOutlet NSArrayController *imageBrowserItemsArrayController;
@property (weak) IBOutlet NSWindow *imageBrowserWindow;
@property (weak) IBOutlet IKImageBrowserView *imageBrowserView;

// Progress window
@property (weak) IBOutlet NSWindow *progressWindow;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTextField *progressDescription;

- (void)chooseSourceImage;

@end
