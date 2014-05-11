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
    
}

@property (readonly) BOOL makepkginfoInstalled;
@property (readonly) BOOL makecatalogsInstalled;
@property (readonly, strong) NSString *makepkginfoVersion;
@property (readonly, strong) NSString *makecatalogsVersion;
@property (strong) NSDictionary *pkginfoBasicKeyMappings;
@property (strong) NSDictionary *pkginfoArrayKeyMappings;
@property (readonly, strong) NSArray *pkginfoAssimilateKeys;
@property (readonly, strong) NSArray *pkginfoAssimilateKeysForAuto;
@property (strong) NSDictionary *receiptKeyMappings;
@property (strong) NSDictionary *installsKeyMappings;
@property (strong) NSDictionary *installerChoicesKeyMappings;
@property (strong) NSDictionary *itemsToCopyKeyMappings;

+ (MunkiRepositoryManager *)sharedManager;

- (BOOL)movePackage:(PackageMO *)aPackage toURL:(NSURL *)targetURL moveInstaller:(BOOL)moveInstaller;
- (void)copyInstallerEnvironmentVariablesFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)copyInstallerChoicesFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)copyInstallsItemsFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)copyItemsToCopyItemsFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)copyCategoryFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)copyDeveloperFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc;

- (void)moveManifest:(ManifestMO *)manifest toURL:(NSURL *)newURL cascade:(BOOL)shouldCascade;
- (NSDictionary *)referencingItemsForPackage:(PackageMO *)aPackage;

- (void)removeManifest:(ManifestMO *)aManifest
        withReferences:(BOOL)removeReferences;

- (void)removePackage:(PackageMO *)aPackage
    withInstallerItem:(BOOL)removeInstallerItem
       withReferences:(BOOL)removeReferences;

- (void)renamePackage:(PackageMO *)aPackage
              newName:(NSString *)newName
              cascade:(BOOL)shouldCascade;

- (void)updateIconForPackage:(PackageMO *)currentPackage;
- (void)clearCustomIconForPackage:(PackageMO *)package;
- (void)setIconNameFromURL:(NSURL *)iconURL forPackage:(PackageMO *)package;
- (void)scanIconsDirectoryForImages;

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
- (NSString *)relativePathToChildURL:(NSURL *)childURL parentURL:(NSURL *)parentURL;

@end
