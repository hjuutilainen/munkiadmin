#import "_ApplicationMO.h"

@interface ApplicationMO : _ApplicationMO {
    
}

@property (weak, readonly) NSDictionary *dictValue;
@property (readonly) BOOL hasCommonDescription;

- (void)updateLatestPackage;

@end
