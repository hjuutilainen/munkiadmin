//
//  main.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 11.1.2010.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
	@autoreleasepool {
		NSString *userDefaultsValuesPath;
		NSDictionary *userDefaultsValuesDict = nil;
		
		// Try to load from YAML first, then fall back to plist
		userDefaultsValuesPath = [[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"yaml"];
		if (userDefaultsValuesPath && [[NSFileManager defaultManager] fileExistsAtPath:userDefaultsValuesPath]) {
			NSLog(@"Loading user defaults from YAML: %@", userDefaultsValuesPath);
			
			// Use yaml_bridge.py to convert YAML to NSDictionary
			NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
			NSString *scriptPath = [bundlePath stringByAppendingPathComponent:@"Contents/Resources/yaml_bridge.py"];
			
			if ([[NSFileManager defaultManager] fileExistsAtPath:scriptPath]) {
				NSTask *task = [[NSTask alloc] init];
				task.launchPath = @"/usr/bin/python3";
				task.arguments = @[scriptPath, userDefaultsValuesPath, @"json"];
				
				NSPipe *pipe = [NSPipe pipe];
				task.standardOutput = pipe;
				task.standardError = [NSPipe pipe];
				
				@try {
					[task launch];
					[task waitUntilExit];
					
					if (task.terminationStatus == 0) {
						NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
						NSError *jsonError;
						userDefaultsValuesDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
						if (jsonError) {
							NSLog(@"Failed to parse YAML-converted JSON: %@", jsonError.localizedDescription);
							userDefaultsValuesDict = nil;
						}
					} else {
						NSData *errorData = [[[task standardError] fileHandleForReading] readDataToEndOfFile];
						NSString *errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
						NSLog(@"YAML conversion failed: %@", errorString);
					}
				} @catch (NSException *exception) {
					NSLog(@"Exception during YAML conversion: %@", exception.reason);
				}
			}
		}
		
		// Fall back to plist if YAML loading failed
		if (!userDefaultsValuesDict) {
			userDefaultsValuesPath = [[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
			if (userDefaultsValuesPath) {
				NSLog(@"Loading user defaults from plist: %@", userDefaultsValuesPath);
				userDefaultsValuesDict = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
			}
		}
		
		// set them in the standard user defaults
		if (userDefaultsValuesDict) {
			[[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];
		} else {
			NSLog(@"Warning: Could not load user defaults from any source");
		}
	}
	
    return NSApplicationMain(argc,  (const char **) argv);
}
