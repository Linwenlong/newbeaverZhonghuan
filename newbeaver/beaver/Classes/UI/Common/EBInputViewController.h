//
// Created by 何 义 on 14-4-10.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "BaseViewController.h"


@interface EBInputViewController : BaseViewController

@property (nonatomic, copy) void(^confirmInputBlock)(NSString *confirmString);

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *value;

@end