//
//  MACoreDataManager.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 16.5.2013.
//
//

#import <Cocoa/Cocoa.h>

@class DirectoryMO;

@interface MACoreDataManager : NSObject {
    
}

+ (MACoreDataManager *)sharedManager;

- (DirectoryMO *)directoryWithURL:(NSURL *)anURL managedObjectContext:(NSManagedObjectContext *)moc;

@end
