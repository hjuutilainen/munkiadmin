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
    NSTabView *tabView;
    NSTextField *customTextField;
    NSTabViewItem *predicateEditorTabViewItem;
    NSTabViewItem *customTabViewItem;
    NSPredicateEditor *predicateEditor;
    
    ConditionalItemMO *conditionToEdit;
    NSString *customPredicateString;
}
@property (retain) NSString *customPredicateString;
@property (assign) ConditionalItemMO *conditionToEdit;
@property (assign) IBOutlet NSPredicateEditor *predicateEditor;
@property (retain) NSPredicate *predicate;
@property (assign) IBOutlet NSTabView *tabView;
@property (assign) IBOutlet NSTextField *customTextField;
@property (assign) IBOutlet NSTabViewItem *predicateEditorTabViewItem;
@property (assign) IBOutlet NSTabViewItem *customTabViewItem;

- (IBAction)saveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (void)resetPredicateToDefault;

@end
