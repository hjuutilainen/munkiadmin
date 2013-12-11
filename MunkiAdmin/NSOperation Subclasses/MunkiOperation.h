//
//  MunkiOperation.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 7.10.2010.
//

#import <Cocoa/Cocoa.h>


@interface MunkiOperation : NSOperation {
    
}

+ (id)makecatalogsOperationWithTarget:(NSURL *)target;
+ (id)makepkginfoOperationWithSource:(NSURL *)sourceFile;
+ (id)installsItemFromURL:(NSURL *)sourceFile;
+ (id)installsItemFromPath:(NSString *)pathToFile;
- (id)initWithCommand:(NSString *)cmd targetURL:(NSURL *)target arguments:(NSArray *)args;
- (NSUserDefaults *)defaults;

@property (strong) NSString *command;
@property (strong) NSURL *targetURL;
@property (strong) NSArray *arguments;
@property (weak) id delegate;

@end


@interface NSObject (MunkiOperationDelegate)

- (void)makepkginfoDidFinish:(NSDictionary *)pkginfoPlist;
- (void)installsItemDidFinish:(NSDictionary *)pkginfoPlist;

@end