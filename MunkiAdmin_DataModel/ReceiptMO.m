#import "ReceiptMO.h"

@implementation ReceiptMO

- (NSDictionary *)dictValue
{
	NSString *title, *subtitle;
	
	BOOL hasFilename, hasPackageID, hasVersion;
	hasFilename = (self.munki_filename != nil) ? TRUE : FALSE;
	NSString *filename = (hasFilename) ? self.munki_filename : @"--";
	hasPackageID = (self.munki_packageid != nil) ? TRUE : FALSE;
	NSString *packageID = (hasPackageID) ? self.munki_packageid : @"--";
	hasVersion = (self.munki_version != nil) ? TRUE : FALSE;
	NSString *version = (hasVersion) ? self.munki_version : @"--";
	
	title = [NSString stringWithFormat:@"%@", packageID];
	subtitle = [NSString stringWithFormat:@"%@, %@", version, filename];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			title, @"title",
			subtitle, @"subtitle",
			@"receipt", @"type",
			nil];
}

- (NSDictionary *)dictValueForSave
{
	NSDictionary *returnDict = [NSDictionary dictionaryWithObjectsAndKeys:
								self.munki_filename, @"filename",
								self.munki_installed_size, @"installed_size",
								self.munki_packageid, @"packageid",
								self.munki_version, @"version",
								nil];
	return returnDict;
}

@end
