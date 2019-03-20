//
//  BasisInformationTableViewCell.m
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//  高度 300
//

#import "BasisInformationTableViewCell.h"

@interface BasisInformationTableViewCell ()

@property (nonatomic, strong)UILabel * address;//产证地址
@property (nonatomic, strong)UILabel * contractType;//合同类型
@property (nonatomic, strong)UILabel * contractCateory;//合同类别
@property (nonatomic, strong)UILabel * contractNo;//合同编号
@property (nonatomic, strong)UILabel * dealDate;//成交日期
@property (nonatomic, strong)UILabel * dealPrice;//成交价格
@property (nonatomic, strong)UILabel * dealArea;//合同面积

@property (nonatomic, strong)UILabel * consultant;//置业顾问
@property (nonatomic, strong)UILabel * signManage;//客户经理
@property (nonatomic, strong)UILabel * manageIphone;//经理电话
@property (nonatomic, strong)UILabel * houseCode;//房源编号
@property (nonatomic, strong)UILabel * propertyCode;//房产证号
@property (nonatomic, strong)UILabel * clientCode;//客源编号

@property (nonatomic, strong)NSString *iphone;

@end


@implementation BasisInformationTableViewCell

-(void)setDic:(NSDictionary *)dic{
    //前面8个
    _address.attributedText = [NSString changeString:[NSString stringWithFormat:@"产证地址: %@",dic[@"house_address"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _contractType.attributedText = [NSString changeString:[NSString stringWithFormat:@"合同类型: %@",dic[@"contract_category"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _contractCateory.attributedText = [NSString changeString:[NSString stringWithFormat:@"合同类型: %@",dic[@"deal_type"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _contractNo.attributedText = [NSString changeString:[NSString stringWithFormat:@"合同编号: %@",dic[@"contract_code"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    
    _dealDate.attributedText = [NSString changeString:[NSString stringWithFormat:@"成交日期: %@",[NSString timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dic[@"complete_date"]]]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _dealPrice.attributedText = [NSString changeString:[NSString stringWithFormat:@"成交价格: %@ 万",dic[@"payment"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_RedColor];
    _dealArea.attributedText = [NSString changeString:[NSString stringWithFormat:@"成交面积: %@m²",dic[@"payarea"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    
    _consultant.attributedText = [NSString changeString:[NSString stringWithFormat:@"置业顾问: %@-%@",dic[@"deal_department"],dic[@"deal_username"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
//    min_agencyFee  deal_department deal_username transfer_username
    if (dic[@"transfer_username"] == nil || [dic[@"transfer_username"] isEqual:[NSNull null]]) {
        _signManage.attributedText = [NSString changeString:[NSString stringWithFormat:@"客户经理: %@",@"  "] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    }else{
        _signManage.attributedText = [NSString changeString:[NSString stringWithFormat:@"客户经理: %@",dic[@"transfer_username"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    }
    _manageIphone.attributedText = [NSString changeString:[NSString stringWithFormat:@"电  话: %@",dic[@"director_phone"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_GreenColor];
    
    _iphone = [NSString stringWithFormat:@"%@",dic[@"director_phone"]];
    _houseCode.attributedText = [NSString changeString:[NSString stringWithFormat:@"房源编号: %@",dic[@"house_code"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _propertyCode.attributedText = [NSString changeString:[NSString stringWithFormat:@"房产证号: %@",dic[@"licence"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _clientCode.attributedText = [NSString changeString:[NSString stringWithFormat:@"客源编号: %@",dic[@"client_code"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    _address = [UILabel new];
    _address.textAlignment = NSTextAlignmentLeft;
    _address.font = [UIFont systemFontOfSize:13.0f];
    
    //合同
    _contractType = [UILabel new];
    _contractType.textAlignment = NSTextAlignmentLeft;
    _contractType.font = [UIFont systemFontOfSize:13.0f];
    
    _contractCateory = [UILabel new];
    _contractCateory.textAlignment = NSTextAlignmentLeft;
    _contractCateory.font = [UIFont systemFontOfSize:13.0f];
    
    _contractNo = [UILabel new];
    _contractNo.textAlignment = NSTextAlignmentLeft;
    _contractNo.font = [UIFont systemFontOfSize:13.0f];
    
    //成交
    _dealDate = [UILabel new];
    _dealDate.textAlignment = NSTextAlignmentLeft;
    _dealDate.font = [UIFont systemFontOfSize:13.0f];
    
    _dealPrice = [UILabel new];
    _dealPrice.textAlignment = NSTextAlignmentLeft;
    _dealPrice.font = [UIFont systemFontOfSize:13.0f];
    
    _dealArea = [UILabel new];
    _dealArea.textAlignment = NSTextAlignmentLeft;
    _dealArea.font = [UIFont systemFontOfSize:13.0f];
    
    
    //下面的
    _consultant = [UILabel new];
    _consultant.textAlignment = NSTextAlignmentLeft;
    _consultant.font = [UIFont systemFontOfSize:13.0f];
    
    _signManage = [UILabel new];
    _signManage.textAlignment = NSTextAlignmentLeft;
    _signManage.font = [UIFont systemFontOfSize:13.0f];
    
    _manageIphone = [UILabel new];
    _manageIphone.userInteractionEnabled = YES;
    _manageIphone.textAlignment = NSTextAlignmentLeft;
    _manageIphone.font = [UIFont systemFontOfSize:13.0f];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(call:)];
    [_manageIphone addGestureRecognizer:tap];
    
    
    _houseCode = [UILabel new];
    _houseCode.textAlignment = NSTextAlignmentLeft;
    _houseCode.font = [UIFont systemFontOfSize:13.0f];
    
    _propertyCode = [UILabel new];
    _propertyCode.textAlignment = NSTextAlignmentLeft;
    _propertyCode.font = [UIFont systemFontOfSize:13.0f];
    
    _clientCode = [UILabel new];
    _clientCode.textAlignment = NSTextAlignmentLeft;
    _clientCode.font = [UIFont systemFontOfSize:13.0f];
    
    [self.contentView sd_addSubviews:@[_address,_contractType,_contractCateory,_contractNo,_dealDate,_dealPrice,_dealArea,_consultant,_signManage,_manageIphone,_houseCode,_propertyCode,_clientCode]];
    
    [self addLayoutSubviews];
}

- (void)addLayoutSubviews{
    CGFloat top = 15;
    CGFloat left = 15;
    CGFloat right = left;
    CGFloat spcing = 5;
    CGFloat h = 15;
    
    _address.sd_layout
    .topSpaceToView(self.contentView,top)
    .leftSpaceToView(self.contentView,left)
    .rightSpaceToView(self.contentView,right)
    .heightIs(h);
    
    _contractType.sd_layout
    .topSpaceToView(_address,spcing)
    .leftEqualToView(_address)
    .rightEqualToView(_address)
    .heightIs(h);
    
    _contractCateory.sd_layout
    .topSpaceToView(_contractType,spcing)
    .leftEqualToView(_address)
    .rightEqualToView(_address)
    .heightIs(h);
    
    _contractNo.sd_layout
    .topSpaceToView(_contractCateory,spcing)
    .leftEqualToView(_address)
    .rightEqualToView(_address)
    .heightIs(h);
    
    _dealDate.sd_layout
    .topSpaceToView(_contractNo,spcing)
    .leftEqualToView(_address)
    .rightEqualToView(_address)
    .heightIs(h);
    
    _dealPrice.sd_layout
    .topSpaceToView(_dealDate,spcing)
    .leftEqualToView(_address)
    .rightEqualToView(_address)
    .heightIs(h);
    
    _dealArea.sd_layout
    .topSpaceToView(_dealPrice,spcing)
    .leftEqualToView(_address)
    .rightEqualToView(_address)
    .heightIs(h);
    
    _consultant.sd_layout
    .topSpaceToView(_dealArea,20)
    .leftEqualToView(_address)
    .rightEqualToView(_address)
    .heightIs(h);
    
    _signManage.sd_layout
    .topSpaceToView(_consultant,spcing)
    .leftEqualToView(_address)
    .rightEqualToView(_address)
    .heightIs(h);
    
    _manageIphone.sd_layout
    .topSpaceToView(_signManage,spcing)
    .leftEqualToView(_address)
    .rightEqualToView(_address)
    .heightIs(h);
    
    _houseCode.sd_layout
    .topSpaceToView(_manageIphone,spcing)
    .leftEqualToView(_address)
    .rightEqualToView(_address)
    .heightIs(h);
    
    _propertyCode.sd_layout
    .topSpaceToView(_houseCode,spcing)
    .leftEqualToView(_address)
    .rightEqualToView(_address)
    .heightIs(h);
    
    _clientCode.sd_layout
    .topSpaceToView(_propertyCode,spcing)
    .leftEqualToView(_address)
    .rightEqualToView(_address)
    .heightIs(h);
}

- (void)call:(UITapGestureRecognizer *)tap{
    if (self.basisDelegate && [self.basisDelegate respondsToSelector:@selector(call:)]) {
        [self.basisDelegate call:_iphone];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
