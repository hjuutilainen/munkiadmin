//
//  ImageAndTitleCell.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 27.2.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MAImageAndTitleCell : NSTextFieldCell
{
	NSMutableDictionary * aTitleAttributes;
	NSMutableDictionary * aSubtitleAttributes;
	
}

@property (strong) NSMutableDictionary * aTitleAttributes;
@property (strong) NSMutableDictionary * aSubtitleAttributes;


@end
