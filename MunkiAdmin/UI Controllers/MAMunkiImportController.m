//
//  MAMunkiImportController.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 8.5.2017.
//
//

#import "MAMunkiImportController.h"
#import "MAMunkiAdmin_AppDelegate.h"
#import "MAMunkiRepositoryManager.h"
#import "MACoreDataManager.h"
#import "CocoaLumberjack.h"
#import "MATaskOperation.h"

DDLogLevel ddLogLevel;

@interface MAMunkiImportController ()

@end

@implementation MAMunkiImportController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.placeHolderView.drawTopLine = YES;
    self.placeHolderView.drawBottomLine = YES;
    self.placeHolderView.drawLeftLine = YES;
    self.placeHolderView.drawRightLine = YES;
    self.placeHolderView.fillColor = [NSColor whiteColor];
    self.placeHolderView.lineColor = [NSColor blackColor];
    
    self.progressIndicator.usesThreadedAnimation = YES;
    
    [self.window registerForDraggedTypes:@[NSURLPboardType]];
    [self.startViewImageView unregisterDraggedTypes];
    
    [self resetStatus];
}


- (IBAction)continueAction:(id)sender
{
    if ([[sender title] isEqualToString:@"Finish"]) {
        [self munkiimport];
    } else {
        NSUInteger currentIndex = [self.viewArray indexOfObject:self.currentView];
        if ((currentIndex + 1) < self.viewArray.count) {
            NSView *next = [self.viewArray objectAtIndex:(currentIndex + 1)];
            [self setContentView:next];
        }
    }
}

- (IBAction)goBackAction:(id)sender
{
    
    NSUInteger currentIndex = [self.viewArray indexOfObject:self.currentView];
    if (currentIndex > 0) {
        NSView *previous = [self.viewArray objectAtIndex:(currentIndex - 1)];
        [self setContentView:previous];
        
    }
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    if ([[pboard types] containsObject:NSURLPboardType]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

/*
-(NSDragOperation) draggingUpdated:(id<NSDraggingInfo>)sender
{
    //NSLog(@"draggingUpdated");
    return NSDragOperationEvery;
}
 */

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSURLPboardType] ) {
        //NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        
        NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
        NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey : @NO};
        NSArray *urls = [pboard readObjectsForClasses:classes options:options];
        for (NSURL *uri in urls) {
            DDLogDebug(@"%@", uri);
            self.itemToImport = uri;
            [self makepkginfoForURL:uri arguments:nil];
        }
        
    }
    return YES;
}

- (IBAction)cancelAction:(id)sender
{
    [[self window] orderOut:self];
    [NSApp stopModalWithCode:NSModalResponseCancel];
}

