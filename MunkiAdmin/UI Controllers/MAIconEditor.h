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

// Image browser window
@property (strong) NSSet *imageBrowserItems;
@property (weak) IBOutlet NSArrayController *imageBrowserItemsArrayController;
@property (weak) IBOutlet NSWindow *imageBrowserWindow;
// IKImageBrowserView is deprecated in favor of NSCollectionView (macOS 10.14+).
// Suppressed for now; migrating this is a separate follow-up task.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (weak) IBOutlet IKImageBrowserView *imageBrowserView;
#pragma clang diagnostic pop

// Progress window
@property (weak) IBOutlet NSWindow *progressWindow;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTextField *progressDescription;

- (void)chooseSourceImage;

@end
