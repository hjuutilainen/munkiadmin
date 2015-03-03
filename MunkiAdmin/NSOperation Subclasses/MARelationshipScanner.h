//
//  RelationshipScanner.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 1.11.2011.
//

#import <Cocoa/Cocoa.h>

@interface MARelationshipScanner : NSOperation {
    
}

+ (id)pkginfoScanner;
+ (id)manifestScanner;
- (id)initWithMode:(NSInteger)mode;

@property (nonatomic, copy) void (^progressCallback) (float);
@property (nonatomic, copy) void (^finishCallback) ();
@property NSInteger operationMode;
@property (strong) NSString *currentJobDescription;
@property (strong) NSString *fileName;
@property (weak) id delegate;
@property (strong) NSArray *allApplications;
@property (strong) NSArray *allPackages;
@property (strong) NSArray *allCatalogs;
@property (strong) NSArray *allManifests;

@end
