//
//  PackageInfosArrayController.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 15.1.2010.
//

/*
 TODO: This should not be an array controller!! This class is wrong in so many different ways...
 
 Currently in use by the catalogs view and holds the checkboxed pkginfos.
 */

#import <Cocoa/Cocoa.h>


@interface MAPackageInfosArrayController : NSArrayController {
	
	IBOutlet id __unsafe_unretained catalogsTableView;

}

@property (unsafe_unretained) IBOutlet id catalogsTableView;

@end
