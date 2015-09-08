#import "InstallsItemMO.h"
#import "InstallsItemCustomKeyMO.h"

@implementation InstallsItemMO

- (NSDictionary *)dictValue
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.munki_path, @"title",
			self.munki_type, @"subtitle",
			@"installsitem", @"type",
			nil];
}

- (NSImage *)iconImage
{
    NSWorkspace *wp = [NSWorkspace sharedWorkspace];
    return [wp iconForFile:self.munki_path];
}

- (BOOL)validateForUpdate:(NSError **)error
{
    BOOL propertiesValid = [super validateForUpdate:error];
    // could stop here if invalid
    BOOL consistencyValid = [self validateConsistency:error];
    return (propertiesValid && consistencyValid);
}

- (BOOL)validateConsistency:(NSError **)error
{
    BOOL valid = YES;
    
    NSString *currentType = self.munki_type;
    
    if (!currentType || [currentType isEqualToString:@""]) {
        valid = NO;
    } else {
        NSArray *supportedTypes = @[@"application", @"bundle", @"file", @"plist"];
        if ([supportedTypes containsObject:currentType]) {
            /*
             Every known installs item type must also have a path
             */
            if (self.munki_path == nil) {
                valid = NO;
                if (error != NULL) {
                    
                    NSString *errorReason = [NSString stringWithFormat:@"Installs item type \"%@\" requires a path.", currentType];
                    
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    [userInfo setObject:errorReason forKey:NSLocalizedFailureReasonErrorKey];
                    [userInfo setObject:self forKey:NSValidationObjectErrorKey];
                    
                    NSError *missingPathError = [NSError errorWithDomain:@"MunkiAdminInstallsItemDomain"
                                                                   code:NSManagedObjectValidationError
                                                               userInfo:userInfo];
                    if (*error == nil) {
                        *error = missingPathError;
                    } else {
                        *error = [self errorFromOriginalError:*error error:missingPathError];
                    }
                }
            }
        }
    }
    return valid;
}

- (NSError *)errorFromOriginalError:(NSError *)originalError error:(NSError *)secondError
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSMutableArray *errors = [NSMutableArray arrayWithObject:secondError];
    
    if ([originalError code] == NSValidationMultipleErrorsError) {
        
        [userInfo addEntriesFromDictionary:[originalError userInfo]];
        [errors addObjectsFromArray:[userInfo objectForKey:NSDetailedErrorsKey]];
    }
    else {
        [errors addObject:originalError];
    }
    
    [userInfo setObject:errors forKey:NSDetailedErrorsKey];
    
    return [NSError errorWithDomain:NSCocoaErrorDomain
                               code:NSValidationMultipleErrorsError
                           userInfo:userInfo];
}

- (BOOL)validateMunki_type:(id *)typeString error:(NSError **)outError
{
    if (*typeString == nil) {
        if (outError != NULL) {
            NSString *errorReason = @"Installs item type is a required value.";
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setObject:errorReason forKey:NSLocalizedFailureReasonErrorKey];
            [userInfo setObject:self forKey:NSValidationObjectErrorKey];
            
            NSError *error = [NSError errorWithDomain:@"MunkiAdminInstallsItemDomain"
                                                 code:NSManagedObjectValidationError
                                             userInfo:userInfo];
            *outError = error;
        }
        return NO;
    }
    return YES;
}

- (NSDictionary *)currentDictValue
{
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithCapacity:9];
	if (self.munki_CFBundleIdentifier != nil) [tmpDict setObject:self.munki_CFBundleIdentifier forKey:@"CFBundleIdentifier"];
	if (self.munki_CFBundleName != nil) [tmpDict setObject:self.munki_CFBundleName forKey:@"CFBundleName"];
	if (self.munki_CFBundleShortVersionString != nil) [tmpDict setObject:self.munki_CFBundleShortVersionString forKey:@"CFBundleShortVersionString"];
    if (self.munki_CFBundleVersion != nil) [tmpDict setObject:self.munki_CFBundleVersion forKey:@"CFBundleVersion"];
    [self.customKeys enumerateObjectsUsingBlock:^(InstallsItemCustomKeyMO *obj, BOOL *stop) {
        if (obj.customKeyName && obj.customKeyValue) {
            [tmpDict setObject:obj.customKeyValue forKey:obj.customKeyName];
        }
    }];
    if (self.munki_version_comparison_key != nil) [tmpDict setObject:self.munki_version_comparison_key forKey:@"version_comparison_key"];
	if (self.munki_path != nil) [tmpDict setObject:self.munki_path forKey:@"path"];
	if (self.munki_type != nil) [tmpDict setObject:self.munki_type forKey:@"type"];
	if (self.munki_md5checksum != nil) [tmpDict setObject:self.munki_md5checksum forKey:@"md5checksum"];
    if (self.munki_minosversion != nil) [tmpDict setObject:self.munki_minosversion forKey:@"minosversion"];
	
	NSDictionary *returnDict = [NSDictionary dictionaryWithDictionary:tmpDict];
	return returnDict;
}

