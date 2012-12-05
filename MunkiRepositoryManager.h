//
//  MunkiRepositoryManager.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 5.12.2012.
//
//

#import <Cocoa/Cocoa.h>

@interface MunkiRepositoryManager : NSObject {
    
}

+ (MunkiRepositoryManager *)sharedManager;
- (void)writePackagePropertyListsToDisk;
- (void)writeManifestPropertyListsToDisk;

@end
