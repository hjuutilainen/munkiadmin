//
//  CatalogsArrayController.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 12.1.2010.
//

#import "CatalogsArrayController.h"


@implementation CatalogsArrayController

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NSSortDescriptor *sortByTitle = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
	[self setSortDescriptors:[NSArray arrayWithObjects:sortByTitle, nil]];

}

@end
