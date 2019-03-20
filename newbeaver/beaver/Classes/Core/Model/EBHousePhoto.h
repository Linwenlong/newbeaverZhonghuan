//
// Created by 何 义 on 14-7-23.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBBaseModel.h"

@class EBHouse;

typedef NS_ENUM(NSInteger , EPhotoAddStatus){
    EPhotoAddStatusWaiting = 0,
    EPhotoAddStatusUploading = 1,
    EPhotoAddStatusUploadSuccess = 2,
    EPhotoAddStatusAdding = 3,
    EPhotoAddStatusAddSuccess = 4,
    EPhotoAddStatusErrorUpload = -1,
    EPhotoAddStatusErrorAdd = -2
};

@interface EBHousePhoto : NSObject

@property (nonatomic, copy) NSURL *localUrl;
@property (nonatomic, copy) NSString *locationDesc;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, copy) NSString *remoteUrl;
@property (nonatomic) CGImageRef thumbnail;
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, copy) NSString *houseType;
@property (nonatomic) CGFloat progress; // 0-1;
@property (nonatomic) EPhotoAddStatus status;
@property (nonatomic) BOOL publishTag;

- (NSDictionary *)toDictionary;
- (NSDictionary *)toAddParams;
+ (EBHousePhoto *)fromDictionary:(NSDictionary *)dictionary;

@end