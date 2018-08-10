//
//  FileCopyOperation.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 27.10.2011.
//

#import "MAFileCopyOperation.h"
#import "MAMunkiRepositoryManager.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

@implementation MAFileCopyOperation

+ (id)fileCopySourceURL:(NSURL *)src toTargetURL:(NSURL *)target
{
	return [[self alloc] initWithSourceURL:src targetURL:target];
}

- (id)initWithSourceURL:(NSURL *)src targetURL:(NSURL *)target {
	if ((self = [super init])) {
		DDLogVerbose(@"Initializing manifest operation");
		self.sourceURL = src;
        self.targetURL = target;
		self.fileName = [self.sourceURL lastPathComponent];
		self.currentJobDescription = @"Initializing copy operation";
		
	}
	return self;
}




-(void)main {
	@try {
		@autoreleasepool {
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm setDelegate:self];
            NSString *filename = [self.targetURL lastPathComponent];
            NSError *copyError = nil;
            
            DDLogDebug(@"Copying %@ to %@", self.fileName, [self.targetURL relativePath]);
            
            if ([fm copyItemAtURL:self.sourceURL toURL:self.targetURL error:&copyError]) {
                DDLogVerbose(@"%@: Done copying", filename);
                
                NSNumber *isDirectory;
                [self.targetURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
                if (![isDirectory boolValue]) {
                    /*
                     Check if we should use custom permissions
                     */
                    NSString *customPermissions = [[NSUserDefaults standardUserDefaults] stringForKey:@"installerItemFilePermissions"];
                    if (customPermissions) {
                        DDLogDebug(@"%@: Setting custom permissions to %@", filename, customPermissions);
                        if (![[MAMunkiRepositoryManager sharedManager] setPermissions:customPermissions forURL:self.targetURL]) {
                            DDLogError(@"%@: Failed to set permissions", filename);
                        }
                    }
                }
            } else {
                DDLogError(@"%@: Copy failed with error: %@", filename, [copyError description]);
            }
            [fm setDelegate:nil];
		}
	}
	@catch(...) {
		// Do not rethrow exceptions.
	}
}

@end
