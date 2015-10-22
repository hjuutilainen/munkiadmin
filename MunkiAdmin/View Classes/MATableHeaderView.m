//
//  MATableHeaderView.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 22.10.2015.
//
//

#import "MATableHeaderView.h"

@implementation MATableHeaderView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

- (NSRect)frame
{
    /*
     Override table view header height on OS X 10.10 and earlier
     Based on http://stackoverflow.com/questions/32712561/backward-compatibility-of-header-hight-of-nstableview-with-os-x-10-11
     */
    NSRect fixedFrame = [super frame];
    if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_10_Max) {
        /* on a 10.10.x system */
        fixedFrame.size.height = 17;
    } else {
        /* 10.11 or later system */
    }
    return fixedFrame;
}


@end
