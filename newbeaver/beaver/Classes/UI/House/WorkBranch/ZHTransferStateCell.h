//
//  ZHTransferStateCell.h
//  chow
//
//  Created by 刘海伟 on 2017/11/6.
//  Copyright © 2017年 eallcn. All rights reserved.
//
//  过户状态cell

#import <UIKit/UIKit.h>

@interface ZHTransferStateCell : UITableViewCell

/** 标题1 */
@property (weak, nonatomic) IBOutlet UILabel *titleOneLbl;

/** 内容1 */
@property (weak, nonatomic) IBOutlet UILabel *contentOneLbl;


+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
