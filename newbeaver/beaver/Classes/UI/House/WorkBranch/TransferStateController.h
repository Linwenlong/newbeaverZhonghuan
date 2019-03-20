//
//  TransferStateController.h
//  chow
//
//  Created by 刘海伟 on 2017/11/3.
//  Copyright © 2017年 eallcn. All rights reserved.
//
//  交易详情2.0 - 过户状态界面

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface TransferStateController : BaseViewController
/** 点击过户状态传递过来的合同号 */
@property (nonatomic, copy) NSString *contractNo;

@end
