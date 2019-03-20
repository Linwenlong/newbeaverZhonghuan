//
//  FinancialDetainModel.h
//  beaver
//
//  Created by mac on 17/12/25.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FinancialDetainModel : NSObject

@property (nonatomic, copy)NSString * update_time; //时间
@property (nonatomic, copy)NSString * price_type;//费用 类型
@property (nonatomic, copy)NSString * price_name;//费用 类型
@property (nonatomic, copy)NSString * status;//费用 状态
@property (nonatomic, copy)NSString * fee_user;//收款方类型
@property (nonatomic, copy)NSString * cost_status;//收款 类型
@property (nonatomic, copy)NSString * price_num;//价格
@property (nonatomic, copy)NSString * memo;//备注

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
