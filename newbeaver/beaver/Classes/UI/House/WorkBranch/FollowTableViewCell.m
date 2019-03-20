//
//  FollowTableViewCell.m
//  beaver
//
//  Created by mac on 17/8/24.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FollowTableViewCell.h"

@interface FollowTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *left_type1;
@property (weak, nonatomic) IBOutlet UILabel *left_type2;
@property (weak, nonatomic) IBOutlet UILabel *left_type3;

@property (weak, nonatomic) IBOutlet UILabel *left_type4;
@property (weak, nonatomic) IBOutlet UILabel *left_num1;
@property (weak, nonatomic) IBOutlet UILabel *left_num2;
@property (weak, nonatomic) IBOutlet UILabel *left_num3;
@property (weak, nonatomic) IBOutlet UILabel *left_num4;

@end

#define smallFont [UIFont systemFontOfSize:12.0f]
#define Color2 UIColorFromRGB(0x808080)
#define Color3 UIColorFromRGB(0xff3800)

@implementation FollowTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _left_type1.textColor = Color2;
    _left_type2.textColor = Color2;
    _left_type3.textColor = Color2;
    _left_type4.textColor = Color2;
    _left_num1.textColor = Color3;
    _left_num2.textColor = Color3;
    _left_num3.textColor = Color3;
    _left_num4.textColor = Color3;
}

- (void)setArray:(NSArray *)arr{
    for (int i = 0; i<arr.count; i++) {
        NSDictionary *dic = arr[i];
        if (i == 0) {
            _left_num1.text = [NSString stringWithFormat:@"%@",dic[@"value"]];
            _left_type1.text = [NSString stringWithFormat:@"%@",dic[@"title"]];
        }else if(i == 1){
            _left_num3.text = [NSString stringWithFormat:@"%@",dic[@"value"]];
            _left_type3.text = [NSString stringWithFormat:@"%@",dic[@"title"]];
        }else if(i == 2){
            _left_num2.text = [NSString stringWithFormat:@"%@",dic[@"value"]];
            _left_type2.text = [NSString stringWithFormat:@"%@",dic[@"title"]];
        }else if(i == 3){
            _left_num4.text = [NSString stringWithFormat:@"%@",dic[@"value"]];
            _left_type4.text = [NSString stringWithFormat:@"%@",dic[@"title"]];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
