#import "_ItemToCopyMO.h"

@interface ItemToCopyMO : _ItemToCopyMO {}

@property (weak, readonly) NSString *contentsDescription;
@property (weak, readonly) NSString *titleDescription;
@property (weak, readonly) NSImage *image;
@property (weak, readonly) NSDictionary *dictValue;
@property (weak, readonly) NSDictionary *dictValueForSave;

@end
