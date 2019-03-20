//
//  ZHTransferStateCell.m
//  chow
//
//  Created by 刘海伟 on 2017/11/6.
//  Copyright © 2017年 eallcn. All rights reserved.
//
//  过户状态cell

#import "ZHTransferStateCell.h"

@implementation ZHTransferStateCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"transfer_cell";
    ZHTransferStateCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ZHTransferStateCell" owner:nil options:nil]lastObject];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


@end
