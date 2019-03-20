//
//  CommonTableViewController.h
//  beaver
//
//  Created by ChenYing on 14-7-22.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonTableViewController : UITableViewController

@property(nonatomic, strong) NSArray *dataSourceArray;
@property(nonatomic, copy) void(^selectedTableRow)(NSInteger selectedIndex);

@end
