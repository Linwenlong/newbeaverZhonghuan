//
//  StoreFinanceViewController.h
//  beaver
//
//  Created by mac on 17/11/13.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "BaseViewController.h"

@interface StoreFinanceViewController : BaseViewController

@property (nonatomic, assign)BOOL monthfinance;//月结统计
@property (nonatomic, assign)BOOL halfmonthfinance;//半月结
@property (nonatomic, assign)BOOL dayfinance;//单日结
@property (nonatomic, assign)BOOL tenfinance;//十日结佣


@property (nonatomic, assign)BOOL isShowFee;//是否显示费用统计
@property (nonatomic, assign)BOOL isShowCompanyMoney;//公司收入分账
@property (nonatomic, assign)BOOL isShowStoneAccount;//门店佣金分账
@property (nonatomic, assign)BOOL isShowReimbursement;//报销划账管理

//费用统计的类型
@property (nonatomic, copy)NSString *financeDec;//费用统计规则
@property (nonatomic, strong)NSMutableArray *finProfile;//费用统计类型


@end
