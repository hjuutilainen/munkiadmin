//
//  IconEditor.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 29.4.2014.
//
//

#import <Cocoa/Cocoa.h>
#import "DataModelHeaders.h"


@interface MAIconEditor : NSWindowController

@property (weak) IBOutlet NSImageView *imageView;
@property (strong) NSArray *packagesToEdit;
@property (strong) NSImage *currentImage;
@property (nonatomic, strong) NSString *windowTitle;
@property BOOL resizeOnSave;
@property BOOL useInSiblingPackages;

- (void)chooseSourceImage;

@end
