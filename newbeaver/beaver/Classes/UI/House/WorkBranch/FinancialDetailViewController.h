//
//  FinancialDetailViewController.h
//  beaver
//
//  Created by mac on 17/11/26.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "BaseViewController.h"

@interface FinancialDetailViewController : BaseViewController

-(void)refreshHeader;

@property (nonatomic, strong)NSNumber *deal_id;
@property (nonatomic, strong)NSString *contract_code;
@property (nonatomic, strong)NSString *dept_id; //部门id
@property (nonatomic, strong)NSString *deal_type;

@end
