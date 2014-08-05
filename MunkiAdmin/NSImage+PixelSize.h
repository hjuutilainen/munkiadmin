//
//  NSImage+PixelSize.h
//  MunkiAdmin
//
//  From Stack Overflow by @foundry:
//  http://stackoverflow.com/a/13978985
//
//

#import <Cocoa/Cocoa.h>

@interface NSImage (PixelSize)

- (NSInteger)pixelsWide;
- (NSInteger)pixelsHigh;
- (NSSize)pixelSize;

@end
