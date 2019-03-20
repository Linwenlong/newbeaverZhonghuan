//
// Created by 何 义 on 14-3-8.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBCondition.h"
#import "EBFilter.h"


@implementation EBCondition

- (NSDictionary *)currentArgs
{
    NSMutableDictionary *args = [_filter currentArgs];

    args[@"title"] = _title;
    if (_communities.count > 0)
    {
        args[@"community"] = [_communities componentsJoinedByString:@";"];
    }
    else
    {
        args[@"community"] = @"";
    }
    if (_id)
    {
        args[@"id"] = _id;
    }

    return args;
}

- (void)parseValuesFrom:(NSDictionary *)dictionary
{
    _id = dictionary[@"special_id"];
    NSString *community = dictionary[@"community"];
    if (community.length > 0)
    {
        _communities = [community componentsSeparatedByString:@";"];
    }
    _filter = [[EBFilter alloc] init];
    [_filter parseFromDictionary:dictionary];
}

@end