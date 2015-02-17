//
//  MAIconBatchExtractor.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 4.2.2015.
//
//

#import "MAIconBatchExtractor.h"
#import "MAMunkiAdmin_AppDelegate.h"
#import "MAMunkiRepositoryManager.h"
#import "MACoreDataManager.h"
#import "NSImage+PixelSize.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

@interface MABatchItem : NSObject

@property (strong) NSString *title;
@property (strong) NSString *statusDescription;
@property (strong) NSNumber *shouldExtract;
@property (strong) NSImage *statusImage;
@property (strong) PackageMO *package;

@end

@implementation MABatchItem

@end

@interface MAIconBatchExtractor ()

@end

@implementation MAIconBatchExtractor

- (void)windowDidLoad {
    [super windowDidLoad];
    
    //[self resetExtractorStatus];
}

- (NSImage *)scaleImage:(NSImage *)image toSize:(NSSize)targetSize
{
    /*
     Proportionally scale an image. Taken from:
     http://theocacao.com/document.page/498
     */
    NSImage *sourceImage = image;
    NSImage *newImage = nil;
    
    if ([sourceImage isValid])
    {
        NSSize imageSize = [sourceImage size];
        CGFloat width  = imageSize.width;
        CGFloat height = imageSize.height;
        
        CGFloat targetWidth  = targetSize.width;
        CGFloat targetHeight = targetSize.height;
        
        CGFloat scaleFactor  = 0.0;
        CGFloat scaledWidth  = targetWidth;
        CGFloat scaledHeight = targetHeight;
        
        NSPoint thumbnailPoint = NSZeroPoint;
        
        if (!NSEqualSizes(imageSize, targetSize))
        {
            
            CGFloat widthFactor  = targetWidth / width;
            CGFloat heightFactor = targetHeight / height;
            
            if (widthFactor < heightFactor) {
                scaleFactor = widthFactor;
            } else {
                scaleFactor = heightFactor;
            }
            
            scaledWidth  = width  * scaleFactor;
            scaledHeight = height * scaleFactor;
            
            if (widthFactor < heightFactor) {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            } else if (widthFactor > heightFactor) {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
        
        newImage = [[NSImage alloc] initWithSize:targetSize];
        
        [newImage lockFocus];
        
        NSRect thumbnailRect;
        thumbnailRect.origin = thumbnailPoint;
        thumbnailRect.size.width = scaledWidth;
        thumbnailRect.size.height = scaledHeight;
        
        [sourceImage drawInRect:thumbnailRect
                       fromRect:NSZeroRect
                      operation:NSCompositeSourceOver
                       fraction:1.0];
        
        [newImage unlockFocus];
    }
    return newImage;
}

- (void)resetExtractorStatus
{
    self.remainingBatchItems = [NSMutableArray new];
    self.extractOperationsRunning = NO;
    self.cancelAllPending = NO;
    self.numExtractOperationsRunning = 0;
    self.overwriteExisting = NO;
    self.resizeOnSave = YES;
    self.extractOKButton.title = @"Extract";
    self.cancelButton.enabled = YES;
    [self.progressIndicator setIndeterminate:YES];
    
    NSSortDescriptor *sortDescr = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    self.batchItemsController.sortDescriptors = @[sortDescr];
    
    /*
     Get all packages grouped by name key
     */
    MACoreDataManager *coreDataManager = [MACoreDataManager sharedManager];
    MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
    NSManagedObjectContext *mainContext = [appDelegate managedObjectContext];
    NSMutableArray *newBatchItems = [NSMutableArray new];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"munki_name" ascending:YES];
    for (ApplicationMO *app in [coreDataManager allObjectsForEntity:@"Application" sortDescriptors:@[sort] inManagedObjectContext:mainContext]) {
        PackageMO *latestPackage = app.latestPackage;
        NSString *installerType = latestPackage.munki_installer_type;
        
        /*
         Check the installer type before doing anything
         */
        if ((![installerType isEqualToString:@"copy_from_dmg"]) && (installerType != nil)) {
            DDLogDebug(@"%@: Not including in icon extraction list because installer type %@ not supported...", latestPackage.titleWithVersion, installerType);
        } else {
            
            MABatchItem *batchItem = [MABatchItem new];
            batchItem.package = latestPackage;
            batchItem.title = latestPackage.munki_name;
            
            if (!batchItem.package.iconImage.originalURL) {
                DDLogDebug(@"%@: Package is using a built-in default icon. Enabling for extraction...", latestPackage.titleWithVersion);
                batchItem.shouldExtract = @YES;
            } else if (!batchItem.package.munki_icon_name) {
                DDLogDebug(@"%@: Package already has an icon. Disabling for extraction...", latestPackage.titleWithVersion);
                batchItem.shouldExtract = @NO;
            } else {
                DDLogDebug(@"%@: Package has a custom icon. Disabling for extraction...", latestPackage.titleWithVersion);
                batchItem.shouldExtract = @NO;
            }
            batchItem.statusImage = [NSImage imageNamed:NSImageNameStatusNone];
            batchItem.statusDescription = @"Idle";
            [newBatchItems addObject:batchItem];
            
        }
    }
    self.batchItems = newBatchItems;
}

- (void)saveImage:(NSImage *)image asIconForPackage:(PackageMO *)package
{
    MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    MAMunkiRepositoryManager *repoManager = [MAMunkiRepositoryManager sharedManager];
    
    
    NSString *iconFileName = [package.munki_name stringByAppendingPathExtension:@"png"];
    NSURL *saveURL = [[appDelegate iconsURL] URLByAppendingPathComponent:iconFileName];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:[saveURL path]] && !self.overwriteExisting) {
        DDLogError(@"%@: Overwrite not allowed and file already exists at path %@", package.titleWithVersion, [saveURL path]);
        return;
    }
    
    /*
     Create a PNG file from the image (resizing it if necessary)
     */
    NSData *imageData;
    NSSize newSize = NSMakeSize(512.0, 512.0);
    if (self.resizeOnSave && [image pixelSize].width > newSize.width) {
        DDLogDebug(@"Resizing image to fit 512x512...");
        imageData = [[self scaleImage:image toSize:newSize] TIFFRepresentation];
    } else {
        imageData = [image TIFFRepresentation];
    }
    NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:imageData];
    NSData *pngData = [rep representationUsingType:NSPNGFileType properties:nil];
    NSError *writeError;
    if (![pngData writeToURL:saveURL options:NSDataWritingAtomic error:&writeError]) {
        DDLogError(@"%@", writeError);
        return;
    }
    DDLogDebug(@"%@: Wrote image to %@", package.titleWithVersion, [saveURL path]);
    
    /*
     The write was successful.
     
     The first thing to do is to check if there is an existing image for the saved URL
     */
    NSFetchRequest *checkForExistingImage = [[NSFetchRequest alloc] init];
    [checkForExistingImage setEntity:[NSEntityDescription entityForName:@"IconImage" inManagedObjectContext:moc]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"originalURL == %@", saveURL];
    [checkForExistingImage setPredicate:predicate];
    NSArray *foundIconImages = [moc executeFetchRequest:checkForExistingImage error:nil];
    if ([foundIconImages count] == 1) {
        /*
         We replaced an existing icon during the save,
         need to reload the image from disk
         */
        DDLogDebug(@"Saved URL points to an existing image object. Need to reload the image from disk...");
        IconImageMO *foundIconImage = foundIconImages[0];
        foundIconImage.imageRepresentation = nil;
        NSData *imageData = [NSData dataWithContentsOfURL:saveURL];
        NSImage *image = [[NSImage alloc] initWithData:imageData];
        foundIconImage.imageRepresentation = image;
        
    } else if ([foundIconImages count] > 1) {
        DDLogError(@"Found multiple IconImage objects for a single URL. This shouldn't happen...");
        return;
    } else {
        // This is the way it should be...
    }
    
    
    // Find all packages with this name
    NSFetchRequest *packagesWithSameNameFetch = [[NSFetchRequest alloc] init];
    [packagesWithSameNameFetch setEntity:[NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc]];
    NSPredicate *siblingPred = [NSPredicate predicateWithFormat:@"munki_name == %@", package.munki_name];
    [packagesWithSameNameFetch setPredicate:siblingPred];
    NSArray *packagesWithSameName = [moc executeFetchRequest:packagesWithSameNameFetch error:nil];
    for (PackageMO *aSibling in packagesWithSameName) {
        [repoManager clearCustomIconForPackage:aSibling];
    }
    
    
}

