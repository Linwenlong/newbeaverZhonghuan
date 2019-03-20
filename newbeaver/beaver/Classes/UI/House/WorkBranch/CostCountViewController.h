//
//  CostCountViewController.h
//  beaver
//
//  Created by mac on 17/10/8.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger , CostCountType)
{
    ZHCostCountTypeMonth = 1,//月
    ZHCostCountTypeHalfMonth = 2,//半月
    ZHCostCountTypeTen = 3,//十日
    ZHCostCountTypeDay//日
};

@interface CostCountViewController : BaseViewController

@property (nonatomic, assign)BOOL monthfinance;//月结统计
@property (nonatomic, assign)BOOL halfmonthfinance;//半月结
@property (nonatomic, assign)BOOL dayfinance;//单日结
@property (nonatomic, assign)BOOL tenfinance;//十日结佣

@property (nonatomic, strong) NSString * financeDec;//费用统计类型

@property (nonatomic, strong) NSArray *totletype;//总的类型
@property (nonatomic, assign) CostCountType costCountType;

@end
