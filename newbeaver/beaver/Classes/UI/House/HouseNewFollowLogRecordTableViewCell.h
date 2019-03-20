//
//  HouseNewFollowLogRecordTableViewCell.h
//  beaver
//
//  Created by 林文龙 on 2018/8/22.
//  Copyright © 2018年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HouseNewFollowLogRecordModel.h"

@interface HouseNewFollowLogRecordTableViewCell : UITableViewCell

@property (nonatomic, strong)HouseNewFollowLogRecordModel * model;

@property (nonatomic, strong) UIView * currentDuration;
@property (nonatomic, strong) UILabel * durationLable;

@property (nonatomic, strong) void(^playRecord)(UIView * currentDuration,UILabel *durationLable,UIImageView *icon);

@property (nonatomic, strong) NSDictionary * dic;

@end
