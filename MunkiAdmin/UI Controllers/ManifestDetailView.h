//
//  ManifestDetailView.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 18.10.2011.
//

#import <Cocoa/Cocoa.h>

@interface ManifestDetailView : NSViewController <NSTableViewDelegate> {
    NSArrayController *__weak managedInstallsController;
    NSArrayController *__weak managedUpdatesController;
    NSArrayController *__weak managedUninstallsController;
    NSArrayController *__weak optionalInstallsController;
    NSArrayController *__weak catalogsController;
    NSArrayController *__weak includedManifestsController;
    NSTableView *__weak nestedManifestsTableView;
    NSTableView *__weak catalogsTableView;
    NSArrayController *__weak conditionalItemsController;
    NSOutlineView *__weak conditionsOutlineView;
    NSTreeController *__weak conditionsTreeController;
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
