//
//  ZHCheckOneCell.m
//  财务收款项目
//
//  Created by 刘海伟 on 2017/11/26.
//  Copyright © 2017年 liuhaiwei. All rights reserved.
//
//  查看界面第一组cell

#import "ZHCheckOneCell.h"

@implementation ZHCheckOneCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"checkOne_cell";
    ZHCheckOneCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ZHCheckOneCell" owner:nil options:nil]lastObject];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
