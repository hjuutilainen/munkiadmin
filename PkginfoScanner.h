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
	id delegate;
	NSDictionary *pkginfoKeyMappings;
	NSDictionary *receiptKeyMappings;
	NSDictionary *installsKeyMappings;
	NSDictionary *itemsToCopyKeyMappings;
}

- (id)initWithURL:(NSURL *)src;

@property (retain) NSString *currentJobDescription;
@property (retain) NSString *fileName;
@property (retain) NSURL *sourceURL;
@property (retain) id delegate;
@property (retain) NSDictionary *pkginfoKeyMappings;
@property (retain) NSDictionary *receiptKeyMappings;
@property (retain) NSDictionary *installsKeyMappings;
@property (retain) NSDictionary *itemsToCopyKeyMappings;


@end
