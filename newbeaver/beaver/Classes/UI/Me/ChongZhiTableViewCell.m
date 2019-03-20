//
//  ChongZhiTableViewCell.m
//  beaver
//
//  Created by 林文龙 on 2018/8/1.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "ChongZhiTableViewCell.h"

@interface ChongZhiTableViewCell ()

@property (nonatomic, strong) UILabel * timeDua;
@property (nonatomic, strong) UILabel * price;
@property (nonatomic, strong) UILabel * homeContact;
@property (nonatomic, strong) UILabel * name;
@property (nonatomic, strong) UILabel * timeDate;

@end

@implementation ChongZhiTableViewCell

- (void)setDic:(NSDictionary *)dic{
    _timeDua.text = [NSString stringWithFormat:@"充值账号: %@",dic[@"tel"]];
    
    _price.text = [NSString stringWithFormat:@"充值金额: %@元",dic[@"money"]];
    
    NSString *str = [dic[@"type"] integerValue] == 1 ? @"账户充值" : ([dic[@"type"] integerValue] == 2 ? @"月租充值"  :  @"短信充值");
    
    _homeContact.text = [NSString stringWithFormat:@"充值类型: %@",str];
    NSString *timeStr = [NSString timeWithTimeIntervalString:dic[@"pay_time"] format:@"MM-dd HH:mm"];
    _name.text = [NSString stringWithFormat:@"充值时间: %@",timeStr];
   
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setUI];
    }
    return self;
}

- (void)setUI{
    _timeDua = [UILabel new];
    _timeDua.textAlignment = NSTextAlignmentLeft;
    _timeDua.font = [UIFont systemFontOfSize:15.0f];
    _timeDua.textColor =  UIColorFromRGB(0x333333);
    
    _price = [UILabel new];
    _price.textColor =  UIColorFromRGB(0x333333);
    _price.textAlignment = NSTextAlignmentLeft;
    _price.font = [UIFont systemFontOfSize:15.0f];
    
    _homeContact = [UILabel new];
    _homeContact.textAlignment = NSTextAlignmentLeft;
    _homeContact.font = [UIFont systemFontOfSize:15.0f];
    _homeContact.textColor =  UIColorFromRGB(0x333333);
    
    _name = [UILabel new];
    _name.textAlignment = NSTextAlignmentLeft;
    _name.font = [UIFont systemFontOfSize:15.0f];
    _name.textColor = UIColorFromRGB(0x333333);
    
    [self.contentView sd_addSubviews:@[_timeDua,_price,_homeContact,_name]];
    
    CGFloat X = 15;
    CGFloat Y = X;
    CGFloat spcing = 8;
    CGFloat h = 20;
    CGFloat w = (kScreenW-2*X)/2.0f;
    
    _timeDua.sd_layout
    .topSpaceToView(self.contentView,Y)
    .leftSpaceToView(self.contentView,X)
    .widthIs(w)
    .heightIs(h);
    
    _price.sd_layout
    .topSpaceToView(self.contentView,Y)
    .rightSpaceToView(self.contentView,X)
    .widthIs(w)
    .heightIs(h);
    

    _homeContact.sd_layout
    .topSpaceToView(_timeDua,spcing)
    .leftSpaceToView(self.contentView,X)
    .widthIs(w)
    .heightIs(h);
    
    _name.sd_layout
    .topSpaceToView(_price,spcing)
    .rightSpaceToView(self.contentView,X)
    .widthIs(w)
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
