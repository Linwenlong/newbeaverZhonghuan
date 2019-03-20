//
//  ZHFundEditController.h
//  财务收款项目
//
//  Created by 刘海伟 on 2017/11/26.
//  Copyright © 2017年 liuhaiwei. All rights reserved.
//
//  编辑控制器

#import <UIKit/UIKit.h>

@interface ZHFundEditController : UIViewController

@property (nonatomic, strong) NSString *deal_id;
@property (nonatomic, strong) NSString *deal_type;

/** vcTag 0:新增 1:编辑 */
@property (nonatomic, assign) NSInteger vcTag;
/** 查看界面传递的dic */
@property (nonatomic, strong) NSDictionary *checkDic;

//block
@property (nonatomic, strong)void(^returnBlock)();

@end
