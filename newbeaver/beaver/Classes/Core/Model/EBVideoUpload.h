//
//  EBVideoUpload.h
//  beaver
//
//  Created by LiuLian on 8/13/15.
//  Copyright (c) 2015 eall. All rights reserved.
//

#import "EBBaseModel.h"

typedef NS_ENUM(NSUInteger, EBVideoStatus) {
//    VideoStatusWaiting,
    VideoStatusUploading,
    VideoStatusFinish,
    VideoStatusError,
};

@class ALAsset;

@interface EBVideoUpload : EBBaseModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *sha1;
@property (nonatomic, strong) NSString *houseUid;
@property (nonatomic, strong) NSURL *tmpURL;
@property (nonatomic, strong) ALAsset *asset;
//@property (nonatomic, strong) NSURL *assetURL;
@property (nonatomic, strong) NSString *remoteUid;
@property (nonatomic, assign) NSUInteger offset;
@property (nonatomic, assign) EBVideoStatus status;
@property (nonatomic, assign) NSInteger errorCounts;
@property (nonatomic, assign) CGFloat progress;

@end