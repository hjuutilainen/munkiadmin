//
//  MAScriptRunner.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 27.1.2015.
//
//

#import <Foundation/Foundation.h>

@interface MAScriptRunner : NSOperation

@property (nonatomic, copy) void (^willStartCallback) ();
@property (nonatomic, copy) void (^progressCallback) (double progress, NSString *description);
@property (nonatomic, copy) void (^didFinishCallback) ();

@property (strong) NSString *launchPath;
@property (strong) NSString *standardInput;
@property (strong) NSString *standardOutput;
@property (strong) NSString *standardError;
@property (strong) NSArray *arguments;
@property (strong) NSString *currentDirectoryPath;
@property (strong) NSDictionary *environment;
@property int terminationStatus;

+ (id)scriptWithPath:(NSString *)launchPath;
- (id)initWithLaunchPath:(NSString *)launchPath arguments:(NSArray *)arguments standardInput:(NSString *)standardInput;


@end
