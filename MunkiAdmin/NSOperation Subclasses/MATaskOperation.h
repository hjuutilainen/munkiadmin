//
//  MATaskOperation.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 23.5.2017.
//
//

#import <Foundation/Foundation.h>

@interface MATaskOperation : NSOperation {
    BOOL        executing;
    BOOL        finished;
}

@property (nonatomic, copy) void (^willStartCallback) ();
@property (nonatomic, copy) void (^progressCallback) (double progress, NSString *description);
@property (nonatomic, copy) void (^didFinishCallback) ();
@property (nonatomic, copy) void (^standardOutputCallback) (NSString *standardOutput);
@property (nonatomic, copy) void (^standardOutputDataCallback) (NSData *standardOutputData);
@property (nonatomic, copy) void (^standardErrorCallback) (NSString *standardError);
@property (nonatomic, copy) void (^standardErrorDataCallback) (NSData *standardErrorData);
@property (nonatomic, copy) void (^terminationCallback) (NSTask *task);

@property (strong) NSString *launchPath;
@property (strong) NSString *standardInput;
@property (strong) NSString *standardOutput;
@property (strong) NSString *standardError;
@property (strong) NSArray *arguments;
@property (strong) NSString *currentDirectoryPath;
@property (strong) NSDictionary *environment;
@property int terminationStatus;

- (void)completeOperation;

@end
