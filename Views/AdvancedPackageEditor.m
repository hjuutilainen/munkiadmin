//
//  AdvancedPackageEditor.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 19.12.2011.
//

#import "AdvancedPackageEditor.h"
#import "MunkiAdmin_AppDelegate.h"
#import "MunkiOperation.h"
#import "SelectPkginfoItemsWindow.h"


@implementation AdvancedPackageEditor
@synthesize forceInstallDatePicker;
@synthesize mainTabView;
@synthesize installsItemsController;
@synthesize pkgController;
@synthesize receiptsArrayController;
@synthesize itemsToCopyArrayController;
@synthesize requiresArrayController;
@synthesize updateForArrayController;

@synthesize temp_preinstall_script_enabled;
@synthesize temp_preuninstall_script_enabled;
@synthesize temp_postinstall_script_enabled;
@synthesize temp_postuninstall_script_enabled;
@synthesize temp_uninstall_script_enabled;
@synthesize temp_force_install_after_date;
@synthesize temp_force_install_after_date_enabled;
@synthesize temp_postinstall_script;
@synthesize temp_postuninstall_script;
@synthesize temp_preinstall_script;
@synthesize temp_preuninstall_script;
@synthesize temp_uninstall_script;
@synthesize modalSession;
@synthesize pkginfoToEdit;
@synthesize delegate;

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

- (NSModalSession)beginEditSessionWithObject:(PackageMO *)aPackage delegate:(id)modalDelegate
{
    self.pkginfoToEdit = aPackage;
    self.delegate = modalDelegate;
    [self.mainTabView selectTabViewItemAtIndex:0];
    
    // Set the force_install_after_date date picker to use UTC
    [self.forceInstallDatePicker setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    [self setDefaultValuesFromPackage:self.pkginfoToEdit];
    
    self.modalSession = [NSApp beginModalSessionForWindow:self.window];
    [NSApp runModalSession:self.modalSession];
    return self.modalSession;
}

- (void)addRequiresItemSheetDidEnd:(id)sheet returnCode:(int)returnCode object:(id)object
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    if (returnCode == NSCancelButton) return;
    
    for (StringObjectMO *selectedItem in [pkginfoSelector selectionAsStringObjects]) {
        selectedItem.typeString = @"package";
        [self.pkginfoToEdit addRequirementsObject:selectedItem];
    }
}

- (IBAction)addRequiresItemAction:(id)sender
{
    [NSApp beginSheet:[pkginfoSelector window]
	   modalForWindow:[self window] modalDelegate:self 
	   didEndSelector:@selector(addRequiresItemSheetDidEnd:returnCode:object:) contextInfo:nil];
}

- (void)addUpdateForItemSheetDidEnd:(id)sheet returnCode:(int)returnCode object:(id)object
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    if (returnCode == NSCancelButton) return;
    
    for (StringObjectMO *selectedItem in [pkginfoSelector selectionAsStringObjects]) {
        selectedItem.typeString = @"package";
        [self.pkginfoToEdit addUpdateForObject:selectedItem];
    }
}

- (IBAction)addUpdateForItem:(id)sender
{
    [NSApp beginSheet:[pkginfoSelector window]
	   modalForWindow:[self window] modalDelegate:self 
	   didEndSelector:@selector(addUpdateForItemSheetDidEnd:returnCode:object:) contextInfo:nil];
}

- (void)installsItemDidFinish:(NSDictionary *)pkginfoPlist
{
	NSDictionary *installsItemProps = [[pkginfoPlist objectForKey:@"installs"] objectAtIndex:0];
	if (installsItemProps != nil) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Got new dictionary from makepkginfo");
        InstallsItemMO *newInstallsItem = [NSEntityDescription insertNewObjectForEntityForName:@"InstallsItem" inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
        newInstallsItem.munki_CFBundleIdentifier = [installsItemProps objectForKey:@"CFBundleIdentifier"];
        newInstallsItem.munki_CFBundleName = [installsItemProps objectForKey:@"CFBundleName"];
        newInstallsItem.munki_CFBundleShortVersionString = [installsItemProps objectForKey:@"CFBundleShortVersionString"];
        newInstallsItem.munki_path = [installsItemProps objectForKey:@"path"];
        newInstallsItem.munki_type = [installsItemProps objectForKey:@"type"];
        newInstallsItem.munki_md5checksum = [installsItemProps objectForKey:@"md5checksum"];
        [self.pkginfoToEdit addInstallsItemsObject:newInstallsItem];
	} else {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Error. Got nil from makepkginfo");
	}
    
}

