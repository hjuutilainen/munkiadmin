//
//  PackageInfosArrayController.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 15.1.2010.
//

#import <Cocoa/Cocoa.h>


@interface PackageInfosArrayController : NSArrayController {
	
	IBOutlet id __unsafe_unretained catalogsTableView;

}

@property (unsafe_unretained) IBOutlet id catalogsTableView;

@end
