//
//  ManifestDetailView.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 18.10.2011.
//

#import <Cocoa/Cocoa.h>

@interface ManifestDetailView : NSViewController {
    NSArrayController *managedInstallsController;
    NSArrayController *managedUpdatesController;
    NSArrayController *managedUninstallsController;
    NSArrayController *optionalInstallsController;
    NSArrayController *catalogsController;
    NSArrayController *includedManifestsController;
}

@property (assign) IBOutlet NSArrayController *managedInstallsController;
@property (assign) IBOutlet NSArrayController *managedUpdatesController;
@property (assign) IBOutlet NSArrayController *managedUninstallsController;
@property (assign) IBOutlet NSArrayController *optionalInstallsController;
@property (assign) IBOutlet NSArrayController *catalogsController;
@property (assign) IBOutlet NSArrayController *includedManifestsController;


@end