- (NSDictionary *)dictValueForSave
{
    /*
     Get the original installs item
     */
    NSDictionary *originalInstallsItemDict = self.originalInstallsItem;
    NSArray *sortedOriginalKeys = [[originalInstallsItemDict allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    
    /*
     Get the current InstallsItemMO object as a dictionary
     */
    NSDictionary *currentInstallsItemDict = [self currentDictValue];
    
    
    /*
     Check for differences in key arrays and log them
     */
    NSSet *originalKeysSet = [NSSet setWithArray:sortedOriginalKeys];
    NSArray *keysToDelete = [NSArray arrayWithObjects:
                             @"CFBundleIdentifier",
                             @"CFBundleName",
                             @"CFBundleShortVersionString",
                             @"CFBundleVersion",
                             @"version_comparison_key",
                             @"path",
                             @"type",
                             @"md5checksum",
                             @"minosversion",
                             nil];
    
    /*
     Create a new dictionary by merging
     the original and the new one.
     */
    NSMutableDictionary *mergedInfoDict = [NSMutableDictionary dictionaryWithDictionary:originalInstallsItemDict];
    [mergedInfoDict addEntriesFromDictionary:[self currentDictValue]];
    
    /*
     Remove keys that were deleted by user
     */
    for (NSString *aKey in keysToDelete) {
        if (([currentInstallsItemDict valueForKey:aKey] == nil) &&
            ([originalInstallsItemDict valueForKey:aKey] != nil)) {
            [mergedInfoDict removeObjectForKey:aKey];
        }
    }
    
    /*
     Once again the "version_comparison_key" requires some special attention
     */
    //NSString *originalComp = [originalInstallsItemDict valueForKey:@"version_comparison_key"];
    //NSString *currentComp = [currentInstallsItemDict valueForKey:@"version_comparison_key"];
    
    /*
    // Remove "version_comparison_key" if it wasn't there originally and it has a default value now
    if (([currentComp isEqualToString:@"CFBundleShortVersionString"]) && (originalComp == nil)) {
        [mergedInfoDict removeObjectForKey:@"version_comparison_key"];
    }
    
    // Remove the key and value for old "version_comparison_key" if the new "version_comparison_key" is different
    else if ((originalComp != nil) && (currentComp != nil) && (![originalComp isEqualToString:currentComp])) {
        [mergedInfoDict removeObjectForKey:originalComp];
    }
     */
    
    /*
     Determine which keys were removed
     */
    NSArray *sortedCurrentKeys = [[mergedInfoDict allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    NSSet *newKeysSet = [NSSet setWithArray:sortedCurrentKeys];
    NSMutableSet *removedItems = [NSMutableSet setWithSet:originalKeysSet];
    [removedItems minusSet:newKeysSet];
    
    /*
     Determine which keys were added
     */
    NSMutableSet *addedItems = [NSMutableSet setWithSet:newKeysSet];
    [addedItems minusSet:originalKeysSet];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
        for (NSString *aKey in [removedItems allObjects]) {
            if (![keysToDelete containsObject:aKey]) {
                NSLog(@"Key change: \"%@\" found in original installs array. Keeping it.", aKey);
            } else {
                NSLog(@"Key change: \"%@\" deleted by MunkiAdmin", aKey);
            }
        }
        for (NSString *aKey in [addedItems allObjects]) {
            NSLog(@"Key change: \"%@\" added by MunkiAdmin", aKey);
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:mergedInfoDict];
}

@end
