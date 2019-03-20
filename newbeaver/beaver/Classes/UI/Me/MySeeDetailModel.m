//
//  MySeeDetailModel.m
//  beaver
//
//  Created by mac on 17/8/31.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MySeeDetailModel.h"

@implementation MySeeDetailModel


- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.client_code = dict[@"client_code"];
        self.tel = dict[@"tel"];
        self.house_num = dict[@"house_num"];
        self.client_name = dict[@"client_name"];
        self.content = dict[@"content"];
        self.create_time = [NSString stringWithFormat:@"%@",[self timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dict[@"create_time"]]]];
          self.house_ids = dict[@"house_ids"];
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
    [formatter setDateFormat:@"yyyy-MM-dd"];
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    //1483849740
    return dateString;
}


@end
