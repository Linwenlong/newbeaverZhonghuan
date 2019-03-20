//
// Created by 何 义 on 14-7-23.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "BaseViewController.h"
#import "AGImagePickerController.h"

@class EBHouse;

typedef void(^RetuenUpLoadPhotoBlock)(NSArray *uploadPhotos);

@interface HousePhotoPreUploadViewController : BaseViewController

@property (nonatomic, copy) RetuenUpLoadPhotoBlock getUpLoadPhotoBlock;

@property (nonatomic) BOOL publishTag;

@property (weak) id keyboardWillHideNotificationObserver;

- (void)uploadPhotos:(NSArray *)photos forHouse:(EBHouse *)house getUpLoadPhotoBlock:retuenUpLoadPhotoBlock;
- (void)uploadCameraPhotos:(UIImage *)cameraPhoto url:(NSURL *)url forHouse:(EBHouse *)house getUpLoadPhotoBlock:retuenUpLoadPhotoBlock;

@end