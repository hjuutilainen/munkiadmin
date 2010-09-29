//
//  ApplicationsArrayController.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 19.1.2010.
//

#import "ApplicationsArrayController.h"


@implementation ApplicationsArrayController

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NSSortDescriptor *sortByTitle = [[[NSSortDescriptor alloc] initWithKey:@"munki_display_name" ascending:YES selector:@selector(localizedStandardCompare:)] autorelease];
	[self setSortDescriptors:[NSArray arrayWithObject:sortByTitle]];
	
	// Reload the table view when packages change
	[self addObserver:self forKeyPath:@"arrangedObjects.packages" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	[self addObserver:self forKeyPath:@"arrangedObjects.munki_display_name" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	[self addObserver:self forKeyPath:@"arrangedObjects.munki_name" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	[self addObserver:self forKeyPath:@"arrangedObjects.munki_description" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[applicationsTableView reloadData];
	
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
