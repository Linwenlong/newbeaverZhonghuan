//
//  FinanceViewController.h
//  beaver
//
//  Created by mac on 17/11/13.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger , FinanceType)
{
    ZHFinanceTypeCompanyIncomeLedger = 1,//公司收入分账
    ZHFinanceTypeStoreCommission  = 2,//门店佣金分账
    ZHFinanceTypeReimbursementAccountManagement = 3//报销划账管理
};


@interface FinanceViewController : BaseViewController

@property (nonatomic, assign)FinanceType finaceType;//财务类型

@end
