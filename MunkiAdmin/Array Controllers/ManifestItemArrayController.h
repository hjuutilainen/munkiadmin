//
//  ManifestItemArrayController.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 16.12.2010.
//

#import <Cocoa/Cocoa.h>


@interface ManifestItemArrayController : NSArrayController {
	id tableView;
}

@property (nonatomic, strong) IBOutlet id tableView;

@end
