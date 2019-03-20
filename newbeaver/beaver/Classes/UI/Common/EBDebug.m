//
//  EAllDebug.m
//  beaver
//
//  Created by 何 义 on 14-3-2.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBDebug.h"

@implementation EBDebug

+(void)showFrame:(UIView *)view
{
   view.layer.borderColor = [UIColor redColor].CGColor;
   view.layer.borderWidth = 1.f;
}

+(void)showFrame:(UIView *)view  withColor:(UIColor *)color
{
   view.layer.borderColor = color.CGColor;
   view.layer.borderWidth = 1.f;
}

@end
