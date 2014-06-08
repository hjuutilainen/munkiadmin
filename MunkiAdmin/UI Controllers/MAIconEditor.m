//
//  IconEditor.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 29.4.2014.
//
//

#import "MAIconEditor.h"
#import "MAMunkiAdmin_AppDelegate.h"
#import "MAMunkiRepositoryManager.h"
#import "MAImageBrowserItem.h"

@interface MAIconEditor ()

@end

@implementation MAIconEditor

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        _resizeOnSave = YES;
        _useInSiblingPackages = YES;
        _windowTitle = @"Window";
        [_progressIndicator setUsesThreadedAnimation:YES];
        [_imageBrowserView setDelegate:self];
        _imageBrowserItems = nil;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    /*
     Configure the initial settings
     */
    self.imageBrowserView.zoomValue = 0.5;
    self.imageBrowserView.allowsMultipleSelection = NO;
    self.imageBrowserView.allowsReordering = NO;
    self.imageBrowserView.animates = YES;
    self.imageBrowserView.draggingDestinationDelegate = self;
    self.imageBrowserView.cellsStyleMask = IKCellsStyleTitled;
    self.imageBrowserView.intercellSpacing = NSMakeSize(20.0, 20.0);
    self.imageBrowserView.delegate = self;
    //self.imageBrowserView.canControlQuickLookPanel = YES;
    
    /*
     Set the image browser view background color
     */
    CALayer *backgroundLayer = [CALayer layer];
    CGColorRef backgroundColor = CGColorCreateGenericGray(1.0, 1.0);
    backgroundLayer.backgroundColor = backgroundColor;
    self.imageBrowserView.backgroundLayer = backgroundLayer;
    CGColorRelease(backgroundColor);
    
    /*
     Change the title font
     */
    NSMutableParagraphStyle *paraphStyle = [[NSMutableParagraphStyle alloc] init];
	[paraphStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[paraphStyle setAlignment:NSCenterTextAlignment];
	
	NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
	[attributes setObject:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] forKey:NSFontAttributeName];
	[attributes setObject:paraphStyle forKey:NSParagraphStyleAttributeName];
	[attributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	[self.imageBrowserView setValue:attributes forKey:IKImageBrowserCellsTitleAttributesKey];
	
	NSMutableDictionary *highlightedAttributes = [[NSMutableDictionary alloc] init];
	[highlightedAttributes setObject:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] forKey:NSFontAttributeName];
	[highlightedAttributes setObject:paraphStyle forKey:NSParagraphStyleAttributeName];
	[highlightedAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	[self.imageBrowserView setValue:highlightedAttributes forKey:IKImageBrowserCellsHighlightedTitleAttributesKey];
    
    /*
     Set sorting
     */
    NSSortDescriptor *sortByPath = [NSSortDescriptor sortDescriptorWithKey:@"imageTitle" ascending:YES selector:@selector(localizedStandardCompare:)];
    self.imageBrowserItemsArrayController.sortDescriptors = @[sortByPath];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
    /*
     Update the window title if package array changes
     */
    if ([key isEqualToString:@"windowTitle"])
    {
        NSSet *affectingKeys = [NSSet setWithObjects:@"packagesToEdit", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }
	
    return keyPaths;
}

- (NSString *)windowTitle
{
    __block NSString *newTitle = @"Icon for";
    NSArray *packageNames = [self.packagesToEdit valueForKeyPath:@"@distinctUnionOfObjects.munki_name"];
    [[packageNames sortedArrayUsingSelector:@selector(localizedStandardCompare:)] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            newTitle = [newTitle stringByAppendingFormat:@" %@", obj];
        } else if (idx == ([packageNames count] - 1)) {
            newTitle = [newTitle stringByAppendingFormat:@" and %@", obj];
        } else {
            newTitle = [newTitle stringByAppendingFormat:@", %@", obj];
        }
    }];
    return newTitle;
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
        float width  = imageSize.width;
        float height = imageSize.height;
        
        float targetWidth  = targetSize.width;
        float targetHeight = targetSize.height;
        
        float scaleFactor  = 0.0;
        float scaledWidth  = targetWidth;
        float scaledHeight = targetHeight;
        
        NSPoint thumbnailPoint = NSZeroPoint;
        
        if (NSEqualSizes(imageSize, targetSize) == NO )
        {
            
            float widthFactor  = targetWidth / width;
            float heightFactor = targetHeight / height;
            
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


- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(NSInteger)returnCode
{
    /*
     Save the actual image
     */
    if (returnCode == NSOKButton)
    {
        MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
        NSManagedObjectContext *moc = [appDelegate managedObjectContext];
        MAMunkiRepositoryManager *repoManager = [MAMunkiRepositoryManager sharedManager];
        
        /*
         Create a PNG file from the image (resizing it if necessary)
         */
        NSData *imageData;
        NSSize newSize = NSMakeSize(512.0, 512.0);
        if (self.resizeOnSave && [self.currentImage size].width > newSize.width) {
            imageData = [[self scaleImage:self.currentImage toSize:newSize] TIFFRepresentation];
        } else {
            imageData = [self.currentImage TIFFRepresentation];
        }
        NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:imageData];
        NSData *pngData = [rep representationUsingType:NSPNGFileType properties:nil];
        NSError *writeError;
        if (![pngData writeToURL:[sheet URL] options:NSDataWritingAtomic error:&writeError]) {
            NSLog(@"%@", writeError);
            [NSApp presentError:writeError];
            return;
        }
        
        /*
         The write was successful.
         
         The first thing to do is to check if there is an existing image for the saved URL
         */
        NSFetchRequest *checkForExistingImage = [[NSFetchRequest alloc] init];
        [checkForExistingImage setEntity:[NSEntityDescription entityForName:@"IconImage" inManagedObjectContext:moc]];
        NSPredicate *siblingPred = [NSPredicate predicateWithFormat:@"originalURL == %@", [sheet URL]];
        [checkForExistingImage setPredicate:siblingPred];
        NSArray *foundIconImages = [moc executeFetchRequest:checkForExistingImage error:nil];
        if ([foundIconImages count] == 1) {
            /*
             User has probably replaced an existing icon during the save.
             We need to reload the image from disk
             */
            IconImageMO *foundIconImage = foundIconImages[0];
            foundIconImage.imageRepresentation = nil;
            NSImage *image = [[NSImage alloc] initByReferencingURL:[sheet URL]];
            foundIconImage.imageRepresentation = image;
            
        } else if ([foundIconImages count] > 1) {
            NSLog(@"Found multiple IconImage objects for a single URL. This shouldn't happen...");
        } else {
            // This is the way it should be...
        }
        
        /*
         Use the created icon in every package with the selected names
         */
        if (self.useInSiblingPackages) {
            
            /*
             Get the individual 'name' keys for selected packages
             */
            NSArray *packageNames = [self.packagesToEdit valueForKeyPath:@"@distinctUnionOfObjects.munki_name"];
            NSURL *mainIconsURL = [appDelegate iconsURL];
            [packageNames enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
                
                NSURL *defaultIconURL = [mainIconsURL URLByAppendingPathComponent:obj];
                defaultIconURL = [defaultIconURL URLByAppendingPathExtension:@"png"];
                
                // Find all packages with this name
                NSFetchRequest *getSiblings = [[NSFetchRequest alloc] init];
                [getSiblings setEntity:[NSEntityDescription entityForName:@"Package" inManagedObjectContext:moc]];
                NSPredicate *siblingPred = [NSPredicate predicateWithFormat:@"munki_name == %@", obj];
                [getSiblings setPredicate:siblingPred];
                NSArray *siblingPackages = [moc executeFetchRequest:getSiblings error:nil];
                
                if ([[sheet URL] isEqualTo:defaultIconURL]) {
                    /*
                     User saved to the default location for this package name
                     */
                    for (PackageMO *aSibling in siblingPackages) {
                        [repoManager clearCustomIconForPackage:aSibling];
                    }
                } else {
                    /*
                     User chose a custom location and/or name for this package name
                     */
                    for (PackageMO *aSibling in siblingPackages) {
                        [repoManager setIconNameFromURL:[sheet URL] forPackage:aSibling];
                    }
                }
            }];
        }
        /*
         Use the created icon only for the selected packages only
         */
        else {
            [self.packagesToEdit enumerateObjectsUsingBlock:^(PackageMO *obj, NSUInteger idx, BOOL *stop) {
                NSURL *mainIconsURL = [appDelegate iconsURL];
                NSURL *defaultIconURL = [mainIconsURL URLByAppendingPathComponent:obj.munki_name];
                defaultIconURL = [defaultIconURL URLByAppendingPathExtension:@"png"];
                
                if ([[sheet URL] isEqualTo:defaultIconURL]) {
                    /*
                     User saved to the default location
                     */
                    [repoManager clearCustomIconForPackage:obj];
                } else {
                    /*
                     User chose a custom location and/or name
                     */
                    [repoManager setIconNameFromURL:[sheet URL] forPackage:obj];
                }
            }];
        }
        
        self.currentImage = nil;
        self.packagesToEdit = nil;
        
        /*
         Close the icon editor window
         */
        [[self window] orderOut:self];
        [NSApp stopModalWithCode:NSModalResponseOK];
        
    } else {
        // User cancelled the save
    }
}

