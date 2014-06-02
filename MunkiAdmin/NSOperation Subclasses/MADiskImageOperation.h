//
//  MADiskImageOperation.h
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 29.5.2014.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MADiskImageOperationType) {
    MADiskImageOperationTypeAttach,
    MADiskImageOperationTypeDetach,
    MADiskImageOperationTypeImageInfo
};

@interface MADiskImageOperation : NSOperation

@property (nonatomic, copy) void (^willStartCallback) ();
@property (nonatomic, copy) void (^progressCallback) (double progress, NSString *description);
@property (nonatomic, copy) void (^didMountHandler) (NSArray *mountPoints, BOOL alreadyMounted);
@property (nonatomic, copy) void (^didFinishCallback) ();
@property BOOL leaveMounted;
@property MADiskImageOperationType operationType;

+ (id)attachOperationWithURL:(NSURL *)url;
+ (id)detachOperationWithMountpoints:(NSArray *)mountpointPaths;
- (id)initWithURL:(NSURL *)url operationType:(MADiskImageOperationType)type;

@end
