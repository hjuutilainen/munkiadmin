//
//  ManifestDetailView.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 18.10.2011.
//

#import "ManifestDetailView.h"
#import "ManifestMO.h"
#import "StringObjectMO.h"
#import "CatalogMO.h"
#import "CatalogInfoMO.h"

@implementation ManifestDetailView

@synthesize managedInstallsController;
@synthesize managedUpdatesController;
@synthesize managedUninstallsController;
@synthesize optionalInstallsController;
@synthesize catalogsController;
@synthesize includedManifestsController;
@synthesize nestedManifestsTableView;
@synthesize catalogsTableView;
@synthesize conditionalItemsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self.nestedManifestsTableView registerForDraggedTypes:[NSArray arrayWithObject:NSURLPboardType]];
	[self.nestedManifestsTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    
    [self.catalogsTableView registerForDraggedTypes:[NSArray arrayWithObject:NSURLPboardType]];
    [self.catalogsTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sortManagedInstallsByTitle"]) {
        [self.managedInstallsController setSortDescriptors:[NSArray arrayWithObjects:sortByTitle, sortByIndex, nil]];
    } else {
        [self.managedInstallsController setSortDescriptors:[NSArray arrayWithObjects:sortByIndex, sortByTitle, nil]];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sortManagedUpdatesByTitle"]) {
        [self.managedUpdatesController setSortDescriptors:[NSArray arrayWithObjects:sortByTitle, sortByIndex, nil]];
    } else {
        [self.managedUpdatesController setSortDescriptors:[NSArray arrayWithObjects:sortByIndex, sortByTitle, nil]];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sortManagedUninstallsByTitle"]) {
        [self.managedUninstallsController setSortDescriptors:[NSArray arrayWithObjects:sortByTitle, sortByIndex, nil]];
    } else {
        [self.managedUninstallsController setSortDescriptors:[NSArray arrayWithObjects:sortByIndex, sortByTitle, nil]];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sortOptionalInstallsByTitle"]) {
        [self.optionalInstallsController setSortDescriptors:[NSArray arrayWithObjects:sortByTitle, sortByIndex, nil]];
    } else {
        [self.optionalInstallsController setSortDescriptors:[NSArray arrayWithObjects:sortByIndex, sortByTitle, nil]];
    }
    
    NSSortDescriptor *sortByIndexInNestedManifest = [NSSortDescriptor sortDescriptorWithKey:@"indexInNestedManifest" ascending:YES selector:@selector(compare:)];
    [self.includedManifestsController setSortDescriptors:[NSArray arrayWithObjects:sortByIndexInNestedManifest, sortByTitle, nil]];
    
    NSSortDescriptor *sortByIndexInManifest = [NSSortDescriptor sortDescriptorWithKey:@"indexInManifest" ascending:YES selector:@selector(compare:)];
    NSSortDescriptor *sortCatalogsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"catalog.title" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.catalogsController setSortDescriptors:[NSArray arrayWithObjects:sortByIndexInManifest, sortCatalogsByTitle, nil]];
    
    NSSortDescriptor *sortByCondition = [NSSortDescriptor sortDescriptorWithKey:@"munki_condition" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.conditionalItemsController setSortDescriptors:[NSArray arrayWithObjects:sortByCondition, nil]];
}



#pragma mark -
#pragma mark NSTableView Delegate

- (BOOL)tableView:(NSTableView *)theTableView writeRowsWithIndexes:(NSIndexSet *)theRowIndexes toPasteboard:(NSPasteboard*)thePasteboard
{
    if (theTableView == self.nestedManifestsTableView) {
        [thePasteboard declareTypes:[NSArray arrayWithObject:NSURLPboardType] owner:self];
        NSMutableArray *urls = [NSMutableArray array];
        [theRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            StringObjectMO *aNestedManifest = [[self.includedManifestsController arrangedObjects] objectAtIndex:idx];
            [urls addObject:[[aNestedManifest objectID] URIRepresentation]];
        }];
        return [thePasteboard writeObjects:urls];
    } else if (theTableView == self.catalogsTableView) {
        [thePasteboard declareTypes:[NSArray arrayWithObject:NSURLPboardType] owner:self];
        NSMutableArray *urls = [NSMutableArray array];
        [theRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            CatalogInfoMO *aCatalogInfo = [[self.catalogsController arrangedObjects] objectAtIndex:idx];
            [urls addObject:[[aCatalogInfo objectID] URIRepresentation]];
        }];
        return [thePasteboard writeObjects:urls];
    }
    
    else {
        return FALSE;
    }
}

- (NSDragOperation)tableView:(NSTableView*)theTableView 
				validateDrop:(id <NSDraggingInfo>)theDraggingInfo 
				 proposedRow:(int)theRow 
	   proposedDropOperation:(NSTableViewDropOperation)theDropOperation
{
	int result = NSDragOperationNone;
	if (theTableView == self.nestedManifestsTableView) {
        if (theDropOperation == NSTableViewDropAbove) {
            result = NSDragOperationMove;
        }
    } else if (theTableView == self.catalogsTableView) {
        if (theDropOperation == NSTableViewDropAbove) {
            result = NSDragOperationMove;
        }
    }
	
    return (result);
}

