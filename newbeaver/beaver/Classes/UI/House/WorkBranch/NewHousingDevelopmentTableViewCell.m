//
//  NewHousingDevelopmentTableViewCell.m
//  beaver
//
//  Created by mac on 17/8/14.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "NewHousingDevelopmentTableViewCell.h"

@interface NewHousingDevelopmentTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *houseCount;


@end

@implementation NewHousingDevelopmentTableViewCell

- (void)setDic:(NSDictionary *)dic{
    _title.text = dic[@"community"];
    if (dic[@"num"] == nil) {
        _houseCount.text = [NSString stringWithFormat:@"%@套房源",@0];
    }else{
        _houseCount.text = [NSString stringWithFormat:@"%@套房源",dic[@"num"]];
    }
    
    _address.text = dic[@"address"];
}

- (void)awakeFromNib {
    _title.textColor = [UIColor colorWithRed:0.46 green:0.46 blue:0.47 alpha:1.00];
    _address.textColor = UIColorFromRGB(0xa4a4a4);
     _houseCount.textColor = UIColorFromRGB(0xa4a4a4);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

  
}

@end
