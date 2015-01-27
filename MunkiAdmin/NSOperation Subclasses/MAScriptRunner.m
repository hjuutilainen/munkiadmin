//
//  MAScriptRunner.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 27.1.2015.
//
//

#import "MAScriptRunner.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

@interface MAScriptRunner ()
// Private interface
@end

@implementation MAScriptRunner

+ (id)scriptWithPath:(NSString *)launchPath
{
    return [[self alloc] initWithLaunchPath:launchPath arguments:nil standardInput:nil];
}

- (id)initWithLaunchPath:(NSString *)launchPath arguments:(NSArray *)arguments standardInput:(NSString *)standardInput
{
    if ((self = [super init])) {
        DDLogVerbose(@"Initializing MAScriptRunner...");
        _launchPath = launchPath;
        _arguments = arguments;
        _standardInput = standardInput;
    }
    return self;
}

- (void)runTask
{
    DDLogDebug(@"Running %@ with arguments: %@", self.launchPath, self.arguments);
    
    /*
     Construct the task
     */
    NSTask *task = [[NSTask alloc] init];
    NSPipe *standardOutputPipe = [NSPipe pipe];
    NSPipe *standardErrorPipe = [NSPipe pipe];
    NSFileHandle *filehandle = [standardOutputPipe fileHandleForReading];
    NSFileHandle *errorfilehandle = [standardErrorPipe fileHandleForReading];
    task.launchPath = self.launchPath;
    task.arguments = self.arguments;
    task.currentDirectoryPath = self.currentDirectoryPath;
    task.standardOutput = standardOutputPipe;
    task.standardError = standardErrorPipe;
    
    NSFileHandle *inputFileHandle;
    if (self.standardInput) {
        NSPipe *standardInputPipe = [NSPipe pipe];
        inputFileHandle = [standardInputPipe fileHandleForWriting];
        task.standardInput = standardInputPipe;
    }
    
    /*
     Run the task
     */
    [task launch];
    
    
    if (self.standardInput) {
        [inputFileHandle writeData:[self.standardInput dataUsingEncoding:NSUTF8StringEncoding]];
        [inputFileHandle closeFile];
    }
    
    [task waitUntilExit];
    
    self.terminationStatus = [task terminationStatus];
    
    if ([task terminationStatus] != 0) {
        /*
         Task failed, check if we got anything in stderr
         */
        NSData *taskErrorData = [errorfilehandle readDataToEndOfFile];
        NSString *errorString = [[NSString alloc] initWithData:taskErrorData encoding:NSUTF8StringEncoding];
        self.standardError = errorString;
        if (![errorString isEqualToString:@""]) {
            DDLogDebug(@"Task failed with error:\n%@", errorString);
        } else {
            DDLogDebug(@"Task failed...");
        }
    } else {
        /*
         Task finished, read the output
         */
        NSData *taskOutputData = [filehandle readDataToEndOfFile];
        NSString *taskOutputAsString = [[NSString alloc] initWithData:taskOutputData encoding:NSUTF8StringEncoding];
        self.standardOutput = taskOutputAsString;
    }
}

- (void)main
{
    DDLogVerbose(@"MAScriptRunner starting...");
    
    if (self.willStartCallback) {
        DDLogVerbose(@"MAScriptRunner running didFinishCallback...");
        self.willStartCallback();
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.launchPath]) {
        [self runTask];
    } else {
        DDLogVerbose(@"File not found: %@", self.launchPath);
    }
    
    if (self.progressCallback) {
        self.progressCallback(1.0, @"");
    }
    
    if (self.didFinishCallback) {
        DDLogVerbose(@"MAScriptRunner running didFinishCallback...");
        self.didFinishCallback();
    }
}

@end
