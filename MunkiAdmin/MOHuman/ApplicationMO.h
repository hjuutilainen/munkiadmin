#import "_ApplicationMO.h"

@interface ApplicationMO : _ApplicationMO {
	NSDictionary *dictValue;
	BOOL hasCommonDescription;
}

@property (readonly) NSDictionary *dictValue;
@property (readonly) BOOL hasCommonDescription;

@end