- (void)resetStatus
{
    self.itemToImport = nil;
    self.name = nil;
    self.displayName = nil;
    self.version = nil;
    self.restartAction = nil;
    self.uninstallMethod = nil;
    self.installerItemSize = nil;
    self.installedSize = nil;
    self.nopkg = NO;
    
    [self updateSubdirectoryComboBoxAutoCompleteList];
    [self updateNameComboBoxAutoCompleteList];
    self.restartActionSuggestions = [@[@"RequireShutdown", @"RequireRestart", @"RecommendRestart", @"RequireLogout", @"None"] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    
    self.viewArray = @[self.startView, self.defaultOptionsView, self.scriptsView];
    self.currentView = self.startView;
    
    [self setContentView:self.startView];
    self.cancelButton.enabled = YES;
}

- (void)setContentView:(NSView *)newContentView
{
    for (id view in [self.placeHolderView subviews]) {
        [view removeFromSuperview];
    }
    
    [self.placeHolderView addSubview:newContentView];
    
    [newContentView setFrame:[self.placeHolderView frame]];
    
    [newContentView setFrameOrigin:NSMakePoint(0,0)];
    [newContentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [newContentView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [newContentView setAutoresizesSubviews:YES];
    self.currentView = newContentView;
    
    if (self.currentView == self.progressView) {
        return;
    }
    
    NSUInteger currentIndex = [self.viewArray indexOfObject:self.currentView];
    self.continueButton.title = @"Continue";
    self.goBackButton.title = @"Go Back";
    self.cancelButton.title = @"Cancel";
    self.cancelButton.enabled = YES;
    
    // Can we go forward
    if ((currentIndex + 1) < self.viewArray.count) {
        self.continueButton.enabled = YES;
    } else {
        self.continueButton.enabled = NO;
    }
    
    // Can we go back
    if (currentIndex == 0) {
        self.goBackButton.enabled = NO;
    } else {
        self.goBackButton.enabled = YES;
    }
    
    // Are we on the last view
    if ((currentIndex + 1) == self.viewArray.count) {
        self.continueButton.enabled = YES;
        self.continueButton.title = @"Finish";
    }
}



- (void)updateSubdirectoryComboBoxAutoCompleteList
{
    MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Directory" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"originalURL != %@", [NSNull null]]];
    NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:nil];
    NSMutableArray *newSubdirectorySuggestions = [NSMutableArray new];
    for (DirectoryMO *directory in fetchResults) {
        NSString *relativePath = [[MAMunkiRepositoryManager sharedManager] relativePathToChildURL:directory.originalURL parentURL:[appDelegate pkgsInfoURL]];
        if (![newSubdirectorySuggestions containsObject:relativePath] && ![relativePath isEqualToString:@""]) {
            [newSubdirectorySuggestions addObject:relativePath];
        }
    }
    [newSubdirectorySuggestions sortUsingSelector:@selector(localizedStandardCompare:)];
    self.subdirectorySuggestions = newSubdirectorySuggestions;
}

- (void)updateNameComboBoxAutoCompleteList
{
    MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:nil];
    
    NSArray *distinctNames = [[fetchResults valueForKeyPath:@"@distinctUnionOfObjects.munki_name"] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    self.nameSuggestions = distinctNames;
    
    NSArray *distinctDisplayNames = [[fetchResults valueForKeyPath:@"@distinctUnionOfObjects.munki_display_name"] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    self.displayNameSuggestions = distinctDisplayNames;
    
}

# pragma mark -
# pragma mark Task

- (NSArray *)munkiimportArguments
{
    NSMutableArray *new = [NSMutableArray new];
    
    MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
    [new addObjectsFromArray:@[@"--nointeractive", @"--repo_url", appDelegate.repoURL.absoluteString]];
    
    if (self.nopkg) {
        [new addObject:@"--nopkg"];
    }
    
    if (self.subdirectory && ![self.subdirectory isEqualToString:@""]) {
        [new addObjectsFromArray:@[@"--subdirectory", self.subdirectory]];
    }
    
    if (self.name && ![self.name isEqualToString:@""]) {
        [new addObjectsFromArray:@[@"--name", self.name]];
    }
    if (self.displayName && ![self.displayName isEqualToString:@""]) {
        [new addObjectsFromArray:@[@"--displayname", self.displayName]];
    }
    if (self.version && ![self.version isEqualToString:@""]) {
        [new addObjectsFromArray:@[@"--pkgvers", self.version]];
    }
    if (self.restartAction && ![self.restartAction isEqualToString:@""]) {
        [new addObjectsFromArray:@[@"--RestartAction", self.restartAction]];
    }
    if (self.uninstallMethod && ![self.uninstallMethod isEqualToString:@""]) {
        [new addObjectsFromArray:@[@"--uninstall_method", self.uninstallMethod]];
    }
    
    if (self.itemToImport) {
        [new addObject:[self.itemToImport path]];
    }
    
    return [NSArray arrayWithArray:new];
}

- (void)makepkginfoSucceeded:(NSDictionary *)pkginfo
{
    if (pkginfo) {
        if (pkginfo[@"name"]) {
            self.name = pkginfo[@"name"];
        }
        if (pkginfo[@"display_name"]) {
            self.displayName = pkginfo[@"display_name"];
        }
        if (pkginfo[@"version"]) {
            self.version = pkginfo[@"version"];
        }
        if (pkginfo[@"RestartAction"]) {
            self.restartAction = pkginfo[@"RestartAction"];
        }
        if (pkginfo[@"uninstall_method"]) {
            self.uninstallMethod = pkginfo[@"uninstall_method"];
        }
        if (pkginfo[@"installer_item_size"]) {
            self.installerItemSize = pkginfo[@"installer_item_size"];
        }
        if (pkginfo[@"installed_size"]) {
            self.installedSize = pkginfo[@"installed_size"];
        }
    }
    
    [self.progressIndicator stopAnimation:nil];
    [self setContentView:self.defaultOptionsView];
}

- (void)makepkginfoFailed
{
    [self.progressIndicator stopAnimation:nil];
    [self setContentView:self.startView];
}

- (void)enableButtons
{
    self.continueButton.enabled = YES;
    self.cancelButton.enabled = YES;
    self.goBackButton.enabled = YES;
}

- (void)disableButtons
{
    self.continueButton.enabled = NO;
    self.cancelButton.enabled = NO;
    self.goBackButton.enabled = NO;
}

- (NSData *)firstPropertyListInData:(NSData *)data
{
    if (!data) {
        return nil;
    }
    NSString *dataAsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSScanner *scanner = [NSScanner scannerWithString:dataAsString];
    
    NSString *scanned;
    [scanner scanUpToString:@"<?xml" intoString:nil];
    if (![scanner scanUpToString:@"</plist>" intoString:&scanned]) {
        return nil;
    }
    
    NSString *fullDictionaryAsString = [scanned stringByAppendingString:@"</plist>"];
    NSData *dictionaryAsData = [fullDictionaryAsString dataUsingEncoding:NSUTF8StringEncoding];
    return dictionaryAsData;
}


- (NSDictionary *)dictionaryFromData:(NSData *)data
{
    if (!data) {
        return nil;
    }
    
    NSData *firstPropertyList = [self firstPropertyListInData:data];
    if (!firstPropertyList) {
        return nil;
    }
    
    NSError *error;
    NSPropertyListFormat format;
    id plist;
    plist = [NSPropertyListSerialization propertyListWithData:firstPropertyList options:NSPropertyListImmutable format:&format error:&error];
    
    if (!plist) {
        DDLogError(@"NSPropertyListSerialization error: %@", [error description]);
        return nil;
    } else {
        return (NSDictionary *)plist;
    }
}

- (NSString *)cleanMakecatalogsMessage:(NSString *)message
{
    NSString *cleanedString = message;
    return [cleanedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)munkiimport
{
    [self setContentView:self.progressView];
    [self.progressIndicator startAnimation:nil];
    [self disableButtons];
    
    MATaskOperation *munkiimportOperation = [[MATaskOperation alloc] init];
    munkiimportOperation.launchPath = @"/usr/local/munki/munkiimport";
    munkiimportOperation.arguments = [self munkiimportArguments];
    
    __block NSMutableData *standardOutData = [NSMutableData new];
    munkiimportOperation.standardOutputDataCallback = ^(NSData *standardOutputData) {
        [standardOutData appendData:standardOutputData];
    };
    __block NSMutableString *standardOutFull = [NSMutableString new];
    munkiimportOperation.standardOutputCallback = ^(NSString *standardOutput) {
        [standardOutFull appendString:standardOutput];
        NSString *cleanedString = [self cleanMakecatalogsMessage:standardOutput];
        if (cleanedString.length > 0) {
            DDLogError(@"%@", cleanedString);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressDescription.stringValue = cleanedString;
            });
        }
    };
    __block NSMutableString *standardErrorFull = [NSMutableString new];
    munkiimportOperation.standardErrorCallback = ^(NSString *standardError) {
        DDLogError(@"%@", standardError);
        [standardErrorFull appendString:standardError];
    };
    munkiimportOperation.terminationCallback = ^(NSTask *task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            int exitCode = task.terminationStatus;
            if (exitCode == 0) {
                DDLogDebug(@"%@ succeeded.", task.launchPath);
                DDLogError(@"%@", standardOutFull);
            } else {
                DDLogError(@"%@", standardErrorFull);
            }
            
            [self.progressIndicator stopAnimation:nil];
            [self setContentView:self.defaultOptionsView];
        });
    };
    
    [munkiimportOperation start];
}

