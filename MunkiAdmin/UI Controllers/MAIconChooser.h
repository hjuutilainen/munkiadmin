//
//  MAIconChooser.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 10.5.2014.
//
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "DataModelHeaders.h"

@interface MAIconChooser : NSWindowController

// IKImageBrowserView is deprecated in favor of NSCollectionView (macOS 10.14+).
// Suppressed for now; migrating this is a separate follow-up task.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (weak) IBOutlet IKImageBrowserView *imageBrowserView;
#pragma clang diagnostic pop
@property (weak) IBOutlet NSArrayController *imagesArrayController;
@property (strong) NSArray *packagesToEdit;
@property double imageBrowserViewZoom;
@property BOOL useInSiblingPackages;
@property (nonatomic, strong) NSString *windowTitle;

- (IBAction)chooseAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
