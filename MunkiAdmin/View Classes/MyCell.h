#import <Cocoa/Cocoa.h>
#import "PackageMO.h"

@interface MyCell : NSTextFieldCell 
{
	NSMutableDictionary * aTitleAttributes;
	NSMutableDictionary * aSubtitleAttributes;
	
}

@property (strong) NSMutableDictionary * aTitleAttributes;
@property (strong) NSMutableDictionary * aSubtitleAttributes;

@end
