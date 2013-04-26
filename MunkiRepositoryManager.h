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

- (NSDictionary *)referencingItemsForPackage:(PackageMO *)aPackage;
- (void)renamePackage:(PackageMO *)aPackage
              newName:(NSString *)newName
              cascade:(BOOL)shouldCascade;

- (void)writePackagePropertyListsToDisk;
- (void)writeManifestPropertyListsToDisk;
- (NSArray *)allObjectsForEntity:(NSString *)entityName;

- (CatalogMO *)newCatalogWithTitle:(NSString *)title;
- (ManifestMO *)newManifestWithTitle:(NSString *)title;
- (ManifestMO *)newManifestWithURL:(NSURL *)fileURL;
- (void)assimilatePackage:(PackageMO *)targetPackage
            sourcePackage:(PackageMO *)sourcePackage
                     keys:(NSArray *)munkiKeys;
- (void)assimilatePackageWithPreviousVersion:(PackageMO *)targetPackage keys:(NSArray *)munkiKeys;

- (NSSet *)modifiedManifestsSinceLastSave;
- (NSSet *)modifiedPackagesSinceLastSave;
- (void)updateMunkiVersions;

@end
