//
//  ZHCheckTwoCell.h
//  财务收款项目
//
//  Created by 刘海伟 on 2017/11/26.
//  Copyright © 2017年 liuhaiwei. All rights reserved.
//
//  查看界面第二组cell

#import <UIKit/UIKit.h>

@interface ZHCheckTwoCell : UITableViewCell
/** 标题lbl */
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;

/** 内容lbl */
@property (weak, nonatomic) IBOutlet UILabel *contentLbl;


+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
