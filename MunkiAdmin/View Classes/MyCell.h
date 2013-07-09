#import <Cocoa/Cocoa.h>
#import "PackageMO.h"

@interface MyCell : NSTextFieldCell 
{
	NSMutableDictionary * aTitleAttributes;
	NSMutableDictionary * aSubtitleAttributes;
	
}

@property (retain) NSMutableDictionary * aTitleAttributes;
@property (retain) NSMutableDictionary * aSubtitleAttributes;

@end
