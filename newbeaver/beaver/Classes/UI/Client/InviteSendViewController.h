//
// Created by 何 义 on 14-5-28.
// Copyright (c) 2014 eall. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "RecommendViewController.h"

@class EBAppointment;


@interface InviteSendViewController : RecommendViewController

@property (nonatomic, strong) EBAppointment *appointment;
@property (nonatomic, strong) NSMutableArray *appointArray;

@end