//
//  PackageNameEditor.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 28.10.2011.
//

#import "PackageNameEditor.h"
#import "MAMunkiRepositoryManager.h"
#import "DataModelHeaders.h"
#import "MAMunkiAdmin_AppDelegate.h"

@implementation PackageNameEditor

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        self.shouldRenameAll = YES;
        self.changedName = @"";
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
    [referencingDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *obj, BOOL *stop) {
        
        if ([key isEqualToString:@"packagesWithSameName"]) {
            [obj enumerateObjectsUsingBlock:^(PackageMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *aDescr = [NSString stringWithFormat:@"%@", obj.relativePath];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"packageWithSameName", @"type", packageIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
        }
        
        else if ([key isEqualToString:@"managedInstalls"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *aDescr = [NSString stringWithFormat:@"%@: managed_installs: \"%@\"", obj.managedInstallReference.title, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"managedInstall", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([key isEqualToString:@"managedUninstalls"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *aDescr = [NSString stringWithFormat:@"%@: managed_uninstalls: \"%@\"", obj.managedUninstallReference.title, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"managedUninstall", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([key isEqualToString:@"managedUpdates"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *aDescr = [NSString stringWithFormat:@"%@: managed_updates: \"%@\"", obj.managedUpdateReference.title, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"managedUpdate", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([key isEqualToString:@"optionalInstalls"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *aDescr = [NSString stringWithFormat:@"%@: optional_installs: \"%@\"", obj.optionalInstallReference.title, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"optionalInstall", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        }
        
        else if ([key isEqualToString:@"conditionalManagedInstalls"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                ConditionalItemMO *cond = obj.managedInstallConditionalReference;
                NSString *aDescr = [NSString stringWithFormat:@"%@: condition \"%@\": managed_installs: \"%@\"", cond.manifest.title, cond.titleWithParentTitle, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"managedInstall", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([key isEqualToString:@"conditionalManagedUninstalls"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                ConditionalItemMO *cond = obj.managedUninstallConditionalReference;
                NSString *aDescr = [NSString stringWithFormat:@"%@: condition \"%@\": managed_uninstalls: \"%@\"", cond.manifest.title, cond.titleWithParentTitle, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"managedUninstall", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([key isEqualToString:@"conditionalManagedUpdates"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                ConditionalItemMO *cond = obj.managedUpdateConditionalReference;
                NSString *aDescr = [NSString stringWithFormat:@"%@: condition \"%@\": managed_updates: \"%@\"", cond.manifest.title, cond.titleWithParentTitle, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"managedUpdate", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([key isEqualToString:@"conditionalOptionalInstalls"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                ConditionalItemMO *cond = obj.optionalInstallConditionalReference;
                NSString *aDescr = [NSString stringWithFormat:@"%@: condition \"%@\": optional_installs: \"%@\"", cond.manifest.title, cond.titleWithParentTitle, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"optionalInstall", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        }
        
        else if ([key isEqualToString:@"requiresItems"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *aDescr = [NSString stringWithFormat:@"%@: requires: \"%@\"", obj.requiresReference.titleWithVersion, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"managedUninstall", @"type", packageIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([key isEqualToString:@"updateForItems"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *aDescr = [NSString stringWithFormat:@"%@: update_for: \"%@\"", obj.updateForReference.titleWithVersion, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"managedUninstall", @"type", packageIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        }
        
        
        
        // With version
        else if ([key isEqualToString:@"managedInstallsWithVersion"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *aDescr = [NSString stringWithFormat:@"%@: managed_installs: \"%@\"", obj.managedInstallReference.title, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"managedInstall", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([key isEqualToString:@"managedUninstallsWithVersion"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *aDescr = [NSString stringWithFormat:@"%@: managed_uninstalls: \"%@\"", obj.managedUninstallReference.title, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"managedUninstall", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([key isEqualToString:@"managedUpdatesWithVersion"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *aDescr = [NSString stringWithFormat:@"%@: managed_updates: \"%@\"", obj.managedUpdateReference.title, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"managedUpdate", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([key isEqualToString:@"optionalInstallsWithVersion"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *aDescr = [NSString stringWithFormat:@"%@: optional_installs: \"%@\"", obj.optionalInstallReference.title, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"optionalInstall", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        }
        
        else if ([key isEqualToString:@"conditionalManagedInstallsWithVersion"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                ConditionalItemMO *cond = obj.managedInstallConditionalReference;
                NSString *aDescr = [NSString stringWithFormat:@"%@: condition \"%@\": managed_installs: \"%@\"", cond.manifest.title, cond.titleWithParentTitle, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"managedInstall", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([key isEqualToString:@"conditionalManagedUninstallsWithVersion"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                ConditionalItemMO *cond = obj.managedUninstallConditionalReference;
                NSString *aDescr = [NSString stringWithFormat:@"%@: condition \"%@\": managed_uninstalls: \"%@\"", cond.manifest.title, cond.titleWithParentTitle, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"managedUninstall", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([key isEqualToString:@"conditionalManagedUpdatesWithVersion"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                ConditionalItemMO *cond = obj.managedUpdateConditionalReference;
                NSString *aDescr = [NSString stringWithFormat:@"%@: condition \"%@\": managed_updates: \"%@\"", cond.manifest.title, cond.titleWithParentTitle, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"managedUpdate", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([key isEqualToString:@"conditionalOptionalInstallsWithVersion"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                ConditionalItemMO *cond = obj.optionalInstallConditionalReference;
                NSString *aDescr = [NSString stringWithFormat:@"%@: condition \"%@\": optional_installs: \"%@\"", cond.manifest.title, cond.titleWithParentTitle, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"optionalInstall", @"type", manifestIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        }
        
        else if ([key isEqualToString:@"requiresItemsWithVersion"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *aDescr = [NSString stringWithFormat:@"%@: requires: \"%@\"", obj.requiresReference.titleWithVersion, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"managedUninstall", @"type", packageIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        } else if ([key isEqualToString:@"updateForItemsWithVersion"]) {
            [obj enumerateObjectsUsingBlock:^(StringObjectMO *obj, NSUInteger idx, BOOL *stop) {
                NSString *aDescr = [NSString stringWithFormat:@"%@: update_for: \"%@\"", obj.updateForReference.titleWithVersion, obj.title];
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:aDescr, @"title", @"managedUninstall", @"type", packageIcon, @"icon", nil];
                [changeDescriptionsForPackage addObject:objectDict];
            }];
            
        }
        
        
    }];
    
    [self setChangeDescriptions:[NSArray arrayWithArray:changeDescriptionsForPackage]];
    self.changedName = self.packageToRename.munki_name;
    self.oldName = self.packageToRename.munki_name;
}


- (void)okAction:(id)sender;
{
    [[MAMunkiRepositoryManager sharedManager] renamePackage:self.packageToRename newName:self.changedName cascade:self.shouldRenameAll];
    
    [[self window] orderOut:sender];
    [NSApp endSheet:[self window] returnCode:NSOKButton];
}

- (void)cancelAction:(id)sender;
{
    [[self window] orderOut:sender];
    [NSApp endSheet:[self window] returnCode:NSCancelButton];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    [self.changeDescriptionsArrayController setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
}

@end
