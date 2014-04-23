//
//  MACreateNewCategoryController.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 22.4.2014.
//
//

#import <Cocoa/Cocoa.h>

@interface MARequestStringValueController : NSWindowController

@property (strong) NSString *stringValue;
@property (strong) NSString *labelText;
@property (strong) NSString *windowTitle;
@property (strong) NSString *descriptionText;
@property (strong) NSString *okButtonTitle;
@property (strong) NSString *cancelButtonTitle;

- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
