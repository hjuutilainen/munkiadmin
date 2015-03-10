//
//  MAManifestsViewSourceListItem.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 6.3.2015.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ManifestSourceItemType) {
    ManifestSourceItemTypeBuiltin,
    ManifestSourceItemTypeFolder,
    ManifestSourceItemTypeUserCreated
};

@interface MAManifestsViewSourceListItem : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSPredicate *filterPredicate;
@property (strong, nonatomic) NSArray *sortDescriptors;
@property (strong, nonatomic) NSURL *representedFileURL;
@property (assign, nonatomic) ManifestSourceItemType type;

+ (id)collectionWithTitle:(NSString *)title identifier:(NSString *)identifier type:(ManifestSourceItemType)type;


@end
