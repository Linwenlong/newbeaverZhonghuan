//
// Created by 何 义 on 14-3-9.
// Copyright (c) 2014 eall. All rights reserved.
//

#import "EBBaseModel.h"

@interface EBPrice : EBBaseModel

@property (nonatomic, copy) NSString *unit;
@property (nonatomic, assign) CGFloat diff;
@property (nonatomic, assign) CGFloat unitCost;
@property (nonatomic, copy) NSString *amount;

@end