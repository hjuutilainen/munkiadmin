//
//  PkginfoAssimilator.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 3.12.2012.
//
//

#import "MAPkginfoAssimilator.h"
#import "MAMunkiAdmin_AppDelegate.h"
#import "DataModelHeaders.h"
#import "MAMunkiRepositoryManager.h"

@interface MAPkginfoAssimilator () {
    
}

@end

@implementation MAPkginfoAssimilator


- (id)initWithWindow:(NSWindow *)window
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    self = [super initWithWindow:window];
    if (self) {
        NSArray *basicKeys = @[@"assimilate_autoremove",
                              @"assimilate_description",
                              @"assimilate_display_name",
                              @"assimilate_installable_condition",
                              @"assimilate_maximum_os_version",
                              @"assimilate_minimum_munki_version",
                              @"assimilate_minimum_os_version",
                              @"assimilate_name",
                              @"assimilate_unattended_install",
                              @"assimilate_unattended_uninstall",
                              @"assimilate_uninstallable",
                              @"assimilate_uninstaller_item_location"];
        
        NSArray *scriptKeys = @[@"assimilate_installcheck_script",
                              @"assimilate_preinstall_script",
                              @"assimilate_postinstall_script",
                              @"assimilate_preuninstall_script",
                              @"assimilate_postuninstall_script",
                              @"assimilate_uninstall_method",
                              @"assimilate_uninstall_script",
                              @"assimilate_uninstallcheck_script"];
        
        NSArray *arrayKeys = @[@"assimilate_blocking_applications",
                              @"assimilate_installer_choices_xml",
                              @"assimilate_installs_items",
                              @"assimilate_items_to_copy",
                              @"assimilate_requires",
                              @"assimilate_supported_architectures",
                              @"assimilate_update_for"];
        
        NSArray *specialKeys = @[@"assimilate_category",
                                 @"assimilate_developer"];
        
        keyGroups = @{basicKeys: @"basicKeys",
                      scriptKeys: @"scriptKeys",
                      arrayKeys: @"arrayKeys",
                      specialKeys: @"specialKeys"};
        
        defaultsKeysToLoop = @[@"assimilate_autoremove",
                              @"assimilate_blocking_applications",
                              @"assimilate_description",
                              @"assimilate_display_name",
                              @"assimilate_installable_condition",
                              @"assimilate_installcheck_script",
                              @"assimilate_installer_choices_xml",
                              @"assimilate_installs_items",
                              @"assimilate_items_to_copy",
                              @"assimilate_maximum_os_version",
                              @"assimilate_minimum_munki_version",
                              @"assimilate_minimum_os_version",
                              @"assimilate_name",
                              @"assimilate_preinstall_script",
                              @"assimilate_postinstall_script",
                              @"assimilate_preuninstall_script",
                              @"assimilate_postuninstall_script",
                              @"assimilate_requires",
                              @"assimilate_supported_architectures",
                              @"assimilate_unattended_install",
                              @"assimilate_unattended_uninstall",
                              @"assimilate_uninstall_method",
                              @"assimilate_uninstall_script",
                              @"assimilate_uninstallable",
                              @"assimilate_uninstallcheck_script",
                              @"assimilate_uninstaller_item_location",
                              @"assimilate_update_for"];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window center];
    
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"munki_name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByVersion = [NSSortDescriptor sortDescriptorWithKey:@"munki_version" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.allPackagesArrayController setSortDescriptors:[NSArray arrayWithObjects:sortByTitle, sortByVersion, nil]];
    
    
}

