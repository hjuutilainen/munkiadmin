#import "ItemToCopyMO.h"

@implementation ItemToCopyMO

- (NSDictionary *)dictValue
{
	NSString *title, *subtitle;
	
	BOOL hasSourceItem, hasPath, hasUser, hasGroup, hasMode;
	hasSourceItem = (self.munki_source_item != nil) ? TRUE : FALSE;
	NSString *sourceItem = (hasSourceItem) ? self.munki_source_item : @"--";
	hasPath = (self.munki_destination_path != nil) ? TRUE : FALSE;
	NSString *path = (hasPath) ? self.munki_destination_path : @"--";
	hasUser = (self.munki_user != nil) ? TRUE : FALSE;
	NSString *user = (hasUser) ? self.munki_user : @"--";
	hasGroup = (self.munki_group != nil) ? TRUE : FALSE;
	NSString *group = (hasGroup) ? self.munki_group : @"--";
	hasMode = (self.munki_mode != nil) ? TRUE : FALSE;
	NSString *mode = (hasMode) ? self.munki_mode : @"--";
	
	title = [NSString stringWithFormat:@"%@", sourceItem];
	subtitle = [NSString stringWithFormat:@"%@, %@:%@, %@", path, user, group, mode];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			title, @"title",
			subtitle, @"subtitle",
			@"itemtocopy", @"type",
			nil];
}

- (NSDictionary *)dictValueForSave
{
	NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithCapacity:5];
	
	if (self.munki_destination_path != nil) [tmpDict setObject:self.munki_destination_path forKey:@"destination_path"];
	if (self.munki_group != nil) [tmpDict setObject:self.munki_group forKey:@"group"];
	if (self.munki_mode != nil) [tmpDict setObject:self.munki_mode forKey:@"mode"];
	if (self.munki_source_item != nil) [tmpDict setObject:self.munki_source_item forKey:@"source_item"];
	if (self.munki_user != nil) [tmpDict setObject:self.munki_user forKey:@"user"];
	
	NSDictionary *returnDict = [NSDictionary dictionaryWithDictionary:tmpDict];
	return returnDict;
}


@end
