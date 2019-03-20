//
//  HouseNewFollowLogRecordModel.m
//  beaver
//
//  Created by 林文龙 on 2018/8/22.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "HouseNewFollowLogRecordModel.h"

@implementation HouseNewFollowLogRecordModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {        
        _date = [NSString stringWithFormat:@"%ld",[dict[@"date"] integerValue]];
        _department = dict[@"department"];
        _user = dict[@"user"];
        _way = dict[@"way"];
        _is_tel_record = [dict[@"is_tel_record"] intValue];
        _c_record = dict[@"c_record"];
        _avatar = dict[@"avatar"];
        _content = dict[@"content"];
    }
    return self;
}


@end