- (void)startExtracting
{
    if ([self.remainingBatchItems count] == 0) {
        return;
    }
    
    MABatchItem *firstItem = self.remainingBatchItems[0];
    [self.remainingBatchItems removeObject:firstItem];
    [self extractIconForBatchItem:firstItem];
}

- (void)extractIconForBatchItem:(MABatchItem *)batchItem
{
    __block PackageMO *blockPackage = batchItem.package;
    NSString *installerType = blockPackage.munki_installer_type;
    
    /*
     Check the installer type before doing anything
     */
    if ((![installerType isEqualToString:@"copy_from_dmg"]) && (installerType != nil)) {
        DDLogDebug(@"Installer type %@ not supported...", installerType);
        return;
    }
    
    [[MAMunkiRepositoryManager sharedManager] iconSuggestionsForPackage:blockPackage completionHandler:^(NSArray *images) {
        dispatch_async(dispatch_get_main_queue(), ^{
            /*
             Single image was extracted, use it
             */
            if ([images count] == 1) {
                NSDictionary *imageDict = images[0];
                DDLogDebug(@"%@: Single image found...", blockPackage.titleWithVersion);
                [self saveImage:imageDict[@"image"] asIconForPackage:blockPackage];
                batchItem.statusImage = [NSImage imageNamed:NSImageNameStatusAvailable];
                batchItem.statusDescription = @"Succeeded";
            }
            
            /*
             Multiple images extracted
             */
            else if ([images count] > 1) {
                DDLogDebug(@"%@: Multiple images found...", blockPackage.titleWithVersion);
                batchItem.statusDescription = @"Skipped: Multiple icons found";
                batchItem.statusImage = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
            }
            
            /*
             No images found
             */
            else {
                DDLogDebug(@"%@: No images found...", blockPackage.titleWithVersion);
                batchItem.statusDescription = @"Failed: No icons found";
                batchItem.statusImage = [NSImage imageNamed:NSImageNameStatusUnavailable];
            }
            
            /*
             Check if we should still keep on extracting or has the user request a cancel
             */
            self.numExtractOperationsRunning--;
            
            if ([self.remainingBatchItems count] > 0 && !self.cancelAllPending) {
                MABatchItem *nextItem = self.remainingBatchItems[0];
                [self.remainingBatchItems removeObject:nextItem];
                [self extractIconForBatchItem:nextItem];
            } else if (self.cancelAllPending) {
                for (MABatchItem *batchItem in self.remainingBatchItems) {
                    batchItem.statusDescription = @"Cancelled";
                    batchItem.statusImage = [NSImage imageNamed:NSImageNameStatusUnavailable];
                }
                self.numExtractOperationsRunning = 0;
            }
            
            /*
             There are no more extractions to do.
             */
            if (self.numExtractOperationsRunning == 0) {
                self.extractOperationsRunning = NO;
                self.extractOKButton.title = @"Close";
                self.cancelButton.enabled = NO;
            }
        });
    } progressHandler:^(double progress, NSString *description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (description && ![description isEqualToString:@""]) {
                batchItem.statusDescription = description;
            }
        });
    }];
}

