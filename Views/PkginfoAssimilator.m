//
//  PkginfoAssimilator.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 3.12.2012.
//
//

#import "PkginfoAssimilator.h"
#import "MunkiAdmin_AppDelegate.h"

@interface PkginfoAssimilator () {
    /*
    BOOL assimilate_blocking_applications;
    BOOL assimilate_requires;
    BOOL assimilate_update_for;
    BOOL assimilate_supported_architectures;
    BOOL assimilate_installs_items;
    BOOL assimilate_installer_choices_xml;
    
    BOOL assimilate_autoremove;
    BOOL assimilate_description;
    BOOL assimilate_display_name;
    BOOL assimilate_installable_condition;
    BOOL assimilate_maximum_os_version;
    BOOL assimilate_minimum_munki_version;
    BOOL assimilate_minimum_os_version;
    BOOL assimilate_name;
    BOOL assimilate_unattended_install;
    BOOL assimilate_unattended_uninstall;
    BOOL assimilate_uninstallable;
    BOOL assimilate_uninstaller_item_location;
    
    BOOL assimilate_installcheck_script;
    BOOL assimilate_preinstall_script;
    BOOL assimilate_postinstall_script;
    BOOL assimilate_preuninstall_script;
    BOOL assimilate_postuninstall_script;
    BOOL assimilate_uninstall_method;
    BOOL assimilate_uninstall_script;
    BOOL assimilate_uninstallcheck_script;
    */
}

@end

@implementation PkginfoAssimilator

@synthesize delegate;
@synthesize modalSession;
@synthesize sourcePkginfo;
@synthesize targetPkginfo;
@synthesize allPackagesArrayController;

