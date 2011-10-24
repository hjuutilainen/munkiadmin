//
//  ManifestDetailView.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 18.10.2011.
//

#import "ManifestDetailView.h"
#import "ManifestMO.h"
#import "StringObjectMO.h"

@implementation ManifestDetailView

@synthesize managedInstallsController;
@synthesize managedUpdatesController;
@synthesize managedUninstallsController;
@synthesize optionalInstallsController;
@synthesize catalogsController;
@synthesize includedManifestsController;
@synthesize nestedManifestsTableView;

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
    
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
    [self.managedInstallsController setSortDescriptors:[NSArray arrayWithObjects:sortByIndex, sortByTitle, nil]];
    [self.managedUpdatesController setSortDescriptors:[NSArray arrayWithObjects:sortByIndex, sortByTitle, nil]];
    [self.managedUninstallsController setSortDescriptors:[NSArray arrayWithObjects:sortByIndex, sortByTitle, nil]];
    [self.optionalInstallsController setSortDescriptors:[NSArray arrayWithObjects:sortByIndex, sortByTitle, nil]];
    
    NSSortDescriptor *sortByIndexInNestedManifest = [NSSortDescriptor sortDescriptorWithKey:@"indexInNestedManifest" ascending:YES selector:@selector(compare:)];
    [self.includedManifestsController setSortDescriptors:[NSArray arrayWithObjects:sortByIndexInNestedManifest, sortByTitle, nil]];
    
    NSSortDescriptor *sortCatalogsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"catalog.title" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.catalogsController setSortDescriptors:[NSArray arrayWithObjects:sortByIndex, sortCatalogsByTitle, nil]];
}



#pragma mark -
#pragma mark NSTableView Delegate

- (BOOL)tableView:(NSTableView *)theTableView writeRowsWithIndexes:(NSIndexSet *)theRowIndexes toPasteboard:(NSPasteboard*)thePasteboard
{
	[thePasteboard declareTypes:[NSArray arrayWithObject:NSURLPboardType] owner:self];
	NSMutableArray *urls = [NSMutableArray array];
    [theRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        StringObjectMO *aNestedManifest = [[self.includedManifestsController arrangedObjects] objectAtIndex:idx];
		[urls addObject:[[aNestedManifest objectID] URIRepresentation]];
    }];
	return [thePasteboard writeObjects:urls];
}

- (NSDragOperation)tableView:(NSTableView*)theTableView 
				validateDrop:(id <NSDraggingInfo>)theDraggingInfo 
				 proposedRow:(int)theRow 
	   proposedDropOperation:(NSTableViewDropOperation)theDropOperation
{
	int result = NSDragOperationNone;
	
    if (theDropOperation == NSTableViewDropAbove) {
        result = NSDragOperationMove;
    }
	
    return (result);
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

- (void)renumberItems
{
	NSInteger index = 0;
	for (StringObjectMO *aNestedManifest in [self.includedManifestsController arrangedObjects]) {
		aNestedManifest.indexInNestedManifest = [NSNumber numberWithInt:index];
		index++;
	}
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)draggingInfo
			  row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
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
	
	[self renumberItems];
	
	return YES;
}



@end
