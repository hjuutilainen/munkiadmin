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
}

@property (readonly) BOOL makepkginfoInstalled;
@property (readonly) BOOL makecatalogsInstalled;

+ (MunkiRepositoryManager *)sharedManager;
- (void)writePackagePropertyListsToDisk;
- (void)writeManifestPropertyListsToDisk;
- (NSArray *)allObjectsForEntity:(NSString *)entityName;

- (CatalogMO *)newCatalogWithTitle:(NSString *)title;
- (ManifestMO *)newManifestWithTitle:(NSString *)title;

@end