- (IBAction)addInstallsItemFromDiskAction:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
	if ([[NSApp delegate] makepkginfoInstalled]) {
		NSArray *filesToAdd = [[NSApp delegate] chooseFiles];
		if (filesToAdd) {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Adding %lu installs items", (unsigned long)[filesToAdd count]);
			for (NSURL *fileToAdd in filesToAdd) {
				if (fileToAdd != nil) {
					MunkiOperation *theOp = [MunkiOperation installsItemFromURL:fileToAdd];
					theOp.delegate = self;
					[[[NSApp delegate] operationQueue] addOperation:theOp];
				}
			}
		}
	} else {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) NSLog(@"Can't find %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"makepkginfoPath"]);
	}
}

- (void)saveAction:(id)sender;
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    
    // Scripts
    if (self.temp_preinstall_script_enabled) {
        if (self.temp_preinstall_script) {
            self.pkginfoToEdit.munki_preinstall_script = self.temp_preinstall_script;
        } else {
            self.pkginfoToEdit.munki_preinstall_script = @"";
        }
    } else {
        self.pkginfoToEdit.munki_preinstall_script = nil;
    }
    
    if (self.temp_postinstall_script_enabled) {
        if (self.temp_postinstall_script) {
            self.pkginfoToEdit.munki_postinstall_script = self.temp_postinstall_script;
        } else {
            self.pkginfoToEdit.munki_postinstall_script = @"";
        }
    } else {
        self.pkginfoToEdit.munki_postinstall_script = nil;
    }
    
    if (self.temp_postuninstall_script_enabled) {
        if (self.temp_postuninstall_script) {
            self.pkginfoToEdit.munki_postuninstall_script = self.temp_postuninstall_script;
        } else {
            self.pkginfoToEdit.munki_postuninstall_script = @"";
        }
    } else {
        self.pkginfoToEdit.munki_postuninstall_script = nil;
    }
    
    if (self.temp_preuninstall_script_enabled) {
        if (self.temp_preuninstall_script) {
            self.pkginfoToEdit.munki_preuninstall_script = self.temp_preuninstall_script;
        } else {
            self.pkginfoToEdit.munki_preuninstall_script = @"";
        }
    } else {
        self.pkginfoToEdit.munki_preuninstall_script = nil;
    }
    
    if (self.temp_uninstall_script_enabled) {
        if (self.temp_uninstall_script) {
            self.pkginfoToEdit.munki_uninstall_script = self.temp_uninstall_script;
        } else {
            self.pkginfoToEdit.munki_uninstall_script = @"";
        }
    } else {
        self.pkginfoToEdit.munki_uninstall_script = nil;
    }
    
    
    if (self.temp_force_install_after_date_enabled) {
        self.pkginfoToEdit.munki_force_install_after_date = self.temp_force_install_after_date;
    } else {
        self.pkginfoToEdit.munki_force_install_after_date = nil;
    }
        
    [[self window] orderOut:sender];
    [NSApp endModalSession:modalSession];
    [NSApp stopModal];
    
    if ([self.delegate respondsToSelector:@selector(packageEditorDidFinish:returnCode:object:)]) {
        [self.delegate packageEditorDidFinish:self returnCode:NSOKButton object:nil];
    }
}

- (void)cancelAction:(id)sender;
{    
    [[self window] orderOut:sender];
    [NSApp endModalSession:modalSession];
    [NSApp stopModal];
    
    if ([self.delegate respondsToSelector:@selector(packageEditorDidFinish:returnCode:object:)]) {
        [self.delegate packageEditorDidFinish:self returnCode:NSCancelButton object:nil];
    }
}

