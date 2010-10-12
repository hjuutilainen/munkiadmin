//
//  MunkiOperation.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 7.10.2010.
//

#import "MunkiOperation.h"


@implementation MunkiOperation

@synthesize command;
@synthesize targetURL;
@synthesize arguments;
@synthesize delegate;


+ (id)makecatalogsOperationWithTarget:(NSURL *)target
{
	return [[[self alloc] initWithCommand:@"makecatalogs" targetURL:target arguments:nil] autorelease];
}

+ (id)makepkginfoOperationWithSource:(NSURL *)sourceFile
{
	return [[[self alloc] initWithCommand:@"makepkginfo" targetURL:sourceFile arguments:nil] autorelease];
}

+ (id)installsItemFromURL:(NSURL *)sourceFile
{
	return [[[self alloc] initWithCommand:@"installsitem" targetURL:sourceFile arguments:[NSArray arrayWithObject:@"--file"]] autorelease];
}

- (id)initWithCommand:(NSString *)cmd targetURL:(NSURL *)target arguments:(NSArray *)args
{
	if (self = [super init]) {
		self.command = cmd;
		self.targetURL = target;
		self.arguments = args;
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Initializing munki operation: %@, target: %@", self.command, [self.targetURL relativePath]);
		//self.currentJobDescription = @"Initializing pkginfo scan operaiton";
		
	}
	return self;
}

- (void)dealloc {
	[command release];
	[targetURL release];
	[arguments release];
	[super dealloc];
}

- (NSUserDefaults *)defaults
{
	return [NSUserDefaults standardUserDefaults];
}

- (NSString *)makeCatalogs
{
	NSTask *makecatalogsTask = [[[NSTask alloc] init] autorelease];
	NSPipe *makecatalogsPipe = [NSPipe pipe];
	NSFileHandle *filehandle = [makecatalogsPipe fileHandleForReading];
	
	NSString *launchPath = [self.defaults stringForKey:@"makecatalogsPath"];
	[makecatalogsTask setLaunchPath:launchPath];
	[makecatalogsTask setArguments:[NSArray arrayWithObject:[self.targetURL relativePath]]];
	[makecatalogsTask setStandardOutput:makecatalogsPipe];
	[makecatalogsTask launch];
	
	NSData *makecatalogsTaskData = [filehandle readDataToEndOfFile];
	
	NSString *makecatalogsResults;
	makecatalogsResults = [[[NSString alloc] initWithData:makecatalogsTaskData encoding:NSUTF8StringEncoding] autorelease];
	return makecatalogsResults;
}

- (NSDictionary *)makepkginfo
{
	NSTask *makepkginfoTask = [[[NSTask alloc] init] autorelease];
	NSPipe *makepkginfoPipe = [NSPipe pipe];
	NSFileHandle *filehandle = [makepkginfoPipe fileHandleForReading];
	
	NSArray *newArguments;
	if ([self.command isEqualToString:@"makepkginfo"]) {
		newArguments = [NSArray arrayWithObject:[self.targetURL relativePath]];
	} else if ([self.command isEqualToString:@"installsitem"]) {
		newArguments = [NSArray arrayWithObjects:@"--file", [self.targetURL relativePath], nil];
	}
	
	NSString *launchPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"makepkginfoPath"];
	[makepkginfoTask setLaunchPath:launchPath];
	[makepkginfoTask setArguments:newArguments];
	[makepkginfoTask setStandardOutput:makepkginfoPipe];
	[makepkginfoTask launch];
	
	NSData *makepkginfoTaskData = [filehandle readDataToEndOfFile];
	
	NSString *error;
	NSPropertyListFormat format;
	id plist;
	plist = [NSPropertyListSerialization propertyListFromData:makepkginfoTaskData
											 mutabilityOption:NSPropertyListImmutable
													   format:&format
											 errorDescription:&error];
	
	if (!plist) {
		if ([self.defaults boolForKey:@"debug"]) {
			NSLog(@"MunkiOperation:makepkginfo:error:%@", [error description]);
			[error release];
		}
		return nil;
	}
	
	else {
		return (NSDictionary *)plist;
	}
	
}


-(void)main {
	@try {
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
		if ([self.command isEqualToString:@"makecatalogs"]) {
			NSString *results = [self makeCatalogs];
			if ([self.defaults boolForKey:@"debug"]) NSLog(@"MunkiOperation:makecatalogs:results: %@", results);
		}
		
		else if ([self.command isEqualToString:@"makepkginfo"]) {
			NSDictionary *pkginfo = [self makepkginfo];
			if ([self.defaults boolForKey:@"debug"]) NSLog(@"MunkiOperation:makepkginfo:results: %@", pkginfo);
			if ([self.delegate respondsToSelector:@selector(makepkginfoDidFinish:)]) {
				[self.delegate performSelectorOnMainThread:@selector(makepkginfoDidFinish:) 
												withObject:pkginfo
											 waitUntilDone:NO];
			}
		}
		
		else if ([self.command isEqualToString:@"installsitem"]) {
			NSDictionary *pkginfo = [self makepkginfo];
			if ([self.defaults boolForKey:@"debug"]) NSLog(@"MunkiOperation:makepkginfo:results: %@", pkginfo);
			if ([self.delegate respondsToSelector:@selector(installsItemDidFinish:)]) {
				[self.delegate performSelectorOnMainThread:@selector(installsItemDidFinish:) 
												withObject:pkginfo
											 waitUntilDone:YES];
			}
		}
		
		else {
			NSLog(@"Command not recognized: %@", self.command);
		}
		
		[pool release];
	}
	@catch(...) {
		// Do not rethrow exceptions.
	}
}


@end
