//
//  NewPushView.m
//  中环经纪人助手-工作总结
//
//  Created by 刘海伟 on 2018/1/23.
//  Copyright © 2018年 liuhaiwei. All rights reserved.
//
//  主推房源新增View

#import "NewPushView.h"

@implementation NewPushView

+ (instancetype)initNewPushView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"NewPushView" owner:nil options:nil] firstObject];
}


//点击了新增按钮
- (IBAction)didClickAdd:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(NewPushViewDidClickAddButton:)]) {
        [self.delegate NewPushViewDidClickAddButton:self];
    }
}





@end
