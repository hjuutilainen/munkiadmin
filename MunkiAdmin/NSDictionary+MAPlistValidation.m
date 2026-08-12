//
//  NSDictionary+MAPlistValidation.m
//  MunkiAdmin
//

#import "NSDictionary+MAPlistValidation.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

static NSString *MAHumanReadablePlistTypeName(id value)
{
    if ([value isKindOfClass:[NSString class]]) return @"a string";
    if ([value isKindOfClass:[NSArray class]]) return @"an array";
    if ([value isKindOfClass:[NSDictionary class]]) return @"a dictionary";
    if ([value isKindOfClass:[NSNumber class]]) return @"a number";
    if ([value isKindOfClass:[NSDate class]]) return @"a date";
    if ([value isKindOfClass:[NSData class]]) return @"data";
    return NSStringFromClass([value class]);
}

@implementation NSDictionary (MAPlistValidation)

- (nullable NSArray *)ma_validatedArrayForKey:(NSString *)key context:(nullable NSString *)context
{
    id value = self[key];
    if (value == nil) {
        return nil;
    }
    if (![value isKindOfClass:[NSArray class]]) {
        DDLogWarn(@"%@: '%@' should be an array, found %@ instead", context ?: @"(unknown)", key, MAHumanReadablePlistTypeName(value));
        return nil;
    }
    return value;
}

- (nullable NSDictionary *)ma_validatedDictionaryForKey:(NSString *)key context:(nullable NSString *)context
{
    id value = self[key];
    if (value == nil) {
        return nil;
    }
    if (![value isKindOfClass:[NSDictionary class]]) {
        DDLogWarn(@"%@: '%@' should be a dictionary, found %@ instead", context ?: @"(unknown)", key, MAHumanReadablePlistTypeName(value));
        return nil;
    }
    return value;
}

@end
