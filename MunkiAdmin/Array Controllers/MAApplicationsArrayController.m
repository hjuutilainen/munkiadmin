//
//  ApplicationsArrayController.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 19.1.2010.
//

#import "MAApplicationsArrayController.h"


@implementation MAApplicationsArrayController

- (void)awakeFromNib
{
	[super awakeFromNib];
	
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"munki_name" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortByDisplayName = [NSSortDescriptor sortDescriptorWithKey:@"munki_display_name" ascending:YES selector:@selector(localizedStandardCompare:)];
	[self setSortDescriptors:[NSArray arrayWithObjects:sortByName, sortByDisplayName, nil]];
	
	// Reload the table view when packages change
	//[self addObserver:self forKeyPath:@"arrangedObjects.packages" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	//[self addObserver:self forKeyPath:@"arrangedObjects.munki_display_name" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	//[self addObserver:self forKeyPath:@"arrangedObjects.munki_name" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	//[self addObserver:self forKeyPath:@"arrangedObjects.munki_description" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[applicationsTableView reloadData];
	
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
