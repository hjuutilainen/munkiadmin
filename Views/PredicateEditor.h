//
//  PredicateEditor.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 9.2.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PredicateEditor : NSWindowController {
    NSPredicate *predicate;
    NSPredicateEditor *predEditor;
}
@property (assign) IBOutlet NSPredicateEditor *predEditor;
@property (retain) NSPredicate *predicate;

- (IBAction)saveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
