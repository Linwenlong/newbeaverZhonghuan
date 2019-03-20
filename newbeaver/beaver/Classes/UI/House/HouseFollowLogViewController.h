//
//  HouseFollowLogViewController.h
//  beaver
//
//  Created by wangyuliang on 14-6-23.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBHouse.h"
#import "EBHouseFollowLog.h"

@interface HouseFollowLogViewController : BaseViewController

@property (nonatomic, strong) EBHouseFollowLog *followLog;
@property (nonatomic, strong) EBHouse *houseDetail;

@end
