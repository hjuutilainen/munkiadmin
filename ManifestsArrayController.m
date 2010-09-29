//
//  ManifestsArrayController.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 21.1.2010.
//

#import "ManifestsArrayController.h"


@implementation ManifestsArrayController

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NSSortDescriptor *sortByTitle = [[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)] autorelease];
	[self setSortDescriptors:[NSArray arrayWithObjects:sortByTitle, nil]];
}

@end
