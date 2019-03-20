//
//  DailyCheckModel.m
//  beaver
//
//  Created by mac on 17/8/30.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "DailyCheckModel.h"
#import "EBCache.h"
#import "EBContact.h"

@interface DailyCheckModel ()

@end

@implementation DailyCheckModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        NSDictionary *contactsDictionary = [[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_CONTACTS];
        NSMutableArray *  allContactsArray = [NSMutableArray arrayWithArray:[contactsDictionary allValues]];
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        if (dict[@"department_id"] != nil) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId contains %@",[NSString stringWithFormat:@"%@",dict[@"department_id"]]];
            resultArray = [[allContactsArray filteredArrayUsingPredicate:predicate] mutableCopy];
        }
        if (resultArray.count>0) {
            EBContact *contact = resultArray.firstObject;
            self.department_name = contact.department;
        }else{
            self.department_name = @"暂无部门";
        }
        self.document_id = dict[@"document_id"];
        self.user_id = dict[@"user_id"];
        self.username = dict[@"username"];
        
        self.status = dict[@"status"];
        self.comment = dict[@"comment"];
        self.update_time = [NSString stringWithFormat:@"%@",[self timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dict[@"update_time"]]]];
        
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
