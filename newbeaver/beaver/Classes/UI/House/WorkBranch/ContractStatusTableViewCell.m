//
//  ContractStatusTableViewCell.m
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ContractStatusTableViewCell.h"

@interface ContractStatusTableViewCell ()

@property (nonatomic, strong)UILabel * commissionStatus;//结佣状态
@property (nonatomic, strong)UILabel * junctionStatus;//结盘状态
@property (nonatomic, strong)UILabel * joinStatus;//交接状态
@property (nonatomic, strong)UIButton * comfire;//确认交接

@property (nonatomic, strong)UILabel * closeStatus;//结案
@property (nonatomic, strong)UILabel * breakStatus;//违约
@property (nonatomic, strong)UILabel * chargeStatus;//退单
@property (nonatomic, strong)UILabel * cuigaohanStatus;//催告函


@end

@implementation ContractStatusTableViewCell

- (void)setDic:(NSDictionary *)dic{
    _commissionStatus.attributedText = [NSString changeString:[NSString stringWithFormat:@"结佣状态: %@",dic[@"commissions_status"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _junctionStatus.attributedText = [NSString changeString:[NSString stringWithFormat:@"结盘状态: %@",dic[@"plate_status"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _joinStatus.attributedText = [NSString changeString:[NSString stringWithFormat:@"交接状态:  %@",dic[@"if_stores"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _closeStatus.attributedText = [NSString changeString:[NSString stringWithFormat:@"结案:  %@",dic[@"close_status"]] frontLength:4 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
     _closeStatus.attributedText = [NSString changeString:[NSString stringWithFormat:@"违约: %@",dic[@"default_status"]] frontLength:4 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
     _closeStatus.attributedText = [NSString changeString:[NSString stringWithFormat:@"退单: %@",dic[@"back_status"]] frontLength:4 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _closeStatus.attributedText = [NSString changeString:[NSString stringWithFormat:@"催告函: %@",dic[@"urge_status"]] frontLength:5 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    if ([dic[@"if_stores"] isEqualToString:@"已确认"]) {
        [_comfire setTitle:@"取消交接" forState:UIControlStateNormal];
        _comfire.tag = 1;
    }else {
         [_comfire setTitle:@"确认交接" forState:UIControlStateNormal];
        _comfire.tag = 2;
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    //卖家
    _commissionStatus = [UILabel new];
    _commissionStatus.textAlignment = NSTextAlignmentLeft;
    _commissionStatus.text = @"结佣状态: 未申请";
    _commissionStatus.textColor = UIColorFromRGB(0x404040);
    _commissionStatus.font = [UIFont systemFontOfSize:13.0f];
    
    _junctionStatus = [UILabel new];
    _junctionStatus.textAlignment = NSTextAlignmentLeft;
    _junctionStatus.text = @"结盘状态: 13528840773";
    _junctionStatus.textColor = UIColorFromRGB(0x404040);
    _junctionStatus.font = [UIFont systemFontOfSize:13.0f];
    
    _joinStatus = [UILabel new];
    _joinStatus.textAlignment = NSTextAlignmentLeft;
    _joinStatus.text = @"交接状态: 未交接";
    _joinStatus.textColor = UIColorFromRGB(0x404040);
    _joinStatus.font = [UIFont systemFontOfSize:13.0f];
    
    _comfire = [UIButton new];
    [_comfire setTitle:@"确认交接" forState:UIControlStateNormal];
    [_comfire setTitleColor:UIColorFromRGB(0x2EB2EF) forState:UIControlStateNormal];
    _comfire.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [_comfire addTarget:self action:@selector(confireClick:) forControlEvents:UIControlEventTouchUpInside];
   
    //买家
    _closeStatus = [UILabel new];
    _closeStatus.textAlignment = NSTextAlignmentLeft;
    _closeStatus.text = @"结案: 未结案";
    _closeStatus.textColor = UIColorFromRGB(0x404040);
    _closeStatus.font = [UIFont systemFontOfSize:13.0f];
    
    _breakStatus = [UILabel new];
    _breakStatus.textAlignment = NSTextAlignmentLeft;
    _breakStatus.text = @"违约: 无";
    _breakStatus.textColor = UIColorFromRGB(0x404040);
    _breakStatus.font = [UIFont systemFontOfSize:13.0f];
    
    _chargeStatus = [UILabel new];
    _chargeStatus.textAlignment = NSTextAlignmentLeft;
    _chargeStatus.text = @"退单: 无";
    _chargeStatus.textColor = UIColorFromRGB(0x404040);
    _chargeStatus.font = [UIFont systemFontOfSize:13.0f];
    
    _cuigaohanStatus = [UILabel new];
    _cuigaohanStatus.textAlignment = NSTextAlignmentLeft;
    _cuigaohanStatus.text = @"催告函: 无催告";
    _cuigaohanStatus.textColor = UIColorFromRGB(0x404040);
    _cuigaohanStatus.font = [UIFont systemFontOfSize:13.0f];
    
    [self.contentView sd_addSubviews:@[_commissionStatus,_junctionStatus,_joinStatus,_comfire,_closeStatus,_breakStatus,_chargeStatus,_cuigaohanStatus]];
    
    [self addLayoutSubviews];
    
}

- (void)addLayoutSubviews{
    CGFloat top = 10;
    CGFloat left = 15;
    CGFloat right = left;
    CGFloat spcing = 5;
    CGFloat h = 15;
    
    _commissionStatus.sd_layout
    .topSpaceToView(self.contentView,top)
    .leftSpaceToView(self.contentView,left)
    .rightSpaceToView(self.contentView,right)
    .heightIs(h);
    
    _junctionStatus.sd_layout
    .topSpaceToView(_commissionStatus,spcing)
    .leftEqualToView(_commissionStatus)
    .rightEqualToView(_commissionStatus)
    .heightIs(h);
    
    _joinStatus.sd_layout
    .topSpaceToView(_junctionStatus,spcing)
    .leftEqualToView(_commissionStatus)
    .widthIs([self sizeToWith:[UIFont systemFontOfSize:13.0f] content:@"交接状态: 未交接"] + 10)
    .heightIs(h);
    
    _comfire.sd_layout
    .topSpaceToView(_junctionStatus,spcing)
    .leftSpaceToView(_joinStatus,left)
    .widthIs([self sizeToWith:[UIFont systemFontOfSize:13.0f] content:@"确认交接"])
    .heightIs(h);
    
    _closeStatus.sd_layout
    .topSpaceToView(_joinStatus,spcing)
    .leftEqualToView(_commissionStatus)
    .rightEqualToView(_commissionStatus)
    .heightIs(h);
    
    _breakStatus.sd_layout
    .topSpaceToView(_closeStatus,spcing)
    .leftEqualToView(_commissionStatus)
    .rightEqualToView(_commissionStatus)
    .heightIs(h);
    
    _chargeStatus.sd_layout
    .topSpaceToView(_breakStatus,spcing)
    .leftEqualToView(_commissionStatus)
    .rightEqualToView(_commissionStatus)
    .heightIs(h);
    
    _cuigaohanStatus.sd_layout
    .topSpaceToView(_chargeStatus,spcing)
    .leftEqualToView(_commissionStatus)
    .rightEqualToView(_commissionStatus)
    .heightIs(h);
}


- (CGFloat)sizeToWith:(UIFont *)font content:(NSString *)content{
    CGSize size = CGSizeMake(kScreenW-100,100);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize  actualsize =[content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;;
    return actualsize.width;
}

- (void)confireClick:(UIButton *)btn{
    if (self.ContractDelegate && [self.ContractDelegate respondsToSelector:@selector(btnClickContractStatus:)]) {
        [self.ContractDelegate btnClickContractStatus:btn];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
