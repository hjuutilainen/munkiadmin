//
//  FileCopyOperation.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 27.10.2011.
//

#import "MAFileCopyOperation.h"
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
            NSError *copyError = nil;
            
            DDLogDebug(@"Copying %@ to %@", self.fileName, [self.targetURL relativePath]);
            
            if ([fm copyItemAtURL:self.sourceURL toURL:self.targetURL error:&copyError]) {
                DDLogVerbose(@"Done copying");
            } else {
                DDLogError(@"Copy failed with error: %@",[copyError description]);
            }
            
		}
	}
	@catch(...) {
		// Do not rethrow exceptions.
	}
}

@end
