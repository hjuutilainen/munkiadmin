//
//  MunkiOperation.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 7.10.2010.
//

#import "MAMunkiOperation.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

@implementation MAMunkiOperation


+ (id)makecatalogsOperationWithTarget:(NSURL *)target
{
	return [[self alloc] initWithCommand:@"makecatalogs" targetURL:target arguments:nil munkitoolsVersion:nil];
}

+ (id)makecatalogsOperationWithTarget:(NSURL *)target munkitoolsVersion:(NSString *)version
{
    return [[self alloc] initWithCommand:@"makecatalogs" targetURL:target arguments:nil munkitoolsVersion:version];
}

+ (id)makepkginfoOperationWithSource:(NSURL *)sourceFile
{
	return [[self alloc] initWithCommand:@"makepkginfo" targetURL:sourceFile arguments:nil munkitoolsVersion:nil];
}

+ (id)installsItemFromURL:(NSURL *)sourceFile
{
	return [[self alloc] initWithCommand:@"installsitem" targetURL:sourceFile arguments:@[@"--file"] munkitoolsVersion:nil];
}

+ (id)installsItemFromPath:(NSString *)pathToFile
{
    NSURL *fileURL = [NSURL fileURLWithPath:pathToFile];
	return [[self alloc] initWithCommand:@"installsitem" targetURL:fileURL arguments:@[@"--file"] munkitoolsVersion:nil];
}

- (id)initWithCommand:(NSString *)cmd targetURL:(NSURL *)target arguments:(NSArray *)args munkitoolsVersion:(NSString *)version
{
	if ((self = [super init])) {
		_command = cmd;
		_targetURL = target;
		_arguments = args;
        _munkitoolsVersion = version;
        DDLogDebug(@"Initializing munki operation: %@, target: %@", self.command, [self.targetURL relativePath]);
	}
	return self;
}


- (NSUserDefaults *)defaults
{
	return [NSUserDefaults standardUserDefaults];
}

- (NSString *)makeCatalogs
{
	NSTask *makecatalogsTask = [[NSTask alloc] init];
	NSPipe *makecatalogsPipe = [NSPipe pipe];
	NSFileHandle *filehandle = [makecatalogsPipe fileHandleForReading];
	
	NSString *launchPath = [self.defaults stringForKey:@"makecatalogsPath"];
    makecatalogsTask.launchPath = launchPath;
    makecatalogsTask.standardOutput = makecatalogsPipe;
    makecatalogsTask.standardError = makecatalogsPipe;
    makecatalogsTask.standardInput = [NSPipe pipe];
    
    NSMutableDictionary *defaultEnv = [[NSMutableDictionary alloc] initWithDictionary:[[NSProcessInfo processInfo] environment]];
    [defaultEnv setObject:@"YES" forKey:@"NSUnbufferedIO"];
    [defaultEnv setObject:@"utf-8" forKey:@"PYTHONIOENCODING"];
    makecatalogsTask.environment = defaultEnv;
     
    NSString *repoArg = [self.targetURL path];
    
    /*
     Check the "Disable sanity checks" preference
     */
    if ([self.defaults boolForKey:@"makecatalogsForceEnabled"]) {
        makecatalogsTask.arguments = @[@"--force", repoArg];
    } else {
        makecatalogsTask.arguments = @[repoArg];
    }
    DDLogDebug(@"Running %@ with arguments: %@", makecatalogsTask.launchPath, makecatalogsTask.arguments);
    
	/*
     Launch the task
     */
	[makecatalogsTask launch];
    
    /*
     Read makecatalogs output
     */
    NSData *makecatalogsTaskData = [filehandle readDataToEndOfFile];
    NSString *makecatalogsResults = [[NSString alloc] initWithData:makecatalogsTaskData
                                                          encoding:NSUTF8StringEncoding];
    if (![makecatalogsResults isEqualToString:@""]) {
        // Check for warnings in makecatalogs output
        NSRange range = NSMakeRange(0, makecatalogsResults.length);
        [makecatalogsResults enumerateSubstringsInRange:range
                                                options:NSStringEnumerationByParagraphs
                                             usingBlock:^(NSString * _Nullable paragraph, NSRange paragraphRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                                                 if ([paragraph hasPrefix:@"WARNING: "]) {
                                                     DDLogError(@"%@", paragraph);
                                                 }
                                             }];
    }
    
    /*
     Check the exit code
     */
    int exitCode = makecatalogsTask.terminationStatus;
    if (exitCode == 0) {
        DDLogDebug(@"makecatalogs succeeded.");
    } else {
        DDLogError(@"makecatalogs exited with code %i", exitCode);
    }
    
	return makecatalogsResults;
}

