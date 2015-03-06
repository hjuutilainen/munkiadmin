//
//  MAManifestsViewSourceListItem.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 6.3.2015.
//
//

#import "MAManifestsViewSourceListItem.h"

@implementation MAManifestsViewSourceListItem

+ (id)collectionWithTitle:(NSString *)title identifier:(NSString *)identifier type:(ManifestSourceItemType)type
{
    MAManifestsViewSourceListItem *sourceListItem = [[MAManifestsViewSourceListItem alloc] init];
    
    sourceListItem.title = title;
    sourceListItem.identifier = identifier;
    sourceListItem.type = type;
    
    return sourceListItem;
}


@end
