//
//  MAIconBatchExtractor.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 4.2.2015.
//
//

#import <Cocoa/Cocoa.h>
#import "DataModelHeaders.h"

@interface MAIconBatchExtractor : NSWindowController

@property (weak) IBOutlet NSArrayController *batchItemsController;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSButton *extractOKButton;
@property (weak) IBOutlet NSButton *cancelButton;

@property (strong) NSArray *batchItems;
@property (strong) NSMutableArray *remainingBatchItems;
@property (nonatomic, strong) NSString *windowTitle;
@property BOOL resizeOnSave;
@property BOOL overwriteExisting;
@property BOOL extractOperationsRunning;
@property BOOL cancelAllPending;
@property NSUInteger numExtractOperationsRunning;

- (void)resetExtractorStatus;

@end
