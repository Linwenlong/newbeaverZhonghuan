//
//  WorkLogModel.m
//  beaver
//
//  Created by mac on 17/12/18.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "WorkLogModel.h"

@implementation WorkLogModel


- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {

        NSString *timeDate = [NSString timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dict[@"update_time"]]];
        self.logType = [NSString stringWithFormat:@"类型: %@",dict[@"subtype"]];
        self.logDate = [NSString stringWithFormat:@"时间: %@",timeDate];
        self.logName = [NSString stringWithFormat:@"操作人: %@",dict[@"username"]];
        self.logDept = [NSString stringWithFormat:@"所在部门: %@",dict[@"department"]];
        self.logContent =[NSString stringWithFormat:@"操作内容: %@",dict[@"content"]] ;
    }
    return self;
}



@end
