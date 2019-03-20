//
//  EBNumberStatus.m
//  beaver
//
//  Created by wangyuliang on 14-7-7.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBNumberStatus.h"

@implementation EBNumberStatus

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"anonymousNumber": @"anonymous_call_number",
             @"enableAnonymous": @"enable_anonymous_call",
             @"isNumberVerified": @"is_number_verified",
             @"canShowNumber": @"can_show_number",
             @"verifyDesc": @"verify_desc"
             };
}

@end
