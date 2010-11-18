#import "StringObjectMO.h"

@implementation StringObjectMO

@dynamic dictValue;

- (NSDictionary *)dictValue
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.title, @"title",
			nil, @"subtitle",
			self.typeString, @"type",
			nil];
}


@end
