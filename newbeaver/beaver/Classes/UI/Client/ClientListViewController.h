//
//  HouseListViewController.h
//  beaver
//
//  Created by 何 义 on 14-3-10.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBController.h"

@interface ClientListViewController : BaseViewController

@property (nonatomic, assign) EClientListType listType;
@property (nonatomic, strong) EBFilter *filter;
@property (nonatomic, strong) NSArray *houses;
@property (nonatomic, copy) void(^handleSelections)(NSArray *);

@property (nonatomic, strong) NSDictionary *appParam;

@end
