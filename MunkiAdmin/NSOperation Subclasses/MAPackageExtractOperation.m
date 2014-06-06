//
//  MAPackageExtractOperation.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 3.6.2014.
//
//

#import "MAPackageExtractOperation.h"

@interface MAPackageExtractOperation ()
@property (strong) NSURL *packageCacheURL;
@property (strong) NSURL *extractedPayloadsURL;
@property (strong) NSString *packageFileName;
@property (strong) NSURL *packageURL;
@end

@implementation MAPackageExtractOperation

+ (id)extractOperationWithURL:(NSURL *)url
{
    return [[self alloc] initWithURL:url];
}


- (id)initWithURL:(NSURL *)url
{
    if ((self = [super init])) {
		_packageURL = url;
        NSString *fileName;
        [url getResourceValue:&fileName forKey:NSURLNameKey error:nil];
        _packageFileName = fileName;
        _packageCacheURL = [self createPackageCacheDirectory];
        _extractedPayloadsURL = [self createExtractedPayloadsDirectory];
        
	}
	return self;
}

- (NSURL *)createPackageCacheDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *cacheDirectory = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask][0];
    NSURL *munkiAdminCacheURL = [cacheDirectory URLByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
    NSURL *packageExtractCache = [munkiAdminCacheURL URLByAppendingPathComponent:@"Extracted Packages"];
    
    NSURL *cacheDirectoryForCurrentExtraction = [packageExtractCache URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    if (![fileManager fileExistsAtPath:[cacheDirectoryForCurrentExtraction path]]) {
        [fileManager createDirectoryAtURL:cacheDirectoryForCurrentExtraction withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return cacheDirectoryForCurrentExtraction;
}

- (NSURL *)createExtractedPayloadsDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *extractedPayloadsURL = [_packageCacheURL URLByAppendingPathComponent:@"Extracted Payloads"];
    
    if (![fileManager fileExistsAtPath:[extractedPayloadsURL path]]) {
        [fileManager createDirectoryAtURL:extractedPayloadsURL withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return extractedPayloadsURL;
}

- (BOOL)dittoExtractSource:(NSString *)sourcePath outPath:(NSString *)outputPath
{
    /*
     Extract with "ditto -x" (thanks for the tip @magervalp)
     */
    NSTask *task = [[NSTask alloc] init];
    NSString *launchPath = @"/usr/bin/ditto";
    [task setLaunchPath:launchPath];
    [task setArguments:@[@"-x", sourcePath, outputPath]];
    [task setCurrentDirectoryPath:outputPath];
    
    [task launch];
    [task waitUntilExit];
    
    int status = [task terminationStatus];
    if (status == 0) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (BOOL)pkgutilExpandSource:(NSString *)sourcePath outPath:(NSString *)outputPath
{
    NSTask *task = [[NSTask alloc] init];
    NSPipe *outPipe = [NSPipe pipe];
    NSString *launchPath = @"/usr/sbin/pkgutil";
	task.launchPath = launchPath;
	task.arguments = @[@"--expand", sourcePath, outputPath];
	task.standardOutput = outPipe;
    
    [task launch];
    [task waitUntilExit];
    
    int status = [task terminationStatus];
    if (status == 0) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (NSURL *)expandFlatPackage
{
    NSURL *expandOutputURL = [self.packageCacheURL URLByAppendingPathComponent:self.packageFileName];
    if ([self pkgutilExpandSource:[self.packageURL path] outPath:[expandOutputURL path]]) {
        return expandOutputURL;
    } else {
        return nil;
    }
}

- (NSArray *)findAllFilesOfType:(NSString *)type atURL:(NSURL *)url
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:url
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey, NSURLTypeIdentifierKey]
                                                             options:nil
                                                        errorHandler:nil];
    NSMutableArray *foundURLs = [NSMutableArray array];
    for (NSURL *fileURL in enumerator) {
        NSString *filename;
        [fileURL getResourceValue:&filename
                           forKey:NSURLNameKey
                            error:nil];
        NSNumber *isDirectory;
        [fileURL getResourceValue:&isDirectory
                           forKey:NSURLIsDirectoryKey
                            error:nil];
        NSString *typeIdentifier;
        [fileURL getResourceValue:&typeIdentifier
                           forKey:NSURLTypeIdentifierKey
                            error:nil];
        //NSLog(@"%@ %@", typeIdentifier, fileURL);
        if ([workspace type:typeIdentifier conformsToType:type]) {
            [foundURLs addObject:fileURL];
        }
    }
    return [NSArray arrayWithArray:foundURLs];
}




- (void)extractPackage
{
    
    /*
     TODO: Distribution packages
     */
    
    /*
     Get the type by checking if the package is a file or a directory (bundle)
     */
    NSNumber *isDirectory;
    [self.packageURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    /*
     Bundle package
     */
    if ([isDirectory boolValue]) {
        
        NSURL *archiveURL = [self.packageURL URLByAppendingPathComponent:@"Contents/Archive.pax.gz"];
        if ([fileManager fileExistsAtPath:[archiveURL path]]) {
            /*
             Single package with an archive
             */
            NSURL *payloadExtractedURL = [self.extractedPayloadsURL URLByAppendingPathComponent:[[archiveURL lastPathComponent] stringByDeletingPathExtension]];
            if (![fileManager fileExistsAtPath:[payloadExtractedURL path]]) {
                [fileManager createDirectoryAtURL:payloadExtractedURL withIntermediateDirectories:YES attributes:nil error:nil];
            }
            if ([fileManager fileExistsAtPath:[archiveURL path]]) {
                [self dittoExtractSource:[archiveURL path] outPath:[payloadExtractedURL path]];
            }
            
            return;
        }
        
        /*
         Metapackage
         */
        for (NSURL *url in [self findAllFilesOfType:@"com.apple.installer-package" atURL:self.packageURL]) {
            if (self.progressCallback) {
                self.progressCallback(1.0, [NSString stringWithFormat:@"Extracting payload from %@...", [url lastPathComponent]]);
            }
            //NSLog(@"%@", url);
            NSURL *payloadURL = [url URLByAppendingPathComponent:@"Contents/Archive.pax.gz"];
            NSURL *payloadExtractedURL = [self.extractedPayloadsURL URLByAppendingPathComponent:[[url lastPathComponent] stringByDeletingPathExtension]];
            if (![fileManager fileExistsAtPath:[payloadExtractedURL path]]) {
                [fileManager createDirectoryAtURL:payloadExtractedURL withIntermediateDirectories:YES attributes:nil error:nil];
            }
            if ([fileManager fileExistsAtPath:[payloadURL path]]) {
                [self dittoExtractSource:[payloadURL path] outPath:[payloadExtractedURL path]];
            }
        }
    }
    
    /*
     Flat package
     */
    else {
        if (self.progressCallback) {
            self.progressCallback(1.0, @"Expanding package...");
        }
        NSURL *expandedURL = [self expandFlatPackage];
        
        for (NSURL *url in [self findAllFilesOfType:@"com.apple.installer-package" atURL:expandedURL]) {
            if (self.progressCallback) {
                self.progressCallback(1.0, [NSString stringWithFormat:@"Extracting payload from %@...", [url lastPathComponent]]);
            }
            NSURL *payloadURL = [url URLByAppendingPathComponent:@"Payload"];
            NSURL *payloadExtractedURL = [self.extractedPayloadsURL URLByAppendingPathComponent:[[url lastPathComponent] stringByDeletingPathExtension]];
            if (![fileManager fileExistsAtPath:[payloadExtractedURL path]]) {
                [fileManager createDirectoryAtURL:payloadExtractedURL withIntermediateDirectories:YES attributes:nil error:nil];
            }
            if ([fileManager fileExistsAtPath:[payloadURL path]]) {
                [self dittoExtractSource:[payloadURL path] outPath:[payloadExtractedURL path]];
            }
        }
    }
    
}

- (void)cleanCache
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *cleanError;
    if (![fileManager removeItemAtURL:self.packageCacheURL error:&cleanError]) {
        NSLog(@"Remove failed:\n%@", [cleanError description]);
    }
}

- (void)main
{
    if (self.willStartCallback) {
        self.willStartCallback();
    }
    
    if (self.progressCallback) {
        self.progressCallback(1.0, @"Starting...");
    }
    
    /*
     Extract
     */
    [self extractPackage];
    
    if (self.didExtractHandler) {
        self.didExtractHandler(self.extractedPayloadsURL);
    }
    
    /*
     Clean everything
     */
    if (self.progressCallback) {
        self.progressCallback(1.0, @"Cleaning...");
    }
    [self cleanCache];
    
    
    if (self.progressCallback) {
        self.progressCallback(1.0, @"Done extracting...");
    }
    if (self.didFinishCallback) {
        self.didFinishCallback();
    }
}


@end
