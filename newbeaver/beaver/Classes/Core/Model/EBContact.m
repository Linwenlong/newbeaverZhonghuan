//
// Created by 何 义 on 14-3-8.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBContact.h"

@implementation EBContact

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
//            @"imId": @"im_id",
            @"deptId": @"dept_id",
            @"deptTel": @"dept_tel",
            @"userId": @"user_id",
            @"department": @"dept_name",
            @"phone": @"user_tel",
            @"name": @"user_name",
            @"avatar": @"user_image",
            @"gender": @"user_gender",
            @"happenDate": @"happen_date"
    };
}

@end