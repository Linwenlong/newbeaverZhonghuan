//
//  SeeTableViewCell.m
//  beaver
//
//  Created by mac on 17/8/24.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "SeeTableViewCell.h"

@interface SeeTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *left_type;
@property (weak, nonatomic) IBOutlet UILabel *left_num;
@property (weak, nonatomic) IBOutlet UILabel *right_type;
@property (weak, nonatomic) IBOutlet UILabel *right_num;


@end

#define smallFont [UIFont systemFontOfSize:12.0f]
#define Color2 UIColorFromRGB(0x808080)
#define Color3 UIColorFromRGB(0xff3800)

@implementation SeeTableViewCell

- (void)setArray:(NSArray *)arr{
    for (int i = 0; i<arr.count; i++) {
         NSDictionary *dic = arr[i];
        if (i == 0) {
            _left_num.text = [NSString stringWithFormat:@"%@",dic[@"value"]];
            _left_type.text = [NSString stringWithFormat:@"%@",dic[@"title"]];
        }else{
            _right_num.text = [NSString stringWithFormat:@"%@",dic[@"value"]];
              _right_type.text = [NSString stringWithFormat:@"%@",dic[@"title"]];
        }
    }
}

- (void)awakeFromNib {
    _left_type.textColor = Color2;
    _left_type.font = smallFont;
    _right_type.textColor = Color2;
    _right_type.font = smallFont;
    
    _left_num.textColor = Color3;
    _left_num.font = smallFont;
    _right_num.textColor = Color3;
    _right_num.font = smallFont;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
