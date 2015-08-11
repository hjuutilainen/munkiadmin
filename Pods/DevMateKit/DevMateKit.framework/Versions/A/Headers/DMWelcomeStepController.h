//
//  DMWelcomeStepController.h
//  DevMateActivations
//
//  Copyright (c) 2012-2015 DevMate Inc. All rights reserved.
//

#import <DevMateKit/DMStepController.h>

@interface DMWelcomeStepController : DMStepController

@property (nonatomic, assign) IBOutlet NSTextField *welcomeDescriptionField;
@property (nonatomic, assign) IBOutlet NSButton *continueButton;
@property (nonatomic, assign) IBOutlet NSButton *cancelButton;
@property (nonatomic, assign) IBOutlet NSButton *getLicenseButton;
@property (nonatomic, assign) IBOutlet NSButton *webStoreButton;

- (IBAction)continueActivation:(id)sender;
- (IBAction)cancelActivation:(id)sender;

//! By default action will open http://hello.devmate.com/gostore/... webpage
- (IBAction)openWebStore:(id)sender;

//! Will open embedded FastSpring store if delegate implements necessary methods or just call -openWebStore: method
- (IBAction)getLicense:(id)sender;

@end
