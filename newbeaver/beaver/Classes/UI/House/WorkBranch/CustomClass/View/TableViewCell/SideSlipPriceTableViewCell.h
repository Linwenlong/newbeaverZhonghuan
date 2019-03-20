//
//  SideSlipPriceTableViewCell.h
//  ZYSideSlipFilter
//
//  Created by zhiyi on 16/10/14.
//  Copyright © 2016年 zhiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideSlipBaseTableViewCell.h"

@interface SideSlipPriceTableViewCell : SideSlipBaseTableViewCell

@property (strong, nonatomic) ZYSideSlipFilterRegionModel *regionModel;

@property (strong, nonatomic) NSString * start;
@property (strong, nonatomic) NSString * end;

@property (strong, nonatomic) NSIndexPath * current_path;

@property (weak, nonatomic) IBOutlet UIButton *startBtn;

@property (weak, nonatomic) IBOutlet UIButton *endBtn;

@end
