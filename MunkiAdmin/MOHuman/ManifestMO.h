#import "_ManifestMO.h"

@interface ManifestMO : _ManifestMO {}

@property (weak, readonly) NSString *manifestContentsDescription;
@property (weak, readonly) NSImage *image;
@property (weak, readonly) NSString *fileName;
@property (weak, readonly) NSDictionary *manifestInfoDictionary;
@property (readonly) NSString *catalogsDescriptionString;
@property (readonly) NSArray *catalogStrings;
@property (readonly) NSString *titleOrDisplayName;
@property (readonly) NSNumber *managedInstallsCount;
@property (readonly) NSNumber *managedUninstallsCount;
@property (readonly) NSNumber *managedUpdatesCount;
@property (readonly) NSNumber *optionalInstallsCount;
@property (readonly) NSNumber *defaultInstallsCount;
@property (readonly) NSNumber *featuredItemsCount;
@property (readonly) NSNumber *includedManifestsCount;
@property (readonly) NSNumber *referencingManifestsCount;
@property (readonly) NSNumber *conditionsCount;

// Cached count properties to avoid expensive fetched property queries
@property (strong, nonatomic) NSNumber *cachedManagedInstallsCount;
@property (strong, nonatomic) NSNumber *cachedManagedUninstallsCount;
@property (strong, nonatomic) NSNumber *cachedManagedUpdatesCount;
@property (strong, nonatomic) NSNumber *cachedOptionalInstallsCount;
@property (strong, nonatomic) NSNumber *cachedDefaultInstallsCount;
@property (strong, nonatomic) NSNumber *cachedFeaturedItemsCount;
@property (strong, nonatomic) NSNumber *cachedIncludedManifestsCount;
@property (strong, nonatomic) NSNumber *cachedReferencingManifestsCount;

- (NSArray *)rootConditionalItems;
- (void)invalidateCountCaches;

@end