- (void)commitChangesToCurrentPackage
{
    for (NSString *assimilateKeyName in [keyGroups objectForKey:@"basicKeys"]) {
        if ([[self valueForKey:assimilateKeyName] boolValue]) {
            NSString *munkiadminKeyName = [assimilateKeyName stringByReplacingOccurrencesOfString:@"assimilate_" withString:@"munki_"];
            id sourceValue = [self.sourcePkginfo valueForKey:munkiadminKeyName];
            [self.targetPkginfo setValue:sourceValue forKey:munkiadminKeyName];
        }
    }
    
    for (NSString *assimilateKeyName in [keyGroups objectForKey:@"scriptKeys"]) {
        if ([[self valueForKey:assimilateKeyName] boolValue]) {
            NSString *munkiadminKeyName = [assimilateKeyName stringByReplacingOccurrencesOfString:@"assimilate_" withString:@"munki_"];
            id sourceValue = [self.sourcePkginfo valueForKey:munkiadminKeyName];
            [self.targetPkginfo setValue:sourceValue forKey:munkiadminKeyName];
        }
    }
    
    NSManagedObjectContext *moc = [(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext];
    MAMunkiRepositoryManager *repoManager = [MAMunkiRepositoryManager sharedManager];
    
    /*
     Developer and category
     */
    if (self.assimilate_category) {
        [repoManager copyCategoryFrom:self.sourcePkginfo target:self.targetPkginfo inManagedObjectContext:moc];
    }
    if (self.assimilate_developer) {
        [repoManager copyDeveloperFrom:self.sourcePkginfo target:self.targetPkginfo inManagedObjectContext:moc];
    }
    
    /*
     Blocking applications
     */
    if (self.assimilate_blocking_applications) {
        for (StringObjectMO *blockingApp in self.sourcePkginfo.blockingApplications) {
            StringObjectMO *newBlockingApplication = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
            newBlockingApplication.title = blockingApp.title;
            newBlockingApplication.typeString = @"package";
            [self.targetPkginfo addBlockingApplicationsObject:newBlockingApplication];
        }
    }
    
    /*
     Requires
     */
    if (self.assimilate_requires) {
        for (StringObjectMO *requiresItem in self.sourcePkginfo.requirements) {
            StringObjectMO *newRequiredPkgInfo = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
            newRequiredPkgInfo.title = requiresItem.title;
            newRequiredPkgInfo.typeString = @"package";
            [self.targetPkginfo addRequirementsObject:newRequiredPkgInfo];
        }
    }
    
    /*
     Update for
     */
    if (self.assimilate_update_for) {
        for (StringObjectMO *updateForItem in self.sourcePkginfo.updateFor) {
            StringObjectMO *newUpdateForItem = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
            newUpdateForItem.title = updateForItem.title;
            newUpdateForItem.typeString = @"package";
            [self.targetPkginfo addUpdateForObject:newUpdateForItem];
        }
    }
    
    /*
     Supported architectures
     */
    if (self.assimilate_supported_architectures) {
        for (StringObjectMO *supportedArch in self.sourcePkginfo.supportedArchitectures) {
            StringObjectMO *newSupportedArchitecture = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
            newSupportedArchitecture.title = supportedArch.title;
            newSupportedArchitecture.typeString = @"architecture";
            [self.targetPkginfo addSupportedArchitecturesObject:newSupportedArchitecture];
        }
    }
    
    /*
     Installs
     */
    if (self.assimilate_installs_items) {
        [repoManager copyInstallsItemsFrom:self.sourcePkginfo target:self.targetPkginfo inManagedObjectContext:moc];
    }
    
    /*
     Installer choices XML
     */
    if (self.assimilate_installer_choices_xml) {
        [repoManager copyInstallerChoicesFrom:self.sourcePkginfo target:self.targetPkginfo inManagedObjectContext:moc];
    }
    
    /*
     Items to copy
     */
    if (self.assimilate_items_to_copy) {
        [repoManager copyItemsToCopyItemsFrom:self.sourcePkginfo target:self.targetPkginfo inManagedObjectContext:moc];
    }
}

- (IBAction)saveAction:(id)sender;
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    
    [self commitChangesToCurrentPackage];
    
    [[self window] orderOut:sender];
    [NSApp endModalSession:self.modalSession];
    [NSApp stopModal];
    
    if ([self.delegate respondsToSelector:@selector(pkginfoAssimilatorDidFinish:returnCode:object:)]) {
        [self.delegate pkginfoAssimilatorDidFinish:self returnCode:NSOKButton object:nil];
    }
}

- (IBAction)cancelAction:(id)sender;
{
    [[self window] orderOut:sender];
    [NSApp endModalSession:self.modalSession];
    [NSApp stopModal];
    
    if ([self.delegate respondsToSelector:@selector(pkginfoAssimilatorDidFinish:returnCode:object:)]) {
        [self.delegate pkginfoAssimilatorDidFinish:self returnCode:NSCancelButton object:nil];
    }
}


- (IBAction)enableAllAction:(id)sender
{
    for (NSString *aKey in defaultsKeysToLoop) {
        [self setValue:[NSNumber numberWithBool:YES] forKey:aKey];
    }
}


- (IBAction)disableAllAction:(id)sender
{
    for (NSString *aKey in defaultsKeysToLoop) {
        [self setValue:[NSNumber numberWithBool:NO] forKey:aKey];
    }
}

- (NSUndoManager*)windowWillReturnUndoManager:(NSWindow*)window
{
    if (!undoManager) {
        undoManager = [[NSUndoManager alloc] init];
    }
    return undoManager;
}


- (NSModalSession)beginEditSessionWithObject:(PackageMO *)targetPackage source:(PackageMO *)sourcePackage delegate:(id)modalDelegate
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    self.targetPkginfo = targetPackage;
    self.sourcePkginfo = nil;
    if (sourcePackage != nil) {
        self.sourcePkginfo = sourcePackage;
    }
    self.delegate = modalDelegate;
    
    self.modalSession = [NSApp beginModalSessionForWindow:self.window];
    [NSApp runModalSession:self.modalSession];
    
    // Setup the default selection
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (NSString *assimilateKeyName in [keyGroups objectForKey:@"basicKeys"]) {
        BOOL sourceValue = [defaults boolForKey:assimilateKeyName];
        [self setValue:[NSNumber numberWithBool:sourceValue] forKey:assimilateKeyName];
    }
    for (NSString *assimilateKeyName in [keyGroups objectForKey:@"scriptKeys"]) {
        BOOL sourceValue = [defaults boolForKey:assimilateKeyName];
        [self setValue:[NSNumber numberWithBool:sourceValue] forKey:assimilateKeyName];
    }
    for (NSString *assimilateKeyName in [keyGroups objectForKey:@"arrayKeys"]) {
        BOOL sourceValue = [defaults boolForKey:assimilateKeyName];
        [self setValue:[NSNumber numberWithBool:sourceValue] forKey:assimilateKeyName];
    }
    for (NSString *assimilateKeyName in [keyGroups objectForKey:@"specialKeys"]) {
        BOOL sourceValue = [defaults boolForKey:assimilateKeyName];
        [self setValue:[NSNumber numberWithBool:sourceValue] forKey:assimilateKeyName];
    }
    
    return self.modalSession;
}



@end