- (NSDictionary *)makepkginfo
{
	NSTask *makepkginfoTask = [[NSTask alloc] init];
	NSPipe *makepkginfoPipe = [NSPipe pipe];
    NSPipe *makepkginfoErrorPipe = [NSPipe pipe];
	NSFileHandle *filehandle = [makepkginfoPipe fileHandleForReading];
    NSFileHandle *errorfilehandle = [makepkginfoErrorPipe fileHandleForReading];
	
	NSArray *newArguments;
	if ([self.command isEqualToString:@"makepkginfo"]) {
        /*
         Get default makepkginfo options from NSUserDefaults (if any)
         */
        NSArray *optionsFromDefaults = [[NSUserDefaults standardUserDefaults] arrayForKey:@"makepkginfoDefaultOptions"];
        NSMutableArray *combinedOptions = [NSMutableArray new];
        if (optionsFromDefaults != nil) {
            [combinedOptions addObjectsFromArray:optionsFromDefaults];
            [combinedOptions addObject:[self.targetURL relativePath]];
            newArguments = [NSArray arrayWithArray:combinedOptions];
        } else {
            newArguments = @[[self.targetURL relativePath]];
        }
	} else if ([self.command isEqualToString:@"installsitem"]) {
		newArguments = @[@"--file", [self.targetURL relativePath]];
	} else {
        return nil;
    }
	
	NSString *launchPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"makepkginfoPath"];
    makepkginfoTask.launchPath = launchPath;
	makepkginfoTask.arguments = newArguments;
	makepkginfoTask.standardOutput = makepkginfoPipe;
    makepkginfoTask.standardError = makepkginfoErrorPipe;
    
    NSMutableDictionary *defaultEnv = [[NSMutableDictionary alloc] initWithDictionary:[[NSProcessInfo processInfo] environment]];
    [defaultEnv setObject:@"utf-8" forKey:@"PYTHONIOENCODING"];
    makepkginfoTask.environment = defaultEnv;
    
    DDLogDebug(@"Running %@ with arguments: %@", makepkginfoTask.launchPath, makepkginfoTask.arguments);
	[makepkginfoTask launch];
	
	NSData *makepkginfoTaskData = [filehandle readDataToEndOfFile];
    
    /*
     Check if we got any warnings or errors from makepkginfo
     */
    NSData *makepkginfoTaskErrorData = [errorfilehandle readDataToEndOfFile];
    NSString *errorString;
    errorString = [[NSString alloc] initWithData:makepkginfoTaskErrorData encoding:NSUTF8StringEncoding];
    if (![errorString isEqualToString:@""]) {
        DDLogError(@"makepkginfo reported error:\n%@", errorString);
        return nil;
    }
    
	
	NSError *error;
	NSPropertyListFormat format;
	id plist;
    plist = [NSPropertyListSerialization propertyListWithData:makepkginfoTaskData
                                                      options:NSPropertyListImmutable
                                                       format:&format
                                                        error:&error];
	
	if (!plist) {
        DDLogError(@"NSPropertyListSerialization propertyListWithData failed with error: %@", [error description]);
		return nil;
	}
	
	else {
		return (NSDictionary *)plist;
	}
	
}


-(void)main {
	@try {
		@autoreleasepool {
            
			if ([self.command isEqualToString:@"makecatalogs"]) {
                DDLogDebug(@"MunkiOperation:makecatalogs");
				NSString *results = [self makeCatalogs];
				DDLogVerbose(@"MunkiOperation:makecatalogs:results:\n%@", results);
			}
			
			else if ([self.command isEqualToString:@"makepkginfo"]) {
                DDLogDebug(@"MunkiOperation:makepkginfo");
				NSDictionary *pkginfo = [self makepkginfo];
                NSMutableDictionary *newPkginfo = [NSMutableDictionary new];
                newPkginfo = [NSMutableDictionary dictionaryWithDictionary:pkginfo];
                if (self.pkginfoAdditions) {
                    [newPkginfo addEntriesFromDictionary:self.pkginfoAdditions];
                }
				DDLogVerbose(@"MunkiOperation:makepkginfo:results: %@", pkginfo);
				if ([self.delegate respondsToSelector:@selector(makepkginfoDidFinish:)]) {
					[self.delegate performSelectorOnMainThread:@selector(makepkginfoDidFinish:)
													withObject:[NSDictionary dictionaryWithDictionary:newPkginfo]
												 waitUntilDone:YES];
				}
			}
			
			else if ([self.command isEqualToString:@"installsitem"]) {
                DDLogDebug(@"MunkiOperation:installsitem");
				NSDictionary *pkginfo = [self makepkginfo];
				DDLogVerbose(@"MunkiOperation:makepkginfo:results: %@", pkginfo);
				if ([self.delegate respondsToSelector:@selector(installsItemDidFinish:)]) {
					[self.delegate performSelectorOnMainThread:@selector(installsItemDidFinish:)
													withObject:pkginfo
												 waitUntilDone:YES];
				}
			}
			
			else {
				DDLogDebug(@"Command not recognized: %@", self.command);
			}
            
		}
	}
	@catch(...) {
		DDLogDebug(@"Caught exception while running %@", self.command);
	}
}


@end
