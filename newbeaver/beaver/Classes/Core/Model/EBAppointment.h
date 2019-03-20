//
// Created by 何 义 on 14-5-27.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBBaseModel.h"

@class EBClient;


@interface EBAppointment : EBBaseModel

@property (nonatomic)  NSInteger timestamp;
@property (nonatomic)  CGFloat latitude;
@property (nonatomic)  CGFloat longitude;
@property (nonatomic, copy)  NSString *addressTitle;
@property (nonatomic, copy)  NSString *addressDetail;
@property (nonatomic, strong) NSArray *houseIds;
@property (nonatomic, strong) EBClient *client;

@property (nonatomic, strong) NSArray *houses;

@end