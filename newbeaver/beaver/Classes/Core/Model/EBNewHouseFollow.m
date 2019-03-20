//
//  EBNewHouseFollow.m
//  beaver
//
//  Created by ChenYing on 14-8-12.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBNewHouseFollow.h"

@implementation EBNewHouseFollow

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"status": @"status",
             @"statusNote": @"status_note",
             @"statusTitle": @"status_title",
             @"updateTime": @"update_time",
             @"createTime": @"create_time",
             @"updateDate": @"update_date",
             @"createDate": @"create_date",
             @"companyId": @"company_id",
             @"companyName": @"company_name",
             @"agentId": @"agent_id",
             @"agentName": @"agent_name",
             @"cityId": @"city_id",
             @"clientName": @"client_name",
             @"clientPhone": @"client_phone",
             @"projectId": @"project_id",
             @"projectName": @"project_name",
             @"statusLog": @"status_log",
    };
}

@end
