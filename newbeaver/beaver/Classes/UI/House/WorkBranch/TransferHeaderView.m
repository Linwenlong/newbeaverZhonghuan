//
//  TransferHeaderView.m
//  chow
//
//  Created by 刘海伟 on 2017/11/6.
//  Copyright © 2017年 eallcn. All rights reserved.
//
//  过户状态headerView

#import "TransferHeaderView.h"

@implementation TransferHeaderView

+ (instancetype)headerView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"TransferHeaderView" owner:nil options:nil] firstObject];
}

@end