- (IBAction)enableAllAction:(id)sender
{
    NSSortDescriptor *sortDescr = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    for (MABatchItem *batchItem in [self.batchItems sortedArrayUsingDescriptors:@[sortDescr]]) {
        batchItem.shouldExtract = @YES;
    }
}

- (IBAction)disableAllAction:(id)sender
{
    NSSortDescriptor *sortDescr = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    for (MABatchItem *batchItem in [self.batchItems sortedArrayUsingDescriptors:@[sortDescr]]) {
        batchItem.shouldExtract = @NO;
    }
}

- (IBAction)cancelAction:(id)sender
{
    if (self.extractOperationsRunning) {
        self.cancelAllPending = YES;
    } else {
        [self resetExtractorStatus];
        [[self window] orderOut:self];
        [NSApp stopModalWithCode:NSModalResponseOK];
    }
}

- (IBAction)extractAction:(id)sender
{
    if ([[sender title] isEqualToString:@"Close"]) {
        [self resetExtractorStatus];
        [[self window] orderOut:self];
        [NSApp stopModalWithCode:NSModalResponseOK];
    
    } else if ([[sender title] isEqualToString:@"Extract"]) {
        
        /*
         Create the 'icons' directory in munki repo if it's missing
         */
        MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
        NSURL *iconsDirectory = [appDelegate iconsURL];
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:[iconsDirectory path]]) {
            NSError *dirCreateError;
            if (![fm createDirectoryAtURL:iconsDirectory withIntermediateDirectories:NO attributes:nil error:&dirCreateError]) {
                DDLogError(@"%@", dirCreateError);
                return;
            }
        }
        
        /*
         Compose an array of items to process
         */
        self.numExtractOperationsRunning = 0;
        NSSortDescriptor *sortDescr = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
        for (MABatchItem *batchItem in [self.batchItems sortedArrayUsingDescriptors:@[sortDescr]]) {
            if ([batchItem.shouldExtract boolValue]) {
                if (![fm fileExistsAtPath:[batchItem.package.packageURL path]]) {
                    DDLogError(@"%@: Installer item not found", batchItem.package.titleWithVersion);
                    batchItem.statusDescription = @"Skipped: Installer item not found";
                    batchItem.statusImage = [NSImage imageNamed:NSImageNameStatusUnavailable];
                } else {
                    if (batchItem.package.iconImage.originalURL && !self.overwriteExisting) {
                        DDLogDebug(@"%@: Skipped because package is not using a built-in icon and we're not allowed to overwrite...", batchItem.package.titleWithVersion);
                        batchItem.statusDescription = @"Skipped: Package already has an icon...";
                        batchItem.statusImage = [NSImage imageNamed:NSImageNameStatusNone];
                    } else {
                        DDLogDebug(@"%@: Queued for extraction...", batchItem.package.titleWithVersion);
                        batchItem.statusDescription = @"Queued";
                        batchItem.statusImage = [NSImage imageNamed:NSImageNameStatusNone];
                        self.extractOperationsRunning = YES;
                        self.numExtractOperationsRunning++;
                        [self.remainingBatchItems addObject:batchItem];
                    }
                }
            } else {
                DDLogDebug(@"%@: Skipped...", batchItem.package.titleWithVersion);
                batchItem.statusDescription = @"Skipped";
            }
        }
        /*
         Kick off the extraction process for the first item
         */
        [self startExtracting];
    }
}

@end
