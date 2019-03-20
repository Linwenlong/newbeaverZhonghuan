//
//  ZHCheckTwoCell.m
//  财务收款项目
//
//  Created by 刘海伟 on 2017/11/26.
//  Copyright © 2017年 liuhaiwei. All rights reserved.
//
//  查看界面第二组cell

#import "ZHCheckTwoCell.h"

@implementation ZHCheckTwoCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"checkTwo_cell";
    ZHCheckTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ZHCheckTwoCell" owner:nil options:nil]lastObject];
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
