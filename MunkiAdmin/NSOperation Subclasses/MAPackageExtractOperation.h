//
//  MAPackageExtractOperation.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 3.6.2014.
//
//

#import <Foundation/Foundation.h>

@interface MAPackageExtractOperation : NSOperation

@property (nonatomic, copy) void (^willStartCallback) ();
@property (nonatomic, copy) void (^progressCallback) (double progress, NSString *description);
@property (nonatomic, copy) void (^didExtractHandler) (NSURL *extractURL);
@property (nonatomic, copy) void (^didFinishCallback) ();

+ (id)extractOperationWithURL:(NSURL *)url;
- (id)initWithURL:(NSURL *)url;

@end
