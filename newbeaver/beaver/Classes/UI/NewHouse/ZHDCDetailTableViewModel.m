//
//  ZHDCDetailTableViewModel.m
//  beaver
//
//  Created by mac on 17/6/20.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ZHDCDetailTableViewModel.h"

@implementation ZHDCDetailTableViewModel
- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        _leftType = dict[@"leftType"];
        _leftConTent = dict[@"leftContent"];
        _rightType = dict[@"rightType"];
        _rightConTent = dict[@"rightContent"];
    }
    return self;
}


@end
