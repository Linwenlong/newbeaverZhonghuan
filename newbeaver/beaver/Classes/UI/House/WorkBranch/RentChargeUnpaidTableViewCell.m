//
//  RentChargeUnpaidTableViewCell.m
//  beaver
//
//  Created by 林文龙 on 2018/11/8.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "RentChargeUnpaidTableViewCell.h"

@interface RentChargeUnpaidTableViewCell ()


@property (nonatomic, strong) UILabel * cost_type;                      //费用类型

@property (nonatomic, strong) UILabel * payment_content;                //付款方
@property (nonatomic, strong) UILabel * cost_price_content;             //费用(元)
@property (nonatomic, strong) UILabel * already_cost_content;           //已收费
@property (nonatomic, strong) UILabel * arrearage_content;              //欠费

@end

@implementation RentChargeUnpaidTableViewCell

-(void)setDic:(NSDictionary *)dic{
    _cost_type.text = dic[@"price_name"];
    if ([dic[@"fee_user"] isEqualToString:@"业主"]) {
         _payment_content.text = @"甲方(出租方)";
    }else   {
         _payment_content.text = @"乙方(承租方)";
    }
    _cost_price_content.text = [NSString stringWithFormat:@"%0.2f",[dic[@"price_num"] floatValue]];//费用
    _already_cost_content.text = @"0.00";
    _arrearage_content.text = [NSString stringWithFormat:@"%0.2f",[dic[@"price_num"] floatValue]];//欠费
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)costBtnClick:(UIButton *)btn{
    self.btnClick(btn.tag);
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
    
    _cost_btn = [UIButton new];
    
    [_cost_btn setTitle:@"收款" forState:UIControlStateNormal];
    [_cost_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _cost_btn.backgroundColor = UIColorFromRGB(0xE60012);
    _cost_btn.titleLabel.font = smallFont;
    _cost_btn.clipsToBounds = YES;
    _cost_btn.layer.cornerRadius = 3.0f;
//    _cost_btn.tag = self.tag;
    [_cost_btn addTarget:self action:@selector(costBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
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
    
    
    UILabel *arrearage = [UILabel new];
    arrearage.textAlignment = NSTextAlignmentLeft;
    arrearage.textColor = deepColor;
    arrearage.font = smallFont;
    arrearage.text = @"欠费(元):";
    
    _arrearage_content = [UILabel new];
    _arrearage_content.textAlignment = NSTextAlignmentRight;
    _arrearage_content.textColor = UIColorFromRGB(0xE60012);
    _arrearage_content.font = smallFont;
    _arrearage_content.text = @"1000.00";
    
    [self.contentView sd_addSubviews:@[_cost_type,_cost_btn,line,payment,_payment_content,cost_price,_cost_price_content,already_cost,_already_cost_content,arrearage,_arrearage_content]];
    
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
    
    _cost_btn.sd_layout
    .topSpaceToView(self.contentView, 7)
    .rightSpaceToView(self.contentView, x)
    .widthIs(h*4)
    .heightIs(h*2);
    
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
    
    
    arrearage.sd_layout
    .topSpaceToView(already_cost, spcing)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _arrearage_content.sd_layout
    .topEqualToView(arrearage)
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
