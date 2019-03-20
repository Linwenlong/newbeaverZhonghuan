//
//  XMGHomeLabel.m
//  02-网易新闻首页
//
//  Created by xiaomage on 15/7/6.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "XMGHomeLabel.h"

const CGFloat XMGRed = 0;
const CGFloat XMGGreen = 0;
const CGFloat XMGBlue = 0;
const CGFloat XMGAlpha = 1.0;
const int XMGAge = 20;
NSString * const XMGName = @"jack";

@implementation XMGHomeLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.font = [UIFont systemFontOfSize:16];
//        self.textColor = [UIColor colorWithRed:XMGRed green:XMGGreen blue:XMGBlue alpha:1.0];
//        self.textColor = [UIColor redColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    
    //      R G B   255
    // 默认：0.4 0.6 0.7
    // 红色：1   0   0
    //绿色 ：0   0.9   0
    
//    CGFloat red = XMGRed + (0 - XMGRed) * scale;
//    CGFloat green = XMGGreen + (0.9 - XMGGreen) * scale;
//    CGFloat blue = XMGBlue + (0 - XMGBlue) * scale;
//    
        CGFloat red = 65/256.0 * scale;
        CGFloat green =  179/256.0 * scale;
        CGFloat blue = 120/256.0 * scale;
    
        self.textColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
//        self.textColor = [UIColor redColor];
        // 大小缩放比例
        CGFloat transformScale = 1 + scale * 0.2; // [1, 1.3]
        self.transform = CGAffineTransformMakeScale(transformScale, transformScale);
 
//        self.textColor = [UIColor colorWithRed:65/256.0 green:179/256.0 blue:120/256.0 alpha:1.0];
    
}
@end