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
}

@property BOOL shouldRenameAll;
@property (retain) NSString *changedName;

@end
