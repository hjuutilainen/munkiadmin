//
//  FileCopyOperation.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 27.10.2011.
//

#import <Cocoa/Cocoa.h>

@interface FileCopyOperation : NSOperation {
    NSString *currentJobDescription;
	NSString *fileName;
	NSURL *sourceURL;
    NSURL *targetURL;
	id delegate;
}

+ (id)fileCopySourceURL:(NSURL *)src toTargetURL:(NSURL *)target;
- (id)initWithSourceURL:(NSURL *)src targetURL:(NSURL *)target;

@property (strong) NSString *currentJobDescription;
@property (strong) NSString *fileName;
@property (strong) NSURL *sourceURL;
@property (strong) NSURL *targetURL;
@property (strong) id delegate;


@end
