//
// Created by 何 义 on 14-5-27.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBBaseModel.h"

@class EBClient;


@interface EBHouseVisitLog : EBBaseModel

@property (nonatomic, copy)  NSString *visitUser;
//@property (nonatomic, copy)  NSString *visitDate;
@property (nonatomic)  NSInteger visitDate;
@property (nonatomic, copy)  NSString *visitContent;
@property (nonatomic, strong) EBClient *client;

@end