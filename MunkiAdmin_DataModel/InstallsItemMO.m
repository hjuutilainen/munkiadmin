#import "InstallsItemMO.h"

@implementation InstallsItemMO

- (NSDictionary *)dictValue
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.munki_path, @"title",
			self.munki_type, @"subtitle",
			@"installsitem", @"type",
			nil];
}

- (NSDictionary *)dictValueForSave
{
	NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithCapacity:7];
	if (self.munki_CFBundleIdentifier != nil) [tmpDict setObject:self.munki_CFBundleIdentifier forKey:@"CFBundleIdentifier"];
	if (self.munki_CFBundleName != nil) [tmpDict setObject:self.munki_CFBundleName forKey:@"CFBundleName"];
	if (self.munki_CFBundleShortVersionString != nil) [tmpDict setObject:self.munki_CFBundleShortVersionString forKey:@"CFBundleShortVersionString"];
	if (self.munki_path != nil) [tmpDict setObject:self.munki_path forKey:@"path"];
	if (self.munki_type != nil) [tmpDict setObject:self.munki_type forKey:@"type"];
	if (self.munki_md5checksum != nil) [tmpDict setObject:self.munki_md5checksum forKey:@"md5checksum"];
    if (self.munki_minosversion != nil) [tmpDict setObject:self.munki_minosversion forKey:@"minosversion"];
	
	NSDictionary *returnDict = [NSDictionary dictionaryWithDictionary:tmpDict];
	return returnDict;
}

@end
