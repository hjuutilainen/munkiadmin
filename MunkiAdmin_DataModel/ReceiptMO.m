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
	NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithCapacity:5];
	
	if (self.munki_filename != nil) [tmpDict setObject:self.munki_filename forKey:@"filename"];
    if (self.munki_name != nil) [tmpDict setObject:self.munki_name forKey:@"name"];
	if (self.munki_packageid != nil) [tmpDict setObject:self.munki_packageid forKey:@"packageid"];
	if (self.munki_version != nil) [tmpDict setObject:self.munki_version forKey:@"version"];
	if (self.munki_installed_size != nil) [tmpDict setObject:self.munki_installed_size forKey:@"installed_size"];
	
	NSDictionary *returnDict = [NSDictionary dictionaryWithDictionary:tmpDict];
	return returnDict;
}

@end
