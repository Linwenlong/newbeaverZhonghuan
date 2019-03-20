//
//  GroupsViewController.h
//  beaver
//
//  Created by 何 义 on 14-3-11.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"

@class EBIMGroup;

@interface GroupsViewController : BaseViewController

@property (nonatomic, copy) void (^groupSelected)(EBIMGroup *group);

@end
