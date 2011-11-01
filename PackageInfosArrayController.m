//
//  PackageInfosArrayController.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 15.1.2010.
//

#import "PackageInfosArrayController.h"


@implementation PackageInfosArrayController

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NSSortDescriptor *sortByMunkiName = [NSSortDescriptor sortDescriptorWithKey:@"package.munki_name" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortByVersion = [NSSortDescriptor sortDescriptorWithKey:@"package.munki_version" ascending:YES selector:@selector(localizedStandardCompare:)];
	[self setSortDescriptors:[NSArray arrayWithObjects:sortByMunkiName, sortByVersion, nil]];
	
	// Reload the table view when catalogs change
	//[self addObserver:self forKeyPath:@"arrangedObjects.isEnabledForCatalog" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{	
	[catalogsTableView reloadData];
	
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
