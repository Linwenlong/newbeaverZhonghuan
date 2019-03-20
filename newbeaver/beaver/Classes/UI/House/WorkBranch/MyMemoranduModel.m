//
//  MyMemoranduModel.m
//  beaver
//
//  Created by mac on 17/8/16.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MyMemoranduModel.h"

@implementation MyMemoranduModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.document_id = dict[@"document_id"];
        self.user_id = dict[@"user_id"];
        self.username = dict[@"username"];
        self.department = dict[@"department"];
        self.title = dict[@"title"];
        self.content = dict[@"content"];
        self.create_time = [NSString stringWithFormat:@"%@",[self timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dict[@"create_time"]]]];
     
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
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm"];
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    //1483849740
    return dateString;
}

@end
