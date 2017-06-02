//
//  PackageNameEditor.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 28.10.2011.
//

#import "MAPackageNameEditor.h"
#import "MAMunkiRepositoryManager.h"
#import "DataModelHeaders.h"
#import "MAMunkiAdmin_AppDelegate.h"

@implementation MAPackageNameEditor

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        _shouldRenameAll = YES;
        _changedName = @"";
    }
    
    return self;
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    if (!undoManager) {
        undoManager = [[NSUndoManager alloc] init];
    }
    return undoManager;
}

- (void)configureRenameOperation
{
    NSDictionary *referencingDict = [[MAMunkiRepositoryManager sharedManager] referencingItemsForPackage:self.packageToRename];
    NSMutableArray *changeDescriptionsForPackage = [[NSMutableArray alloc] init];
    NSImage *manifestIcon = [NSImage imageNamed:@"manifestIcon_32x32"];
    NSImage *packageIcon = [NSImage imageNamed:@"packageIcon_32x32"];
    [referencingDict enumerateKeysAndObjectsUsingBlock:^(NSString *referencingKey, NSArray *referencingObject, BOOL *stopReferenceEnum) {
        
        if ([referencingKey isEqualToString:@"packagesWithSameName"]) {
            [referencingObject enumerateObjectsUsingBlock:^(PackageMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *description = [NSString stringWithFormat:@"%@", obj.relativePath];
                NSDictionary *objectDict = @{@"title" : description, @"type" : @"packageWithSameName", @"icon" : packageIcon};
                [changeDescriptionsForPackage addObject:objectDict];
            }];
        }
        
        else if ([referencingKey isEqualToString:@"managedInstalls"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *description = [NSString stringWithFormat:@"%@: managed_installs: \"%@\"", obj.managedInstallReference.title, obj.title];
                NSDictionary *objectDict = @{@"title" : description, @"type" : @"managedInstall", @"icon" : manifestIcon};
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([referencingKey isEqualToString:@"managedUninstalls"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *description = [NSString stringWithFormat:@"%@: managed_uninstalls: \"%@\"", obj.managedUninstallReference.title, obj.title];
                NSDictionary *objectDict = @{@"title" : description, @"type" : @"managedUninstall", @"icon" : manifestIcon};
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([referencingKey isEqualToString:@"managedUpdates"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *description = [NSString stringWithFormat:@"%@: managed_updates: \"%@\"", obj.managedUpdateReference.title, obj.title];
                NSDictionary *objectDict = @{@"title" : description, @"type" : @"managedUpdate", @"icon" : manifestIcon};
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([referencingKey isEqualToString:@"optionalInstalls"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *description = [NSString stringWithFormat:@"%@: optional_installs: \"%@\"", obj.optionalInstallReference.title, obj.title];
                NSDictionary *objectDict = @{@"title" : description, @"type" : @"optionalInstall", @"icon" : manifestIcon};
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([referencingKey isEqualToString:@"featuredItems"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *description = [NSString stringWithFormat:@"%@: featured_items: \"%@\"", obj.featuredItemReference.title, obj.title];
                NSDictionary *objectDict = @{@"title" : description, @"type" : @"featuredItem", @"icon" : manifestIcon};
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        }
        
        else if ([referencingKey isEqualToString:@"conditionalManagedInstalls"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                ConditionalItemMO *conditional = obj.managedInstallConditionalReference;
                NSString *description = [NSString stringWithFormat:@"%@: condition \"%@\": managed_installs: \"%@\"", conditional.manifest.title, conditional.titleWithParentTitle, obj.title];
                NSDictionary *objectDict = @{@"title" : description, @"type" : @"managedInstall", @"icon" : manifestIcon};
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([referencingKey isEqualToString:@"conditionalManagedUninstalls"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                ConditionalItemMO *conditional = obj.managedUninstallConditionalReference;
                NSString *description = [NSString stringWithFormat:@"%@: condition \"%@\": managed_uninstalls: \"%@\"", conditional.manifest.title, conditional.titleWithParentTitle, obj.title];
                NSDictionary *objectDict = @{@"title" : description, @"type" : @"managedUninstall", @"icon" : manifestIcon};
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([referencingKey isEqualToString:@"conditionalManagedUpdates"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                ConditionalItemMO *conditional = obj.managedUpdateConditionalReference;
                NSString *description = [NSString stringWithFormat:@"%@: condition \"%@\": managed_updates: \"%@\"", conditional.manifest.title, conditional.titleWithParentTitle, obj.title];
                NSDictionary *objectDict = @{@"title" : description, @"type" : @"managedUpdate", @"icon" : manifestIcon};
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([referencingKey isEqualToString:@"conditionalOptionalInstalls"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                ConditionalItemMO *conditional = obj.optionalInstallConditionalReference;
                NSString *description = [NSString stringWithFormat:@"%@: condition \"%@\": optional_installs: \"%@\"", conditional.manifest.title, conditional.titleWithParentTitle, obj.title];
                NSDictionary *objectDict = @{@"title" : description, @"type" : @"optionalInstall", @"icon" : manifestIcon};
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([referencingKey isEqualToString:@"conditionalFeaturedItems"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                ConditionalItemMO *conditional = obj.featuredItemConditionalReference;
                NSString *description = [NSString stringWithFormat:@"%@: condition \"%@\": featured_items: \"%@\"", conditional.manifest.title, conditional.titleWithParentTitle, obj.title];
                NSDictionary *objectDict = @{@"title" : description, @"type" : @"featuredItem", @"icon" : manifestIcon};
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        }
        
        else if ([referencingKey isEqualToString:@"requiresItems"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *description = [NSString stringWithFormat:@"%@: requires: \"%@\"", obj.requiresReference.titleWithVersion, obj.title];
                NSDictionary *objectDict = @{@"title" : description, @"type" : @"managedUninstall", @"icon" : packageIcon};
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([referencingKey isEqualToString:@"updateForItems"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *description = [NSString stringWithFormat:@"%@: update_for: \"%@\"", obj.updateForReference.titleWithVersion, obj.title];
                NSDictionary *objectDict = @{@"title" : description, @"type" : @"managedUninstall", @"icon" : packageIcon};
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        }
        
        
        
        // With version
        else if ([referencingKey isEqualToString:@"managedInstallsWithVersion"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *description = [NSString stringWithFormat:@"%@: managed_installs: \"%@\"", obj.managedInstallReference.title, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:description, @"title", @"managedInstall", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([referencingKey isEqualToString:@"managedUninstallsWithVersion"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *description = [NSString stringWithFormat:@"%@: managed_uninstalls: \"%@\"", obj.managedUninstallReference.title, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:description, @"title", @"managedUninstall", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([referencingKey isEqualToString:@"managedUpdatesWithVersion"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *description = [NSString stringWithFormat:@"%@: managed_updates: \"%@\"", obj.managedUpdateReference.title, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:description, @"title", @"managedUpdate", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([referencingKey isEqualToString:@"optionalInstallsWithVersion"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *description = [NSString stringWithFormat:@"%@: optional_installs: \"%@\"", obj.optionalInstallReference.title, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:description, @"title", @"optionalInstall", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([referencingKey isEqualToString:@"featuredItemsWithVersion"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *description = [NSString stringWithFormat:@"%@: featured_items: \"%@\"", obj.featuredItemReference.title, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:description, @"title", @"featuredItem", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        }
        
        else if ([referencingKey isEqualToString:@"conditionalManagedInstallsWithVersion"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                ConditionalItemMO *conditional = obj.managedInstallConditionalReference;
                NSString *description = [NSString stringWithFormat:@"%@: condition \"%@\": managed_installs: \"%@\"", conditional.manifest.title, conditional.titleWithParentTitle, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:description, @"title", @"managedInstall", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([referencingKey isEqualToString:@"conditionalManagedUninstallsWithVersion"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                ConditionalItemMO *conditional = obj.managedUninstallConditionalReference;
                NSString *description = [NSString stringWithFormat:@"%@: condition \"%@\": managed_uninstalls: \"%@\"", conditional.manifest.title, conditional.titleWithParentTitle, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:description, @"title", @"managedUninstall", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([referencingKey isEqualToString:@"conditionalManagedUpdatesWithVersion"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                ConditionalItemMO *conditional = obj.managedUpdateConditionalReference;
                NSString *description = [NSString stringWithFormat:@"%@: condition \"%@\": managed_updates: \"%@\"", conditional.manifest.title, conditional.titleWithParentTitle, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:description, @"title", @"managedUpdate", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([referencingKey isEqualToString:@"conditionalOptionalInstallsWithVersion"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                ConditionalItemMO *conditional = obj.optionalInstallConditionalReference;
                NSString *description = [NSString stringWithFormat:@"%@: condition \"%@\": optional_installs: \"%@\"", conditional.manifest.title, conditional.titleWithParentTitle, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:description, @"title", @"optionalInstall", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([referencingKey isEqualToString:@"conditionalFeaturedItemsWithVersion"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                ConditionalItemMO *conditional = obj.featuredItemConditionalReference;
                NSString *description = [NSString stringWithFormat:@"%@: condition \"%@\": featured_items: \"%@\"", conditional.manifest.title, conditional.titleWithParentTitle, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:description, @"title", @"featuredItem", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        }
        
        else if ([referencingKey isEqualToString:@"requiresItemsWithVersion"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *description = [NSString stringWithFormat:@"%@: requires: \"%@\"", obj.requiresReference.titleWithVersion, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:description, @"title", @"managedUninstall", @"type", packageIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([referencingKey isEqualToString:@"updateForItemsWithVersion"]) {
            [referencingObject enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *description = [NSString stringWithFormat:@"%@: update_for: \"%@\"", obj.updateForReference.titleWithVersion, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:description, @"title", @"managedUninstall", @"type", packageIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        }
        
        
    }];
    
    [self setChangeDescriptions:[NSArray arrayWithArray:changeDescriptionsForPackage]];
    self.changedName = self.packageToRename.munki_name;
    self.oldName = self.packageToRename.munki_name;
}


- (void)okAction:(id)sender
{
    MAMunkiRepositoryManager *repositoryManager = [MAMunkiRepositoryManager sharedManager];
    [repositoryManager renamePackage:self.packageToRename newName:self.changedName cascade:self.shouldRenameAll];
    
    if ([NSWindow instancesRespondToSelector:@selector(endSheet:returnCode:)]) {
        // 10.9 or later
        [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
        [self.window orderOut:sender];
    } else {
        // 10.8 or earlier
        [self.window orderOut:sender];
        [NSApp endSheet:self.window returnCode:NSOKButton];
    }
}

- (void)cancelAction:(id)sender
{
    if ([NSWindow instancesRespondToSelector:@selector(endSheet:returnCode:)]) {
        // 10.9 or later
        [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
        [self.window orderOut:sender];
    } else {
        // 10.8 or earlier
        [self.window orderOut:sender];
        [NSApp endSheet:self.window returnCode:NSCancelButton];
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.changeDescriptionsArrayController setSortDescriptors:@[sort]];
}

@end
