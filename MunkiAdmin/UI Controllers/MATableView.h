//
//  MATableView.h
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 29.2.2012.
//

#import <Cocoa/Cocoa.h>

@class MATableView;
@protocol MATableViewDelegate <NSObject>
- (void)tableViewDidEndAllEditing:(MATableView *)sender;
@end

@interface MATableView : NSTableView

@end
