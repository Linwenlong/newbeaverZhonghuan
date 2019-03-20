//
//  FolowupModel.m
//  beaver
//
//  Created by mac on 17/6/21.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FolowupModel.h"

@implementation FolowupModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.document_id = dict[@"document_id"];
        self.house_title = dict[@"new_house_title"];
        self.house_id = dict[@"new_house_id"];
        self.custom_detail = [NSString stringWithFormat:@"%@    %@",dict[@"custom_name"],dict[@"custom_phone"]];
        self.create_time = [self timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dict[@"create_time"]]];
        self.status = dict[@"status"];
        if ([dict[@"custom_remarks"] isEqualToString:@""]) {
            self.custom_remarks = [NSString stringWithFormat:@"备注    %@",@"暂无备注"];
        }else{
            self.custom_remarks = [NSString stringWithFormat:@"备注    %@",dict[@"custom_remarks"]];
        }
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
