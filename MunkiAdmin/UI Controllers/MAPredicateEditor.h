//
//  PredicateEditor.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 9.2.2012.
//

#import <Cocoa/Cocoa.h>

@class ConditionalItemMO;

@interface MAPredicateEditor : NSWindowController {
    
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
