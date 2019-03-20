//
// Created by 何 义 on 14-7-23.
// Copyright (c) 2014 eall. All rights reserved.
//
//图片上传的类

#import <Foundation/Foundation.h>


@interface EBHousePhotoUploader : NSObject

+ (EBHousePhotoUploader *)sharedInstance;

- (void)addHousePhotos:(NSArray *)photos;
- (BOOL)checkUploading;
- (void)resumeUploading;
- (void)pauseUploading;
- (void)retry:(NSInteger)photoIndex;
- (void)cancel:(NSInteger)photoIndex;

- (BOOL)isUploading;
- (NSInteger)failureCount;
- (NSInteger)finishedCount;

@property (nonatomic, readonly) NSArray *uploadingPhotos;

@end