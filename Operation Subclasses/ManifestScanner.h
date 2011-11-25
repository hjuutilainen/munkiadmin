//
//  ManifestScanner.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 6.10.2010.
//

#import <Cocoa/Cocoa.h>
#import "ManifestMO.h"
#import "ManifestInfoMO.h"

@interface ManifestScanner : NSOperation {
	
	NSString *currentJobDescription;
	NSString *fileName;
	NSURL *sourceURL;
	id delegate;
	NSDictionary *pkginfoKeyMappings;
	NSDictionary *receiptKeyMappings;
	NSDictionary *installsKeyMappings;
    
    NSArray *apps;
    NSArray *packages;
}

- (id)initWithURL:(NSURL *)src;

@property (retain) NSString *currentJobDescription;
@property (retain) NSString *fileName;
@property (retain) NSURL *sourceURL;
@property (retain) id delegate;
@property (retain) NSDictionary *pkginfoKeyMappings;
@property (retain) NSDictionary *receiptKeyMappings;
@property (retain) NSDictionary *installsKeyMappings;


@end
