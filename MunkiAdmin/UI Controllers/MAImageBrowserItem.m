//
//  MAImageBrowserItem.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 3.6.2014.
//
//

#import "MAImageBrowserItem.h"
#import <Quartz/Quartz.h>

@implementation MAImageBrowserItem

- (NSString *)imageRepresentationType {
    return IKImageBrowserNSImageRepresentationType;
}

- (id)imageRepresentation
{
    return self.image;
}

@end
