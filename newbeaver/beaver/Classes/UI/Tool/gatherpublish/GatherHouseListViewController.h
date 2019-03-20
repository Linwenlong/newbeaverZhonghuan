//
//  GatherHouseListViewController.h
//  beaver
//
//  Created by ChenYing on 14-8-28.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBController.h"

@interface GatherHouseListViewController : BaseViewController

@property (nonatomic, assign) EGatherHouseListType listType;
@property (nonatomic, strong) EBCondition *condition;
@property (nonatomic, strong) EBFilter *filter;

@end
