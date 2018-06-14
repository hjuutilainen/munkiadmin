//
//  MAPackageExtractOperation.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 3.6.2014.
//
//

#import <Foundation/Foundation.h>

@interface MAPackageExtractOperation : NSOperation

@property (nonatomic, copy) void (^ _Nullable willStartCallback) (void);
@property (nonatomic, copy) void (^ _Nullable progressCallback) (double progress, NSString * _Nonnull description);
@property (nonatomic, copy) void (^ _Nullable didExtractHandler) (NSURL * _Nonnull extractURL);
@property (nonatomic, copy) void (^ _Nullable didFinishCallback) (void);

+ (nullable id)extractOperationWithURL:(nonnull NSURL *)url;
- (nullable id)initWithURL:(nonnull NSURL *)url;

@end
