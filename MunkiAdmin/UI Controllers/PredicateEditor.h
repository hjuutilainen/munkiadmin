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
    NSTabView *__weak tabView;
    NSTextField *__weak customTextField;
    NSTabViewItem *__weak predicateEditorTabViewItem;
    NSTabViewItem *__weak customTabViewItem;
    NSPredicateEditor *__weak predicateEditor;
    
    ConditionalItemMO *__weak conditionToEdit;
    NSString *customPredicateString;
}
@property (strong) NSString *customPredicateString;
@property (weak) ConditionalItemMO *conditionToEdit;
@property (weak) IBOutlet NSPredicateEditor *predicateEditor;
@property (strong) NSPredicate *predicate;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSTextField *customTextField;
@property (weak) IBOutlet NSTabViewItem *predicateEditorTabViewItem;
@property (weak) IBOutlet NSTabViewItem *customTabViewItem;

- (IBAction)saveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (void)resetPredicateToDefault;

@end
