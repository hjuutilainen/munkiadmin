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


- (NSUserDefaults *)defaults
{
	return [NSUserDefaults standardUserDefaults];
}

+ (id)makecatalogsOperationWithTarget:(NSURL *)target
{
	return [[[self alloc] initWithCommand:@"makecatalogs" targetURL:target arguments:nil] autorelease];
}

- (id)initWithCommand:(NSString *)cmd targetURL:(NSURL *)target arguments:(NSArray *)args
{
	if (self = [super init]) {
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Initializing munki operation");
		self.command = cmd;
		self.targetURL = target;
		self.arguments = args;
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


-(void)main {
	@try {
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
		if ([self.command isEqualToString:@"makecatalogs"]) {
			NSString *results = [self makeCatalogs];
			//if ([self.defaults boolForKey:@"debug"]) NSLog(@"makecatalogs: %@", results);
		} else if ([self.command isEqualToString:@"makepkginfo"]) {
			//
		} else {
			NSLog(@"Command not recognized: %@", self.command);
		}

		
		
		//self.currentJobDescription = [NSString stringWithFormat:@"Reading file %@", self.fileName];
		//if ([self.defaults boolForKey:@"debug"]) NSLog(@"Reading file %@", [self.sourceURL relativePath]);
		
		
		if ([self.delegate respondsToSelector:@selector(munkiOperationDidFinish:)]) {
			[self.delegate performSelectorOnMainThread:@selector(munkiOperationDidFinish:) 
											withObject:nil
										 waitUntilDone:YES];
		}
		
		[pool release];
	}
	@catch(...) {
		// Do not rethrow exceptions.
	}
}


@end
