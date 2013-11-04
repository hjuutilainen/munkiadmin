//
//  PackageArrayController.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 11.1.2010.
//

#import <Cocoa/Cocoa.h>

@interface PackageArrayController : NSArrayController {
	
	NSNumber *checkedDisplayName;
	NSNumber *checkedLocation;
	NSNumber *checkedDescription;
	NSNumber *checkedVersion;
	NSNumber *checkedName;
	NSNumber *checkedInstallerType;
	NSNumber *checkedUninstallMethod;
	NSNumber *checkedAll;
	
	NSString *prefixString;
	NSString *suffixString;
	NSString *searchString;
	NSString *replaceString;
	
	NSView *addPrefixSuffixCustomView;
	NSTextField *prefixTextField;
	NSWindow *addPrefixSuffixWindow;
}

@property (nonatomic, strong) IBOutlet NSView *addPrefixSuffixCustomView;
@property (nonatomic, strong) IBOutlet NSTextField *prefixTextField;
@property (nonatomic, strong) IBOutlet NSWindow *addPrefixSuffixWindow;

@property (strong) NSString *prefixString;
@property (strong) NSString *suffixString;
@property (strong) NSString *searchString;
@property (strong) NSString *replaceString;
@property (strong) NSNumber *checkedDisplayName;
@property (strong) NSNumber *checkedLocation;
@property (strong) NSNumber *checkedDescription;
@property (strong) NSNumber *checkedVersion;
@property (strong) NSNumber *checkedName;
@property (strong) NSNumber *checkedInstallerType;
@property (strong) NSNumber *checkedUninstallMethod;
@property (strong) NSNumber *checkedAll;

- (IBAction)showModifyWindow:sender;
- (IBAction)closeModifyWindow:sender;
- (IBAction)addPrefiXSuffixAction:sender;

@end