- (void)makepkginfoForURL:(NSURL *)url arguments:(NSArray *)arguments
{
    [self setContentView:self.progressView];
    [self.progressIndicator startAnimation:nil];
    [self disableButtons];
    
    MATaskOperation *makepkginfo = [[MATaskOperation alloc] init];
    makepkginfo.launchPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"makepkginfoPath"];
    makepkginfo.arguments = @[url.path];
    
    __block NSMutableData *standardOutData = [NSMutableData new];
    makepkginfo.standardOutputDataCallback = ^(NSData *standardOutputData) {
        [standardOutData appendData:standardOutputData];
    };
    __block NSMutableString *standardErrorFull = [NSMutableString new];
    makepkginfo.standardErrorCallback = ^(NSString *standardError) {
        DDLogError(@"%@", standardError);
        [standardErrorFull appendString:standardError];
    };
    makepkginfo.terminationCallback = ^(NSTask *task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            int exitCode = task.terminationStatus;
            if (exitCode == 0) {
                DDLogDebug(@"%@ succeeded.", task.launchPath);
                
                // Parse data
                NSDictionary *pkginfo = [self dictionaryFromData:standardOutData];
                [self makepkginfoSucceeded:pkginfo];
                
                if (standardErrorFull.length != 0) {
                    // Check for warnings in makecatalogs stderr
                    NSRange range = NSMakeRange(0, standardErrorFull.length);
                    __block NSMutableString *warnings = [NSMutableString new];
                    [standardErrorFull enumerateSubstringsInRange:range
                                                      options:NSStringEnumerationByParagraphs
                                                   usingBlock:^(NSString * _Nullable paragraph, NSRange paragraphRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                                                       if ([paragraph hasPrefix:@"WARNING: "]) {
                                                           [warnings appendFormat:@"\n%@", paragraph];
                                                       }
                                                   }];
                    if (warnings.length != 0) {
                        DDLogDebug(@"%@ produced warnings.", task.launchPath);
                        DDLogError(@"%@", warnings);
                    }
                }
                
            } else {
                [self makepkginfoFailed];
                DDLogError(@"%@ exited with code %i", task.launchPath, exitCode);
                DDLogError(@"%@", standardErrorFull);
            }
        });
    };
    
    [makepkginfo start];
    
}

@end
