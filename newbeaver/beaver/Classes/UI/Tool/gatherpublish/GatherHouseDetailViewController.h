//
//  GatherHouseDetailViewController.h
//  beaver
//
//  Created by wangyuliang on 14-8-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBGatherHouse.h"

@interface GatherHouseDetailViewController : BaseViewController

@property (nonatomic, strong) EBGatherHouse *house;
@property (nonatomic) BOOL openPhoneSet;

@end
