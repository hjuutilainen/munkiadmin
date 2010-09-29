//
//  CatalogInfosArrayController.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 12.1.2010.
//

#import "CatalogInfosArrayController.h"


@implementation CatalogInfosArrayController

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NSSortDescriptor *sortByTitle = [[[NSSortDescriptor alloc] initWithKey:@"catalog.title" ascending:YES selector:@selector(localizedStandardCompare:)] autorelease];
	[self setSortDescriptors:[NSArray arrayWithObject:sortByTitle]];
}

@end
