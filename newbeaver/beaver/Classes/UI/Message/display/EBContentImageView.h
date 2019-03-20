//
// Created by 何 义 on 14-4-1.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBContentBaseView.h"

@class EBIMMessage;

@interface EBContentImageView : EBContentBaseView

@property (nonatomic, readonly) UIImageView *imageView;

+ (CGSize)neededContentSize:(EBIMMessage *)message;

@end