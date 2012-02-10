//
//  PredicateEditor.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 9.2.2012.
//

#import <Cocoa/Cocoa.h>

@class ConditionalItemMO;

@interface PredicateEditor : NSWindowController {
    NSPredicate *predicate;
    NSPredicateEditor *predicateEditor;
    
    ConditionalItemMO *conditionToEdit;
}

@property (assign) ConditionalItemMO *conditionToEdit;
@property (assign) IBOutlet NSPredicateEditor *predicateEditor;
@property (retain) NSPredicate *predicate;

- (IBAction)saveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (void)resetPredicateToDefault;

@end
