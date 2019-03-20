//
//  EBAgent.m
//  beaver
//
//  Created by ChenYing on 14-8-11.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBAgent.h"

@implementation EBAgent

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"deptName": @"dept_name",
             @"userId": @"user_id",
             @"userName": @"user_name",
             @"userTel": @"user_tel",
             @"happenDate": @"happen_date"
    };
}

@end
