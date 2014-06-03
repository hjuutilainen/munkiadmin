//
//  MAImageBrowserItem.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 3.6.2014.
//
//

#import <Foundation/Foundation.h>

@interface MAImageBrowserItem : NSObject

@property (strong) NSImage *image;
@property (strong) NSString *imageTitle;
@property (strong) NSString *imageUID;

- (NSString *)imageRepresentationType;
- (id)imageRepresentation;

@end
