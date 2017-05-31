//
//  MAMunkiImportController.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 8.5.2017.
//
//

#import <Cocoa/Cocoa.h>
#import "MASolidBackgroundView.h"

@interface MAMunkiImportController : NSWindowController

@property (weak) IBOutlet NSButton *continueButton;
@property (weak) IBOutlet NSButton *cancelButton;
@property (weak) IBOutlet NSButton *goBackButton;
@property (weak) IBOutlet MASolidBackgroundView *placeHolderView;
@property (weak) IBOutlet NSView *startView;
@property (weak) IBOutlet NSView *progressView;
@property (weak) IBOutlet NSView *defaultOptionsView;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTextField *progressDescription;
@property (weak) IBOutlet NSView *scriptsView;
@property (weak) IBOutlet NSImageView *startViewImageView;

@property (strong) NSArray *viewArray;
@property (assign) NSView *currentView;

/*
 Arguments to munkiimport
 */
@property (strong) NSURL *itemToImport;
@property (strong) NSString *subdirectory;
@property (strong) NSArray *subdirectorySuggestions;
@property (strong) NSString *name;
@property (strong) NSArray *nameSuggestions;
@property (strong) NSString *displayName;
@property (strong) NSArray *displayNameSuggestions;
@property (strong) NSString *version;
@property (strong) NSString *restartAction;
@property (strong) NSArray *restartActionSuggestions;
@property (strong) NSString *uninstallMethod;
@property (strong) NSString *developer;
@property (strong) NSString *category;
@property (strong) NSNumber *installerItemSize;
@property (strong) NSNumber *installedSize;

@property (strong) NSString *installcheckScript;
@property (strong) NSString *uninstallcheckScript;
@property (strong) NSString *preinstallScript;
@property (strong) NSString *postinstallScript;
@property (strong) NSString *preuninstallScript;
@property (strong) NSString *postuninstallScript;
@property (strong) NSString *uninstallScript;

@property (strong) NSMutableArray *catalogs;

@property BOOL autoremove;
@property BOOL uninstallable;
@property BOOL unattendedInstall;
@property BOOL unattendedUninstall;
@property BOOL onDemand;
@property BOOL nopkg;

- (IBAction)continueAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)goBackAction:(id)sender;
- (void)resetStatus;


@end
