//
//  HouseListViewController.h
//  beaver
//
//  Created by 何 义 on 14-3-10.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBController.h"

@interface HouseListViewController : BaseViewController

@property (nonatomic, assign) EHouseListType listType;
@property (nonatomic, strong) EBFilter *filter;
@property (nonatomic, strong) EBClient *client;
@property (nonatomic, strong) EBCondition *condition;
@property (nonatomic, copy) void(^handleSelections)(NSArray *);

@property (nonatomic, strong) NSDictionary *appParam;

//lwl
@property (nonatomic, assign) BOOL isLWL;
@property (nonatomic, assign) BOOL is_hidden_sort_btn;

@end
