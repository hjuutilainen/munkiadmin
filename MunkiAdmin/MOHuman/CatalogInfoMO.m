#import "CatalogInfoMO.h"
#import "ManifestMO.h"

@implementation CatalogInfoMO

- (void)setIsEnabledForManifest:(NSNumber *)isEnabledForManifest
{
    [self willChangeValueForKey:@"isEnabledForManifest"];
    if (self.manifest) {
        [self.manifest willChangeValueForKey:@"catalogsDescriptionString"];
        [self.manifest willChangeValueForKey:@"catalogsCountDescriptionString"];
    }
    
    [self setPrimitiveValue:isEnabledForManifest forKey:@"isEnabledForManifest"];
    
    if (self.manifest) {
        [self.manifest didChangeValueForKey:@"catalogsDescriptionString"];
        [self.manifest didChangeValueForKey:@"catalogsCountDescriptionString"];
    }
    [self didChangeValueForKey:@"isEnabledForManifest"];
}

- (void)setIndexInManifest:(NSNumber *)indexInManifest
{
    [self willChangeValueForKey:@"indexInManifest"];
    if (self.manifest) {
        [self.manifest willChangeValueForKey:@"catalogsDescriptionString"];
        [self.manifest willChangeValueForKey:@"catalogsCountDescriptionString"];
    }
    
    [self setPrimitiveValue:indexInManifest forKey:@"indexInManifest"];
    
    if (self.manifest) {
        [self.manifest didChangeValueForKey:@"catalogsDescriptionString"];
        [self.manifest didChangeValueForKey:@"catalogsCountDescriptionString"];
    }
    [self didChangeValueForKey:@"indexInManifest"];
}

@end
