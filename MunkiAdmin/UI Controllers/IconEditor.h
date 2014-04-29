//
//  IconEditor.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 29.4.2014.
//
//

#import <Cocoa/Cocoa.h>
#import "DataModelHeaders.h"


@interface IconEditor : NSWindowController

@property (weak) IBOutlet NSImageView *imageView;
@property (weak) PackageMO *packageToEdit;
@property (strong) NSImage *currentImage;
@property BOOL resizeOnSave;
@property BOOL useInSiblingPackages;

@end
