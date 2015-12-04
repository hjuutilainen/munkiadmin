//
//  ManifestScanner.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 6.10.2010.
//

#import <Cocoa/Cocoa.h>
#import "ManifestMO.h"
#import "ManifestInfoMO.h"

@interface MAManifestScanner : NSOperation {
    NSArray *apps;
    NSArray *packages;
}

- (id)initWithURL:(NSURL *)src;

@property (nonatomic, copy) void (^progressCallback) (float);
@property (nonatomic, copy) void (^finishCallback) ();
@property (strong) NSString *currentJobDescription;
@property (strong) NSString *fileName;
@property (strong) NSURL *sourceURL;
@property (weak) id delegate;
@property (strong) NSDictionary *pkginfoKeyMappings;
@property (strong) NSDictionary *receiptKeyMappings;
@property (strong) NSDictionary *installsKeyMappings;
@property (strong) ManifestMOID *manifestID;
@property BOOL performFullScan;


@end
