//
//  EBElementStyle.m
//  MyQuickDialog
//
//  Created by LiuLian on 7/22/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#import "EBElementStyle.h"
#import "EBStyle.h"

@implementation EBElementStyle

+ (EBElementStyle *)defaultStyle
{
    EBElementStyle *style = [EBElementStyle new];
    style.fontSize = 16;
    style.font = [UIFont systemFontOfSize:style.fontSize];
    style.fontColor = [EBStyle darkBlueTextColor];
    style.prefixFont = style.suffixFont = style.font;
    style.prefixFontColor = [EBStyle blackTextColor];
    style.suffixFontColor = [EBStyle grayTextColor];
    style.textAlignment = NSTextAlignmentLeft;
    style.underline = YES;
    style.padding = UIEdgeInsetsMake(0, 80, 0, 0);
    return style;
}

- (id)copyWithZone:(NSZone *)zone
{
    EBElementStyle *copy = [[self class] allocWithZone:zone];
    
    
    return copy;
}
@end
