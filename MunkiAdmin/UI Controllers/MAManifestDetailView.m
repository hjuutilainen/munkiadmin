//
//  ManifestDetailView.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 18.10.2011.
//

#import "MAManifestDetailView.h"
#import "DataModelHeaders.h"
#import "MAMunkiAdmin_AppDelegate.h"

NSString *ConditionalItemType = @"ConditionalItemType";

@implementation MAManifestDetailView

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
    [self.nestedManifestsTableView registerForDraggedTypes:@[NSURLPboardType]];
	[self.nestedManifestsTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];

    [self.catalogsTableView registerForDraggedTypes:@[NSURLPboardType]];
    [self.catalogsTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];

    [self.conditionsOutlineView registerForDraggedTypes:@[ConditionalItemType]];
    [self.conditionsOutlineView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:YES];
    [self.conditionsOutlineView setAutoresizesSubviews:NO];
    
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"sortManagedInstallsByTitle"]) {
        [self.managedInstallsController setSortDescriptors:@[sortByTitle, sortByIndex]];
    } else {
        [self.managedInstallsController setSortDescriptors:@[sortByIndex, sortByTitle]];
    }

    if ([defaults boolForKey:@"sortManagedUpdatesByTitle"]) {
        [self.managedUpdatesController setSortDescriptors:@[sortByTitle, sortByIndex]];
    } else {
        [self.managedUpdatesController setSortDescriptors:@[sortByIndex, sortByTitle]];
    }
    
    if ([defaults boolForKey:@"sortManagedUninstallsByTitle"]) {
        [self.managedUninstallsController setSortDescriptors:@[sortByTitle, sortByIndex]];
    } else {
        [self.managedUninstallsController setSortDescriptors:@[sortByIndex, sortByTitle]];
    }
    
    if ([defaults boolForKey:@"sortOptionalInstallsByTitle"]) {
        [self.optionalInstallsController setSortDescriptors:@[sortByTitle, sortByIndex]];
    } else {
        [self.optionalInstallsController setSortDescriptors:@[sortByIndex, sortByTitle]];
    }
    
    NSSortDescriptor *sortByIndexInNestedManifest = [NSSortDescriptor sortDescriptorWithKey:@"indexInNestedManifest" ascending:YES selector:@selector(compare:)];
    [self.includedManifestsController setSortDescriptors:@[sortByIndexInNestedManifest, sortByTitle]];
    
    NSSortDescriptor *sortByIndexInManifest = [NSSortDescriptor sortDescriptorWithKey:@"indexInManifest" ascending:YES selector:@selector(compare:)];
    NSSortDescriptor *sortCatalogsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"catalog.title" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.catalogsController setSortDescriptors:@[sortByIndexInManifest, sortCatalogsByTitle]];
    
    NSSortDescriptor *sortByCondition = [NSSortDescriptor sortDescriptorWithKey:@"munki_condition" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByTitleWithParentTitle = [NSSortDescriptor sortDescriptorWithKey:@"titleWithParentTitle" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.conditionalItemsController setSortDescriptors:@[sortByTitleWithParentTitle, sortByCondition]];
    [self.conditionsTreeController setSortDescriptors:@[sortByTitleWithParentTitle, sortByCondition]];
    [self.conditionsOutlineView expandItem:nil expandChildren:YES];
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
	NSDragOperation result = NSDragOperationNone;
	if (theTableView == self.nestedManifestsTableView) {
        if (theDropOperation == NSTableViewDropAbove) {
            result = NSDragOperationMove;
        }
    } else if (theTableView == self.catalogsTableView) {
        if (theDropOperation == NSTableViewDropAbove) {
            result = NSDragOperationMove;
        }
    }
	
    return result;
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
    NSPasteboard *draggingPasteboard = [draggingInfo draggingPasteboard];
    if (theTableView == self.nestedManifestsTableView) {
        NSArray *dragTypes = [draggingPasteboard types];
        if ([dragTypes containsObject:NSURLPboardType]) {
            
            NSPasteboard *pasteboard = draggingPasteboard;
            NSArray *classes = @[[NSURL class]];
            NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey : @NO};
            NSArray *urls = [pasteboard readObjectsForClasses:classes options:options];
            for (NSURL *uri in urls) {
                NSManagedObjectContext *moc = [self.includedManifestsController managedObjectContext];
                NSManagedObjectID *objectID = [[moc persistentStoreCoordinator] managedObjectIDForURIRepresentation:uri];
                StringObjectMO *mo = (StringObjectMO *)[moc objectRegisteredForID:objectID];
                [self makeRoomForManifestsAtIndex:row];
                mo.indexInNestedManifest = @(row);
                
            }
        }
        
        [self renumberManifestItems];
        
        return YES;
    } else if (theTableView == self.catalogsTableView) {
        NSArray *dragTypes = [draggingPasteboard types];
        if ([dragTypes containsObject:NSURLPboardType]) {
            
            NSPasteboard *pasteboard = draggingPasteboard;
            NSArray *classes = @[[NSURL class]];
            NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey : @NO};
            NSArray *urls = [pasteboard readObjectsForClasses:classes options:options];
            for (NSURL *uri in urls) {
                NSManagedObjectContext *moc = [self.catalogsController managedObjectContext];
                NSManagedObjectID *objectID = [[moc persistentStoreCoordinator] managedObjectIDForURIRepresentation:uri];
                CatalogInfoMO *mo = (CatalogInfoMO *)[moc objectRegisteredForID:objectID];
                [self makeRoomForCatalogsAtIndex:row];
                mo.indexInManifest = @(row);
                
            }
        }
        
        [self renumberCatalogItems];
        
        return YES;
    }
    
    else {
        return NO;
    }
}


