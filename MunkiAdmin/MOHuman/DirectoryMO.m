#import "DirectoryMO.h"

@implementation DirectoryMO

- (NSDictionary *)dictValue
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.title, @"title",
			@"", @"subtitle",
			[self icon], @"icon",
			nil];
}

@end
