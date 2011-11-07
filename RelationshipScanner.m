//
//  RelationshipScanner.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 1.11.2011.
//

#import "RelationshipScanner.h"
#import "PackageMO.h"
#import "PackageInfoMO.h"
#import "CatalogMO.h"
#import "CatalogInfoMO.h"
#import "ApplicationMO.h"
#import "ManifestMO.h"
#import "ManifestInfoMO.h"
#import "StringObjectMO.h"

@implementation RelationshipScanner

@synthesize currentJobDescription;
@synthesize fileName;
@synthesize delegate;
@synthesize operationMode;
@synthesize allCatalogs;
@synthesize allPackages;
@synthesize allApplications;
@synthesize allManifests;

- (NSUserDefaults *)defaults
{
	return [NSUserDefaults standardUserDefaults];
}

+ (id)pkginfoScanner
{
	return [[[self alloc] initWithMode:0] autorelease];
}

+ (id)manifestScanner
{
	return [[[self alloc] initWithMode:1] autorelease];
}

- (id)initWithMode:(NSInteger)mode {
	if ((self = [super init])) {
		if ([self.defaults boolForKey:@"debug"]) NSLog(@"Initializing relationship operation");
		self.operationMode = mode;
		self.currentJobDescription = @"Initializing relationship operation";
		
	}
	return self;
}

- (void)dealloc {
	[fileName release];
	[currentJobDescription release];
	[delegate release];
	[super dealloc];
}

- (void)contextDidSave:(NSNotification*)notification 
{
	[[self delegate] performSelectorOnMainThread:@selector(mergeChanges:) 
									  withObject:notification 
								   waitUntilDone:YES];
}

- (id)matchingAppOrPkgForString:(NSString *)aString
{
    NSPredicate *appPred = [NSPredicate predicateWithFormat:@"munki_name == %@", aString];
    NSUInteger foundIndex = [self.allApplications indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [appPred evaluateWithObject:obj];
    }];
    if (foundIndex != NSNotFound) {
        return [self.allApplications objectAtIndex:foundIndex];
    } else {
        NSPredicate *pkgPred = [NSPredicate predicateWithFormat:@"titleWithVersion == %@", aString];
        NSUInteger foundPkgIndex = [self.allPackages indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [pkgPred evaluateWithObject:obj];
        }];
        if (foundPkgIndex != NSNotFound) {
            return [self.allPackages objectAtIndex:foundPkgIndex];
        } else {
            return nil;
        }
    }
}

- (id)matchingCatalogForString:(NSString *)aString
{
    NSPredicate *catalogTitlePredicate = [NSPredicate predicateWithFormat:@"title == %@", aString];
    NSUInteger foundIndex = [self.allCatalogs indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [catalogTitlePredicate evaluateWithObject:obj];
    }];
    if (foundIndex != NSNotFound) {
        return [self.allCatalogs objectAtIndex:foundIndex];
    } else {
        return nil;
    }
}

