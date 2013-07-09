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

@property (nonatomic, retain) IBOutlet NSView *addPrefixSuffixCustomView;
@property (nonatomic, retain) IBOutlet NSTextField *prefixTextField;
@property (nonatomic, retain) IBOutlet NSWindow *addPrefixSuffixWindow;

@property (retain) NSString *prefixString;
@property (retain) NSString *suffixString;
@property (retain) NSString *searchString;
@property (retain) NSString *replaceString;
@property (retain) NSNumber *checkedDisplayName;
@property (retain) NSNumber *checkedLocation;
@property (retain) NSNumber *checkedDescription;
@property (retain) NSNumber *checkedVersion;
@property (retain) NSNumber *checkedName;
@property (retain) NSNumber *checkedInstallerType;
@property (retain) NSNumber *checkedUninstallMethod;
@property (retain) NSNumber *checkedAll;

- (IBAction)showModifyWindow:sender;
- (IBAction)closeModifyWindow:sender;
- (IBAction)addPrefiXSuffixAction:sender;

@end
