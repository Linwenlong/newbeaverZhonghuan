//
//  WorkClientCodeTableViewCell.m
//  beaver
//
//  Created by mac on 18/1/19.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "WorkClientCodeTableViewCell.h"

@interface WorkClientCodeTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *code;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *person;

@end

@implementation WorkClientCodeTableViewCell

- (void)setDic:(NSDictionary *)dic{
    _code.text = [NSString stringWithFormat:@"需求编号:%@",dic[@"client_code"]];
    _name.text = [NSString stringWithFormat:@"客户姓名:%@",dic[@"customer_name"]];
    _person.text =[NSString stringWithFormat:@"维护人:%@",dic[@"principal_username"]] ;
}

- (void)awakeFromNib {
    // Initialization code
    self.contentView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    
    _backView.clipsToBounds = YES;
    _backView.layer.cornerRadius = 5.0f;
    _backView.layer.borderColor = UIColorFromRGB(0xEBEBEB) .CGColor;
    _backView.layer.borderWidth = 1.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
