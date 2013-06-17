//
//  MunkiRepositoryManager.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 5.12.2012.
//
//

#import <Cocoa/Cocoa.h>

@class CatalogMO;
@class PackageMO;
@class ManifestMO;
@class InstallsItemMO;

@interface MunkiRepositoryManager : NSObject {
    BOOL makepkginfoInstalled;
    BOOL makecatalogsInstalled;
    NSString *makepkginfoVersion;
    NSString *makecatalogsVersion;
    NSDictionary *pkginfoBasicKeyMappings;
    NSDictionary *pkginfoArrayKeyMappings;
    NSArray *pkginfoAssimilateKeys;
    NSArray *pkginfoAssimilateKeysForAuto;
	NSDictionary *receiptKeyMappings;
	NSDictionary *installsKeyMappings;
    NSDictionary *installerChoicesKeyMappings;
	NSDictionary *itemsToCopyKeyMappings;
}

@property (readonly) BOOL makepkginfoInstalled;
@property (readonly) BOOL makecatalogsInstalled;
@property (readonly, retain) NSString *makepkginfoVersion;
@property (readonly, retain) NSString *makecatalogsVersion;
@property (retain) NSDictionary *pkginfoBasicKeyMappings;
@property (retain) NSDictionary *pkginfoArrayKeyMappings;
@property (readonly, retain) NSArray *pkginfoAssimilateKeys;
@property (readonly, retain) NSArray *pkginfoAssimilateKeysForAuto;
@property (retain) NSDictionary *receiptKeyMappings;
@property (retain) NSDictionary *installsKeyMappings;
@property (retain) NSDictionary *installerChoicesKeyMappings;
@property (retain) NSDictionary *itemsToCopyKeyMappings;

+ (MunkiRepositoryManager *)sharedManager;

- (BOOL)movePackage:(PackageMO *)aPackage toURL:(NSURL *)targetURL moveInstaller:(BOOL)moveInstaller;
- (void)copyInstallerEnvironmentVariablesFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)copyInstallerChoicesFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)copyInstallsItemsFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)copyItemsToCopyItemsFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc;

- (void)moveManifest:(ManifestMO *)manifest toURL:(NSURL *)newURL cascade:(BOOL)shouldCascade;
- (NSDictionary *)referencingItemsForPackage:(PackageMO *)aPackage;
- (void)renamePackage:(PackageMO *)aPackage
              newName:(NSString *)newName
              cascade:(BOOL)shouldCascade;

- (void)writePackagePropertyListsToDisk;
- (void)writeManifestPropertyListsToDisk;
- (NSArray *)allObjectsForEntity:(NSString *)entityName;

- (void)assimilatePackage:(PackageMO *)targetPackage
            sourcePackage:(PackageMO *)sourcePackage
                     keys:(NSArray *)munkiKeys;
- (void)assimilatePackageWithPreviousVersion:(PackageMO *)targetPackage keys:(NSArray *)munkiKeys;

- (NSSet *)modifiedManifestsSinceLastSave;
- (NSSet *)modifiedPackagesSinceLastSave;
- (void)updateMunkiVersions;
- (BOOL)canImportURL:(NSURL *)fileURL error:(NSError **)error;

@end
