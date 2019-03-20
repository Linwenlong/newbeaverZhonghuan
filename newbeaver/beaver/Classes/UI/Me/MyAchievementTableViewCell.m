//
//  MyAchievementTableViewCell.m
//  beaver
//
//  Created by mac on 17/8/22.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MyAchievementTableViewCell.h"

@interface MyAchievementTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *left_num;
@property (weak, nonatomic) IBOutlet UILabel *left_type;
@property (weak, nonatomic) IBOutlet UILabel *right_type;
@property (weak, nonatomic) IBOutlet UILabel *right_num;
@property (weak, nonatomic) IBOutlet UIView *line1;


@end

@implementation MyAchievementTableViewCell

- (void)setLeftTitle:(NSString *)leftType leftConnent:(NSString *)leftConnent rightType:(NSString *)rightType rightConnent:(NSString *)rightConnent{
    _left_type.text  = leftType;
    _left_num.text = leftConnent;
    
    _right_type.text  = rightType;
    _right_num.text = rightConnent;
}

- (void)awakeFromNib {
    // Initialization code
    _line1.backgroundColor =[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00];
    _left_type.textColor = [UIColor colorWithRed:0.51 green:0.51 blue:0.51 alpha:1.00];
    _left_num.textColor = UIColorFromRGB(0xff3800);
    _right_type.textColor = [UIColor colorWithRed:0.51 green:0.51 blue:0.51 alpha:1.00];
    _right_num.textColor = UIColorFromRGB(0xff3800);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
