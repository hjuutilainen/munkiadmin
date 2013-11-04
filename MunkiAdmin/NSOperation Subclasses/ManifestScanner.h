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

@property (strong) NSString *currentJobDescription;
@property (strong) NSString *fileName;
@property (strong) NSURL *sourceURL;
@property (strong) id delegate;
@property (strong) NSDictionary *pkginfoKeyMappings;
@property (strong) NSDictionary *receiptKeyMappings;
@property (strong) NSDictionary *installsKeyMappings;


@end
