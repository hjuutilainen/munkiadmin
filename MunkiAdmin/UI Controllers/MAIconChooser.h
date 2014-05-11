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

@property (weak) IBOutlet IKImageBrowserView *imageBrowserView;
@property (weak) IBOutlet NSArrayController *imagesArrayController;
@property (strong) NSArray *packagesToEdit;
@property double imageBrowserViewZoom;
@property BOOL useInSiblingPackages;
@property (nonatomic, strong) NSString *windowTitle;

- (IBAction)chooseAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
