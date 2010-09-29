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
	NSMutableDictionary *returnDict = [NSMutableDictionary dictionaryWithCapacity:6];
	if (self.munki_CFBundleIdentifier != nil) [returnDict setObject:self.munki_CFBundleIdentifier forKey:@"CFBundleIdentifier"];
	if (self.munki_CFBundleName != nil) [returnDict setObject:self.munki_CFBundleName forKey:@"CFBundleName"];
	if (self.munki_CFBundleShortVersionString != nil) [returnDict setObject:self.munki_CFBundleShortVersionString forKey:@"CFBundleShortVersionString"];
	if (self.munki_path != nil) [returnDict setObject:self.munki_path forKey:@"path"];
	if (self.munki_type != nil) [returnDict setObject:self.munki_type forKey:@"type"];
	if (self.munki_md5checksum != nil) [returnDict setObject:self.munki_md5checksum forKey:@"md5checksum"];
	
	return returnDict;
}

@end
