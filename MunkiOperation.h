//
//  MunkiOperation.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 7.10.2010.
//

#import <Cocoa/Cocoa.h>


@interface MunkiOperation : NSOperation {
	
	NSString *command;
	NSURL *targetURL;
	NSArray *arguments;
	id delegate;
}

+ (id)makecatalogsOperationWithTarget:(NSURL *)target;
- (id)initWithCommand:(NSString *)cmd targetURL:(NSURL *)target arguments:(NSArray *)args;

@property (retain) NSString *command;
@property (retain) NSURL *targetURL;
@property (retain) NSArray *arguments;
@property (retain) id delegate;

@end
