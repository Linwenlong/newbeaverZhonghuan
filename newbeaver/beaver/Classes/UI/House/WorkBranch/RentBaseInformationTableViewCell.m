//
//  RentBaseInformationTableViewCell.m
//  beaver
//
//  Created by 林文龙 on 2018/11/8.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "RentBaseInformationTableViewCell.h"



@interface RentBaseInformationTableViewCell ()

@property (nonatomic, strong) UILabel * baseInfo;//基本信息

@property (nonatomic, strong) UILabel * house_address_content;      //房源地址
@property (nonatomic, strong) UILabel * produce_address_content;    //房证地址
@property (nonatomic, strong) UILabel * contract_content;           //合同编号
@property (nonatomic, strong) UILabel * rent_price_content;         //租金(元/月)
@property (nonatomic, strong) UILabel * contract_category_content;  //合同类别
@property (nonatomic, strong) UILabel * contract_type_content;      //合同类型
@property (nonatomic, strong) UILabel * deal_date_content;          //成交日期
@property (nonatomic, strong) UILabel * rent_date_content;          //租赁周期
@property (nonatomic, strong) UILabel * property_consultant_content;//置业顾问
@property (nonatomic, strong) UILabel * sign_manager_content;       //签约经理
@property (nonatomic, strong) UILabel * house_number_content;       //房源编号
@property (nonatomic, strong) UILabel * client_number_content;      //客源编号
@property (nonatomic, strong) UILabel * produce_number_content;     //房产证号

@end

@implementation RentBaseInformationTableViewCell



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}

-(void)setDic:(NSDictionary *)dic{
    
    _house_address_content.text = [NSString stringWithFormat:@"%@-%@-%@ %@ %@ %@",dic[@"district"],dic[@"region"],dic[@"community"],dic[@"block"],dic[@"unit_name"],dic[@"room_code"]];
    _produce_address_content.text = dic[@"house_address"];
    _contract_content.text = dic[@"contract_code"];
    _rent_price_content.text = [NSString stringWithFormat:@"%@%@",dic[@"rent_price"],dic[@"rent_unit"]];
    _contract_category_content.text = dic[@"contract_category"];
    _contract_type_content.text = dic[@"type"];
    _deal_date_content.text = [NSString stringWithFormat:@"%@",[NSString timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dic[@"complete_date"]]]];
    _rent_date_content.text = [NSString stringWithFormat:@"%@至%@",[NSString timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dic[@"rent_start"]]],[NSString timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dic[@"rent_end"]]]];
    _property_consultant_content.text = [NSString stringWithFormat:@"%@-%@",dic[@"deal_department"],dic[@"deal_username"]];
    _sign_manager_content.text = [NSString stringWithFormat:@"%@-%@",dic[@"director_department"],dic[@"director"]];
    _house_number_content.text = dic[@"house_code"];
    _client_number_content.text = dic[@"client_code"];
    _produce_number_content.text = dic[@"licence"];
}


