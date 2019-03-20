//
//  AddFollowLogViewController.h
//  beaver
//
//  Created by wangyuliang on 14-7-22.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBClient.h"
#import "EBHouse.h"

typedef void(^completeBlock)();

@interface AddFollowLogViewController : BaseViewController

@property (nonatomic, assign) BOOL isHouse;

@property (nonatomic, strong) EBClient *client;

@property (nonatomic, strong) EBHouse *house;

@property (nonatomic, copy) completeBlock complete;

@end
