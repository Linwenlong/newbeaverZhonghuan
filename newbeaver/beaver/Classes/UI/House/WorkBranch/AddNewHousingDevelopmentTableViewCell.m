//
//  AddNewHousingDevelopmentTableViewCell.m
//  beaver
//
//  Created by mac on 17/8/17.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "AddNewHousingDevelopmentTableViewCell.h"
#import "CommuityModel.h"

@interface AddNewHousingDevelopmentTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *commuity_name;
@property (weak, nonatomic) IBOutlet UILabel *commuity_address;

@end


@implementation AddNewHousingDevelopmentTableViewCell

- (void)setModel:(CommuityModel *)model{
    _commuity_name.text = model.commuity_name;
    if (model.address.length == 0) {
        _commuity_address.text = [NSString stringWithFormat:@"%@-%@",model.ppname,model.pname];
    }else{
        _commuity_address.text = model.address;
    }
}

- (void)awakeFromNib {
    _commuity_name.textColor = UIColorFromRGB(0x404040);
    _commuity_address.textColor = UIColorFromRGB(0x808080);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
