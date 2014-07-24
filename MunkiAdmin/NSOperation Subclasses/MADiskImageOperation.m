//
//  MADiskImageOperation.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 29.5.2014.
//
//

#import "MADiskImageOperation.h"

@interface MADiskImageOperation ()
// Private interface
@property (strong) NSURL *diskImageURL;
@property (strong) NSArray *mountpoints;
@property (strong) NSDictionary *diskImageInfo;
@property (strong) NSDictionary *hdiutilInfo;
@end

@implementation MADiskImageOperation

+ (id)attachOperationWithURL:(NSURL *)url
{
    return [[self alloc] initWithURL:url operationType:MADiskImageOperationTypeAttach];
}

+ (id)detachOperationWithMountpoints:(NSArray *)mountpointPaths
{
    return [[self alloc] initWithMountpoints:mountpointPaths operationType:MADiskImageOperationTypeDetach];
}

- (id)initWithMountpoints:(NSArray *)mountpointPaths operationType:(MADiskImageOperationType)type
{
    if ((self = [super init])) {
		_diskImageURL = nil;
        _leaveMounted = NO;
        _operationType = type;
        _mountpoints = mountpointPaths;
	}
	return self;
}

- (id)initWithURL:(NSURL *)url operationType:(MADiskImageOperationType)type
{
    if ((self = [super init])) {
		_diskImageURL = url;
        _leaveMounted = NO;
        _operationType = type;
        _mountpoints = nil;
	}
	return self;
}

