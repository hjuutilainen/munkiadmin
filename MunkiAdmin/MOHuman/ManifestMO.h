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
@property (readonly) NSNumber *includedManifestsCount;
@property (readonly) NSNumber *referencingManifestsCount;
@property (readonly) NSNumber *conditionsCount;

- (NSArray *)rootConditionalItems;

@end
