//
//  PackageArrayController.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 11.1.2010.
//

#import "PackageArrayController.h"
#import "PackageMO.h"


@implementation PackageArrayController

@synthesize suffixString, prefixString;
@synthesize searchString, replaceString;
@synthesize checkedDisplayName;
@synthesize checkedLocation;
@synthesize checkedDescription;
@synthesize checkedVersion;
@synthesize checkedName;
@synthesize checkedInstallerType;
@synthesize checkedUninstallMethod;
@synthesize addPrefixSuffixCustomView;
@synthesize addPrefixSuffixWindow;
@synthesize prefixTextField;
@dynamic checkedAll;

- (NSNumber *)checkedAll
{
	return checkedAll;
}

- (void)setCheckedAll:(NSNumber *)newValue {
    if (newValue != checkedAll) {
		self.checkedDisplayName = newValue;
		self.checkedLocation = newValue;
		self.checkedDescription = newValue;
		self.checkedVersion = newValue;
		self.checkedName = newValue;
		self.checkedInstallerType = newValue;
		self.checkedUninstallMethod = newValue;
        checkedAll = newValue;
    }
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NSSortDescriptor *sortByTitle = [[[NSSortDescriptor alloc] initWithKey:@"munki_name" ascending:YES selector:@selector(localizedStandardCompare:)] autorelease];
	NSSortDescriptor *sortByVersion = [[[NSSortDescriptor alloc] initWithKey:@"munki_version" ascending:YES selector:@selector(localizedStandardCompare:)] autorelease];
	[self setSortDescriptors:[NSArray arrayWithObjects:sortByTitle, sortByVersion, nil]];
}

- (IBAction)showModifyWindow:sender
{
	[self.addPrefixSuffixWindow makeKeyAndOrderFront:self];
	[self.addPrefixSuffixWindow center];
}

- (IBAction)closeModifyWindow:sender
{
	//[NSApp stopModalWithCode:[sender tag]];
}

- (IBAction)addPrefiXSuffixAction:sender
{
	
	NSString *prefix, *suffix;
	prefix = (nil != self.prefixString) ? self.prefixString : @"";
	suffix = (nil != self.suffixString) ? self.suffixString : @"";
	
	BOOL shouldPrefix = NO;
	if (![prefix isEqualToString:@""] ||
		![suffix isEqualToString:@""])
	{
		shouldPrefix = YES;
	}
	
	NSString *search, *replace;
	search = (nil != self.searchString) ? self.searchString : @"";
	replace = (nil != self.replaceString) ? self.replaceString : @"";
	
	BOOL shouldSearch = NO;
	if (![search isEqualToString:@""] &&
		![replace isEqualToString:@""])
	{
		shouldSearch = YES;
	}
	
	for (PackageMO *aPackage in [self selectedObjects]) {

		if ([self.checkedDisplayName boolValue]) {
			NSString *curDisplayName = aPackage.munki_display_name;
			if (shouldPrefix)
				aPackage.munki_display_name = [NSString stringWithFormat:@"%@%@%@", prefix, curDisplayName, suffix];
			if (shouldSearch)
				aPackage.munki_display_name = [curDisplayName stringByReplacingOccurrencesOfString:search withString:replace]; 
		}
		if ([self.checkedLocation boolValue]) {
			NSString *curLoc = aPackage.munki_installer_item_location;
			if (shouldPrefix)
				aPackage.munki_installer_item_location = [NSString stringWithFormat:@"%@%@%@", prefix, curLoc, suffix];
			if (shouldSearch)
				aPackage.munki_installer_item_location = [curLoc stringByReplacingOccurrencesOfString:search withString:replace]; 
		}
		if ([self.checkedDescription boolValue]) {
			NSString *curDscr = aPackage.munki_description;
			if (shouldPrefix)
				aPackage.munki_description = [NSString stringWithFormat:@"%@%@%@", prefix, curDscr, suffix];
			if (shouldSearch)
				aPackage.munki_description = [curDscr stringByReplacingOccurrencesOfString:search withString:replace];
		}
		if ([self.checkedVersion boolValue]) {
			NSString *curVersion = aPackage.munki_version;
			if (shouldPrefix)
				aPackage.munki_version = [NSString stringWithFormat:@"%@%@%@", prefix, curVersion, suffix];
			if (shouldSearch)
				aPackage.munki_version = [curVersion stringByReplacingOccurrencesOfString:search withString:replace];
		}
		if ([self.checkedName boolValue]) {
			NSString *curName = aPackage.munki_name;
			if (shouldPrefix)
				aPackage.munki_name = [NSString stringWithFormat:@"%@%@%@", prefix, curName, suffix];
			if (shouldSearch)
				aPackage.munki_name = [curName stringByReplacingOccurrencesOfString:search withString:replace];
		}
		if ([self.checkedInstallerType boolValue]) {
			NSString *curType = aPackage.munki_installer_type;
			if (shouldPrefix)
				aPackage.munki_installer_type = [NSString stringWithFormat:@"%@%@%@", prefix, curType, suffix];
			if (shouldSearch)
				aPackage.munki_installer_type = [curType stringByReplacingOccurrencesOfString:search withString:replace];
		}
		if ([self.checkedUninstallMethod boolValue]) {
			NSString *curUniMethod = aPackage.munki_uninstall_method;
			if (shouldPrefix)
				aPackage.munki_uninstall_method = [NSString stringWithFormat:@"%@%@%@", prefix, curUniMethod, suffix];
			if (shouldSearch)
				aPackage.munki_uninstall_method = [curUniMethod stringByReplacingOccurrencesOfString:search withString:replace];
		}
	}
	[self.addPrefixSuffixWindow performClose:self];
}


	
@end
