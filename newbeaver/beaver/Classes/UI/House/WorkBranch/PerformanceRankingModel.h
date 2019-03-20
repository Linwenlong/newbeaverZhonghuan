//
//  PerformanceRankingModel.h
//  beaver
//
//  Created by mac on 17/8/15.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PerformanceRankingModel : NSObject

@property (nonatomic, copy) NSString *deal_username;//经纪人名字
@property (nonatomic, copy) NSString *deal_count;//销售的数量
@property (nonatomic, copy)NSString *deal_department_name;//门店
@property (nonatomic, copy)NSString *deal_district;//销售的小区


- (instancetype)initWithDict:(NSDictionary *)dict;

@end