- (void)scanManifests
{
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
    [moc setPersistentStoreCoordinator:[[self delegate] persistentStoreCoordinator]];
    [moc setUndoManager:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:moc];
    NSEntityDescription *catalogEntityDescr = [NSEntityDescription entityForName:@"Catalog" inManagedObjectContext:moc];
    NSEntityDescription *manifestEntityDescr = [NSEntityDescription entityForName:@"Manifest" inManagedObjectContext:moc];
    NSEntityDescription *applicationEntityDescr = [NSEntityDescription entityForName:@"Application" inManagedObjectContext:moc];
    NSEntityDescription *packageEntityDescr = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc];
    
    // Get all manifest objects for later use
    NSFetchRequest *getManifests = [[NSFetchRequest alloc] init];
    [getManifests setEntity:manifestEntityDescr];
    self.allManifests = [moc executeFetchRequest:getManifests error:nil];
    [getManifests release];
    
    // Get all application objects for later use
    NSFetchRequest *getApplications = [[NSFetchRequest alloc] init];
    [getApplications setEntity:applicationEntityDescr];
    self.allApplications = [moc executeFetchRequest:getApplications error:nil];
    [getApplications release];
    
    // Get all catalogs
    NSFetchRequest *getAllCatalogs = [[NSFetchRequest alloc] init];
    [getAllCatalogs setEntity:catalogEntityDescr];
    self.allCatalogs = [moc executeFetchRequest:getAllCatalogs error:nil];
    [getAllCatalogs release];
    
    // Get all packages for later use
    NSFetchRequest *getPackages = [[NSFetchRequest alloc] init];
    [getPackages setEntity:packageEntityDescr];
    self.allPackages = [moc executeFetchRequest:getPackages error:nil];
    [getPackages release];
    
    [self.allManifests enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        self.currentJobDescription = [NSString stringWithFormat:@"Processing %i/%i", idx+1, [self.allManifests count]];
        ManifestMO *currentManifest = (ManifestMO *)obj;
        NSDictionary *originalManifestDict = (NSDictionary *)currentManifest.originalManifest;
        
        // =================================
        // Get "catalogs" items
        // =================================
        NSArray *catalogs = [originalManifestDict objectForKey:@"catalogs"];
        for (CatalogMO *aCatalog in self.allCatalogs) {
            NSString *catalogTitle = [aCatalog title];
            CatalogInfoMO *newCatalogInfo;
            newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:moc];
            newCatalogInfo.catalog.title = catalogTitle;
            [aCatalog addManifestsObject:currentManifest];
            newCatalogInfo.manifest = currentManifest;
            [aCatalog addCatalogInfosObject:newCatalogInfo];
            
            if (catalogs == nil) {
                newCatalogInfo.isEnabledForManifestValue = NO;
                newCatalogInfo.originalIndexValue = 0;
                newCatalogInfo.indexInManifestValue = 0;
            } else if ([catalogs containsObject:catalogTitle]) {
                newCatalogInfo.isEnabledForManifestValue = YES;
                newCatalogInfo.originalIndexValue = [catalogs indexOfObject:catalogTitle];
                newCatalogInfo.indexInManifestValue = [catalogs indexOfObject:catalogTitle];
            } else {
                newCatalogInfo.isEnabledForManifestValue = NO;
                newCatalogInfo.originalIndexValue = ([catalogs count] + 1);
                newCatalogInfo.indexInManifestValue = ([catalogs count] + 1);
            }
        }
        
        for (StringObjectMO *aManagedInstall in currentManifest.managedInstallsFaster) {
            id matchingObject = [self matchingAppOrPkgForString:aManagedInstall.title];
            if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
                aManagedInstall.originalApplication = matchingObject;
            } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
                aManagedInstall.originalPackage = matchingObject;
            }
        }
        for (StringObjectMO *aManagedUninstall in currentManifest.managedUninstallsFaster) {
            id matchingObject = [self matchingAppOrPkgForString:aManagedUninstall.title];
            if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
                aManagedUninstall.originalApplication = matchingObject;
            } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
                aManagedUninstall.originalPackage = matchingObject;
            }
        }
        for (StringObjectMO *aManagedUpdate in currentManifest.managedUpdatesFaster) {
            id matchingObject = [self matchingAppOrPkgForString:aManagedUpdate.title];
            if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
                aManagedUpdate.originalApplication = matchingObject;
            } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
                aManagedUpdate.originalPackage = matchingObject;
            }
        }
        for (StringObjectMO *anOptionalInstall in currentManifest.optionalInstallsFaster) {
            id matchingObject = [self matchingAppOrPkgForString:anOptionalInstall.title];
            if ([matchingObject isKindOfClass:[ApplicationMO class]]) {
                anOptionalInstall.originalApplication = matchingObject;
            } else if ([matchingObject isKindOfClass:[PackageMO class]]) {
                anOptionalInstall.originalPackage = matchingObject;
            }
        }
    }];
    
    
    self.currentJobDescription = [NSString stringWithFormat:@"Merging changes..."];
    
    // Save the context, this causes main app delegate to merge new items
    NSError *error = nil;
    if (![moc save:&error]) {
        [NSApp presentError:error];
    }
    
    if ([self.delegate respondsToSelector:@selector(relationshipScannerDidFinish:)]) {
        [self.delegate performSelectorOnMainThread:@selector(relationshipScannerDidFinish:) 
                                        withObject:@"manifests"
                                     waitUntilDone:YES];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:moc];
    [moc release], moc = nil;
    
    
}

