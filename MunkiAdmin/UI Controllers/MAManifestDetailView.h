//
//  ManifestDetailView.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 18.10.2011.
//

#import <Cocoa/Cocoa.h>

@interface MAManifestDetailView : NSViewController <NSTableViewDelegate> {
    
}

@property (weak) IBOutlet NSArrayController *managedInstallsController;
@property (weak) IBOutlet NSArrayController *managedUpdatesController;
@property (weak) IBOutlet NSArrayController *managedUninstallsController;
@property (weak) IBOutlet NSArrayController *optionalInstallsController;
@property (weak) IBOutlet NSArrayController *catalogsController;
@property (weak) IBOutlet NSArrayController *includedManifestsController;
@property (weak) IBOutlet NSTableView *nestedManifestsTableView;
@property (weak) IBOutlet NSTableView *catalogsTableView;
@property (weak) IBOutlet NSArrayController *conditionalItemsController;
@property (weak) IBOutlet NSOutlineView *conditionsOutlineView;
@property (weak) IBOutlet NSTreeController *conditionsTreeController;


@end
