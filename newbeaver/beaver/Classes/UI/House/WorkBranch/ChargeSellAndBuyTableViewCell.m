//
//  ChargeSellAndBuyTableViewCell.m
//  beaver
//
//  Created by mac on 17/12/20.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ChargeSellAndBuyTableViewCell.h"

@interface ChargeSellAndBuyTableViewCell ()

@property (nonatomic, strong)UILabel * feeType;
@property (nonatomic, strong)UILabel * feeDate;
@property (nonatomic, strong)UIView * line1;
@property (nonatomic, strong)UILabel * feeTotle;
@property (nonatomic, strong)UILabel * feeGain;
@property (nonatomic, strong)UILabel * feeOther;

@end

@implementation ChargeSellAndBuyTableViewCell


- (void)setDic:(NSDictionary *)dic{
    
    CGFloat top = 15;
    CGFloat left = 15;
    CGFloat right = left;
    CGFloat h = 15;
    
    if (dic[@"chargeType"] != nil && dic[@"itemName"] != nil) {
        _feeType.text = [NSString stringWithFormat:@"%@-%@",dic[@"chargeType"],dic[@"itemName"]];
    }
    
    _feeDate.text = [NSString timeWithTimeIntervalString:dic[@"receivedTime"]];
    
    
    _feeTotle.sd_resetLayout
    .topSpaceToView(_line1,top)
    .leftSpaceToView(self.contentView,left)
    .widthIs([self sizeToWith:[UIFont systemFontOfSize:13.0f] content:[NSString stringWithFormat:@"费用: %@",dic[@"receivable"]]]+10)
    .heightIs(h);
    
    _feeGain.sd_resetLayout
    .topSpaceToView(_line1,top)
    .centerXEqualToView(self.contentView)
    .widthIs([self sizeToWith:[UIFont systemFontOfSize:13.0f] content:[NSString stringWithFormat:@"已收费: %@",dic[@"received"]]]+10)
    .heightIs(h);
    
    _feeOther.sd_resetLayout
    .topSpaceToView(_line1,top)
    .rightSpaceToView(self.contentView,right)
    .leftSpaceToView(_feeGain,5)
    .heightIs(h);
    
    _feeTotle.attributedText = [NSString changeString:[NSString stringWithFormat:@"费用: %@",dic[@"receivable"]] frontLength:4 frontColor:LWL_LightGrayColor otherColor:LWL_RedColor];
    if (![NSString StringIsNullOrEmpty:dic[@"received"]]) {
        _feeGain.attributedText = [NSString changeString:[NSString stringWithFormat:@"已收费: %@",dic[@"received"]] frontLength:4 frontColor:LWL_LightGrayColor otherColor:LWL_RedColor];
    }else{
        _feeGain.attributedText = [NSString changeString:[NSString stringWithFormat:@"已收费: %d",0] frontLength:4 frontColor:LWL_LightGrayColor otherColor:LWL_RedColor];
    }
    
    CGFloat totel_other = 0;
    if (![NSString StringIsNullOrEmpty:dic[@"receivable"]]) {
        //欠费receivable
        if (![NSString StringIsNullOrEmpty:dic[@"received"]]) {
            totel_other += [dic[@"receivable"] floatValue] - [dic[@"received"] floatValue];
        }else{
            totel_other += [dic[@"receivable"] floatValue] - 0;
        }
    }else{
        if (![NSString StringIsNullOrEmpty:dic[@"received"]]) {
            totel_other += 0 - [dic[@"received"] floatValue];
        }
    }
    if (totel_other > 0) {
        _feeOther.text = [NSString stringWithFormat:@"欠费: %0.2f",fabs(totel_other)];
        _feeOther.textColor = LWL_PurpleColor;
    }else if (totel_other < 0){
        _feeOther.text = [NSString stringWithFormat:@"应退: %0.2f",fabs(totel_other)];
        _feeOther.textColor = LWL_YellowColor;
    }else{
        _feeOther.text = @"已补齐";
        _feeOther.textColor = LWL_GreenColor;
    }
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    _feeType = [UILabel new];
    _feeType.textAlignment = NSTextAlignmentLeft;
    _feeType.text = @"过户代缴费-土地出纳金";
    _feeType.textColor = UIColorFromRGB(0x404040);
    _feeType.font = [UIFont boldSystemFontOfSize:14.0f];
    
    _feeDate = [UILabel new];
    _feeDate.textAlignment = NSTextAlignmentRight;
    _feeDate.text = @"2017-12-07 10:12";
    _feeDate.textColor = UIColorFromRGB(0x808080);
    _feeDate.font = [UIFont systemFontOfSize:13.0f];
    
    _line1 = [UIView new];
    _line1.backgroundColor = UIColorFromRGB(0xe8e8e8);
    
    _feeTotle = [UILabel new];
    _feeTotle.textAlignment = NSTextAlignmentLeft;
    _feeTotle.text = @"费用: 20159.26";
    _feeTotle.textColor = UIColorFromRGB(0x404040);
    _feeTotle.font = [UIFont boldSystemFontOfSize:13.0f];
    
   
    _feeGain = [UILabel new];
    _feeGain.textAlignment = NSTextAlignmentLeft;
    _feeGain.text = @"费用: 20159.26";
    _feeGain.textColor = UIColorFromRGB(0x404040);
    _feeGain.font = [UIFont boldSystemFontOfSize:13.0f];
    
    _feeOther = [UILabel new];
    _feeOther.textAlignment = NSTextAlignmentRight;
    _feeOther.text = @"应退: 200.00";
    _feeOther.textColor = UIColorFromRGB(0x2EB2EF);
    _feeOther.font = [UIFont systemFontOfSize:13.0f];
    
    [self.contentView sd_addSubviews:@[_feeType,_feeDate,_line1,_feeTotle,_feeGain,_feeOther]];
    
    [self addLayoutSubviews];
    
}

- (void)addLayoutSubviews{
    CGFloat top = 15;
    CGFloat left = 15;
    CGFloat right = left;
    CGFloat h = 15;
    
    _feeType.sd_layout
    .topSpaceToView(self.contentView,top)
    .leftSpaceToView(self.contentView,left)
    .widthIs(kScreenW/2.0f)
    .heightIs(h);
    
    _feeDate.sd_layout
    .topSpaceToView(self.contentView,top)
    .rightSpaceToView(self.contentView,right)
    .widthIs(kScreenW/2.0f)
    .heightIs(h);
    
    _line1.sd_layout
    .topSpaceToView(_feeType,top)
    .rightSpaceToView(self.contentView,right)
    .leftSpaceToView(self.contentView,left)
    .heightIs(1);
    
    _feeTotle.sd_layout
    .topSpaceToView(_line1,top)
    .leftSpaceToView(self.contentView,left)
    .widthIs(kScreenW/2.0f)
    .heightIs(h);
    
    _feeGain.sd_resetLayout
    .topSpaceToView(_line1,top)
    .centerXEqualToView(self.contentView)
    .widthIs(80)
    .heightIs(h);
    
    _feeOther.sd_layout
    .topSpaceToView(_line1,top)
    .rightSpaceToView(self.contentView,right)
    .widthIs(kScreenW/2.0f)
    .heightIs(h);
    
}


- (CGFloat)sizeToWith:(UIFont *)font content:(NSString *)content{
    CGSize size = CGSizeMake(kScreenW-100,200);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize  actualsize =[content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;;
    return actualsize.width;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
