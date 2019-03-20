//
//  houseTypeTableViewController.h
//  beaver
//
//  Created by hfy on 16/7/25.
//  Copyright © 2016年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HouseTypeTableViewController : UITableViewController
@property (nonatomic,strong)NSArray *houseTypeChoiceArr;
@property(nonatomic,copy) void(^myblock)(NSString *str);
@end
