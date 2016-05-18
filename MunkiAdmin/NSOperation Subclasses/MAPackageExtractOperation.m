//
//  MAPackageExtractOperation.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 3.6.2014.
//
//

#import "MAPackageExtractOperation.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

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
        DDLogVerbose(@"Initializing extract operation for %@", [url path]);
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
    
    DDLogDebug(@"Running /usr/bin/ditto with arguments: %@", task.arguments);
    
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
    
    DDLogDebug(@"Running /usr/sbin/pkgutil with arguments: %@", task.arguments);
    
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
    if (!url) {
        DDLogError(@"MAPackageExtractOperation: findAllFilesOfType:atURL: The URL can not be nil");
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:url
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey, NSURLTypeIdentifierKey]
                                                             options:0
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
        //DDLogDebug(@"%@ %@", typeIdentifier, fileURL);
        if ([workspace type:typeIdentifier conformsToType:type]) {
            [foundURLs addObject:fileURL];
        }
    }
    return [NSArray arrayWithArray:foundURLs];
}


- (void)extractArchiveFromBundlePackageURL:(NSURL *)packageURL
{
    if (!packageURL) {
        DDLogError(@"MAPackageExtractOperation: extractArchiveFromBundlePackageURL: The URL can not be nil");
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *archiveURL = [packageURL URLByAppendingPathComponent:@"Contents/Archive.pax.gz"];
    NSURL *archiveExtractedURL = [self.extractedPayloadsURL URLByAppendingPathComponent:[[packageURL lastPathComponent] stringByDeletingPathExtension]];
    if (![fileManager fileExistsAtPath:[archiveExtractedURL path]]) {
        [fileManager createDirectoryAtURL:archiveExtractedURL withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if ([fileManager fileExistsAtPath:[archiveURL path]]) {
        [self dittoExtractSource:[archiveURL path] outPath:[archiveExtractedURL path]];
    } else {
        DDLogError(@"MAPackageExtractOperation error: Archive file doesn't exist: %@", [archiveURL path]);
    }
}

- (void)extractPayloadFromExpandedPackageURL:(NSURL *)packageURL
{
    if (!packageURL) {
        DDLogError(@"MAPackageExtractOperation: extractPayloadFromExpandedPackageURL: The URL can not be nil");
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *payloadURL = [packageURL URLByAppendingPathComponent:@"Payload"];
    NSURL *payloadExtractedURL = [self.extractedPayloadsURL URLByAppendingPathComponent:[[packageURL lastPathComponent] stringByDeletingPathExtension]];
    if (![fileManager fileExistsAtPath:[payloadExtractedURL path]]) {
        [fileManager createDirectoryAtURL:payloadExtractedURL withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if ([fileManager fileExistsAtPath:[payloadURL path]]) {
        [self dittoExtractSource:[payloadURL path] outPath:[payloadExtractedURL path]];
    } else {
        DDLogError(@"MAPackageExtractOperation error: Payload file doesn't exist: %@", [payloadURL path]);
    }
}


- (void)extractPackageAtURL:(NSURL *)packageURL
{
    DDLogDebug(@"MAPackageExtractOperation extracting...");
    
    /*
     TODO: Distribution packages
     */
    
    /*
     Get the type by checking if the package is a file or a directory (bundle)
     */
    NSNumber *isDirectory;
    [packageURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
    /*
     Bundle package
     */
    if ([isDirectory boolValue]) {
        
        DDLogDebug(@"MAPackageExtractOperation processing bundle style package...");
        
        /*
         Single package with an archive
         */
        [self extractArchiveFromBundlePackageURL:packageURL];
        
        /*
         Metapackage
         */
        for (NSURL *url in [self findAllFilesOfType:@"com.apple.installer-package" atURL:packageURL]) {
            DDLogDebug(@"MAPackageExtractOperation found subpackage: %@", [url path]);
            if (self.progressCallback) {
                self.progressCallback(1.0, [NSString stringWithFormat:@"Extracting payload from %@...", [url lastPathComponent]]);
            }
            [self extractArchiveFromBundlePackageURL:url];
        }
    }
    
    /*
     Flat package
     */
    else {
        DDLogDebug(@"MAPackageExtractOperation processing flat package...");
        if (self.progressCallback) {
            self.progressCallback(1.0, @"Expanding package...");
        }
        NSURL *expandedURL = [self expandFlatPackage];
        if (expandedURL) {
            [self extractPayloadFromExpandedPackageURL:expandedURL];
            
            for (NSURL *url in [self findAllFilesOfType:@"com.apple.installer-package" atURL:expandedURL]) {
                DDLogDebug(@"MAPackageExtractOperation found subpackage: %@", [url path]);
                if (self.progressCallback) {
                    self.progressCallback(1.0, [NSString stringWithFormat:@"Extracting payload from %@...", [url lastPathComponent]]);
                }
                
                [self extractPayloadFromExpandedPackageURL:url];
            }
        }
    }
}

- (void)cleanCache
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *cleanError;
    if (![fileManager removeItemAtURL:self.packageCacheURL error:&cleanError]) {
        DDLogError(@"MAPackageExtractOperation Remove failed:\n%@", [cleanError description]);
    }
}

- (void)main
{
    DDLogDebug(@"MAPackageExtractOperation starting...");
    
    if (self.willStartCallback) {
        self.willStartCallback();
    }
    
    if (self.progressCallback) {
        self.progressCallback(1.0, @"Starting...");
    }
    
    /*
     Extract
     */
    [self extractPackageAtURL:self.packageURL];
    
    DDLogDebug(@"MAPackageExtractOperation running didExtractHandler...");
    if (self.didExtractHandler) {
        self.didExtractHandler(self.extractedPayloadsURL);
    }
    
    /*
     Clean everything
     */
    DDLogDebug(@"MAPackageExtractOperation cleaning cache...");
    if (self.progressCallback) {
        self.progressCallback(1.0, @"Cleaning...");
    }
    [self cleanCache];
    
    DDLogDebug(@"MAPackageExtractOperation running didFinishCallback...");
    if (self.progressCallback) {
        self.progressCallback(1.0, @"Package extracted...");
    }
    if (self.didFinishCallback) {
        self.didFinishCallback();
    }
}


@end
