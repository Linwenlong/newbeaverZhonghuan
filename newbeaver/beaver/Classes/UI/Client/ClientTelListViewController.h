//
//  HouseListViewController.h
//  beaver
//
//  Created by 何 义 on 14-3-10.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBController.h"

@interface ClientTelListViewController : BaseViewController

@property (nonatomic, strong) NSArray *clientList;
@property (nonatomic, copy) void(^finishBlock)(BOOL success, NSDictionary *info);

@end
