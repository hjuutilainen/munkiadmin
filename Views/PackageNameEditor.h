//
//  PackageNameEditor.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 28.10.2011.
//

#import <Cocoa/Cocoa.h>

@interface PackageNameEditor : NSWindowController {
    BOOL shouldRenameAll;
    NSString *changedName;
    NSArrayController *changeDescriptionsArrayController;
}

@property BOOL shouldRenameAll;
@property (retain) NSString *changedName;
@property (retain) NSArray *changeDescriptions;
@property (assign) IBOutlet NSArrayController *changeDescriptionsArrayController;

@end
