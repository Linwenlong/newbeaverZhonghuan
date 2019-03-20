//
//  FinanceDetailModel.m
//  beaver
//
//  Created by mac on 17/11/14.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FinanceDetailModel.h"

@implementation FinanceDetailModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        _name = dict[@"name"];
        _value = dict[@"value"];
    }
    return self;
}




@end
