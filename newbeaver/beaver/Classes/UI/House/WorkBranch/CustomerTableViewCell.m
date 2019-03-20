//
//  CustomerTableViewCell.m
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//  高度 200

#import "CustomerTableViewCell.h"

@interface CustomerTableViewCell ()

@property (nonatomic, strong)UILabel * sellName;//卖家电话
@property (nonatomic, strong)UILabel * sellPhone;//卖家电话
@property (nonatomic, strong)UILabel * sellNumber;//卖家身份证号
@property (nonatomic, strong)UILabel * sellAddress;//卖家地址

@property (nonatomic, strong)UILabel * buyName;//买家电话
@property (nonatomic, strong)UILabel * buyPhone;//买家电话
@property (nonatomic, strong)UILabel * buyNumber;//买家身份证号
@property (nonatomic, strong)UILabel * buyAddress;//买家地址

@end

@implementation CustomerTableViewCell

- (void)setDic:(NSDictionary *)dic{
    _sellName.attributedText = [NSString changeString:[NSString stringWithFormat:@"甲方（卖家）: %@",dic[@"owner_name"]] frontLength:8 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _sellPhone.attributedText = [NSString changeString:[NSString stringWithFormat:@"电话:%@",dic[@"owner_tel"]] frontLength:4 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _sellNumber.attributedText = [NSString changeString:[NSString stringWithFormat:@"身份证号: %@",dic[@"owner_id_card"]] frontLength:4 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _sellAddress.attributedText = [NSString changeString:[NSString stringWithFormat:@"地址: %@",dic[@"owner_address"]] frontLength:4 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    
    _buyName.attributedText = [NSString changeString:[NSString stringWithFormat:@"乙方（买家）: %@",dic[@"client_name"]] frontLength:8 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _buyPhone.attributedText = [NSString changeString:[NSString stringWithFormat:@"电话:%@",dic[@"client_tel"]] frontLength:4 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _buyNumber.attributedText = [NSString changeString:[NSString stringWithFormat:@"身份证号: %@",dic[@"client_id_card"]] frontLength:4 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _buyAddress.attributedText = [NSString changeString:[NSString stringWithFormat:@"地址: %@",dic[@"client_address"]] frontLength:4 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
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
    _sellName = [UILabel new];
    _sellName.textAlignment = NSTextAlignmentLeft;
    _sellName.text = @"甲方（卖家）: 林文龙";
    _sellName.textColor = UIColorFromRGB(0x404040);
    _sellName.font = [UIFont systemFontOfSize:13.0f];
    
    _sellPhone = [UILabel new];
    _sellPhone.textAlignment = NSTextAlignmentLeft;
    _sellPhone.text = @"电话: 13528840773";
    _sellPhone.textColor = UIColorFromRGB(0x404040);
    _sellPhone.font = [UIFont systemFontOfSize:13.0f];
    
    _sellNumber = [UILabel new];
    _sellNumber.textAlignment = NSTextAlignmentLeft;
    _sellNumber.text = @"身份证号: 362325199204204219";
    _sellNumber.textColor = UIColorFromRGB(0x404040);
    _sellNumber.font = [UIFont systemFontOfSize:13.0f];
    
    _sellAddress = [UILabel new];
    _sellAddress.textAlignment = NSTextAlignmentLeft;
    _sellAddress.text = @"地址: 红谷滩学府南大道新力珀7栋1单元1504";
    _sellAddress.textColor = UIColorFromRGB(0x404040);
    _sellAddress.font = [UIFont systemFontOfSize:13.0f];
    
    //买家
    _buyName = [UILabel new];
    _buyName.textAlignment = NSTextAlignmentLeft;
    _buyName.text = @"乙方（买家）: 林文龙";
    _buyName.textColor = UIColorFromRGB(0x404040);
    _buyName.font = [UIFont systemFontOfSize:13.0f];
    
    _buyPhone = [UILabel new];
    _buyPhone.textAlignment = NSTextAlignmentLeft;
    _buyPhone.text = @"电话: 13528840773";
    _buyPhone.textColor = UIColorFromRGB(0x404040);
    _buyPhone.font = [UIFont systemFontOfSize:13.0f];
    
    _buyNumber = [UILabel new];
    _buyNumber.textAlignment = NSTextAlignmentLeft;
    _buyNumber.text = @"身份证号: 362325199204204219";
    _buyNumber.textColor = UIColorFromRGB(0x404040);
    _buyNumber.font = [UIFont systemFontOfSize:13.0f];
    
    _buyAddress = [UILabel new];
    _buyAddress.textAlignment = NSTextAlignmentLeft;
    _buyAddress.text = @"地址: 红谷滩学府南大道新力珀7栋1单元1504";
    _buyAddress.textColor = UIColorFromRGB(0x404040);
    _buyAddress.font = [UIFont systemFontOfSize:13.0f];
    
    [self.contentView sd_addSubviews:@[_sellName,_sellPhone,_sellNumber,_sellAddress,_buyName,_buyPhone,_buyNumber,_buyAddress]];
    
    [self addLayoutSubviews];
  
}

- (void)addLayoutSubviews{
    CGFloat top = 15;
    CGFloat left = 15;
    CGFloat right = left;
    CGFloat spcing = 5;
    CGFloat h = 15;
    
    _sellName.sd_layout
    .topSpaceToView(self.contentView,top)
    .leftSpaceToView(self.contentView,left)
    .rightSpaceToView(self.contentView,right)
    .heightIs(h);
    
    _sellPhone.sd_layout
    .topSpaceToView(_sellName,spcing)
    .leftEqualToView(_sellName)
    .rightEqualToView(_sellName)
    .heightIs(h);
    
    _sellNumber.sd_layout
    .topSpaceToView(_sellPhone,spcing)
    .leftEqualToView(_sellName)
    .rightEqualToView(_sellName)
    .heightIs(h);
    
    _sellAddress.sd_layout
    .topSpaceToView(_sellNumber,spcing)
    .leftEqualToView(_sellName)
    .rightEqualToView(_sellName)
    .heightIs(h);
    
    _buyName.sd_layout
    .topSpaceToView(_sellAddress,20)
    .leftEqualToView(_sellName)
    .rightEqualToView(_sellName)
    .heightIs(h);
    
    _buyPhone.sd_layout
    .topSpaceToView(_buyName,spcing)
    .leftEqualToView(_sellName)
    .rightEqualToView(_sellName)
    .heightIs(h);
    
    _buyNumber.sd_layout
    .topSpaceToView(_buyPhone,spcing)
    .leftEqualToView(_sellName)
    .rightEqualToView(_sellName)
    .heightIs(h);
    
    _buyAddress.sd_layout
    .topSpaceToView(_buyNumber,spcing)
    .leftEqualToView(_sellName)
    .rightEqualToView(_sellName)
    .heightIs(h);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