- (void)scanPkginfos
{
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
    [moc setPersistentStoreCoordinator:[[self delegate] persistentStoreCoordinator]];
    [moc setUndoManager:nil];
    [moc setMergePolicy:NSOverwriteMergePolicy];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:moc];
    NSEntityDescription *catalogEntityDescr = [NSEntityDescription entityForName:@"Catalog" inManagedObjectContext:moc];
    NSEntityDescription *packageEntityDescr = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc];
    
    // Get all packages for later use
    NSFetchRequest *getPackages = [[NSFetchRequest alloc] init];
    [getPackages setEntity:packageEntityDescr];
    [getPackages setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"packageInfos", nil]];
    self.allPackages = [moc executeFetchRequest:getPackages error:nil];
    [getPackages release];
    
    // Get all catalogs
    NSFetchRequest *getAllCatalogs = [[NSFetchRequest alloc] init];
    [getAllCatalogs setEntity:catalogEntityDescr];
    [getPackages setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"packageInfos", @"catalogInfos", @"packages", nil]];
    self.allCatalogs = [moc executeFetchRequest:getAllCatalogs error:nil];
    [getAllCatalogs release];
    
    
    [self.allPackages enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        self.currentJobDescription = [NSString stringWithFormat:@"Processing %i/%i", idx+1, [self.allPackages count]];
        PackageMO *currentPackage = (PackageMO *)obj;
        NSArray *existingCatalogTitles = [currentPackage.catalogInfos valueForKeyPath:@"catalog.title"];
        NSDictionary *originalPkginfo = (NSDictionary *)currentPackage.originalPkginfo;
        
        for (CatalogMO *aCatalog in self.allCatalogs) {
            if (![existingCatalogTitles containsObject:aCatalog.title]) {
                CatalogInfoMO *newCatalogInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CatalogInfo" inManagedObjectContext:moc];
                newCatalogInfo.package = currentPackage;
                newCatalogInfo.catalog.title = aCatalog.title;
                
                [aCatalog addPackagesObject:currentPackage];
                [aCatalog addCatalogInfosObject:newCatalogInfo];
                
                PackageInfoMO *newPackageInfo = [NSEntityDescription insertNewObjectForEntityForName:@"PackageInfo" inManagedObjectContext:moc];
                newPackageInfo.catalog = aCatalog;
                newPackageInfo.title = [currentPackage.munki_display_name stringByAppendingFormat:@" %@", currentPackage.munki_version];
                newPackageInfo.package = currentPackage;
                
                if ([[originalPkginfo objectForKey:@"catalogs"] containsObject:aCatalog.title]) {
                    newCatalogInfo.isEnabledForPackageValue = YES;
                    newCatalogInfo.originalIndexValue = [[originalPkginfo objectForKey:@"catalogs"] indexOfObject:aCatalog.title];
                    newPackageInfo.isEnabledForCatalogValue = YES;
                } else {
                    newCatalogInfo.isEnabledForPackageValue = NO;
                    newCatalogInfo.originalIndexValue = 10000;
                    newPackageInfo.isEnabledForCatalogValue = NO;
                }
            }
        }
    }];
    
    self.currentJobDescription = [NSString stringWithFormat:@"Merging changes..."];
    
    // Save the context, this causes main app delegate to merge new items
    NSError *error = nil;
    if (![moc save:&error]) {
        [NSApp presentError:error];
    }
    
    if ([self.delegate respondsToSelector:@selector(relationshipScannerDidFinish:)]) {
        [self.delegate performSelectorOnMainThread:@selector(relationshipScannerDidFinish:) 
                                        withObject:@"pkgs"
                                     waitUntilDone:YES];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:moc];
    [moc release], moc = nil;
}


-(void)main {
	@try {
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
        switch (self.operationMode) {
            case 0:
                [self scanPkginfos];
                break;
            case 1:
                [self scanManifests];
            default:
                break;
        }
        
		[pool release];
	}
	@catch(...) {
		// Do not rethrow exceptions.
	}
}

@end
