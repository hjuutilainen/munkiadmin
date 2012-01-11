//
//  AdvancedPackageEditor.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 19.12.2011.
//

#import "AdvancedPackageEditor.h"

@implementation AdvancedPackageEditor
@synthesize forceInstallDatePicker;

@synthesize temp_preinstall_script_enabled;
@synthesize temp_preuninstall_script_enabled;
@synthesize temp_postinstall_script_enabled;
@synthesize temp_postuninstall_script_enabled;
@synthesize temp_uninstall_script_enabled;
@synthesize temp_autoremove;
@synthesize temp_description;
@synthesize temp_display_name;
@synthesize temp_force_install_after_date;
@synthesize temp_force_install_after_date_enabled;
@synthesize temp_installed_size;
@synthesize temp_installer_item_hash;
@synthesize temp_installer_item_location;
@synthesize temp_installer_item_size;
@synthesize temp_installer_type;
@synthesize temp_maximum_os_version;
@synthesize temp_minimum_os_version;
@synthesize temp_name;
@synthesize temp_package_path;
@synthesize temp_postinstall_script;
@synthesize temp_postuninstall_script;
@synthesize temp_preinstall_script;
@synthesize temp_preuninstall_script;
@synthesize temp_RestartAction;
@synthesize temp_suppress_bundle_relocation;
@synthesize temp_unattended_install;
@synthesize temp_unattended_uninstall;
@synthesize temp_uninstall_method;
@synthesize temp_uninstall_script;
@synthesize temp_uninstaller_item_location;
@synthesize temp_uninstallable;
@synthesize temp_version;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Set the force_install_after_date date picker to use UTC
    [self.forceInstallDatePicker setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
}

- (void)setDefaultValuesFromPackage:(PackageMO *)aPackage
{
    self.temp_autoremove = aPackage.munki_autoremove;
    self.temp_description = aPackage.munki_description;
    self.temp_display_name = aPackage.munki_display_name;
    self.temp_installed_size = aPackage.munki_installed_size;
    self.temp_installer_item_hash = aPackage.munki_installer_item_hash;
    self.temp_installer_item_location = aPackage.munki_installer_item_location;
    self.temp_installer_item_size = aPackage.munki_installer_item_size;
    self.temp_installer_type = aPackage.munki_installer_type;
    self.temp_maximum_os_version = aPackage.munki_maximum_os_version;
    self.temp_minimum_os_version = aPackage.munki_minimum_os_version;
    self.temp_name = aPackage.munki_name;
    self.temp_package_path = aPackage.munki_package_path;
    self.temp_RestartAction = aPackage.munki_RestartAction;
    self.temp_suppress_bundle_relocation = aPackage.munki_suppress_bundle_relocation;
    self.temp_unattended_install = aPackage.munki_unattended_install;
    self.temp_unattended_uninstall = aPackage.munki_unattended_uninstall;
    self.temp_uninstall_method = aPackage.munki_uninstall_method;
    self.temp_uninstaller_item_location = aPackage.munki_uninstaller_item_location;
    self.temp_uninstallable = aPackage.munki_uninstallable;
    self.temp_version = aPackage.munki_version;
    
    if (aPackage.munki_postinstall_script == nil) {
        self.temp_postinstall_script_enabled = NO;
    } else {
        self.temp_postinstall_script_enabled = YES;
        self.temp_postinstall_script = aPackage.munki_postinstall_script;
    }
    
    if (aPackage.munki_postuninstall_script == nil) {
        self.temp_postuninstall_script_enabled = NO;
    } else {
        self.temp_postuninstall_script_enabled = YES;
        self.temp_postuninstall_script = aPackage.munki_postuninstall_script;
    }
    
    if (aPackage.munki_preinstall_script == nil) {
        self.temp_preinstall_script_enabled = NO;
    } else {
        self.temp_preinstall_script_enabled = YES;
        self.temp_preinstall_script = aPackage.munki_preinstall_script;
    }
    
    if (aPackage.munki_preuninstall_script == nil) {
        self.temp_preuninstall_script_enabled = NO;
    } else {
        self.temp_preuninstall_script_enabled = YES;
        self.temp_preuninstall_script = aPackage.munki_preuninstall_script;
    }
    
    if (aPackage.munki_uninstall_script == nil) {
        self.temp_uninstall_script_enabled = NO;
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
