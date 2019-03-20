//
//  FinanceDetailViewController.h
//  beaver
//
//  Created by mac on 17/11/14.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "FinanceViewController.h"

@interface FinanceDetailViewController : BaseViewController

@property (nonatomic, strong) void(^returnBlock)();

@property (nonatomic, strong)NSNumber *document_id;
@property (nonatomic, assign)FinanceType finaceType;//财务类型

@end
