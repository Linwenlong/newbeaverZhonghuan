//
// Created by 何 义 on 14-4-3.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "SVProgressHUD.h"

typedef NSInteger(^TAudioAmpBlock)();

@interface EBRecordingHUD : UIView

+ (void)showWithAmpBlock:(TAudioAmpBlock)ampBlock;
+ (void)showReleaseHint;
+ (void)showRecording;
+ (void)dismiss;

@end