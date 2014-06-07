//
//  ManifestItemArrayController.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 16.12.2010.
//

#import "ManifestItemArrayController.h"
#import "ApplicationProxyMO.h"


@implementation ManifestItemArrayController

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
	
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
	
	
	
	[self.tableView setDelegate:self];
	[self.tableView setMenu:theMenu];
	
	// Reload the table view when contents change
	//[self addObserver:self forKeyPath:@"arrangedObjects" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	
}

- (void)enableSelected:(id)sender
{
	for (ApplicationProxyMO *selectedItem in [self selectedObjects]) {
		[selectedItem setIsEnabledValue:YES];
	}
}

- (void)disableSelected:(id)sender
{
	for (ApplicationProxyMO *selectedItem in [self selectedObjects]) {
		[selectedItem setIsEnabledValue:NO];
	}
}

- (void)enableAll:(id)sender
{
	for (ApplicationProxyMO *selectedItem in [self arrangedObjects]) {
		[selectedItem setIsEnabledValue:YES];
	}
}

- (void)disableAll:(id)sender
{
	for (ApplicationProxyMO *selectedItem in [self arrangedObjects]) {
		[selectedItem setIsEnabledValue:NO];
	}
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{	
	[self.tableView reloadData];
	
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


@end
