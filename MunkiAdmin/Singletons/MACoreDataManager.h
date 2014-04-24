//
//  MACoreDataManager.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 16.5.2013.
//
//

#import <Cocoa/Cocoa.h>

@class DirectoryMO;
@class CatalogMO;
@class ManifestMO;
@class InstallsItemMO;
@class CategoryMO;
@class DeveloperMO;

@interface MACoreDataManager : NSObject {
    
}

+ (MACoreDataManager *)sharedManager;

- (InstallsItemMO *)createInstallsItemFromDictionary:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)moc;
- (DirectoryMO *)directoryWithURL:(NSURL *)anURL managedObjectContext:(NSManagedObjectContext *)moc;
- (CatalogMO *)createCatalogWithTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)moc;
- (ManifestMO *)createManifestWithURL:(NSURL *)fileURL inManagedObjectContext:(NSManagedObjectContext *)moc;
- (ManifestMO *)createManifestWithTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)moc;
- (CategoryMO *)createCategoryWithTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)moc;
- (BOOL)renameCategory:(CategoryMO *)category newTitle:(NSString *)newTitle inManagedObjectContext:(NSManagedObjectContext *)moc;
- (DeveloperMO *)createDeveloperWithTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)moc;
- (BOOL)renameDeveloper:(DeveloperMO *)developer newTitle:(NSString *)newTitle inManagedObjectContext:(NSManagedObjectContext *)moc;
- (NSArray *)allObjectsForEntity:(NSString *)entityName inManagedObjectContext:(NSManagedObjectContext *)moc;

@end
