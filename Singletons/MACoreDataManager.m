//
//  MACoreDataManager.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 16.5.2013.
//
//

#import "MACoreDataManager.h"
#import "MunkiRepositoryManager.h"
#import "DataModelHeaders.h"

@implementation MACoreDataManager

# pragma mark -
# pragma mark Creating new objects

- (DirectoryMO *)directoryWithURL:(NSURL *)anURL managedObjectContext:(NSManagedObjectContext *)moc
{
    if (!anURL || !moc) {
        return nil;
    }
    
    DirectoryMO *directory = nil;
    NSFetchRequest *checkForExisting = [[NSFetchRequest alloc] init];
    [checkForExisting setEntity:[NSEntityDescription entityForName:@"Directory" inManagedObjectContext:moc]];
    NSPredicate *parentPredicate = [NSPredicate predicateWithFormat:@"originalURL == %@", anURL];
    [checkForExisting setPredicate:parentPredicate];
    NSUInteger foundItems = [moc countForFetchRequest:checkForExisting error:nil];
    if (foundItems == 0) {
        directory = [NSEntityDescription insertNewObjectForEntityForName:@"Directory" inManagedObjectContext:moc];
        directory.originalURL = anURL;
    } else {
        directory = [[moc executeFetchRequest:checkForExisting error:nil] objectAtIndex:0];
    }
    [checkForExisting release];
    return directory;
}


# pragma mark -
# pragma mark Singleton methods

static MACoreDataManager *sharedOperationManager = nil;
static dispatch_queue_t serialQueue;

+ (id)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceQueue;
    
    dispatch_once(&onceQueue, ^{
        serialQueue = dispatch_queue_create("MunkiAdmin.CoreDataManager.SerialQueue", NULL);
        if (sharedOperationManager == nil) {
            sharedOperationManager = [super allocWithZone:zone];
        }
    });
    
    return sharedOperationManager;
}

+ (MACoreDataManager *)sharedManager {
    static dispatch_once_t onceQueue;
    
    dispatch_once(&onceQueue, ^{
        sharedOperationManager = [[MACoreDataManager alloc] init];
    });
    
    return sharedOperationManager;
}

- (id)init {
    id __block obj;
    
    dispatch_sync(serialQueue, ^{
        obj = [super init];
        if (obj) {
            
        }
    });
    
    self = obj;
    return self;
}


@end
