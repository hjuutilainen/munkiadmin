#import "InstallerChoicesItemMO.h"

@implementation InstallerChoicesItemMO

- (NSDictionary *)dictValue
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.munki_choiceIdentifier, @"title",
			self.munki_choiceAttribute, @"subtitle",
			@"choicesitem", @"type",
			nil];
}

- (NSDictionary *)dictValueForSave
{
	NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithCapacity:3];
	if (self.munki_choiceIdentifier != nil) [tmpDict setObject:self.munki_choiceIdentifier forKey:@"choiceIdentifier"];
	if (self.munki_choiceAttribute != nil) [tmpDict setObject:self.munki_choiceAttribute forKey:@"choiceAttribute"];
    if (self.munki_attributeSetting != nil) {
        [tmpDict setObject:self.munki_attributeSetting forKey:@"attributeSetting"];
    } else {
        [tmpDict setObject:@NO forKey:@"attributeSetting"];
    }
	NSDictionary *returnDict = [NSDictionary dictionaryWithDictionary:tmpDict];
	return returnDict;
}


@end
