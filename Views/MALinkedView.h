//
//  MALinkedView.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 16.10.2012.
//
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>

@interface MALinkedView : NSView {
    IBOutlet MALinkedView *previousView;
    IBOutlet MALinkedView *nextView;
    
    IBOutlet NSButton *nextButton;
    IBOutlet NSButton *previousButton;
}

@property (retain) MALinkedView *previousView, *nextView;

@end
