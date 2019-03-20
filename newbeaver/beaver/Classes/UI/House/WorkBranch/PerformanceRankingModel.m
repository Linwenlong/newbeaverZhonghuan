//
//  PerformanceRankingModel.m
//  beaver
//
//  Created by mac on 17/8/15.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "PerformanceRankingModel.h"

@implementation PerformanceRankingModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.deal_username = dict[@"deal_username"];
        self.deal_count = [NSString stringWithFormat:@"%@",dict[@"deal_count"]];
        self.deal_department_name = dict[@"deal_department_name"];
        self.deal_district = dict[@"deal_district"];
    }
    return self;
}

@end