- (void)makeRoomForCatalogsAtIndex:(NSInteger)index
{
    NSManagedObjectContext *moc = [self.catalogsController managedObjectContext];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"CatalogInfo" inManagedObjectContext:moc];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	NSPredicate *indexPredicate = [NSPredicate predicateWithFormat:@"indexInManifest >= %@", [NSNumber numberWithInt:index]];
	[request setPredicate:indexPredicate];
	
	NSUInteger foundItems = [moc countForFetchRequest:request error:nil];
	if (foundItems == 0) {
		
	} else {
		NSArray *results = [moc executeFetchRequest:request error:nil];
		for (CatalogInfoMO *aCatalogInfo in results) {
			NSInteger currentIndex = [aCatalogInfo.indexInManifest integerValue];
			aCatalogInfo.indexInManifestValue = currentIndex + 1;
		}
	}
	[request release];
}

- (void)renumberCatalogItems
{
	NSInteger index = 0;
	for (CatalogInfoMO *aCatalogInfo in [self.catalogsController arrangedObjects]) {
		aCatalogInfo.indexInManifest = [NSNumber numberWithInt:index];
		index++;
	}
}

- (void)makeRoomForManifestsAtIndex:(NSInteger)index
{
	NSManagedObjectContext *moc = [self.includedManifestsController managedObjectContext];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"StringObject" inManagedObjectContext:moc];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	NSPredicate *indexPredicate = [NSPredicate predicateWithFormat:@"indexInNestedManifest >= %@", [NSNumber numberWithInt:index]];
	[request setPredicate:indexPredicate];
	
	NSUInteger foundItems = [moc countForFetchRequest:request error:nil];
	if (foundItems == 0) {
		
	} else {
		NSArray *results = [moc executeFetchRequest:request error:nil];
		for (StringObjectMO *aNestedManifest in results) {
			NSInteger currentIndex = [aNestedManifest.indexInNestedManifest integerValue];
			aNestedManifest.indexInNestedManifestValue = currentIndex + 1;
		}
	}
	[request release];
}

- (void)renumberManifestItems
{
	NSInteger index = 0;
	for (StringObjectMO *aNestedManifest in [self.includedManifestsController arrangedObjects]) {
		aNestedManifest.indexInNestedManifest = [NSNumber numberWithInt:index];
		index++;
	}
}

- (BOOL)tableView:(NSTableView *)theTableView acceptDrop:(id <NSDraggingInfo>)draggingInfo
			  row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    if (theTableView == self.nestedManifestsTableView) {
        NSArray *dragTypes = [[draggingInfo draggingPasteboard] types];
        if ([dragTypes containsObject:NSURLPboardType]) {
            
            NSPasteboard *pasteboard = [draggingInfo draggingPasteboard];
            NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
            NSDictionary *options = [NSDictionary dictionaryWithObject:
                                     [NSNumber numberWithBool:NO] forKey:NSPasteboardURLReadingFileURLsOnlyKey];
            NSArray *urls = [pasteboard readObjectsForClasses:classes options:options];
            for (NSURL *uri in urls) {
                NSManagedObjectContext *moc = [self.includedManifestsController managedObjectContext];
                NSManagedObjectID *objectID = [[moc persistentStoreCoordinator] managedObjectIDForURIRepresentation:uri];
                StringObjectMO *mo = (StringObjectMO *)[moc objectRegisteredForID:objectID];
                [self makeRoomForManifestsAtIndex:row];
                mo.indexInNestedManifest = [NSNumber numberWithInt:row];
                
            }
        }
        
        [self renumberManifestItems];
        
        return YES;
    } else if (theTableView == self.catalogsTableView) {
        NSArray *dragTypes = [[draggingInfo draggingPasteboard] types];
        if ([dragTypes containsObject:NSURLPboardType]) {
            
            NSPasteboard *pasteboard = [draggingInfo draggingPasteboard];
            NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
            NSDictionary *options = [NSDictionary dictionaryWithObject:
                                     [NSNumber numberWithBool:NO] forKey:NSPasteboardURLReadingFileURLsOnlyKey];
            NSArray *urls = [pasteboard readObjectsForClasses:classes options:options];
            for (NSURL *uri in urls) {
                NSManagedObjectContext *moc = [self.catalogsController managedObjectContext];
                NSManagedObjectID *objectID = [[moc persistentStoreCoordinator] managedObjectIDForURIRepresentation:uri];
                CatalogInfoMO *mo = (CatalogInfoMO *)[moc objectRegisteredForID:objectID];
                [self makeRoomForCatalogsAtIndex:row];
                mo.indexInManifest = [NSNumber numberWithInt:row];
                
            }
        }
        
        [self renumberCatalogItems];
        
        return YES;
    }
    
    else {
        return NO;
    }
}



@end
