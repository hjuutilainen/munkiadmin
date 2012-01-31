//
//  PackageInfosArrayController.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 15.1.2010.
//

#import <Cocoa/Cocoa.h>


@interface PackageInfosArrayController : NSArrayController {
	
	IBOutlet id catalogsTableView;

}

@property (assign) IBOutlet id catalogsTableView;

@end
