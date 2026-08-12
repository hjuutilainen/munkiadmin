//
//  NSDictionary+MAPlistValidation.h
//  MunkiAdmin
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (MAPlistValidation)

/*
 Returns the value for `key` if it exists and is an NSArray.

 pkginfo/manifest authors sometimes set an array-typed key (e.g.
 "supported_architectures" or "managed_installs") to a single string
 instead of a one-item array. If the value exists but isn't an array,
 this logs a warning identifying `context` (typically the file being
 scanned) and the key, and returns nil instead of the wrong-typed value.
 */
- (nullable NSArray *)ma_validatedArrayForKey:(NSString *)key context:(nullable NSString *)context;

/*
 Same as -ma_validatedArrayForKey:context: but for keys that should
 contain a dictionary (e.g. "preinstall_alert", "installer_environment").
 */
- (nullable NSDictionary *)ma_validatedDictionaryForKey:(NSString *)key context:(nullable NSString *)context;

@end

NS_ASSUME_NONNULL_END
