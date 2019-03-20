//
// Created by 何 义 on 14-3-9.
// Copyright (c) 2014 eall. All rights reserved.
//


typedef NS_ENUM(NSInteger , EIconPosition)
{
    EIconPositionRight = 0,
    EIconPositionBottom = 1,
    EIconPositionLeft = 2,
    EIconPositionTop = 3,
};

@interface EBIconLabel : UIView

@property (nonatomic, readonly) UILabel *label;
@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, assign) EIconPosition iconPosition;
@property (nonatomic, assign) BOOL iconVerticalCenter;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat gap;
@property (nonatomic, readonly) CGRect currentFrame;

@end