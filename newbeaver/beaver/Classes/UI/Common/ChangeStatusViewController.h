//
//  ChangeStatusViewController.h
//  beaver
//
//  Created by ChenYing on 14-7-24.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "RTLabel.h"
#import "EBHouse.h"
#import "EBClient.h"

@interface ChangeStatusViewController : BaseViewController <UIScrollViewDelegate, UITextViewDelegate, RTLabelDelegate, UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong)EBHouse *house;
@property(nonatomic, strong)EBClient *client;
@property(nonatomic)BOOL isClient;

@end
