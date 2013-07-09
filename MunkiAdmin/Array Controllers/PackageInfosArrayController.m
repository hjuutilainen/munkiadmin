//
//  PackageInfosArrayController.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 15.1.2010.
//

#import "PackageInfosArrayController.h"
#import "PackageInfoMO.h"


@implementation PackageInfosArrayController

@synthesize catalogsTableView;

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NSSortDescriptor *sortByMunkiName = [NSSortDescriptor sortDescriptorWithKey:@"package.munki_name" ascending:YES selector:@selector(localizedStandardCompare:)];
	NSSortDescriptor *sortByVersion = [NSSortDescriptor sortDescriptorWithKey:@"package.munki_version" ascending:YES selector:@selector(localizedStandardCompare:)];
	[self setSortDescriptors:[NSArray arrayWithObjects:sortByMunkiName, sortByVersion, nil]];
	
	// Reload the table view when catalogs change
	//[self addObserver:self forKeyPath:@"arrangedObjects.isEnabledForCatalog" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	
    NSMenu *theMenu = [[[NSMenu alloc] initWithTitle:@"Contextual Menu"] autorelease];
	
	NSMenuItem *enableSelected = [theMenu insertItemWithTitle:@"Enable Selected" 
                                                       action:@selector(enableSelected:) 
                                                keyEquivalent:@"" 
                                                      atIndex:0];
	enableSelected.tag = 0;
	[enableSelected setTarget:self];
	
	NSMenuItem *disableSelected = [theMenu insertItemWithTitle:@"Disable Selected" 
                                                        action:@selector(disableSelected:) 
                                                 keyEquivalent:@"" 
                                                       atIndex:1];
	disableSelected.tag = 1;
	[disableSelected setTarget:self];
	
	[theMenu insertItem:[NSMenuItem separatorItem] atIndex:2];
	
	NSMenuItem *enableAll = [theMenu insertItemWithTitle:@"Enable All" 
												  action:@selector(enableAll:) 
										   keyEquivalent:@"" 
												 atIndex:3];
	enableAll.tag = 3;
	[enableAll setTarget:self];
	
	NSMenuItem *disableAll = [theMenu insertItemWithTitle:@"Disable All" 
												   action:@selector(disableAll:) 
											keyEquivalent:@"" 
												  atIndex:4];
	disableAll.tag = 4;
	[disableAll setTarget:self];
	
	
	
	[catalogsTableView setDelegate:self];
	[catalogsTableView setMenu:theMenu];
	
	// Reload the table view when contents change
	//[self addObserver:self forKeyPath:@"arrangedObjects" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	
}

- (void)enableSelected:(id)sender
{
	for (PackageInfoMO *selectedItem in [self selectedObjects]) {
		[selectedItem setIsEnabledForCatalogValue:YES];
	}
}

- (void)disableSelected:(id)sender
{
	for (PackageInfoMO *selectedItem in [self selectedObjects]) {
		[selectedItem setIsEnabledForCatalogValue:NO];
	}
}

- (void)enableAll:(id)sender
{
	for (PackageInfoMO *selectedItem in [self arrangedObjects]) {
		[selectedItem setIsEnabledForCatalogValue:YES];
	}
}

- (void)disableAll:(id)sender
{
	for (PackageInfoMO *selectedItem in [self arrangedObjects]) {
		[selectedItem setIsEnabledForCatalogValue:NO];
	}
}

/*- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{	
	[catalogsTableView reloadData];
	
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}*/

@end
