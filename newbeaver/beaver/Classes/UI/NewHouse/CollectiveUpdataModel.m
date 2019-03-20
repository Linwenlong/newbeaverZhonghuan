//
//  CollectiveUpdataModel.m
//  beaver
//
//  Created by mac on 17/6/29.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "CollectiveUpdataModel.h"

@implementation CollectiveUpdataModel



- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.house_title = dict[@"title"];
        self.house_id = dict[@"id"];
          }
    return self;
}


@end
