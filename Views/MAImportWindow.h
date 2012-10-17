//
//  MAImportWindow.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 16.10.2012.
//
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>
#import "MALinkedView.h"

@interface MAImportWindow : NSWindowController {
    IBOutlet MALinkedView *currentView;
    
    CATransition *transition;
}

@property (retain) MALinkedView *currentView;

- (IBAction)nextView:(id)sender;
- (IBAction)previousView:(id)sender;

@end