- (id)initWithWindow:(NSWindow *)window
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    self = [super initWithWindow:window];
    if (self) {
        NSArray *basicKeys = [NSArray arrayWithObjects:
                              @"assimilate_autoremove",
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
                              @"assimilate_uninstaller_item_location",
                              nil];
        NSArray *scriptKeys = [NSArray arrayWithObjects:
                              @"assimilate_installcheck_script",
                              @"assimilate_preinstall_script",
                              @"assimilate_postinstall_script",
                              @"assimilate_preuninstall_script",
                              @"assimilate_postuninstall_script",
                              @"assimilate_uninstall_method",
                              @"assimilate_uninstall_script",
                              @"assimilate_uninstallcheck_script",
                              nil];
        NSArray *arrayKeys = [NSArray arrayWithObjects:
                              @"assimilate_blocking_applications",
                              @"assimilate_installer_choices_xml",
                              @"assimilate_installs_items",
                              @"assimilate_requires",
                              @"assimilate_supported_architectures",
                              @"assimilate_update_for",
                              nil];
        keyGroups = [[NSDictionary alloc] initWithObjectsAndKeys:
                     basicKeys, @"basicKeys",
                     scriptKeys, @"scriptKeys",
                     arrayKeys, @"arrayKeys",
                     nil];
        
        defaultsKeysToLoop = [[NSArray alloc] initWithObjects:
                              @"assimilate_autoremove",
                              @"assimilate_blocking_applications",
                              @"assimilate_description",
                              @"assimilate_display_name",
                              @"assimilate_installable_condition",
                              @"assimilate_installcheck_script",
                              @"assimilate_installer_choices_xml",
                              @"assimilate_installs_items",
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
                              @"assimilate_update_for",
                              nil];
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
    
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
        
    // Blocking applications
    if (self.assimilate_blocking_applications) {
        for (StringObjectMO *blockingApp in self.sourcePkginfo.blockingApplications) {
            StringObjectMO *newBlockingApplication = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
            newBlockingApplication.title = blockingApp.title;
            newBlockingApplication.typeString = @"package";
            [self.targetPkginfo addBlockingApplicationsObject:newBlockingApplication];
        }
    }
    
    // Requires
    if (self.assimilate_requires) {
        for (StringObjectMO *requiresItem in self.sourcePkginfo.requirements) {
            StringObjectMO *newRequiredPkgInfo = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
            newRequiredPkgInfo.title = requiresItem.title;
            newRequiredPkgInfo.typeString = @"package";
            [self.targetPkginfo addRequirementsObject:newRequiredPkgInfo];
        }
    }
    
    // Update for
    if (self.assimilate_update_for) {
        for (StringObjectMO *updateForItem in self.sourcePkginfo.updateFor) {
            StringObjectMO *newUpdateForItem = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
            newUpdateForItem.title = updateForItem.title;
            newUpdateForItem.typeString = @"package";
            [self.targetPkginfo addRequirementsObject:newUpdateForItem];
        }
    }
    
    // Supported architectures
    if (self.assimilate_supported_architectures) {
        for (StringObjectMO *supportedArch in self.sourcePkginfo.supportedArchitectures) {
            StringObjectMO *newSupportedArchitecture = [NSEntityDescription insertNewObjectForEntityForName:@"StringObject" inManagedObjectContext:moc];
            newSupportedArchitecture.title = supportedArch.title;
            newSupportedArchitecture.typeString = @"architecture";
            [self.targetPkginfo addSupportedArchitecturesObject:newSupportedArchitecture];
        }
    }
    
    // Installs
    if (self.assimilate_installs_items) {
        for (InstallsItemMO *installsItem in self.sourcePkginfo.installsItems) {
            InstallsItemMO *newInstallsItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallsItem" inManagedObjectContext:moc];
            newInstallsItem.munki_CFBundleIdentifier = installsItem.munki_CFBundleIdentifier;
            newInstallsItem.munki_CFBundleName = installsItem.munki_CFBundleName;
            newInstallsItem.munki_CFBundleShortVersionString = installsItem.munki_CFBundleShortVersionString;
            newInstallsItem.munki_md5checksum = installsItem.munki_md5checksum;
            newInstallsItem.munki_minosversion = installsItem.munki_minosversion;
            newInstallsItem.munki_path = installsItem.munki_path;
            newInstallsItem.munki_type = installsItem.munki_type;
            [self.targetPkginfo addInstallsItemsObject:newInstallsItem];
        }
    }
    
    // Installer choices XML
    if (self.assimilate_installer_choices_xml) {
        for (InstallerChoicesItemMO *installerChoicesItem in self.sourcePkginfo.installerChoicesItems) {
            InstallerChoicesItemMO *newInstallerChoicesItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallerChoicesItem" inManagedObjectContext:moc];
            newInstallerChoicesItem.munki_attributeSetting = installerChoicesItem.munki_attributeSetting;
            newInstallerChoicesItem.munki_choiceAttribute = installerChoicesItem.munki_choiceAttribute;
            newInstallerChoicesItem.munki_choiceIdentifier = installerChoicesItem.munki_choiceIdentifier;
            [self.targetPkginfo addInstallerChoicesItemsObject:newInstallerChoicesItem];
        }
    }
}

- (IBAction)saveAction:(id)sender;
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    
    [self commitChangesToCurrentPackage];
    
    [[self window] orderOut:sender];
    [NSApp endModalSession:modalSession];
    [NSApp stopModal];
    
    if ([self.delegate respondsToSelector:@selector(pkginfoAssimilatorDidFinish:returnCode:object:)]) {
        [self.delegate pkginfoAssimilatorDidFinish:self returnCode:NSOKButton object:nil];
    }
}

- (IBAction)cancelAction:(id)sender;
{
    [[self window] orderOut:sender];
    [NSApp endModalSession:modalSession];
    [NSApp stopModal];
    
    if ([self.delegate respondsToSelector:@selector(pkginfoAssimilatorDidFinish:returnCode:object:)]) {
        [self.delegate pkginfoAssimilatorDidFinish:self returnCode:NSCancelButton object:nil];
    }
}


- (IBAction)enableAllAction:(id)sender
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    for (NSString *aKey in defaultsKeysToLoop) {
        [def setBool:YES forKey:aKey];
    }
}


- (IBAction)disableAllAction:(id)sender
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    for (NSString *aKey in defaultsKeysToLoop) {
        [def setBool:NO forKey:aKey];
    }
}

- (NSUndoManager*)windowWillReturnUndoManager:(NSWindow*)window
{
    if (!undoManager) {
        undoManager = [[NSUndoManager alloc] init];
    }
    return undoManager;
}

- (void)dealloc
{
    [undoManager release];
    [super dealloc];
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
        NSLog(@"%@", assimilateKeyName);
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
    
    return self.modalSession;
}



@end
