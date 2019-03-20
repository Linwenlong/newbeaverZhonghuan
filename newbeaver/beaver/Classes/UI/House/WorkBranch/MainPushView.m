//
//  MainPushView.m
//  中环经纪人助手-工作总结
//
//  Created by 刘海伟 on 2018/1/23.
//  Copyright © 2018年 liuhaiwei. All rights reserved.
//
//  主推房源View

#import "MainPushView.h"

@implementation MainPushView

+ (instancetype)initMainPushView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"MainPushView" owner:nil options:nil] firstObject];
}

// 点击了添加按钮
- (IBAction)didClickAddBtn:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(mainPushViewDidClickAddButton:)]) {
        [self.delegate mainPushViewDidClickAddButton:self];
    }
    
}




@end
