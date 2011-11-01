//
//  ApplicationInfosArrayController.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 29.1.2010.
//

#import "ApplicationInfosArrayController.h"


@implementation ApplicationInfosArrayController

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NSSortDescriptor *sortByTitle = [[[NSSortDescriptor alloc] initWithKey:@"application.munki_name" ascending:YES selector:@selector(localizedStandardCompare:)] autorelease];
	[self setSortDescriptors:[NSArray arrayWithObjects:sortByTitle, nil]];
	
	// Reload the table view when catalogs change
	//[self addObserver:self forKeyPath:@"arrangedObjects.isEnabledForManifest" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{	
	[manifestTableView reloadData];
	
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
