//
//  ContactRentTableViewCell.m
//  beaver
//
//  Created by 林文龙 on 2018/11/8.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "ContactRentTableViewCell.h"

@interface ContactRentTableViewCell ()

@property (nonatomic, strong)UILabel *address;

@property (nonatomic, strong)UILabel *contractNo;
@property (nonatomic, strong)UILabel * contractNoContent;

@property (nonatomic, strong)UILabel *contractDate;
@property (nonatomic, strong)UILabel *contractDateContent;

@property (nonatomic, strong)UILabel *contractType;
@property (nonatomic, strong)UILabel *contractTypeContent;

@property (nonatomic, strong)UILabel *contractRentDate;
@property (nonatomic, strong)UILabel *contractRentDateContent;

@property (nonatomic, strong)UILabel *sellType;
@property (nonatomic, strong)UILabel *buyType;
@property (nonatomic, strong)UILabel *sellNames;
@property (nonatomic, strong)UILabel *buyNames;

@property (nonatomic, strong)UIView *line1;
@property (nonatomic, strong)UIView *line2;

@end

@implementation ContactRentTableViewCell

- (void)setDic:(NSDictionary *)dic{
    _address.text = dic[@"house_address"];
    _contractNoContent.text = dic[@"contract_code"];
    
    NSString *timeStr = [NSString timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dic[@"complete_date"]]];
    _contractDateContent.text = timeStr;
    _contractTypeContent.text = dic[@"type"];
    
    _contractRentDateContent.text = [NSString stringWithFormat:@"%@至%@",[NSString timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dic[@"rent_start"]]],[NSString timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dic[@"rent_end"]]]];
    _sellNames.text = dic[@"owner_name"];
    _buyNames.text = dic[@"client_name"];
    
}

- (void)setFrame:(CGRect)frame
{
    frame.size.width = kScreenW;
    [super setFrame:frame];
    
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
    _address.text = @"红谷滩新区绿地悦城77栋1单元501";
    _address.textAlignment = NSTextAlignmentLeft;
    _address.font = [UIFont boldSystemFontOfSize:15.0f];
    _address.textColor = RGB(0, 0, 0);
    
    _line1 = [UIView new];
    _line1.backgroundColor = UIColorFromRGB(0xF6F6F6);
    //    [self drawDashLine:_line1 lineLength:4 lineSpacing:1.0 lineColor:LWL_LineColor];
    
    _contractNo = [UILabel new];
    _contractNo.textAlignment = NSTextAlignmentLeft;
    _contractNo.font = [UIFont systemFontOfSize:15.0f];
    _contractNo.textColor = RGB(0, 0, 0);
    _contractNo.text = @"合同编号:";
    
    _contractNoContent = [UILabel new];
    _contractNoContent.textAlignment = NSTextAlignmentRight;
    _contractNoContent.font = [UIFont systemFontOfSize:15.0f];
    _contractNoContent.textColor = RGB(71, 71, 71);
    _contractNoContent.text = @"CTR1745154123355122";
    
    
    _contractDate = [UILabel new];
    _contractDate.textAlignment = NSTextAlignmentLeft;
    _contractDate.font = [UIFont systemFontOfSize:15.0f];
    _contractDate.textColor = RGB(0, 0, 0);
    _contractDate.text = @"签约日期:";
    
    _contractDateContent = [UILabel new];
    _contractDateContent.textAlignment = NSTextAlignmentRight;
    _contractDateContent.font = [UIFont systemFontOfSize:15.0f];
    _contractDateContent.textColor = RGB(71, 71, 71);
    _contractDateContent.text = @"2018-08-01";
    
    
    _contractType = [UILabel new];
    _contractType.textAlignment = NSTextAlignmentLeft;
    _contractType.font = [UIFont systemFontOfSize:15.0f];
    _contractType.textColor = RGB(0, 0, 0);
    _contractType.text = @"成交类型:";
    
    _contractTypeContent = [UILabel new];
    _contractTypeContent.textAlignment = NSTextAlignmentRight;
    _contractTypeContent.font = [UIFont systemFontOfSize:15.0f];
    _contractTypeContent.textColor = RGB(255, 147, 62);
    _contractTypeContent.text = @"租赁";
    
    _contractRentDate = [UILabel new];
    _contractRentDate.textAlignment = NSTextAlignmentLeft;
    _contractRentDate.font = [UIFont systemFontOfSize:15.0f];
    _contractRentDate.textColor = RGB(0, 0, 0);
    _contractRentDate.text = @"租期:";
    
    _contractRentDateContent = [UILabel new];
    _contractRentDateContent.textAlignment = NSTextAlignmentRight;
    _contractRentDateContent.font = [UIFont systemFontOfSize:15.0f];
    _contractRentDateContent.textColor = RGB(71, 71, 71);
    _contractRentDateContent.text = @"2018-08-01至2018-12-01";
    
    _line2 = [UIView new];;
    _line2.backgroundColor = UIColorFromRGB(0xF6F6F6);
    //    [self drawDashLine:_line2 lineLength:4 lineSpacing:0.8 lineColor:LWL_LineColor];
    
    _sellType = [UILabel new];
    _sellType.textAlignment = NSTextAlignmentLeft;
    _sellType.font = [UIFont systemFontOfSize:15.0f];
    _sellType.textColor = RGB(0, 0, 0);
    _sellType.text = @"甲方(出租方):";
    
    _buyType = [UILabel new];
    _buyType.text = @"乙方(承租方):";
    _buyType.textAlignment = NSTextAlignmentLeft;
    _buyType.font = [UIFont systemFontOfSize:15.0f];
    _buyType.textColor = RGB(0, 0, 0);
    
    _sellNames = [UILabel new];
    _sellNames.textAlignment = NSTextAlignmentRight;
    _sellNames.font = [UIFont systemFontOfSize:15.0f];
    _sellNames.textColor = RGB(71, 71, 71);
    _sellNames.text = @"林一";
    
    _buyNames = [UILabel new];
    _buyNames.textAlignment = NSTextAlignmentRight;
    _buyNames.font = [UIFont systemFontOfSize:15.0f];
    _buyNames.textColor = RGB(71, 71, 71);
    _buyNames.text = @"王一";
    
    
    [self.contentView sd_addSubviews:@[_address,_line1,_contractNo,_contractNoContent,_contractDate,_contractDateContent,_contractType,_contractTypeContent,_contractRentDate,_contractRentDateContent,_line2,_sellType,_sellNames,_buyType,_buyNames]];
    
    [self addLayoutSubviews];
}

