//
//  PublicNoticeModel.m
//  beaver
//
//  Created by mac on 17/8/14.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "PublicNoticeModel.h"

@implementation PublicNoticeModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.document_id = dict[@"document_id"];
        self.create_time = [self timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dict[@"create_time"]]];
        self.title = dict[@"title"];
        self.username = dict[@"username"];
        self.type = dict[@"type"];
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
