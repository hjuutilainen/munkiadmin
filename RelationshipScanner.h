//
//  RelationshipScanner.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 1.11.2011.
//

#import <Cocoa/Cocoa.h>

@interface RelationshipScanner : NSOperation {
    NSString *currentJobDescription;
	NSString *fileName;
	id delegate;
    NSInteger operationMode;
    
    NSArray *allApplications;
    NSArray *allPackages;
    NSArray *allCatalogs;
    NSArray *allManifests;
}

+ (id)pkginfoScanner;
+ (id)manifestScanner;
- (id)initWithMode:(NSInteger)mode;

@property NSInteger operationMode;
@property (retain) NSString *currentJobDescription;
@property (retain) NSString *fileName;
@property (retain) id delegate;
@property (retain) NSArray *allApplications;
@property (retain) NSArray *allPackages;
@property (retain) NSArray *allCatalogs;
@property (retain) NSArray *allManifests;

@end
