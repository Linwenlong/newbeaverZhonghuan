//
//  FollowupDetailModel.m
//  beaver
//
//  Created by mac on 17/6/29.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FollowupDetailModel.h"

@implementation FollowupDetailModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.status = dict[@"status"];
        self.memo = dict[@"memo"];
        self.update_time =[self timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dict[@"update_time"]]] ;
        self.custom_name = dict[@"custom_name"];
        self.custom_phone = dict[@"custom_phone"];
        self.house_title = dict[@"new_house_title"];
    }
    return self;
}

#pragma mark -- 时间戳转时间
- (NSString *)timeWithTimeIntervalString:(NSString *)timeString{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd   hh : mm"];
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    //1483849740
    return dateString;
}


@end