- (IBAction)extractAction:(id)sender
{
    PackageMO *pkg = self.packagesToEdit[0];
    [self.window beginSheet:self.progressWindow completionHandler:^(NSModalResponse returnCode) {
        
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressIndicator setIndeterminate:YES];
        [self.progressDescription setStringValue:@"Starting..."];
        [self.progressIndicator startAnimation:self];
    });
    
    [[MAMunkiRepositoryManager sharedManager] iconSuggestionsForPackage:pkg completionHandler:^(NSArray *images) {
        dispatch_async(dispatch_get_main_queue(), ^{
            /*
             Single image was extracted, use it
             */
            if ([images count] == 1) {
                NSDictionary *imageDict = images[0];
                self.currentImage = imageDict[@"image"];
            }
            
            /*
             Multiple images extracted, ask the user to choose which one to use
             */
            else if ([images count] > 1) {
                self.imageBrowserItems = nil;
                NSMutableArray *newImages = [NSMutableArray new];
                for (NSDictionary *imageDict in images) {
                    MAImageBrowserItem *newItem = [[MAImageBrowserItem alloc] init];
                    newItem.image = imageDict[@"image"];
                    newItem.imageTitle = [(NSURL *)imageDict[@"URL"] lastPathComponent];
                    newItem.imageUID = [[NSUUID UUID] UUIDString];
                    [newImages addObject:newItem];
                }
                self.imageBrowserItems = [NSSet setWithArray:newImages];
                [self.window beginSheet:self.imageBrowserWindow completionHandler:^(NSModalResponse returnCode) {
                    if (returnCode == NSModalResponseOK) {
                        MAImageBrowserItem *selectedItem = [self.imageBrowserItemsArrayController selectedObjects][0];
                        self.currentImage = (NSImage *)[selectedItem imageRepresentation];
                    } else {
                        // User cancelled the selection
                    }
                }];
            }
            
            /*
             No images found
             */
            else {
                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = @"No images found";
                [alert addButtonWithTitle:@"OK"];
                [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {}];
            }
            
            /*
             Dismiss the progress sheet
             */
            [self.progressIndicator stopAnimation:self];
            [self.window endSheet:self.progressWindow returnCode:NSModalResponseOK];
        });
    } progressHandler:^(double progress, NSString *description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressDescription setStringValue:description];
        });
    }];
    
    
    
}

