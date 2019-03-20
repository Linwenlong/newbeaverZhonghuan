//
//  ZHCheckOneCell.h
//  财务收款项目
//
//  Created by 刘海伟 on 2017/11/26.
//  Copyright © 2017年 liuhaiwei. All rights reserved.
//
//  查看界面第一组cell

#import <UIKit/UIKit.h>

@interface ZHCheckOneCell : UITableViewCell
/** 标题lbl */
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;

/** 条形码imgIcon */
@property (weak, nonatomic) IBOutlet UIImageView *barCodeImgIcon;


+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