- (void)setUI{
    
    UIFont *bigFont = [UIFont boldSystemFontOfSize:17.0f];
    UIFont *smallFont = [UIFont systemFontOfSize:15.0f];
    
    UIColor *deepColor = UIColorFromRGB(0x000000);
    UIColor *lightColor = UIColorFromRGB(0x474747);
    
    _baseInfo = [UILabel new];
    _baseInfo.textAlignment = NSTextAlignmentLeft;
    _baseInfo.textColor = deepColor;
    _baseInfo.font = bigFont;
    _baseInfo.text = @"基本信息";
    
    UIView *line1 = [UIView new];
    line1.backgroundColor = UIColorFromRGB(0xF6F6F6);
    
    
    UILabel *house_address = [UILabel new];
    house_address.textAlignment = NSTextAlignmentLeft;
    house_address.textColor = deepColor;
    house_address.font = smallFont;
    house_address.text = @"房源地址:";
    
    _house_address_content = [UILabel new];
    _house_address_content.textAlignment = NSTextAlignmentRight;
    _house_address_content.textColor = lightColor;
    _house_address_content.font = smallFont;
//    _house_address_content.text = @"东湖-民德路-南方大厦";
    

    UILabel *produce_address = [UILabel new];
    produce_address.textAlignment = NSTextAlignmentLeft;
    produce_address.textColor = deepColor;
    produce_address.font = smallFont;
    produce_address.text = @"房证地址:";
    
    _produce_address_content = [UILabel new];
    _produce_address_content.textAlignment = NSTextAlignmentRight;
    _produce_address_content.textColor = lightColor;
    _produce_address_content.font = smallFont;
//    _produce_address_content.text = @"西湖区解放西路塔子桥南14号10栋";
    
    
    UILabel *contract = [UILabel new];
    contract.textAlignment = NSTextAlignmentLeft;
    contract.textColor = deepColor;
    contract.font = smallFont;
    contract.text = @"合同编号:";
    
    _contract_content = [UILabel new];
    _contract_content.textAlignment = NSTextAlignmentRight;
    _contract_content.textColor = lightColor;
    _contract_content.font = smallFont;
//    _contract_content.text = @"NCZ18288701";
    
    
    UILabel *rent_price = [UILabel new];
    rent_price.textAlignment = NSTextAlignmentLeft;
    rent_price.textColor = deepColor;
    rent_price.font = smallFont;
    rent_price.text = @"租   金:";
    
    _rent_price_content = [UILabel new];
    _rent_price_content.textAlignment = NSTextAlignmentRight;
    _rent_price_content.textColor = lightColor;
    _rent_price_content.font = smallFont;
//    _rent_price_content.text = @"10000";
    
    
    UILabel *contract_category = [UILabel new];
    contract_category.textAlignment = NSTextAlignmentLeft;
    contract_category.textColor = deepColor;
    contract_category.font = smallFont;
    contract_category.text = @"合同类别:";
    
    _contract_category_content = [UILabel new];
    _contract_category_content.textAlignment = NSTextAlignmentRight;
    _contract_category_content.textColor = UIColorFromRGB(0xFF933E);
    _contract_category_content.font = smallFont;
//    _contract_category_content.text = @"租赁";
    
    UILabel *contract_type = [UILabel new];
    contract_type.textAlignment = NSTextAlignmentLeft;
    contract_type.textColor = deepColor;
    contract_type.font = smallFont;
    contract_type.text = @"合同类型:";
    
    _contract_type_content = [UILabel new];
    _contract_type_content.textAlignment = NSTextAlignmentRight;
    _contract_type_content.textColor = UIColorFromRGB(0xFF933E);
    _contract_type_content.font = smallFont;
//    _contract_type_content.text = @"租赁";
    
    UILabel *deal_date = [UILabel new];
    deal_date.textAlignment = NSTextAlignmentLeft;
    deal_date.textColor = deepColor;
    deal_date.font = smallFont;
    deal_date.text = @"成交日期:";
    
    _deal_date_content = [UILabel new];
    _deal_date_content.textAlignment = NSTextAlignmentRight;
    _deal_date_content.textColor = lightColor;
    _deal_date_content.font = smallFont;
//    _deal_date_content.text = @"2018-11-01";
    
    
    UILabel *rent_date = [UILabel new];
    rent_date.textAlignment = NSTextAlignmentLeft;
    rent_date.textColor = deepColor;
    rent_date.font = smallFont;
    rent_date.text = @"租赁周期:";
    
    _rent_date_content = [UILabel new];
    _rent_date_content.textAlignment = NSTextAlignmentRight;
    _rent_date_content.textColor = lightColor;
    _rent_date_content.font = smallFont;
//    _rent_date_content.text = @"2018-11-01至2018-12-01";
    
    UIView *line2 = [UIView new];
    line2.backgroundColor = UIColorFromRGB(0xF6F6F6);
    
    UILabel *property_consultant = [UILabel new];
    property_consultant.textAlignment = NSTextAlignmentLeft;
    property_consultant.textColor = deepColor;
    property_consultant.font = smallFont;
    property_consultant.text = @"置业顾问:";
    
    _property_consultant_content = [UILabel new];
    _property_consultant_content.textAlignment = NSTextAlignmentRight;
    _property_consultant_content.textColor = lightColor;
    _property_consultant_content.font = smallFont;
//    _property_consultant_content.text = @"状元桥-李大元";
    
    UILabel *sign_manager = [UILabel new];
    sign_manager.textAlignment = NSTextAlignmentLeft;
    sign_manager.textColor = deepColor;
    sign_manager.font = smallFont;
    sign_manager.text = @"签约经理:";
    
    _sign_manager_content = [UILabel new];
    _sign_manager_content.textAlignment = NSTextAlignmentRight;
    _sign_manager_content.textColor = lightColor;
    _sign_manager_content.font = smallFont;
//    _sign_manager_content.text = @"合规部-李木 13988888888";
    
    UILabel *house_number = [UILabel new];
    house_number.textAlignment = NSTextAlignmentLeft;
    house_number.textColor = deepColor;
    house_number.font = smallFont;
    house_number.text = @"房源编号:";
    
    _house_number_content = [UILabel new];
    _house_number_content.textAlignment = NSTextAlignmentRight;
    _house_number_content.textColor = lightColor;
    _house_number_content.font = smallFont;
//    _house_number_content.text = @"ZHFY-F16-47722833";
    
    UILabel *client_number = [UILabel new];
    client_number.textAlignment = NSTextAlignmentLeft;
    client_number.textColor = deepColor;
    client_number.font = smallFont;
    client_number.text = @"客源编号:";
    
    _client_number_content = [UILabel new];
    _client_number_content.textAlignment = NSTextAlignmentRight;
    _client_number_content.textColor = lightColor;
    _client_number_content.font = smallFont;
//    _client_number_content.text = @"ZHFY004033";
    
    UILabel *produce_number = [UILabel new];
    produce_number.textAlignment = NSTextAlignmentLeft;
    produce_number.textColor = deepColor;
    produce_number.font = smallFont;
    produce_number.text = @"房产证号:";
    
    _produce_number_content = [UILabel new];
    _produce_number_content.textAlignment = NSTextAlignmentRight;
    _produce_number_content.textColor = lightColor;
    _produce_number_content.font = smallFont;
//    _produce_number_content.text = @"ZHFY004033";


    [self.contentView sd_addSubviews:@[_baseInfo,line1,house_address,_house_address_content,produce_address,_produce_address_content,contract,_contract_content,rent_price,_rent_price_content,contract_category,_contract_category_content,contract_type,_contract_type_content,deal_date,_deal_date_content,rent_date,_rent_date_content,line2,property_consultant,_property_consultant_content,sign_manager,_sign_manager_content,house_number,_house_number_content,client_number,_client_number_content,produce_number,_produce_number_content]];
    
    
    CGFloat x = 20;
    CGFloat y = 15;
    CGFloat spcing = 19;
    
    CGFloat title_w = 70;
    CGFloat content_w = (kScreenW - 2 * x - title_w);
    CGFloat h  = 15;
    
    _baseInfo.sd_layout
    .topSpaceToView(self.contentView, y)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(17);
    
    line1.sd_layout
    .topSpaceToView(_baseInfo, y)
    .leftSpaceToView(self.contentView, 13)
    .rightSpaceToView(self.contentView, 13)
    .heightIs(1);
    
    house_address.sd_layout
    .topSpaceToView(line1, y)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _house_address_content.sd_layout
    .topEqualToView(house_address)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
    produce_address.sd_layout
    .topSpaceToView(house_address, spcing)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _produce_address_content.sd_layout
    .topEqualToView(produce_address)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
    contract.sd_layout
    .topSpaceToView(produce_address, spcing)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _contract_content.sd_layout
    .topEqualToView(contract)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
    rent_price.sd_layout
    .topSpaceToView(contract, spcing)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w+20)
    .heightIs(h);
    
    _rent_price_content.sd_layout
    .topEqualToView(rent_price)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
    contract_category.sd_layout
    .topSpaceToView(rent_price, spcing)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _contract_category_content.sd_layout
    .topEqualToView(contract_category)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
    contract_type.sd_layout
    .topSpaceToView(contract_category, spcing)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _contract_type_content.sd_layout
    .topEqualToView(contract_type)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
    deal_date.sd_layout
    .topSpaceToView(contract_type, spcing)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _deal_date_content.sd_layout
    .topEqualToView(deal_date)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
    rent_date.sd_layout
    .topSpaceToView(deal_date, spcing)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _rent_date_content.sd_layout
    .topEqualToView(rent_date)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
    line2.sd_layout
    .topSpaceToView(rent_date, y)
    .leftSpaceToView(self.contentView, 13)
    .rightSpaceToView(self.contentView, 13)
    .heightIs(1);
    
    
    property_consultant.sd_layout
    .topSpaceToView(line2, y)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _property_consultant_content.sd_layout
    .topEqualToView(property_consultant)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
    sign_manager.sd_layout
    .topSpaceToView(property_consultant, spcing)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _sign_manager_content.sd_layout
    .topEqualToView(sign_manager)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
    house_number.sd_layout
    .topSpaceToView(sign_manager, spcing)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _house_number_content.sd_layout
    .topEqualToView(house_number)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
    client_number.sd_layout
    .topSpaceToView(house_number, spcing)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _client_number_content.sd_layout
    .topEqualToView(client_number)
    .rightSpaceToView(self.contentView, x)
    .widthIs(content_w)
    .heightIs(h);
    
    produce_number.sd_layout
    .topSpaceToView(client_number, spcing)
    .leftSpaceToView(self.contentView, x)
    .widthIs(title_w)
    .heightIs(h);
    
    _produce_number_content.sd_layout
    .topEqualToView(produce_number)
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