- (IBAction)saveAction:(id)sender
{
    MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
    
    /*
     Create the 'icons' directory in munki repo if it's missing
     */
    NSURL *iconsDirectory = [appDelegate iconsURL];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:[iconsDirectory path]]) {
        NSError *dirCreateError;
        if (![fm createDirectoryAtURL:iconsDirectory withIntermediateDirectories:NO attributes:nil error:&dirCreateError]) {
            NSLog(@"%@", dirCreateError);
            return;
        }
    }
    
    /*
     Present the save dialog
     */
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setDirectoryURL:[appDelegate iconsURL]];
	[savePanel setCanSelectHiddenExtension:NO];
    NSString *filename;
    NSArray *packageNames = [self.packagesToEdit valueForKeyPath:@"@distinctUnionOfObjects.munki_name"];
    if ([packageNames count] == 1) {
        filename = [(NSString *)packageNames[0] stringByAppendingPathExtension:@"png"];
    } else {
        filename = @"New Icon.png";
    }
    [savePanel setNameFieldStringValue:filename];
	
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton) {
            // Dismiss the sheet before doing anything else
            [savePanel orderOut:nil];
            // Process the save
            [self savePanelDidEnd:savePanel returnCode:result];
        }
	}];
}

- (IBAction)cancelAction:(id)sender
{
    self.currentImage = nil;
    self.packagesToEdit = nil;
    [[self window] orderOut:sender];
    [NSApp stopModalWithCode:NSModalResponseCancel];
}

