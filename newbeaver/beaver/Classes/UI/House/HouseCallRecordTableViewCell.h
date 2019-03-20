//
//  HouseCallRecordTableViewCell.h
//  beaver
//
//  Created by 林文龙 on 2018/7/20.
//  Copyright © 2018年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface HouseCallRecordTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView * currentDuration;
@property (nonatomic, strong) UILabel * durationLable;

- (void)setDic:(NSDictionary *)dic;

@property (nonatomic, strong) void(^playRecord)(UIView * currentDuration,UILabel *durationLable,UIImageView *icon);

@end
