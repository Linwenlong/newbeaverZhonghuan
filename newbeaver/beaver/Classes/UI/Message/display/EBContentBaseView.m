//
// Created by 何 义 on 14-4-1.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBContentBaseView.h"
#import "EBIMMessage.h"
#import "UIImage+Alpha.h"

@implementation EBContentBaseView

+ (CGSize)neededContentSize:(EBIMMessage *)message
{
   return CGSizeMake(85, 25);
}

- (void)updateContent:(EBIMMessage*)message
{
    self.message = message;
}

- (void)handleTapEvent
{

}

- (UIImageView *)bubbleImageView
{
   EBBubbleView *bubbleView = (EBBubbleView *)[self superview];
   return bubbleView.bubbleImageView;
}

- (NSString *)toPasteboard
{
    return @" ";
}
@end