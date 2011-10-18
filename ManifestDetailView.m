//
//  ManifestDetailView.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 18.10.2011.
//

#import "ManifestDetailView.h"

@implementation ManifestDetailView

@synthesize managedInstallsController;
@synthesize managedUpdatesController;
@synthesize managedUninstallsController;
@synthesize optionalInstallsController;
@synthesize catalogsController;
@synthesize includedManifestsController;

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
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortByIndex = [NSSortDescriptor sortDescriptorWithKey:@"originalIndex" ascending:YES selector:@selector(compare:)];
    [managedInstallsController setSortDescriptors:[NSArray arrayWithObjects:sortByIndex, sortByTitle, nil]];
    [managedUpdatesController setSortDescriptors:[NSArray arrayWithObjects:sortByIndex, sortByTitle, nil]];
    [managedUninstallsController setSortDescriptors:[NSArray arrayWithObjects:sortByIndex, sortByTitle, nil]];
    [optionalInstallsController setSortDescriptors:[NSArray arrayWithObjects:sortByIndex, sortByTitle, nil]];
    [includedManifestsController setSortDescriptors:[NSArray arrayWithObjects:sortByIndex, sortByTitle, nil]];
    
    NSSortDescriptor *sortCatalogsByTitle = [NSSortDescriptor sortDescriptorWithKey:@"catalog.title" ascending:YES selector:@selector(localizedStandardCompare:)];
    [catalogsController setSortDescriptors:[NSArray arrayWithObjects:sortByIndex, sortCatalogsByTitle, nil]];
}


@end
