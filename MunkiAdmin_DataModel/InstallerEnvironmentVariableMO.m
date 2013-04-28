#import "InstallerEnvironmentVariableMO.h"


@interface InstallerEnvironmentVariableMO ()

// Private interface goes here.

@end


@implementation InstallerEnvironmentVariableMO

- (NSDictionary *)dictValueForSave
{
	NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithCapacity:1];
    
    // We absolutely need a value for the key
	if (self.munki_installer_environment_key != nil) {
        
        // It would also be good to have a value for the value
        if (self.munki_installer_environment_value != nil) {
            
            // We have something for both the key and value
            [tmpDict setObject:self.munki_installer_environment_value
                        forKey:self.munki_installer_environment_key];
        }
        else {
            // Set an empty string for the value, values can't be nil
            [tmpDict setObject:@"" forKey:self.munki_installer_environment_key];
        }
    }
    
	NSDictionary *returnDict = [NSDictionary dictionaryWithDictionary:tmpDict];
	return returnDict;
}

@end
