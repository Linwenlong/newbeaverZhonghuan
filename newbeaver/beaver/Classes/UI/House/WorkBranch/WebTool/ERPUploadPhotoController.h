//
//  ERPUploadPhotoController.h
//  chowRentAgent
//
//  Created by 凯文马 on 15/11/17.
//  Copyright © 2015年 eallcn. All rights reserved.
//

#import "BaseViewController.h"
#import "AGImagePickerController.h"

@class EBHouse;

typedef void(^RetuenUpLoadPhotoBlock)(NSArray *uploadPhotos);

@interface ERPUploadPhotoController : BaseViewController

@property (nonatomic, copy) RetuenUpLoadPhotoBlock getUpLoadPhotoBlock;

@property (nonatomic) BOOL publishTag;

@property (nonatomic, strong) NSArray *localations;

@property (nonatomic, assign) BOOL memoEnable;

@property (nonatomic, assign) CGFloat maxWidth;

@property (nonatomic, assign) NSUInteger selectCount;

@property (weak) id keyboardWillHideNotificationObserver;

- (void)uploadPhotos:(NSArray *)photos forHouse:(EBHouse *)house getUpLoadPhotoBlock:retuenUpLoadPhotoBlock;
- (void)uploadCameraPhotos:(UIImage *)cameraPhoto url:(NSURL *)url forHouse:(EBHouse *)house getUpLoadPhotoBlock:retuenUpLoadPhotoBlock;


@end