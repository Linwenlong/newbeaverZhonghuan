//
//  SatisfiedInvest.h
//  beaver
//
//  Created by mac on 17/12/20.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SatisfiedInvestModel : NSObject

@property (nonatomic, copy)NSString * visitType; //回访类型
@property (nonatomic, copy)NSString * visitObject;//回访对象
@property (nonatomic, copy)NSString * deptJudge;//门店评价
@property (nonatomic, copy)NSString * clientJudge;//客户评价
@property (nonatomic, copy)NSString * warrantJudge;//权证评价
@property (nonatomic, copy)NSString * officeJudge;//内勤评价
@property (nonatomic, copy)NSString * fieldworkJudge;//外勤评价
@property (nonatomic, copy)NSString * isorNot;//是否可以转
@property (nonatomic, copy)NSString * visitDate;//回访时间
@property (nonatomic, copy)NSString * keyIn;//录入
@property (nonatomic, copy)NSString * keyInDate;//录入时间
@property (nonatomic, copy)NSString * remarks;//备注

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
