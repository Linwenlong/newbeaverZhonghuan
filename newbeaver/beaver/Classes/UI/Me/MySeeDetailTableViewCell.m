//
//  MySeeDetailTableViewCell.m
//  beaver
//
//  Created by mac on 17/8/23.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MySeeDetailTableViewCell.h"

@interface MySeeDetailTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *line1;
@property (weak, nonatomic) IBOutlet UILabel *submitDate;
@property (weak, nonatomic) IBOutlet UILabel *clientName;
@property (weak, nonatomic) IBOutlet UIImageView *iphoneImage;
@property (weak, nonatomic) IBOutlet UILabel *commuityName;
@property (weak, nonatomic) IBOutlet UILabel *ppidName;//大区

@property (nonatomic, strong)NSString * tel;

@property (weak, nonatomic) IBOutlet UIView *backView;

@end

@implementation MySeeDetailTableViewCell

-(void)setModel:(MySeeDetailModel *)model{
    _submitDate.text = model.create_time;
    _clientName.text = model.client_name;
    _commuityName.text = model.client_code;
    _ppidName.text = model.content;
    //客户电话
    _tel = model.tel;
}

- (void)awakeFromNib {
    _line1.backgroundColor = UIColorFromRGB(0xff3800);
    _submitDate.textColor = UIColorFromRGB(0x808080);
    _ppidName.textColor = UIColorFromRGB(0x808080);
    _clientName.textColor = UIColorFromRGB(0x808080);
    _commuityName.textColor = UIColorFromRGB(0x808080);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick:)];
    _backView.userInteractionEnabled = YES;
    [_backView addGestureRecognizer:tap];
    
}

- (void)imageClick:(UITapGestureRecognizer *)tap{
    NSLog(@"打电话");
    NSMutableString* str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",_tel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
