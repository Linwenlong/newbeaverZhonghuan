//
//  YueZuFeiTableViewCell.m
//  beaver
//
//  Created by 林文龙 on 2018/7/6.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "YueZuFeiTableViewCell.h"


@interface YueZuFeiTableViewCell ()

@property (nonatomic, strong) UILabel * timeDua;
@property (nonatomic, strong) UILabel * price;
@property (nonatomic, strong) UILabel * homeContact;
@property (nonatomic, strong) UILabel * name;

@end

@implementation YueZuFeiTableViewCell

- (void)setDic:(NSDictionary *)dic{
    NSString *timeStr = [NSString stringWithFormat:@"%@ 消费:",[NSString timeWithTimeIntervalString:dic[@"create_time"] format:@"yyyy-MM"]];
    _timeDua.text = timeStr;

    _price.text =  [NSString stringWithFormat:@"%0.2f元",[dic[@"money"] floatValue]];;
    
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
    _timeDua.textColor = [UIColor blackColor];
    
    _price = [UILabel new];
    _price.textAlignment = NSTextAlignmentRight;
    _price.font = [UIFont systemFontOfSize:15.0f];
    
//    _homeContact = [UILabel new];
//    _homeContact.text = @"充值: ¥30.00";
//    _homeContact.textAlignment = NSTextAlignmentLeft;
//    _homeContact.font = [UIFont systemFontOfSize:13.0f];
//    _homeContact.textColor = [UIColor blackColor];
//    
//    _name = [UILabel new];
//    _name.text = @"余额:  ¥20.00";
//    _name.textAlignment = NSTextAlignmentRight;
//    _name.font = [UIFont systemFontOfSize:13.0f];
//    _name.textColor = [UIColor blackColor];
    
    
    [self.contentView sd_addSubviews:@[_timeDua,_price]];
    
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
    
//    _homeContact.sd_layout
//    .topSpaceToView(_timeDua,spcing)
//    .leftSpaceToView(self.contentView,X)
//    .widthIs(w)
//    .heightIs(h);
//    
//    _name.sd_layout
//    .topSpaceToView(_price,spcing)
//    .rightSpaceToView(self.contentView,X)
//    .widthIs(w)
//    .heightIs(h);
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}



@end
