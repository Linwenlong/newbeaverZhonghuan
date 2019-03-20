//
// Created by 何 义 on 14-4-24.
// Copyright (c) 2014 eall. All rights reserved.
//


typedef NS_ENUM(NSInteger , ERecordingButtonEvent)
{
    ERecordingButtonEventTouchesBegin,
    ERecordingButtonEventTouchesMoveOut,
    ERecordingButtonEventTouchesMoveIn,
    ERecordingButtonEventTouchesCanceled,
    ERecordingButtonEventTouchesEnd,
};

@interface EBRecordingButton : UIView

@property (nonatomic, copy) void(^eventBlock)(ERecordingButtonEvent event);
@property (nonatomic, readonly) BOOL stillTouching;
@property (nonatomic, readonly) BOOL touchOutside;

@end