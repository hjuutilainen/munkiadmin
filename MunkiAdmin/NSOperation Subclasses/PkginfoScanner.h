//
//  PkginfoScanner.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 5.10.2010.
//

#import <Cocoa/Cocoa.h>


@interface PkginfoScanner : NSOperation {
	
	NSString *currentJobDescription;
	NSString *fileName;
	NSURL *sourceURL;
	NSDictionary *sourceDict;
	id delegate;
	BOOL canModify;
}

+ (id)scannerWithURL:(NSURL *)url;
+ (id)scannerWithDictionary:(NSDictionary *)dict;
- (id)initWithURL:(NSURL *)src;
- (id)initWithDictionary:(NSDictionary *)dict;

@property (retain) NSString *currentJobDescription;
@property (retain) NSString *fileName;
@property (retain) NSURL *sourceURL;
@property (retain) NSDictionary *sourceDict;
@property (retain) id delegate;
@property BOOL canModify;

@end
