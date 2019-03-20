//
//  ChargeTableViewCell.m
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
// 收费，过户，贷款 高度90
//

#import "ChargeTableViewCell.h"

@interface ChargeTableViewCell ()

@property (nonatomic, strong)UIImageView *statusIcon;
@property (nonatomic, strong)UILabel *statusTitle;//状态
@property (nonatomic, strong)UILabel *statusContentSell;//卖家
@property (nonatomic, strong)UILabel *statusContentBuy;//买家
@property (nonatomic, strong)UIImageView *accoryIcon;

@end

@implementation ChargeTableViewCell

-(void)setDic:(NSDictionary *)dic{
    
    //合同的状态
    if ([dic[@"chargeStatus"] integerValue] == 0) {//未收费 0
        _statusIcon.image = [UIImage imageNamed:@"chargeFailure"];
        _statusTitle.text = @"未收费";
    }else if ([dic[@"chargeStatus"] integerValue] == 1){//已收齐 1
        _statusTitle.text = @"已收齐";
        _statusIcon.image = [UIImage imageNamed:@"chargeSucess"];
    }else{//已欠费 2
        _statusIcon.image = [UIImage imageNamed:@"chargeFailure"];
        _statusTitle.text = @"已欠费";
    }
    
    //下面的信息
    NSDictionary *jfFinanceSummary = dic[@"jfFinanceSummary"];
    NSString *jfStatus = @"";
    if ([jfFinanceSummary[@"chargedStatus"] integerValue] == 0) {//未收费 0
        jfStatus = @"未收费";
    }else if ([jfFinanceSummary[@"chargedStatus"] integerValue] == 1){//已收齐 1
        jfStatus = @"已收齐";
    }else{//已欠费 2
        jfStatus = @"已欠费";
    }
    
    _statusContentSell.attributedText = [NSString changeString:[NSString stringWithFormat:@"甲方(卖家): %@  应收 ¥%@",jfStatus,jfFinanceSummary[@"fee"]] frontLength:13+jfStatus.length frontColor:LWL_DarkGrayrColor otherColor:LWL_RedColor];
    
    //买家的信息
    NSDictionary *yfFinanceSummary = dic[@"yfFinanceSummary"];
    NSString *yfStatus = @"";
    if ([yfFinanceSummary[@"chargedStatus"] integerValue] == 0) {//未收费 0
        yfStatus = @"未收费";
    }else if ([yfFinanceSummary[@"chargedStatus"] integerValue] == 1){//已收齐 1
        yfStatus = @"已收齐";
    }else{//已欠费 2
        yfStatus = @"已欠费";
    }
    _statusContentBuy.attributedText = [NSString changeString:[NSString stringWithFormat:@"乙方(买家): %@  应收 ¥%@",yfStatus,yfFinanceSummary[@"fee"]] frontLength:13+yfStatus.length frontColor:LWL_DarkGrayrColor otherColor:LWL_RedColor];
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    _statusIcon = [UIImageView new];
    _statusIcon.image = [UIImage imageNamed:@"chargeFailure"];
    
    _statusTitle = [UILabel new];
    _statusTitle.textAlignment = NSTextAlignmentLeft;
    _statusTitle.text = @"已欠费";
    _statusTitle.textColor = UIColorFromRGB(0x404040);
    _statusTitle.font = [UIFont systemFontOfSize:13.0f];
    
    _statusContentSell = [UILabel new];
    _statusContentSell.textAlignment = NSTextAlignmentLeft;
    _statusContentSell.text = @"甲方（卖家）: 已收齐 ¥51,000.00";
    _statusContentSell.textColor = UIColorFromRGB(0x808080);
    _statusContentSell.font = [UIFont systemFontOfSize:13.0f];
    
    _statusContentBuy = [UILabel new];
    _statusContentBuy.textAlignment = NSTextAlignmentLeft;
    _statusContentBuy.text = @"乙方（买家）: 乙欠费 ¥51,000.00";
    _statusContentBuy.textColor = UIColorFromRGB(0x808080);
    _statusContentBuy.font = [UIFont systemFontOfSize:13.0f];
    
    _accoryIcon = [UIImageView new];
    _accoryIcon.image = [UIImage imageNamed:@"jiantou"];
    
    [self.contentView sd_addSubviews:@[_statusIcon,_statusTitle,_statusContentSell,_statusContentBuy,_accoryIcon]];
    
    [self addLayoutSubviews];
}

- (void)addLayoutSubviews{
    CGFloat top = 15;
    CGFloat left = 15;
    CGFloat right = left;
    
    CGFloat h = 15;
    
    _statusIcon.sd_layout
    .topSpaceToView(self.contentView,top)
    .leftSpaceToView(self.contentView,left)
    .widthIs(h)
    .heightIs(h);
    
    _accoryIcon.sd_layout
    .topSpaceToView(self.contentView,top)
    .rightSpaceToView(self.contentView,right)
    .widthIs(7)
    .heightIs(12);
    
    _statusTitle.sd_layout
    .topSpaceToView(self.contentView,top)
    .leftSpaceToView(_statusIcon,3)
    .rightSpaceToView(_accoryIcon,right)
    .heightIs(h);
    
    _statusContentSell.sd_layout
    .topSpaceToView(_statusTitle,10)
    .leftEqualToView(_statusTitle)
    .rightSpaceToView(self.contentView,right)
    .heightIs(h);
    
    _statusContentBuy.sd_layout
    .topSpaceToView(_statusContentSell,5)
    .leftEqualToView(_statusTitle)
    .rightSpaceToView(self.contentView,right)
    .heightIs(h);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
