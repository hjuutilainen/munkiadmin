//
//  MATaskOperation.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 23.5.2017.
//
//

#import "MATaskOperation.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

@implementation MATaskOperation

- (id)init
{
    self = [super init];
    if (self) {
        executing = NO;
        finished = NO;
    }
    return self;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return executing;
}

- (BOOL)isFinished
{
    return finished;
}

- (void)start
{
    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main
{
    @try {
        
        // Do the main work of the operation here.
        
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = self.launchPath;
        
        NSMutableDictionary *defaultEnv = [[NSMutableDictionary alloc] initWithDictionary:[[NSProcessInfo processInfo] environment]];
        [defaultEnv setObject:@"YES" forKey:@"NSUnbufferedIO"] ;
        task.environment = defaultEnv;
        NSMutableArray *newArgs = [NSMutableArray new];
        if (self.arguments) {
            [newArgs addObjectsFromArray:self.arguments];
        }
        task.arguments = newArgs;
        DDLogDebug(@"Running %@ with arguments: %@", task.launchPath, task.arguments);
        
        
        __block NSMutableString *standardOutput = [NSMutableString new];
        __block NSMutableData *standardOutData = [NSMutableData new];
        task.standardOutput = [NSPipe pipe];
        [[task.standardOutput fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
            NSData *data = [file availableData];
            if (self.standardOutputDataCallback) {
                self.standardOutputDataCallback(data);
            }
            [standardOutData appendData:data];
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            DDLogVerbose(@"%@", string);
            [standardOutput appendString:string];
            if (self.standardOutputCallback) {
                self.standardOutputCallback(string);
            }
        }];
        
        __block NSMutableString *standardError = [[NSMutableString alloc] init];
        __block NSMutableData *standardErrorData = [NSMutableData new];
        task.standardError = [NSPipe pipe];
        [[task.standardError fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
            NSData *data = [file availableData];
            if (self.standardErrorDataCallback) {
                self.standardErrorDataCallback(data);
            }
            [standardErrorData appendData:data];
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            DDLogVerbose(@"%@", string);
            [standardError appendString:string];
            if (self.standardErrorCallback) {
                self.standardErrorCallback(string);
            }
        }];
        
        [task setTerminationHandler:^(NSTask *aTask) {
            
            [aTask.standardOutput fileHandleForReading].readabilityHandler = nil;
            [aTask.standardError fileHandleForReading].readabilityHandler = nil;
            
            int exitCode = aTask.terminationStatus;
            if (exitCode == 0) {
                DDLogDebug(@"%@ succeeded.", aTask.launchPath);
                
                if (standardError.length != 0) {
                    
                }
                
            } else {
                DDLogError(@"%@ exited with code %i", aTask.launchPath, exitCode);
            }
            
            if (self.terminationCallback) {
                self.terminationCallback(aTask);
            }
            
        }];
        
        [task launch];

        [self completeOperation];
    }
    @catch(...) {
        // Do not rethrow exceptions.
    }
}

- (void)completeOperation
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
