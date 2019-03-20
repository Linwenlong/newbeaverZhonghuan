//
//  ZHCheckController.h
//  财务收款项目
//
//  Created by 刘海伟 on 2017/11/26.
//  Copyright © 2017年 liuhaiwei. All rights reserved.
//
//  "查看"控制器

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ZHCheckController : BaseViewController

@property (nonatomic, strong) void (^returnBlock)();

@property (nonatomic, strong) NSString *deal_id;
@property (nonatomic, strong) NSString *deal_type;
@property (nonatomic, strong) NSDictionary *checkDic;

@end
