//
//  FileCopyOperation.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 27.10.2011.
//

#import <Cocoa/Cocoa.h>

@interface MAFileCopyOperation : NSOperation <NSFileManagerDelegate> {
    
}

+ (id)fileCopySourceURL:(NSURL *)src toTargetURL:(NSURL *)target;
- (id)initWithSourceURL:(NSURL *)src targetURL:(NSURL *)target;

@property (strong) NSString *currentJobDescription;
@property (strong) NSString *fileName;
@property (strong) NSURL *sourceURL;
@property (strong) NSURL *targetURL;
@property (weak) id delegate;


@end
