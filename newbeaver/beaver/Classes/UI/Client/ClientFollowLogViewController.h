//
//  ClientFollowLogViewController.h
//  beaver
//
//  Created by wangyuliang on 14-6-22.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBClientFollowLog.h"
#import "EBClient.h"

@interface ClientFollowLogViewController : BaseViewController

@property (nonatomic, strong) EBClientFollowLog *followLog;
@property (nonatomic, strong) EBClient *clientDetail;

@end
