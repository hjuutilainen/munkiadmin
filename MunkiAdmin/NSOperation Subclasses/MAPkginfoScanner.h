//
//  PkginfoScanner.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 5.10.2010.
//

#import <Cocoa/Cocoa.h>


@interface MAPkginfoScanner : NSOperation {
    
}

+ (id)scannerWithURL:(NSURL *)url;
+ (id)scannerWithDictionary:(NSDictionary *)dict;
- (id)initWithURL:(NSURL *)src;
- (id)initWithDictionary:(NSDictionary *)dict;

@property (strong) NSString *currentJobDescription;
@property (strong) NSString *fileName;
@property (strong) NSURL *sourceURL;
@property (strong) NSDictionary *sourceDict;
@property (weak) id delegate;
@property BOOL canModify;

@end
