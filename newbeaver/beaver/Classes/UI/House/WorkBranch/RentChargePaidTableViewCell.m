//
//  RentChargePaidTableViewCell.m
//  beaver
//
//  Created by 林文龙 on 2018/11/8.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "RentChargePaidTableViewCell.h"

@interface RentChargePaidTableViewCell ()

@property (nonatomic, strong) UILabel * cost_type;                      //费用类型
@property (nonatomic, strong) UILabel * cost_status;                    //费用状态
@property (nonatomic, strong) UILabel * payment_content;                //付款方
@property (nonatomic, strong) UILabel * cost_price_content;             //费用(元)
@property (nonatomic, strong) UILabel * already_cost_content;           //已收费

@end

@implementation RentChargePaidTableViewCell

-(void)setDic:(NSDictionary *)dic{
    _cost_type.text = dic[@"price_name"];
    _cost_status.text = @"已收齐";
    if ([dic[@"fee_user"] isEqualToString:@"业主"]) {
        _payment_content.text = @"甲方(出租方)";
    }else   {
        _payment_content.text = @"乙方(承租方)";
    }
    _cost_price_content.text = [NSString stringWithFormat:@"%0.2f",[dic[@"price_num"] floatValue]];//费用
    _already_cost_content.text = [NSString stringWithFormat:@"%0.2f",[dic[@"price_num"] floatValue]];//费用
}



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    UIFont *bigFont = [UIFont boldSystemFontOfSize:17.0f];
    UIFont *smallFont = [UIFont systemFontOfSize:15.0f];
    
    UIColor *deepColor = UIColorFromRGB(0x000000);
    UIColor *lightColor = UIColorFromRGB(0x474747);
    
    _cost_type = [UILabel new];
    _cost_type.textAlignment = NSTextAlignmentLeft;
    _cost_type.textColor = deepColor;
    _cost_type.font = bigFont;
    _cost_type.text = @"佣金";
    
    _cost_status = [UILabel new];
    
    _cost_status = [UILabel new];
    _cost_status.textAlignment = NSTextAlignmentRight;
    _cost_status.textColor = UIColorFromRGB(0xE60012);
    _cost_status.font = smallFont;
    _cost_status.text = @"已收齐";
    
    UIView *line = [UIView new];
    line.backgroundColor  = UIColorFromRGB(0xF6F6F6);
    
    UILabel *payment = [UILabel new];
    payment.textAlignment = NSTextAlignmentLeft;
    payment.textColor = deepColor;
    payment.font = smallFont;
    payment.text = @"付款方:";
    
    _payment_content = [UILabel new];
    _payment_content.textAlignment = NSTextAlignmentRight;
    _payment_content.textColor = lightColor;
    _payment_content.font = smallFont;
    _payment_content.text = @"甲方(出租方)";
    
    UILabel *cost_price = [UILabel new];
    cost_price.textAlignment = NSTextAlignmentLeft;
    cost_price.textColor = deepColor;
    cost_price.font = smallFont;
    cost_price.text = @"费用(元):";
    
    _cost_price_content = [UILabel new];
    _cost_price_content.textAlignment = NSTextAlignmentRight;
    _cost_price_content.textColor = lightColor;
    _cost_price_content.font = smallFont;
    _cost_price_content.text = @"1000.00";
    
    UILabel *already_cost = [UILabel new];
    already_cost.textAlignment = NSTextAlignmentLeft;
    already_cost.textColor = deepColor;
    already_cost.font = smallFont;
    already_cost.text = @"已收费(元):";
    
    _already_cost_content = [UILabel new];
    _already_cost_content.textAlignment = NSTextAlignmentRight;
    _already_cost_content.textColor = lightColor;
    _already_cost_content.font = smallFont;
    _already_cost_content.text = @"0.00";
    
    
    [self.contentView sd_addSubviews:@[_cost_type,_cost_status,line,payment,_payment_content,cost_price,_cost_price_content,already_cost,_already_cost_content]];
    
    CGFloat x = 20;
    CGFloat y = 15;
    CGFloat spcing = 19;
    
    CGFloat title_w = 100;
    CGFloat content_w = (kScreenW - 2 * x - title_w);
    CGFloat h  = 15;
    
    _cost_type.sd_layout
    .topSpaceToView(self.contentView, y)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(17);
    
    _cost_status.sd_layout
    .topSpaceToView(self.contentView, y)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
    line.sd_layout
    .topSpaceToView(_cost_type, y)
    .leftSpaceToView(self.contentView, 13)
    .rightSpaceToView(self.contentView, 13)
    .heightIs(1);
    
    payment.sd_layout
    .topSpaceToView(line, y)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _payment_content.sd_layout
    .topEqualToView(payment)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
    cost_price.sd_layout
    .topSpaceToView(payment, spcing)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _cost_price_content.sd_layout
    .topEqualToView(cost_price)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
    
    already_cost.sd_layout
    .topSpaceToView(cost_price, spcing)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _already_cost_content.sd_layout
    .topEqualToView(already_cost)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