- (void)addLayoutSubviews{
    
    CGFloat h = 15;
    CGFloat w = 70;
    
    _address.sd_layout
    .topSpaceToView(self.contentView,16)
    .leftSpaceToView(self.contentView,20)
    .rightSpaceToView(self.contentView,20)
    .heightIs(h);
    
    _line1.sd_layout
    .topSpaceToView(_address, 15)
    .leftSpaceToView(self.contentView, 15)
    .rightSpaceToView(self.contentView, 15)
    .heightIs(1);
    
    _contractNo.sd_layout
    .topSpaceToView(_line1,14)
    .leftSpaceToView(self.contentView,20)
    .widthIs(w)
    .heightIs(h);
    
    _contractNoContent.sd_layout
    .topSpaceToView(_line1,14)
    .rightSpaceToView(self.contentView,20)
    .widthIs(kScreenW - 20 * 2 - w )
    .heightIs(h);;
    
    _contractDate.sd_layout
    .topSpaceToView(_contractNo,20)
    .leftSpaceToView(self.contentView,20)
    .widthIs(w)
    .heightIs(h);
    
    _contractDateContent.sd_layout
    .topSpaceToView(_contractNo,20)
    .rightSpaceToView(self.contentView,20)
    .widthIs(kScreenW - 20 * 2 - w )
    .heightIs(h);
    
    _contractType.sd_layout
    .topSpaceToView(_contractDate,20)
    .leftSpaceToView(self.contentView,20)
    .widthIs(w)
    .heightIs(h);
    
    _contractTypeContent.sd_layout
    .topSpaceToView(_contractDate,20)
    .rightSpaceToView(self.contentView,20)
    .widthIs(kScreenW - 20 * 2 - w )
    .heightIs(h);
    
    _contractRentDate.sd_layout
    .topSpaceToView(_contractType,20)
    .leftSpaceToView(self.contentView,20)
    .widthIs(w)
    .heightIs(h);
    
    _contractRentDateContent.sd_layout
    .topSpaceToView(_contractType,20)
    .rightSpaceToView(self.contentView,20)
    .widthIs(kScreenW - 20 * 2 - w )
    .heightIs(h);
    
    _line2.sd_layout
    .topSpaceToView(_contractRentDate,14)
    .leftSpaceToView(self.contentView,15)
    .rightSpaceToView(self.contentView,15)
    .heightIs(1);
    
    
    _sellType.sd_layout
    .topSpaceToView(_line2,14)
    .leftSpaceToView(self.contentView,20)
    .widthIs(self.contentView.width/2.0f)
    .heightIs(h);
    
    _buyType.sd_layout
    .topSpaceToView(_sellType,19)
    .leftSpaceToView(self.contentView,20)
    .widthIs(self.contentView.width/2.0f)
    .heightIs(h);
    
    _sellNames.sd_layout
    .topSpaceToView(_line2,14)
    .rightSpaceToView(self.contentView,20)
    .widthIs(self.contentView.width/2.0f)
    .heightIs(h);
    
    _buyNames.sd_layout
    .topSpaceToView(_sellNames,19)
    .rightSpaceToView(self.contentView,20)
    .widthIs(self.contentView.width/2.0f)
    .heightIs(h);

}


@end
