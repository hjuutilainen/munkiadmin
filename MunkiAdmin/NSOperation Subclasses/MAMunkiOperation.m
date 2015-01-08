//
//  MunkiOperation.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 7.10.2010.
//

#import "MAMunkiOperation.h"


@implementation MAMunkiOperation


+ (id)makecatalogsOperationWithTarget:(NSURL *)target
{
	return [[self alloc] initWithCommand:@"makecatalogs" targetURL:target arguments:nil];
}

+ (id)makepkginfoOperationWithSource:(NSURL *)sourceFile
{
	return [[self alloc] initWithCommand:@"makepkginfo" targetURL:sourceFile arguments:nil];
}

+ (id)installsItemFromURL:(NSURL *)sourceFile
{
	return [[self alloc] initWithCommand:@"installsitem" targetURL:sourceFile arguments:@[@"--file"]];
}

+ (id)installsItemFromPath:(NSString *)pathToFile
{
    NSURL *fileURL = [NSURL fileURLWithPath:pathToFile];
	return [[self alloc] initWithCommand:@"installsitem" targetURL:fileURL arguments:@[@"--file"]];
}

- (id)initWithCommand:(NSString *)cmd targetURL:(NSURL *)target arguments:(NSArray *)args
{
	if ((self = [super init])) {
		self.command = cmd;
		self.targetURL = target;
		self.arguments = args;
        if ([self.defaults boolForKey:@"debug"]) {
            NSLog(@"Initializing munki operation: %@, target: %@", self.command, [self.targetURL relativePath]);
        }
		//self.currentJobDescription = @"Initializing pkginfo scan operaiton";
		
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
    
    /*
     Check the "Disable sanity checks" preference
     */
    if ([self.defaults boolForKey:@"makecatalogsForceEnabled"]) {
        makecatalogsTask.arguments = @[@"--force", [self.targetURL relativePath]];
    } else {
        makecatalogsTask.arguments = @[[self.targetURL relativePath]];
    }
    
	/*
     Launch and read the output
     */
	[makecatalogsTask launch];
	NSData *makecatalogsTaskData = [filehandle readDataToEndOfFile];
	NSString *makecatalogsResults = [[NSString alloc] initWithData:makecatalogsTaskData
                                                          encoding:NSUTF8StringEncoding];
    
    /*
     Check the exit code even though makecatalogs (currently) always exits with 0
     */
    int exitCode = makecatalogsTask.terminationStatus;
    if (exitCode == 0) {
        if ([self.defaults boolForKey:@"debug"]) {
            NSLog(@"makecatalogs succeeded.");
        }
    } else {
        if ([self.defaults boolForKey:@"debug"]) {
            NSLog(@"makecatalogs failed with code %i", exitCode);
        }
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
	[makepkginfoTask launch];
	
	NSData *makepkginfoTaskData = [filehandle readDataToEndOfFile];
    
    /*
     Check if we got any warnings or errors from makepkginfo
     */
    NSData *makepkginfoTaskErrorData = [errorfilehandle readDataToEndOfFile];
    NSString *errorString;
    errorString = [[NSString alloc] initWithData:makepkginfoTaskErrorData encoding:NSUTF8StringEncoding];
    if (![errorString isEqualToString:@""]) {
        NSLog(@"makepkginfo reported error:\n%@", errorString);
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
		if ([self.defaults boolForKey:@"debug"]) {
			NSLog(@"MunkiOperation:makepkginfo:error:%@", [error description]);
		}
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
				NSString *results = [self makeCatalogs];
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"MunkiOperation:makecatalogs");
				if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"MunkiOperation:makecatalogs:results: %@", results);
			}
			
			else if ([self.command isEqualToString:@"makepkginfo"]) {
				NSDictionary *pkginfo = [self makepkginfo];
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"MunkiOperation:makepkginfo");
				if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"MunkiOperation:makepkginfo:results: %@", pkginfo);
				if ([self.delegate respondsToSelector:@selector(makepkginfoDidFinish:)]) {
					[self.delegate performSelectorOnMainThread:@selector(makepkginfoDidFinish:)
													withObject:pkginfo
												 waitUntilDone:YES];
				}
			}
			
			else if ([self.command isEqualToString:@"installsitem"]) {
				NSDictionary *pkginfo = [self makepkginfo];
                if ([self.defaults boolForKey:@"debug"]) NSLog(@"MunkiOperation:installsitem");
				if ([self.defaults boolForKey:@"debugLogAllProperties"]) NSLog(@"MunkiOperation:makepkginfo:results: %@", pkginfo);
				if ([self.delegate respondsToSelector:@selector(installsItemDidFinish:)]) {
					[self.delegate performSelectorOnMainThread:@selector(installsItemDidFinish:)
													withObject:pkginfo
												 waitUntilDone:YES];
				}
			}
			
			else {
				NSLog(@"Command not recognized: %@", self.command);
			}
            
		}
	}
	@catch(...) {
		// Do not rethrow exceptions.
	}
}


@end
