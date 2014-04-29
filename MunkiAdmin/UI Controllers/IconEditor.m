//
//  IconEditor.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 29.4.2014.
//
//

#import "IconEditor.h"
#import "MunkiAdmin_AppDelegate.h"

@interface IconEditor ()

@end

@implementation IconEditor

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        self.resizeOnSave = YES;
        self.useInSiblingPackages = YES;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
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
        NSData *imageData;
        NSSize newSize = NSMakeSize(512.0, 512.0);
        if (self.resizeOnSave && [self.currentImage size].width > newSize.width) {
            imageData = [[self scaleImage:self.currentImage toSize:newSize] TIFFRepresentation];
        } else {
            imageData = [self.currentImage TIFFRepresentation];
        }
        NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:imageData];
        NSData *pngData = [rep representationUsingType:NSPNGFileType properties:nil];
        [pngData writeToURL:[sheet URL] atomically:YES];
        
        NSError *writeError;
        if (![pngData writeToURL:[sheet URL] options:NSDataWritingAtomic error:&writeError]) {
            NSLog(@"%@", writeError);
        }
        
        /*
         The write was successful
         
         If the icon save path is not the default one,
         set the icon_name key
         */
        if (self.useInSiblingPackages) {
            /*
             TODO
             */
        } else {
            /*
             TODO
             */
        }
        
        /*
         Close the icon editor window
         */
        [[self window] orderOut:self];
        [NSApp stopModalWithCode:NSModalResponseOK];
        
    } else {
        // User cancelled the save
    }
}

- (IBAction)saveAction:(id)sender
{
    /*
     Create the 'icons' directory in munki repo if it's missing
     */
    NSURL *iconsDirectory = [[NSApp delegate] iconsURL];
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
    [savePanel setDirectoryURL:[[NSApp delegate] iconsURL]];
	[savePanel setCanSelectHiddenExtension:YES];
    NSString *filename = [self.packageToEdit.munki_name stringByAppendingPathExtension:@"png"];
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
        self.currentImage = image;
    }
    /*
     User gave us some other file, extract the icon from it.
     */
    else {
        NSImage *image = [[NSWorkspace sharedWorkspace] iconForFile:[url path]];
        [image setScalesWhenResized:YES];
        [image setSize:NSMakeSize(1024.0, 1024.0)];
        self.currentImage = image;
    }
}

- (IBAction)chooseFileAction:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanSelectHiddenExtension:YES];
	[openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton) {
            [openPanel orderOut:nil];
            [self openImageURL:[openPanel URL]];
        }
	}];
}

@end
