//
//  GatherSettingViewController.h
//  beaver
//
//  Created by ChenYing on 14-8-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "RTLabel.h"

@interface GatherSettingViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, RTLabelDelegate>

@property (nonatomic, copy) void(^settingChanged)();

@end
