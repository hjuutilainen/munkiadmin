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
@class IconImageMO;

@interface MAMunkiRepositoryManager : NSObject {
    
}

@property (readonly) BOOL makepkginfoInstalled;
@property (readonly) BOOL makecatalogsInstalled;
@property (readonly) BOOL repositoryHasPreSaveScript;
@property (readonly) BOOL repositoryHasPostSaveScript;
@property (readonly) BOOL repositoryHasPreOpenScript;
@property (readonly) BOOL repositoryHasPostOpenScript;
@property (readonly) BOOL repositoryHasPkginfoPreSaveScript;
@property (readonly) BOOL repositoryHasPkginfoPostSaveScript;
@property (readonly) BOOL repositoryHasManifestPreSaveScript;
@property (readonly) BOOL repositoryHasManifestPostSaveScript;
@property NSUInteger lengthForUniqueCatalogTitles;
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
@property (strong) NSOperationQueue *diskImageQueue;
@property BOOL makecatalogsRunNeeded;

+ (MAMunkiRepositoryManager *)sharedManager;

- (BOOL)movePackage:(PackageMO *)aPackage toURL:(NSURL *)targetURL moveInstaller:(BOOL)moveInstaller;
- (void)copyInstallerEnvironmentVariablesFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)copyInstallerChoicesFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)copyInstallsItemsFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)copyItemsToCopyItemsFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)copyCategoryFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)copyDeveloperFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)copyIconNameFrom:(PackageMO *)source target:(PackageMO *)target inManagedObjectContext:(NSManagedObjectContext *)moc;

- (BOOL)duplicateManifest:(ManifestMO *)manifest;
- (BOOL)duplicateManifest:(ManifestMO *)manifest toURL:(NSURL *)newURL;
- (void)moveManifest:(ManifestMO *)manifest toURL:(NSURL *)newURL cascade:(BOOL)shouldCascade;
- (NSDictionary *)referencingItemsForPackage:(PackageMO *)aPackage;

- (void)removeManifest:(ManifestMO *)aManifest
        withReferences:(BOOL)removeReferences;

- (void)removePackages:(NSArray *)packages
     withInstallerItem:(BOOL)removeInstallerItem
        withReferences:(BOOL)removeReferences;

- (void)renamePackage:(PackageMO *)aPackage
              newName:(NSString *)newName
              cascade:(BOOL)shouldCascade;

- (IconImageMO *)createIconImageFromURL:(NSURL *)url managedObjectContext:(NSManagedObjectContext *)moc;
- (void)updateIconForPackage:(PackageMO *)currentPackage;
- (NSString *)calculateSHA256HashForURL:(NSURL *)url;
- (NSString *)calculateSHA256HashForData:(NSData *)data;
- (void)deleteIconHashForPackage:(PackageMO *)package;
- (void)updateIconHashForPackage:(PackageMO *)package;
- (void)clearCustomIconForPackage:(PackageMO *)package;
- (void)setIconNameFromURL:(NSURL *)iconURL forPackage:(PackageMO *)package;
- (void)scanIconsDirectoryForImages;

- (void)iconSuggestionsForPackage:(PackageMO *)package
                completionHandler:(void (^)(NSArray *images))completionHandler
                  progressHandler:(void (^)(double progress, NSString *description))progressHandler;

- (void)writeRepositoryChangesToDisk:(BOOL *)success didWritePkginfos:(BOOL *)pkginfos didWriteManifests:(BOOL *)manifests;
- (BOOL)writePackagePropertyListsToDisk:(BOOL *)wroteToDisk;
- (BOOL)writeManifestPropertyListsToDisk:(BOOL *)wroteToDisk;
- (BOOL)backupPackage:(PackageMO *)aPackage;
- (BOOL)backupManifest:(ManifestMO *)aManifest;
- (NSArray *)allObjectsForEntity:(NSString *)entityName;

- (void)assimilatePackage:(PackageMO *)targetPackage
            sourcePackage:(PackageMO *)sourcePackage
                     keys:(NSArray *)munkiKeys;
- (void)assimilatePackageWithPreviousVersion:(PackageMO *)targetPackage keys:(NSArray *)munkiKeys;

- (NSSet *)modifiedManifestsSinceLastSave;
- (NSSet *)modifiedPackagesSinceLastSave;
- (BOOL)repositoryHasUnstagedChanges;
- (void)updateMunkiVersions;
- (BOOL)canImportURL:(NSURL *)fileURL error:(NSError **)error;
- (NSString *)relativePathToChildURL:(NSURL *)childURL parentURL:(NSURL *)parentURL;
- (BOOL)setPermissions:(NSString *)octalAsString forURL:(NSURL *)url;
- (void)updateUniqueCatalogStringLength;

@end
