//
// Created by 何 义 on 14-4-1.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBBubbleView.h"

@class EBIMMessage;

@interface EBContentBaseView : UIView

@property (nonatomic, strong) EBIMMessage *message;

+ (CGSize)neededContentSize:(EBIMMessage *)message;

- (void)updateContent:(EBIMMessage*)message;
- (NSString *)toPasteboard;
- (void)handleTapEvent;
- (UIImageView *)bubbleImageView;

@end