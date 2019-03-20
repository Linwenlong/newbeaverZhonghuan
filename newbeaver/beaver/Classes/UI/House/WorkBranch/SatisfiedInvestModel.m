//
//  SatisfiedInvest.m
//  beaver
//
//  Created by mac on 17/12/20.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "SatisfiedInvestModel.h"


@implementation SatisfiedInvestModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.visitType = dict[@"satis_type"];
        self.visitObject = dict[@"satis_object"];
        
        self.deptJudge = dict[@"mendian"];
        self.clientJudge = dict[@"kehu"];
        self.warrantJudge = dict[@"quanzheng"];
        self.officeJudge = dict[@"neiqin"];
        self.fieldworkJudge = dict[@"waiqin"];
        self.isorNot = dict[@"yuanzhuan"];
        
        self.visitDate = [NSString stringWithFormat:@"%@",dict[@"satis_time"]];
        self.keyIn = dict[@"input_user_name"];
        self.keyInDate =[NSString stringWithFormat:@"%@",dict[@"update_time"]] ;
        self.remarks = dict[@"remarks"];
    }
    return self;
}


@end
