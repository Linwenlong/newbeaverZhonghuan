//
//  FinancialDetainModel.m
//  beaver
//
//  Created by mac on 17/12/25.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FinancialDetainModel.h"

@implementation FinancialDetainModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.update_time = [NSString timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dict[@"update_time"]]];
        self.price_type = dict[@"price_type"];
        self.price_name = dict[@"price_name"];
        self.status = dict[@"status"];
        self.fee_user = dict[@"fee_user"];
        if ([dict.allKeys containsObject:@"cost_status"]) {
            self.cost_status = dict[@"cost_status"];
        }else{
            self.cost_status = dict[@"price_charge"];
        }
        self.price_num = [NSString stringWithFormat:@"%@",dict[@"price_num"]];
        self.memo = dict[@"memo"];
    }
    return self;
}

@end
