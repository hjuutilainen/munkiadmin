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
		NSDictionary *userDefaultsValuesDict;
		
		// load the default values for the user defaults
		userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
		userDefaultsValuesDict=[NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
		
		// set them in the standard user defaults
		[[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];
	}
	
    return NSApplicationMain(argc,  (const char **) argv);
}