# pragma mark - NSOutlineView delegates


- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard {
    [pboard declareTypes:[NSArray arrayWithObject:ConditionalItemType] owner:self];
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:[items valueForKey:@"indexPath"]] forType:ConditionalItemType];
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)proposedParentItem childIndex:(NSInteger)index {
    
    NSArray *droppedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:ConditionalItemType]];
	
	NSMutableArray *draggedNodes = [NSMutableArray array];
	for (NSIndexPath *indexPath in droppedIndexPaths) {
        id treeRoot = [self.conditionsTreeController arrangedObjects];
        NSTreeNode *node = [treeRoot descendantNodeAtIndexPath:indexPath];
		[draggedNodes addObject:node];
    }
    
    for (NSTreeNode *aNode in draggedNodes) {
        ConditionalItemMO *droppedConditional = [aNode representedObject];
        NSTreeNode *parent = proposedParentItem;
        ConditionalItemMO *parentConditional = [parent representedObject];
        
        if (!proposedParentItem) {
            droppedConditional.parent = nil;
        }
        else {
            droppedConditional.parent = parentConditional;
        }
        
        [[(MAMunkiAdmin_AppDelegate *)[NSApp delegate] managedObjectContext] refreshObject:droppedConditional.manifest mergeChanges:YES];
    }
    
    [self.conditionsTreeController rearrangeObjects];
    [self.conditionalItemsController rearrangeObjects];
    
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
    
    // Deny drag and drop reordering
    if (index != -1) {
        return NSDragOperationNone;
    }
        
    NSArray *draggedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:ConditionalItemType]];
    for (NSIndexPath *indexPath in draggedIndexPaths) {
        id treeRoot = [self.conditionsTreeController arrangedObjects];
        NSTreeNode *node = [treeRoot descendantNodeAtIndexPath:indexPath];
        ConditionalItemMO *droppedConditional = [node representedObject];
        NSTreeNode *parent = item;
        ConditionalItemMO *parentConditional = [parent representedObject];
        
        // Dragging a 1st level item so deny dropping to root
        if ((droppedConditional.parent == nil) && (parentConditional == nil)) {
            return NSDragOperationNone;
        }
        
        // Can't drop on child items
        while (parent != nil) {
            if (parent == node) {
                return NSDragOperationNone;
            }
            parent = [parent parentNode];
        }
    }
    return NSDragOperationGeneric;
}



@end
