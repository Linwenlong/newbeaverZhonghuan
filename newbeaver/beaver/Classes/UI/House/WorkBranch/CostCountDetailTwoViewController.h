//
//  CostCountDetailTwoViewController.h
//  beaver
//
//  Created by mac on 17/10/18.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "BaseViewController.h"

@interface CostCountDetailTwoViewController : BaseViewController


@property (nonatomic, strong) NSString *month_half;//统计类型
@property (nonatomic, strong) NSString *statistics;//统计类型

@property (nonatomic, strong) NSDictionary *dic;//字典

@property (nonatomic, strong) NSString *config_type;//子类

@property (nonatomic, strong) NSString *type;//类型

@property (nonatomic, strong) NSString *month;//月份

@end
