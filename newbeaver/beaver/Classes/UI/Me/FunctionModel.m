//
//  FunctionModel.m
//  beaver
//
//  Created by mac on 17/11/30.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FunctionModel.h"

@implementation FunctionModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.subtitle = dict[@"subtitle"];
        self.date = dict[@"date"];
        self.content = dict[@"content"];
    }
    return self;
}

@end
