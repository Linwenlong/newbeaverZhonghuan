//
//  CostCountDetailViewController.h
//  beaver
//
//  Created by mac on 17/10/10.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "BaseViewController.h"

@interface CostCountDetailViewController : BaseViewController

@property (nonatomic, copy)  void(^textBlock) ();

@property (nonatomic, strong) NSString *month_half;//统计状态
@property (nonatomic, strong) NSString *statistics;//统计类型

@property (nonatomic, strong) NSDictionary *dic;//字典
@property (nonatomic, strong) NSArray *feedickeys;//字典keys

@property (nonatomic, copy) NSString *type;//字典
@property (nonatomic, copy) NSString *month;//字典


@end
