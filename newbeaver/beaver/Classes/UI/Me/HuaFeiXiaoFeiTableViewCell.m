//
//  HuaFeiXiaoFeiTableViewCell.m
//  beaver
//
//  Created by 林文龙 on 2018/7/6.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "HuaFeiXiaoFeiTableViewCell.h"

@interface HuaFeiXiaoFeiTableViewCell ()

@property (nonatomic, strong) UILabel * timeDua;
@property (nonatomic, strong) UILabel * price;
@property (nonatomic, strong) UILabel * homeContact;
@property (nonatomic, strong) UILabel * name;
@property (nonatomic, strong) UILabel * timeDate;

@end

@implementation HuaFeiXiaoFeiTableViewCell

- (void)setDic:(NSDictionary *)dic{
    _timeDua.text = [NSString stringWithFormat:@"接通时长: %@分",dic[@"bill_minutes"]];
    NSString *origionStr = [NSString stringWithFormat:@"消 费:  ¥%@",dic[@"bill_mount"]];
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:origionStr];
    
    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 5)];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xff3800) range:NSMakeRange(5,origionStr.length - 5)];
    [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.0f] range:NSMakeRange(0, origionStr.length)];
    _price.attributedText = attributeStr;
    
    _homeContact.text = [NSString stringWithFormat:@"相关房源: %@",dic[@"fk_code"]];
    _name.text = [NSString stringWithFormat:@"接听人:  %@",dic[@"answer_name"]];
    NSString *timeStr = [NSString timeWithTimeIntervalString:dic[@"start_time"] format:@"yyyy-MM-dd HH:mm:ss"];
    _timeDate.text = [NSString stringWithFormat:@"接打时间: %@",timeStr];
    
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
    _timeDua.text = @"接通时长: 1分30秒";
    _timeDua.textAlignment = NSTextAlignmentLeft;
    _timeDua.font = [UIFont systemFontOfSize:14.0f];
    _timeDua.textColor = [UIColor blackColor];
    
    _price = [UILabel new];
    NSString *origionStr = @"消 费:  ¥3.00";
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:origionStr];
    
    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 5)];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xff3800) range:NSMakeRange(5,origionStr.length - 5)];
    [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.0f] range:NSMakeRange(0, origionStr.length)];
    
    _price.attributedText = attributeStr;
    _price.textAlignment = NSTextAlignmentRight;
    
    _homeContact = [UILabel new];
    _homeContact.text = @"相关房源: HGZL-F17-174976";
    _homeContact.textAlignment = NSTextAlignmentLeft;
    _homeContact.font = [UIFont systemFontOfSize:14.0f];
    _homeContact.textColor = [UIColor blackColor];
    
    _name = [UILabel new];
    _name.text = @"接听人:  李四";
    _name.textAlignment = NSTextAlignmentRight;
    _name.font = [UIFont systemFontOfSize:14.0f];
    _name.textColor = [UIColor blackColor];
    
    _timeDate = [UILabel new];
    _timeDate.text = @"接打时间: 2018-07-03 17:30:30";
    _timeDate.textAlignment = NSTextAlignmentLeft;
    _timeDate.font = [UIFont systemFontOfSize:14.0f];
    _timeDate.textColor = [UIColor blackColor];
    
    [self.contentView sd_addSubviews:@[_timeDua,_price,_homeContact,_name,_timeDate]];
    
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
    .widthIs(w+30)
    .heightIs(h);
    
    _name.sd_layout
    .topSpaceToView(_price,spcing)
    .rightSpaceToView(self.contentView,X)
    .widthIs(w-30)
    .heightIs(h);
    
    _timeDate.sd_layout
    .topSpaceToView(_homeContact,spcing)
    .rightSpaceToView(self.contentView,X)
    .widthIs(kScreenW - 2*X)
    .heightIs(h);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

@end
