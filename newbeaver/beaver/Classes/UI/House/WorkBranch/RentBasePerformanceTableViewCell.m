//
//  RentBasePerformanceTableViewCell.m
//  beaver
//
//  Created by 林文龙 on 2018/11/8.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "RentBasePerformanceTableViewCell.h"

@interface RentBasePerformanceTableViewCell ()


@property (nonatomic, strong) UILabel * divide_people_content;          //分成人
@property (nonatomic, strong) UILabel * divide_reason_content;          //分成缘由
@property (nonatomic, strong) UILabel * receivable_content;             //应收业绩
@property (nonatomic, strong) UILabel * official_content;               //实收业绩
@property (nonatomic, strong) UILabel * divide_scale_content;           //分成比例


@end

@implementation RentBasePerformanceTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setDic:(NSDictionary *)dic pay_money:(NSString *)payMoney expect_money:(NSString *)expect_money{
    _divide_people_content.text = [NSString stringWithFormat:@"%@-%@",dic[@"department"],dic[@"username"]];
    _divide_reason_content.text = dic[@"commission_type"];
    _receivable_content.text = [NSString stringWithFormat:@"%0.2f",[expect_money integerValue] * [dic[@"proportion"] integerValue] / 100.0];
    _official_content.text = [NSString stringWithFormat:@"%0.2f",[payMoney integerValue] * [dic[@"proportion"] integerValue] / 100.0];
    _divide_scale_content.text = [NSString stringWithFormat:@"%@%@",dic[@"proportion"],@"%"];
}

- (void)setUI{
    
    UIFont *smallFont = [UIFont systemFontOfSize:15.0f];
    
    UIColor *deepColor = UIColorFromRGB(0x000000);
    UIColor *lightColor = UIColorFromRGB(0x474747);
    
    UILabel *divide_people = [UILabel new];
    divide_people.textAlignment = NSTextAlignmentLeft;
    divide_people.textColor = deepColor;
    divide_people.font = smallFont;
    divide_people.text = @"分成人:";
    
    _divide_people_content = [UILabel new];
    _divide_people_content.textAlignment = NSTextAlignmentRight;
    _divide_people_content.textColor = lightColor;
    _divide_people_content.font = smallFont;
//    _divide_people_content.text = @"状元桥-李大元";
    
    
    UILabel *divide_reason = [UILabel new];
    divide_reason.textAlignment = NSTextAlignmentLeft;
    divide_reason.textColor = deepColor;
    divide_reason.font = smallFont;
    divide_reason.text = @"分成缘由:";
    
    _divide_reason_content = [UILabel new];
    _divide_reason_content.textAlignment = NSTextAlignmentRight;
    _divide_reason_content.textColor = lightColor;
    _divide_reason_content.font = smallFont;
//    _divide_reason_content.text = @"合同成交人";
    
    UILabel *receivable = [UILabel new];
    receivable.textAlignment = NSTextAlignmentLeft;
    receivable.textColor = deepColor;
    receivable.font = smallFont;
    receivable.text = @"应收业绩(元):";
    
    _receivable_content = [UILabel new];
    _receivable_content.textAlignment = NSTextAlignmentRight;
//    _receivable_content.textColor = lightColor;
    _receivable_content.textColor = UIColorFromRGB(0xE60012);
    _receivable_content.font = smallFont;
//    _receivable_content.text = @"7200.00";
    
    UILabel *official = [UILabel new];
    official.textAlignment = NSTextAlignmentLeft;
    official.textColor = deepColor;
    official.font = smallFont;
    official.text = @"实收业绩(元):";
    
    _official_content = [UILabel new];
    _official_content.textAlignment = NSTextAlignmentRight;
    _official_content.textColor = UIColorFromRGB(0xE60012);
    _official_content.font = smallFont;
//    _official_content.text = @"800.00";
    
    UILabel *divide_scale = [UILabel new];
    divide_scale.textAlignment = NSTextAlignmentLeft;
    divide_scale.textColor = deepColor;
    divide_scale.font = smallFont;
    divide_scale.text = @"分成比例:";
    
    _divide_scale_content = [UILabel new];
    _divide_scale_content.textAlignment = NSTextAlignmentRight;
    _divide_scale_content.textColor = lightColor;
    _divide_scale_content.font = smallFont;
//    _divide_scale_content.text = @"80%";
    
    [self.contentView sd_addSubviews:@[divide_people,_divide_people_content,divide_reason,_divide_reason_content,receivable,_receivable_content,official,_official_content,divide_scale,_divide_scale_content]];
    
    CGFloat x = 20;
    CGFloat y = 15;
    CGFloat spcing = 19;
    
    CGFloat title_w = 100;
    CGFloat content_w = (kScreenW - 2 * x - title_w);
    CGFloat h  = 15;
    
    divide_people.sd_layout
    .topSpaceToView(self.contentView, y)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _divide_people_content.sd_layout
    .topEqualToView(divide_people)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
    divide_reason.sd_layout
    .topSpaceToView(divide_people, spcing)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _divide_reason_content.sd_layout
    .topEqualToView(divide_reason)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);

    receivable.sd_layout
    .topSpaceToView(divide_reason, spcing)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _receivable_content.sd_layout
    .topEqualToView(receivable)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
    official.sd_layout
    .topSpaceToView(receivable, spcing)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _official_content.sd_layout
    .topEqualToView(official)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
    divide_scale.sd_layout
    .topSpaceToView(official, spcing)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _divide_scale_content.sd_layout
    .topEqualToView(divide_scale)
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
