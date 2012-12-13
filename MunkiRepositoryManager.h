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
    NSDictionary *pkginfoKeyMappings;
	NSDictionary *receiptKeyMappings;
	NSDictionary *installsKeyMappings;
    NSDictionary *installerChoicesKeyMappings;
	NSDictionary *itemsToCopyKeyMappings;
}

@property (readonly) BOOL makepkginfoInstalled;
@property (readonly) BOOL makecatalogsInstalled;
@property (retain) NSDictionary *pkginfoKeyMappings;
@property (retain) NSDictionary *receiptKeyMappings;
@property (retain) NSDictionary *installsKeyMappings;
@property (retain) NSDictionary *installerChoicesKeyMappings;
@property (retain) NSDictionary *itemsToCopyKeyMappings;

+ (MunkiRepositoryManager *)sharedManager;

- (void)renamePackage:(PackageMO *)aPackage
              newName:(NSString *)newName
              cascade:(BOOL)shouldCascade;

- (void)writePackagePropertyListsToDisk;
- (void)writeManifestPropertyListsToDisk;
- (NSArray *)allObjectsForEntity:(NSString *)entityName;

- (CatalogMO *)newCatalogWithTitle:(NSString *)title;
- (ManifestMO *)newManifestWithTitle:(NSString *)title;
- (void)assimilatePackage:(PackageMO *)targetPackage
            sourcePackage:(PackageMO *)sourcePackage
                     keys:(NSArray *)munkiKeys;
- (void)assimilatePackageWithPreviousVersion:(PackageMO *)targetPackage keys:(NSArray *)munkiKeys;

- (NSSet *)modifiedManifestsSinceLastSave;
- (NSSet *)modifiedPackagesSinceLastSave;

@end
