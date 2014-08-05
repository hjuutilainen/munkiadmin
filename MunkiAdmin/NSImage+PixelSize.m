//
//  NSImage+PixelSize.m
//  MunkiAdmin
//
//  From Stack Overflow by @foundry:
//  http://stackoverflow.com/a/13978985
//
//

#import "NSImage+PixelSize.h"

@implementation NSImage (PixelSize)

- (NSInteger)pixelsWide
{
    /*
     returns the pixel width of NSImage.
     Selects the largest bitmapRep by preference
     If there is no bitmapRep returns largest size reported by any imageRep.
     */
    NSInteger result = 0;
    NSInteger bitmapResult = 0;
    
    for (NSImageRep *imageRep in [self representations]) {
        if ([imageRep isKindOfClass:[NSBitmapImageRep class]]) {
            if (imageRep.pixelsWide > bitmapResult)
                bitmapResult = imageRep.pixelsWide;
        } else {
            if (imageRep.pixelsWide > result)
                result = imageRep.pixelsWide;
        }
    }
    if (bitmapResult) result = bitmapResult;
    return result;
    
}

- (NSInteger)pixelsHigh
{
    /*
     returns the pixel height of NSImage.
     Selects the largest bitmapRep by preference
     If there is no bitmapRep returns largest size reported by any imageRep.
     */
    NSInteger result = 0;
    NSInteger bitmapResult = 0;
    
    for (NSImageRep *imageRep in [self representations]) {
        if ([imageRep isKindOfClass:[NSBitmapImageRep class]]) {
            if (imageRep.pixelsHigh > bitmapResult)
                bitmapResult = imageRep.pixelsHigh;
        } else {
            if (imageRep.pixelsHigh > result)
                result = imageRep.pixelsHigh;
        }
    }
    if (bitmapResult) result = bitmapResult;
    return result;
}

- (NSSize)pixelSize
{
    return NSMakeSize(self.pixelsWide, self.pixelsHigh);
}

@end
