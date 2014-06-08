//
//  MAIconChooser.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 10.5.2014.
//
//

#import "MAIconChooser.h"
#import "MAMunkiRepositoryManager.h"
#import "MAMunkiAdmin_AppDelegate.h"

@interface MAIconChooser ()

@end

@implementation MAIconChooser

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        _useInSiblingPackages = YES;
    }
    return self;
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

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    /*
     Configure the initial settings
     */
    self.imageBrowserViewZoom = 0.5;
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
    self.imagesArrayController.sortDescriptors = @[sortByPath];
    
    [[MAMunkiRepositoryManager sharedManager] scanIconsDirectoryForImages];
}

- (IBAction)chooseAction:(id)sender
{
    if ([self.imagesArrayController.selectedObjects count] == 0) {
        /*
         TODO: Nothing chosen, should present an error
         */
        return;
    }
    
    IconImageMO *selectedImage = self.imagesArrayController.selectedObjects[0];
    NSURL *selectedURL = selectedImage.originalURL;
    
    MAMunkiAdmin_AppDelegate *appDelegate = (MAMunkiAdmin_AppDelegate *)[NSApp delegate];
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    MAMunkiRepositoryManager *repoManager = [MAMunkiRepositoryManager sharedManager];
    
    /*
     Use the selected icon in every package with the selected names
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
            
            if ([selectedURL isEqualTo:defaultIconURL]) {
                /*
                 Selected icon URL is the default location for this package name
                 */
                for (PackageMO *aSibling in siblingPackages) {
                    [repoManager clearCustomIconForPackage:aSibling];
                }
            } else {
                /*
                 Selected icon requires setting a custom icon_name for this package
                 */
                for (PackageMO *aSibling in siblingPackages) {
                    [repoManager setIconNameFromURL:selectedURL forPackage:aSibling];
                }
            }
        }];
    }
    /*
     Use the icon for the selected packages only
     */
    else {
        [self.packagesToEdit enumerateObjectsUsingBlock:^(PackageMO *obj, NSUInteger idx, BOOL *stop) {
            NSURL *mainIconsURL = [appDelegate iconsURL];
            NSURL *defaultIconURL = [mainIconsURL URLByAppendingPathComponent:obj.munki_name];
            defaultIconURL = [defaultIconURL URLByAppendingPathExtension:@"png"];
            
            if ([selectedURL isEqualTo:defaultIconURL]) {
                /*
                 Selected icon URL is the default location for this package
                 */
                [repoManager clearCustomIconForPackage:obj];
            } else {
                /*
                 Selected icon requires setting a custom icon_name for this package
                 */
                [repoManager setIconNameFromURL:selectedURL forPackage:obj];
            }
        }];
    }
    
    self.packagesToEdit = nil;
    
    /*
     Close the window
     */
    [[self window] orderOut:self];
    [NSApp stopModalWithCode:NSModalResponseOK];
}


- (IBAction)cancelAction:(id)sender
{
    self.packagesToEdit = nil;
    [[self window] orderOut:sender];
    [NSApp stopModalWithCode:NSModalResponseCancel];
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
    [self chooseAction:self];
    
}

@end
