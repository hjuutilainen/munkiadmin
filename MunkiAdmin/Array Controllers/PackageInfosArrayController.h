//
//  PackageInfosArrayController.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 15.1.2010.
//

#import <Cocoa/Cocoa.h>


@interface PackageInfosArrayController : NSArrayController <NSTableViewDelegate> {
	
}

@property (weak) IBOutlet NSTableView *catalogsTableView;

@end
