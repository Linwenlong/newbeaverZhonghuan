//
// Created by 何 义 on 14-3-8.
// Copyright (c) 2014 eall. All rights reserved.
//

#import "EBBaseModel.h"

@class EBFilter;

@interface EBCondition : NSObject

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray *communities;
@property (nonatomic, strong) EBFilter *filter;

- (void)parseValuesFrom:(NSDictionary *)dictionary;
- (NSDictionary *)currentArgs;

@end