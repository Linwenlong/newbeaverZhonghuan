//
//  NewsModel.m
//  beaver
//
//  Created by mac on 17/7/25.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "NewsModel.h"

@implementation NewsModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.detail = dict[@"detail"];
        self.title = dict[@"title"];
        self.type = dict[@"type"];
    }
    return self;
}

@end