- (BOOL)detach
{
    BOOL succeeded = NO;
    
    /*
     Run hdiutil
     */
    if (!self.mountpoints) {
        return NO;
    }
    NSArray *arguments = @[@"detach", self.mountpoints[0]];
    NSData *outputData = [self hdiutilTaskWithArguments:arguments standardInput:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    /*
     If the task failed, try again with -force argument
     */
    if (outputData == nil) {
        
        if ([defaults boolForKey:@"debug"]) {
            NSLog(@"Detach failed, retrying with -force...");
        }
        arguments = @[@"detach", self.mountpoints[0], @"-force"];
        NSData *outputDataFromForced = [self hdiutilTaskWithArguments:arguments standardInput:nil];
        if (outputDataFromForced == nil) {
            succeeded = NO;
        } else {
            succeeded = YES;
        }
    }
    
    /*
     The task succeeded
     */
    else {
        NSString *outputString;
        outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        if (![outputString isEqualToString:@""] && [[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
            for (NSString *aLine in [outputString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
                NSLog(@"%@", aLine);
            }
        }
        succeeded = YES;
    }
    return succeeded;
}

- (BOOL)diskImageHasSLA
{
    if (!self.diskImageInfo) {
        self.diskImageInfo = [self imageinfo];
    }
    NSDictionary *properties = self.diskImageInfo[@"Properties"];
    NSNumber *hasSLA = properties[@"Software License Agreement"];
    if (hasSLA) {
        return [hasSLA boolValue];
    } else {
        return NO;
    }
}

- (BOOL)diskImageIsMounted
{
    if (!self.hdiutilInfo) {
        self.hdiutilInfo = [self info];
    }
    
    for (NSDictionary *imageProperties in self.hdiutilInfo[@"images"]) {
        NSString *imagePath = imageProperties[@"image-path"];
        if ([imagePath isEqualToString:[self.diskImageURL path]]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)mountpointsForDiskImage
{
    if (!self.hdiutilInfo) {
        self.hdiutilInfo = [self info];
    }
    
    NSMutableArray *dmgMountpoints = [NSMutableArray new];
    for (NSDictionary *imageProperties in self.hdiutilInfo[@"images"]) {
        NSString *imagePath = imageProperties[@"image-path"];
        if ([imagePath isEqualToString:[self.diskImageURL path]]) {
            for (NSDictionary *systemEntity in imageProperties[@"system-entities"]) {
                NSString *mountpoint = systemEntity[@"mount-point"];
                if (mountpoint) {
                    [dmgMountpoints addObject:mountpoint];
                }
            }
        }
    }
    return [NSArray arrayWithArray:dmgMountpoints];
}

- (NSDictionary *)attach
{
    /*
     Make sure a cache directory exists
     */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *cacheDirectory = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask][0];
    NSURL *munkiAdminCacheURL = [cacheDirectory URLByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
    if (![fileManager fileExistsAtPath:[munkiAdminCacheURL path]]) {
        [fileManager createDirectoryAtURL:munkiAdminCacheURL withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    /*
     Run hdiutil
     */
    NSString *dmgPath = [self.diskImageURL path];
    NSString *cachePath = [munkiAdminCacheURL path];
    NSArray *arguments = @[@"attach", dmgPath, @"-mountRandom", cachePath, @"-nobrowse", @"-plist"];
    NSData *outputData;
    if ([self diskImageHasSLA]) {
        outputData = [self hdiutilTaskWithArguments:arguments standardInput:@"Y\n"];
    } else {
        outputData = [self hdiutilTaskWithArguments:arguments standardInput:nil];
    }
    NSDictionary *outputDict = [self dictionaryFromData:outputData];
    return outputDict;
}


- (NSDictionary *)info
{
    NSArray *arguments = @[@"info", @"-plist"];
    NSData *outputData = [self hdiutilTaskWithArguments:arguments standardInput:nil];
    NSDictionary *outputDict = [self dictionaryFromData:outputData];
    return outputDict;
}


- (NSDictionary *)imageinfo
{
    NSString *dmgPath = [self.diskImageURL path];
    NSArray *arguments = @[@"imageinfo", dmgPath, @"-plist"];
    NSData *outputData = [self hdiutilTaskWithArguments:arguments standardInput:nil];
    NSDictionary *outputDict = [self dictionaryFromData:outputData];
    return outputDict;
}


- (NSData *)firstPropertyListInData:(NSData *)data
{
    if (!data) {
        return nil;
    }
    NSString *dataAsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSScanner *scanner = [NSScanner scannerWithString:dataAsString];
    
    NSString *scanned;
    [scanner scanUpToString:@"<?xml" intoString:nil];
    if (![scanner scanUpToString:@"</plist>" intoString:&scanned]) {
        return nil;
    }
    
    NSString *fullDictionaryAsString = [scanned stringByAppendingString:@"</plist>"];
    NSData *dictionaryAsData = [fullDictionaryAsString dataUsingEncoding:NSUTF8StringEncoding];
    return dictionaryAsData;
}


- (NSDictionary *)dictionaryFromData:(NSData *)data
{
    if (!data) {
        return nil;
    }
    
    NSData *firstPropertyList = [self firstPropertyListInData:data];
    if (!firstPropertyList) {
        return nil;
    }
    
    NSError *error;
    NSPropertyListFormat format;
    id plist;
    plist = [NSPropertyListSerialization propertyListWithData:firstPropertyList options:NSPropertyListImmutable format:&format error:&error];
    
    if (!plist) {
        NSLog(@"NSPropertyListSerialization error: %@", [error description]);
        return nil;
    } else {
        return (NSDictionary *)plist;
    }
}

- (id)hdiutilTaskWithArguments:(NSArray *)arguments standardInput:(NSString *)inputString
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"debug"]) {
        NSLog(@"Running hdiutil task with arguments: %@", arguments);
    }
    
    /*
     Construct the task
     */
    NSTask *task = [[NSTask alloc] init];
	NSPipe *standardOutputPipe = [NSPipe pipe];
    NSPipe *standardErrorPipe = [NSPipe pipe];
	NSFileHandle *filehandle = [standardOutputPipe fileHandleForReading];
    NSFileHandle *errorfilehandle = [standardErrorPipe fileHandleForReading];
    task.launchPath = @"/usr/bin/hdiutil";
    task.arguments = arguments;
    task.standardOutput = standardOutputPipe;
    task.standardError = standardErrorPipe;
    
    NSFileHandle *inputFileHandle;
    if (inputString) {
        NSPipe *standardInputPipe = [NSPipe pipe];
        inputFileHandle = [standardInputPipe fileHandleForWriting];
        task.standardInput = standardInputPipe;
    }
    
    /*
     Run the task
     */
	[task launch];
    
    
    if (inputString) {
        [inputFileHandle writeData:[inputString dataUsingEncoding:NSUTF8StringEncoding]];
        [inputFileHandle closeFile];
    }
    
    [task waitUntilExit];
    
    if ([task terminationStatus] != 0) {
        /*
         hdiutil failed, check if we got anything in stderr
         */
        NSData *taskErrorData = [errorfilehandle readDataToEndOfFile];
        NSString *errorString;
        errorString = [[NSString alloc] initWithData:taskErrorData encoding:NSUTF8StringEncoding];
        if (![errorString isEqualToString:@""]) {
            NSLog(@"Task failed with error:\n%@", errorString);
            return nil;
        } else {
            NSLog(@"Task failed...");
            return nil;
        }
    } else {
        /*
         hdiutil finished, return the output as is
         */
        NSData *taskOutputData = [filehandle readDataToEndOfFile];
        return taskOutputData;
    }
    
    return nil;
}


- (void)main
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"debug"]) {
        NSLog(@"MADiskImageOperation starting...");
    }
    
    if (self.willStartCallback) {
        self.willStartCallback();
    }
    
    if (self.progressCallback) {
        self.progressCallback(0.1, @"Starting...");
    }
    
    /*
     Attach operation
     */
    if (self.operationType == MADiskImageOperationTypeAttach) {
        
        if ([defaults boolForKey:@"debug"]) {
            NSLog(@"MADiskImageOperation type is MADiskImageOperationTypeAttach");
        }
        
        if (self.progressCallback) {
            self.progressCallback(0.2, @"Getting disk image info...");
        }
        
        // Get the image properties
        self.diskImageInfo = [self diskImageInfo];
        self.hdiutilInfo = [self hdiutilInfo];
        
        BOOL alreadyMounted = NO;
        if ([self diskImageIsMounted]) {
            self.mountpoints = [self mountpointsForDiskImage];
            alreadyMounted = YES;
        } else {
            if (self.progressCallback) {
                self.progressCallback(0.4, @"Mounting disk image...");
            }
            // Attach the image
            NSDictionary *plist = [self attach];
            
            // Get mount points from the attach task output
            NSMutableArray *mountpoints = [NSMutableArray new];
            for (id systemEntity in plist[@"system-entities"]) {
                if (systemEntity[@"mount-point"]) {
                    [mountpoints addObject:systemEntity[@"mount-point"]];
                }
            }
            self.mountpoints = [NSArray arrayWithArray:mountpoints];
        }
        
        if (self.progressCallback) {
            self.progressCallback(0.6, @"Processing mounts...");
        }
        if (self.didMountHandler) {
            self.didMountHandler(self.mountpoints, alreadyMounted);
        }
    }
    
    /*
     Detach operation
     */
    else if (self.operationType == MADiskImageOperationTypeDetach) {
        if ([defaults boolForKey:@"debug"]) {
            NSLog(@"MADiskImageOperation type is MADiskImageOperationTypeDetach");
        }
        if (self.mountpoints) {
            if (self.progressCallback) {
                self.progressCallback(0.4, @"Ejecting disk image...");
            }
            if (![self detach]) {
                NSLog(@"Detaching %@ failed...", self.mountpoints[0]);
            }
        } else {
            NSLog(@"No mountpoints to detach...");
        }
    }
    
    /*
     Image info operation
     */
    else if (self.operationType == MADiskImageOperationTypeImageInfo) {
        if ([defaults boolForKey:@"debug"]) {
            NSLog(@"MADiskImageOperation type is MADiskImageOperationTypeImageInfo");
        }
        if ([defaults boolForKey:@"debug"]) {
            NSLog(@"Type MADiskImageOperationTypeImageInfo not yet implemented");
        }
        // TODO
    }
    
    if (self.progressCallback) {
        self.progressCallback(1.0, @"");
    }
    if ([defaults boolForKey:@"debug"]) {
        NSLog(@"MADiskImageOperation running didFinishCallback...");
    }
    if (self.didFinishCallback) {
        self.didFinishCallback();
    }
}


@end
