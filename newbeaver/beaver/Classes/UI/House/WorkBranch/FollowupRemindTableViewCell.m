//
//  FollowupRemindTableViewCell.m
//  beaver
//
//  Created by mac on 17/8/16.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FollowupRemindTableViewCell.h"

@interface FollowupRemindTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *type;
@property (weak, nonatomic) IBOutlet UILabel *rank;//等级
@property (weak, nonatomic) IBOutlet UILabel *days;//多少天
@property (weak, nonatomic) IBOutlet UILabel *houses;

@end

@implementation FollowupRemindTableViewCell

- (void)setDic:(NSDictionary *)dic{
    _type.text =[NSString stringWithFormat:@"【%@%@】",dic[@"type"],dic[@"rank"]];

    _days.text = [NSString stringWithFormat:@"%@天未回访",dic[@"day_min"]] ;
    if ([dic[@"type"] isEqualToString:@"出售"] || [dic[@"type"] isEqualToString:@"出租"]){
        _houses.text = [NSString stringWithFormat:@"%@套房源",dic[@"num"]];
    }else{
        _houses.text = [NSString stringWithFormat:@"%@条客源",dic[@"num"]];
    }
}

- (void)awakeFromNib {
   _type.textColor = UIColorFromRGB(0xff3800);
    _rank.textColor = UIColorFromRGB(0x188fd1);
    _days.textColor = [UIColor colorWithRed:0.46 green:0.46 blue:0.47 alpha:1.00];
    _houses.textColor = UIColorFromRGB(0xa4a4a4);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