- (id)initWithWindow:(NSWindow *)window
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    pkginfoSelector = [[SelectPkginfoItemsWindow alloc] initWithWindowNibName:@"SelectPkginfoItemsWindow"];
    
    // Set the force_install_after_date date picker to use UTC
    [self.forceInstallDatePicker setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [self setDefaultValuesFromPackage:self.pkginfoToEdit];
    
    [self.mainTabView selectTabViewItemAtIndex:0];
    
    NSSortDescriptor *sortInstallsItems = [NSSortDescriptor sortDescriptorWithKey:@"munki_path" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.installsItemsController setSortDescriptors:[NSArray arrayWithObject:sortInstallsItems]];
    
    NSSortDescriptor *sortItemsToCopyByDestPath = [NSSortDescriptor sortDescriptorWithKey:@"munki_destination_path" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortItemsToCopyBySource = [NSSortDescriptor sortDescriptorWithKey:@"munki_source_item" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.itemsToCopyArrayController setSortDescriptors:[NSArray arrayWithObjects:sortItemsToCopyByDestPath, sortItemsToCopyBySource, nil]];
    
    NSSortDescriptor *sortReceiptsByPackageID = [NSSortDescriptor sortDescriptorWithKey:@"munki_packageid" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortReceiptsByName = [NSSortDescriptor sortDescriptorWithKey:@"munki_name" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.receiptsArrayController setSortDescriptors:[NSArray arrayWithObjects:sortReceiptsByPackageID, sortReceiptsByName, nil]];
    
    NSSortDescriptor *sortStringObjectsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.updateForArrayController setSortDescriptors:[NSArray arrayWithObject:sortStringObjectsByTitle]];
    [self.requiresArrayController setSortDescriptors:[NSArray arrayWithObject:sortStringObjectsByTitle]];
}

- (void)setDefaultValuesFromPackage:(PackageMO *)aPackage
{
    if (aPackage.munki_postinstall_script == nil) {
        self.temp_postinstall_script_enabled = NO;
        self.temp_postinstall_script = @"";
    } else {
        self.temp_postinstall_script_enabled = YES;
        self.temp_postinstall_script = aPackage.munki_postinstall_script;
    }
    
    if (aPackage.munki_postuninstall_script == nil) {
        self.temp_postuninstall_script_enabled = NO;
        self.temp_postuninstall_script = @"";
    } else {
        self.temp_postuninstall_script_enabled = YES;
        self.temp_postuninstall_script = aPackage.munki_postuninstall_script;
    }
    
    if (aPackage.munki_preinstall_script == nil) {
        self.temp_preinstall_script_enabled = NO;
        self.temp_preinstall_script = @"";
    } else {
        self.temp_preinstall_script_enabled = YES;
        self.temp_preinstall_script = aPackage.munki_preinstall_script;
    }
    
    if (aPackage.munki_preuninstall_script == nil) {
        self.temp_preuninstall_script_enabled = NO;
        self.temp_preuninstall_script = @"";
    } else {
        self.temp_preuninstall_script_enabled = YES;
        self.temp_preuninstall_script = aPackage.munki_preuninstall_script;
    }
    
    if (aPackage.munki_uninstall_script == nil) {
        self.temp_uninstall_script_enabled = NO;
        self.temp_uninstall_script = @"";
    } else {
        self.temp_uninstall_script_enabled = YES;
        self.temp_uninstall_script = aPackage.munki_uninstall_script;
    }
    
    if (aPackage.munki_force_install_after_date == nil) {
        
        /*
         Package doesn't have a forced date.
         Set the default date to something meaningful (now + 7 days)
         in case the user decides to enable it
         */
        
        NSDate *now = [NSDate date];
        NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        NSDateComponents *dateComponents = [gregorian components:( NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:now];
        [dateComponents setMinute:0];
        [dateComponents setSecond:0];
        NSDate *normalizedDate = [gregorian dateFromComponents:dateComponents];
        
        NSDateComponents *offsetComponents = [[[NSDateComponents alloc] init] autorelease];
        [offsetComponents setDay:7];
        NSDate *newDate = [gregorian dateByAddingComponents:offsetComponents toDate:normalizedDate options:0];
        
        self.temp_force_install_after_date = newDate;
        self.temp_force_install_after_date_enabled = NO;
        
    } else {
        self.temp_force_install_after_date_enabled = YES;
        self.temp_force_install_after_date = aPackage.munki_force_install_after_date;
    }

}

@end
