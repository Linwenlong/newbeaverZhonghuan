//
//  HotModel.m
//  beaver
//
//  Created by mac on 17/6/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "HotModel.h"

@implementation HotModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.house_id = dict[@"id"];
        NSString *title = dict[@"title"];
        if ([title isEqualToString:@"（"]) {
            NSRange range = [title rangeOfString:@"（"];
            self.house_title = [title substringToIndex:range.location];
        }else{
            self.house_title = title;
        }
        
    }
    return self;
}


@end
