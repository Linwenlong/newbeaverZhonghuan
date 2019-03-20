//
//  ClientHisInviteViewController.h
//  beaver
//
//  Created by wangyuliang on 14-6-23.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBController.h"
#import "HouseListViewController.h"
#import "EBAppointment.h"

@interface ClientHisInviteViewController : BaseViewController

@property (nonatomic, strong) NSMutableArray *appointArray;
@property (nonatomic, strong) EBClient *clientDetail;

@end
