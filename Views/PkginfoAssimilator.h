//
//  PkginfoAssimilator.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 3.12.2012.
//
//

#import <Cocoa/Cocoa.h>
#import "PackageMO.h"
#import "StringObjectMO.h"

@interface PkginfoAssimilator : NSWindowController {
    
    NSUndoManager *undoManager;
    PackageMO *sourcePkginfo;
    PackageMO *targetPkginfo;
    NSModalSession modalSession;
    id delegate;
    NSArray *defaultsKeysToLoop;
    NSDictionary *keyGroups;
}

- (NSModalSession)beginEditSessionWithObject:(PackageMO *)targetPackage
                                      source:(PackageMO *)sourcePackage
                                    delegate:(id)modalDelegate;

- (IBAction)saveAction:(id)sender;
- (IBAction)enableAllAction:(id)sender;
- (IBAction)disableAllAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (void)commitChangesToCurrentPackage;

@property (assign) IBOutlet NSButton *cancelButton;
@property (assign) IBOutlet NSButton *okButton;
@property (assign) IBOutlet NSArrayController *allPackagesArrayController;

@property (retain) id delegate;
@property (assign) PackageMO *sourcePkginfo;
@property (assign) PackageMO *targetPkginfo;
@property NSModalSession modalSession;


@end
