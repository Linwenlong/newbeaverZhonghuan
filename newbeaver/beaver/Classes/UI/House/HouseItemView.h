//
// Created by 何 义 on 14-5-27.
// Copyright (c) 2014 eall. All rights reserved.
//


@class EBIconLabel;
@class RTLabel;
@class EBHouse;

@interface HouseItemView : UIView

@property (nonatomic, readonly) EBIconLabel *titleView;
@property (nonatomic, readonly) EBIconLabel *rentPriceView;
@property (nonatomic, readonly) EBIconLabel *sellPriceView;
@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) UIButton *markView;
@property (nonatomic, readonly) UIImageView *tagNew;
//@property (nonatomic, readonly) UIImageView *rcmdIcon;
@property (nonatomic, readonly) UIImageView *tagAccess;
@property (nonatomic, readonly) UIImageView *tagRental;
@property (nonatomic, readonly) UIImageView *tagUrgent;
@property (nonatomic, readonly) UIView *leftPartView;
@property (nonatomic, readonly) UIButton *clickView;
@property (nonatomic, readonly) UIView *rightPartView;
@property (nonatomic, readonly) RTLabel *detailLabel;
@property (nonatomic, strong) EBHouse *house;
@property (nonatomic, assign) BOOL marking;
@property (nonatomic, assign) BOOL selecting;
@property (nonatomic, copy) NSString *targetClientId;
@property (nonatomic, copy) void(^changeMarkedStausBlock)(BOOL marked);

@property (nonatomic) BOOL showImage;

- (void)changeSize;

@end