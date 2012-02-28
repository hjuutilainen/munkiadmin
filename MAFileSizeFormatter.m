//
//  MAFileSizeFormatter.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 28.2.2012.
//

#import "MAFileSizeFormatter.h"


@implementation MAFileSizeFormatter

BOOL leopardOrGreater(){
    static BOOL alreadyComputedOS = NO;
    static BOOL leopardOrGreater = NO;
    if (!alreadyComputedOS) {
        SInt32 majorVersion, minorVersion;
        Gestalt(gestaltSystemVersionMajor, &majorVersion);
        Gestalt(gestaltSystemVersionMinor, &minorVersion);
        leopardOrGreater = ((majorVersion == 10 && minorVersion >= 5) || majorVersion > 10);
        alreadyComputedOS = YES;
    }
    return leopardOrGreater;
}

enum {
    kUnitStringBinaryUnits     = 1 << 0,
    kUnitStringOSNativeUnits   = 1 << 1,
    kUnitStringLocalizedFormat = 1 << 2
};

- (NSString *)formatBytes:(float)bytes
{
	NSArray *suffix = [NSArray arrayWithObjects:@"B", @"KB", @"MB", @"GB", @"TB", nil];
	int i = 1;
	while(bytes > 1024)
	{
		bytes = bytes/1024.0;
		i++;
	}
	
	return [NSString stringWithFormat:@"%1.2f %@", bytes, [suffix objectAtIndex:i]];
}


- (NSString *)stringForObjectValue:(id)anObject {
    if (![anObject isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    
    float bytes = [anObject floatValue];
    NSArray *suffix = [NSArray arrayWithObjects:@"B", @"KB", @"MB", @"GB", @"TB", nil];
	int i = 1;
	while(bytes > 1024)
	{
		bytes = bytes/1024.0;
		i++;
	}
    
    NSNumberFormatter* formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setMaximumFractionDigits:1];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // Uses localized number formats.
    [formatter setAlwaysShowsDecimalSeparator:NO];
    
    NSString *sizeInUnits = [formatter stringFromNumber:[NSNumber numberWithFloat:bytes]];
    
    
	//return [NSString stringWithFormat:@"%1.2f %@", bytes, [suffix objectAtIndex:i]];
    return [NSString stringWithFormat:@"%@ %@", sizeInUnits, [suffix objectAtIndex:i]];
    
    /*
    NSLog(@"%@", [self formatBytes:[anObject floatValue]]);
    double bytes = [anObject doubleValue] * 1024;
    uint8_t flags = 0;
    
    static const char units[] = { '\0', 'k', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y' };
    static int maxUnits = sizeof units - 1;
    
    int multiplier = ((flags & kUnitStringOSNativeUnits && !leopardOrGreater()) || flags & kUnitStringBinaryUnits) ? 1024 : 1000;
    int exponent = 0;
    
    while (bytes >= multiplier && exponent < maxUnits) {
        bytes /= multiplier;
        exponent++;
    }
    NSNumberFormatter* formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setMaximumFractionDigits:2];
    if (flags & kUnitStringLocalizedFormat) {
        [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    }
    return [NSString stringWithFormat:@"%@ %cB", [formatter stringFromNumber: [NSNumber numberWithDouble: bytes]], units[exponent]];
     */
}

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString  **)error {
    /*
    float floatResult;
    NSScanner *scanner;
    BOOL returnValue = NO;
    
    scanner = [NSScanner scannerWithString: string];
    [scanner scanString: @"$" intoString: NULL];    //ignore  return value
    if ([scanner scanFloat:&floatResult] && ([scanner isAtEnd])) {
        returnValue = YES;
        if (obj)
            *obj = [NSNumber numberWithFloat:floatResult];
    } else {
        if (error)
            *error = NSLocalizedString(@"Couldn’t convert  to float", @"Error converting");
    }
    return returnValue;
     */
    return [super getObjectValue:obj forString:string errorDescription:error];
}


@end