- (void)openImageURL:(NSURL *)url
{
    /*
     Get the UTI
     */
    NSString *typeIdentifier;
    NSError *error;
    if (![url getResourceValue:&typeIdentifier forKey:NSURLTypeIdentifierKey error:&error]) {
        NSLog(@"%@", error);
        return;
    }
    
    /*
     If the user gave us an image file, use it as is.
     */
    if ([[NSWorkspace sharedWorkspace] type:typeIdentifier conformsToType:@"public.image"]) {
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
        NSImageRep *bestRepresentation = [image bestRepresentationForRect:NSMakeRect(0, 0, 1024.0, 1024.0) context:nil hints:nil];
        [image setSize:[bestRepresentation size]];
        self.currentImage = image;
    }
    /*
     User gave us some other file, extract the icon from it.
     */
    else {
        NSImage *image = [[NSWorkspace sharedWorkspace] iconForFile:[url path]];
        [image setSize:NSMakeSize(1024.0, 1024.0)];
        self.currentImage = image;
    }
}

- (void)chooseSourceImage
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.message = @"Choose an image to create an icon or choose any other file to extract its icon.";
	[openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton) {
            [openPanel orderOut:nil];
            [self openImageURL:[openPanel URL]];
        }
	}];
}

- (IBAction)chooseFileAction:(id)sender
{
	[self chooseSourceImage];
}


# pragma mark -
# pragma mark Image browser window

- (IBAction)chooseImageFromImageBrowserAction:(id)sender
{
    [self.window endSheet:self.imageBrowserWindow returnCode:NSModalResponseOK];
}

- (IBAction)cancelImageBrowserAction:(id)sender
{
    [self.window endSheet:self.imageBrowserWindow returnCode:NSModalResponseCancel];
}


- (void)imageBrowserSelectionDidChange:(IKImageBrowserView *)aBrowser
{
    //NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)imageBrowser:(IKImageBrowserView *)aBrowser cellWasRightClickedAtIndex:(NSUInteger)index withEvent:(NSEvent *)event
{
    //NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)imageBrowser:(IKImageBrowserView *)aBrowser cellWasDoubleClickedAtIndex:(NSUInteger)index
{
    [self chooseImageFromImageBrowserAction:self];
    
}

@end
